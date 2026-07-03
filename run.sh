#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"
MSYS2_ROOT=${MSYS2_ROOT:-/h/msys64}
USR_BIN="$MSYS2_ROOT/usr/bin"
MINGW_BIN="$MSYS2_ROOT/mingw64/bin"
BUILD="$ROOT/build"
DIST="$ROOT/dist"
ISO_ROOT="$BUILD/iso"
KERNEL_OBJ="$BUILD/kernel.o"
KERNEL_ELF="$BUILD/skyos.elf"
DISK_IMG="$BUILD/disk0.img"
ISO="$DIST/skyos.iso"
ISO_NEW="$DIST/skyos-new.iso"
SKYOS_VERSION="1.0.3.0.GSOSYGP"
SKYOS_INTERNAL_VERSION="10015"
SKYOS_SYSTEM_ID="skyos-10015"

find_tool() {
    preferred=$1
    name=$2
    if [ -x "$preferred" ]; then
        printf '%s\n' "$preferred"
    elif command -v "$name" >/dev/null 2>&1; then
        command -v "$name"
    else
        printf '%s\n' "$preferred"
    fi
}

NASM=$(find_tool "$USR_BIN/nasm.exe" nasm)
LD=$(find_tool "$USR_BIN/ld.lld.exe" ld.lld)
XORRISO=$(find_tool "$USR_BIN/xorriso.exe" xorriso)
GRUB_MKRESCUE=$(find_tool "$USR_BIN/grub-mkrescue.exe" grub-mkrescue)
QEMU=$(find_tool "$MINGW_BIN/qemu-system-i386.exe" qemu-system-i386)
QEMU_IMG=$(find_tool "$MINGW_BIN/qemu-img.exe" qemu-img)

require_tool() {
    if ! command -v "$1" >/dev/null 2>&1 && [ ! -x "$1" ]; then
        echo "Missing $2: $1" >&2
        exit 1
    fi
}

net_device_arg() {
    if [ -n "${SKYOS_MAC:-}" ]; then
        printf 'e1000,netdev=net0,mac=%s' "$SKYOS_MAC"
    else
        printf 'e1000,netdev=net0'
    fi
}

qemu_common_args() {
    printf '%s\n' -machine pc,acpi=on -rtc base=localtime
}

qemu_display_args() {
    local vga="${SKYOS_VGA:-virtio}"
    local display="${SKYOS_DISPLAY:-gtk,zoom-to-fit=on,show-tabs=off,full-screen=on}"
    printf '%s\n' -vga "$vga" -display "$display"
}

user_netdev_arg() {
    if [ -n "${SKYOS_NETDEV:-}" ]; then
        printf '%s' "$SKYOS_NETDEV"
    else
        printf 'user,id=net0,net=10.0.2.0/24,dhcpstart=10.0.2.15,dns=10.0.2.3,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22'
    fi
}

sata_disk_args() {
    printf '%s\n' -device ich9-ahci,id=sata0 -drive "id=skyosdisk,file=$DISK_IMG,format=raw,if=none,media=disk" -device ide-hd,drive=skyosdisk,bus=sata0.0
}

run_cmd() {
    printf '+'
    for arg in "$@"; do printf ' %s' "$arg"; done
    printf '\n'
    "$@"
}

ensure_dirs() {
    mkdir -p "$BUILD" "$DIST"
}

build_kernel() {
    require_tool "$NASM" NASM
    require_tool "$LD" LLD
    ensure_dirs
    run_cmd "$NASM" -f bin boot/hdboot.asm -o "$BUILD/hdboot.bin"
    run_cmd "$NASM" -f bin boot/hdstage2.asm -o "$BUILD/hdstage2.bin"
    run_cmd "$NASM" -f elf32 src/kernel.asm -o "$KERNEL_OBJ"
    run_cmd "$LD" -m elf_i386 -T linker.ld -o "$KERNEL_ELF" "$KERNEL_OBJ"
    echo "Built $KERNEL_ELF"
}

build_img() {
    require_tool "$QEMU_IMG" qemu-img
    ensure_dirs
    if [ ! -f "$DISK_IMG" ]; then
        run_cmd "$QEMU_IMG" create -f raw "$DISK_IMG" 64M
    else
        echo "Exists $DISK_IMG"
    fi
}

blank_img() {
    require_tool "$QEMU_IMG" qemu-img
    ensure_dirs
    rm -f "$DISK_IMG"
    run_cmd "$QEMU_IMG" create -f raw "$DISK_IMG" 64M
    echo "Created blank disk image: $DISK_IMG"
}

write_file() {
    path=$1
    shift
    mkdir -p "$(dirname "$path")"
    printf '%s\n' "$*" > "$path"
}

initialize_iso_payload() {
    rm -rf "$ISO_ROOT" "$BUILD/rootfs" "$BUILD/initramfs"
    mkdir -p "$ISO_ROOT/boot/grub" "$BUILD/rootfs" "$BUILD/initramfs"
    rootfs="$BUILD/rootfs"
    initramfs="$BUILD/initramfs"
    for dir in bin sbin etc/sapp etc/systemd/system dev home/root lib/modules/i386-skyos lib/firmware usr/bin usr/share/doc/skyos var/log tmp mnt proc sys boot; do
        mkdir -p "$rootfs/$dir"
    done
    write_file "$rootfs/etc/os-release" "NAME=SkyOS
VERSION=$SKYOS_VERSION
VERSION_ID=$SKYOS_VERSION
BUILD_ID=$SKYOS_INTERNAL_VERSION
ID=skyos
ARCH=i386"
    write_file "$rootfs/etc/fstab" "ramfs / ramfs defaults 0 0
disk0 /mnt/disk0 raw-ide defaults 0 0"
    write_file "$rootfs/etc/passwd" "root:x:0:0:root:/home/root:/bin/skysh"
    write_file "$rootfs/etc/group" "root:x:0:"
    write_file "$rootfs/etc/sapp/sources.list" "deb https://skyapps.skyu.cc.cd skyos main"
    write_file "$rootfs/sbin/init" "#!/bin/soj
echo SkyOS init starting
exec systemd list
exec mount"
    write_file "$rootfs/bin/skysh" "SkyOS builtin shell entrypoint. The current kernel executes this in-kernel until ELF exec lands."
    for tool in ls cat cp mv rm mkdir chmod grep vi nano ping ip wget curl sapp systemctl; do
        write_file "$rootfs/usr/bin/$tool" "SkyOS builtin command stub: $tool"
    done
    write_file "$rootfs/etc/systemd/system/network.service" "[Unit]
Description=SkyOS network hardware manager"
    write_file "$rootfs/etc/systemd/system/sapp.service" "[Unit]
Description=SkyOS package manager transport"
    write_file "$rootfs/lib/modules/i386-skyos/e1000.driver" "driver=e1000
class=net
status=builtin-mmio-polling"
    write_file "$rootfs/lib/modules/i386-skyos/ide.driver" "driver=ide-pio
class=block
status=builtin-sector-rw"
    write_file "$rootfs/lib/modules/i386-skyos/sata.driver" "driver=ahci-sata
class=block
status=pci-probe-compatible-path"
    write_file "$rootfs/lib/modules/i386-skyos/vga.driver" "driver=vga-text
class=console
status=builtin"
    write_file "$rootfs/lib/firmware/FIRMWARE.MANIFEST" "SkyOS firmware catalogue placeholder. Real redistributable firmware blobs must be added with license metadata."
    write_file "$rootfs/var/log/boot.log" "SkyOS ISO rootfs generated by run.sh"
    write_file "$rootfs/usr/share/doc/skyos/README" "This root filesystem is staged for ISO inspection and future initramfs/rootfs mounting."

    mkdir -p "$initramfs/bin" "$initramfs/etc" "$initramfs/dev" "$initramfs/proc" "$initramfs/sys"
    write_file "$initramfs/init" "#!/bin/soj
echo initramfs: mounting rootfs
exec fsinfo
exec systemd list"
    write_file "$initramfs/etc/initramfs.conf" "root=/dev/disk0p1
rootfstype=skyfs
fallback=ramfs"
    write_file "$initramfs/bin/skysh" "SkyOS initramfs shell stub"

    cp -R "$rootfs"/. "$ISO_ROOT"/
    mkdir -p "$ISO_ROOT/rootfs" "$ISO_ROOT/install" "$ISO_ROOT/kernel" "$ISO_ROOT/pool/main" "$ISO_ROOT/dists/skyos/main/binary-i386" "$ISO_ROOT/drivers" "$ISO_ROOT/firmware" "$ISO_ROOT/EFI/BOOT"
    (cd "$rootfs" && tar -czf "$ISO_ROOT/rootfs/rootfs.tar.gz" .)
    (cd "$initramfs" && tar -czf "$ISO_ROOT/boot/initramfs.img" .)
    write_file "$ISO_ROOT/rootfs/MANIFEST" "rootfs.tar.gz: compressed SkyOS root filesystem archive
layout: /bin /sbin /etc /usr /lib /var /home /dev /proc /sys"
    write_file "$ISO_ROOT/kernel/skyos-kernel.manifest" "kernel=/boot/skyos.elf
initramfs=/boot/initramfs.img
arch=i386"
    write_file "$ISO_ROOT/install/install.soj" "echo SkyOS installer
exec installer
echo Configure: sudo settings display auto; timezone set
echo Install: sudo disk select 0; sudo disk partition 4; sudo disk format 0; sudo install
echo Verify: disk verify; mount"
    write_file "$ISO_ROOT/install/INSTALL.md" "SkyOS installer stage. Boot the ISO, run installer to review display/timezone/disk state, then use settings display auto, timezone set, disk select 0, disk partition 4, disk format 0, and install. Device names are exposed as /dev/disk0 and /dev/disk0p0..p3 in the current IDE driver stage. The installer formats the target SkyFS partition before writing rootfs metadata and files, then writes MBR stage1, stage2, kernel ELF, and SkyFS v0 metadata so the disk can boot without the ISO."
    write_file "$ISO_ROOT/dists/skyos/Release" "Origin: SkyOS
Suite: skyos
Codename: skyos
Architectures: i386
Components: main"
    write_file "$ISO_ROOT/dists/skyos/main/binary-i386/Packages" "Package: base-tools
Version: $SKYOS_VERSION
InternalVersion: $SKYOS_INTERNAL_VERSION
Architecture: i386
System: $SKYOS_SYSTEM_ID
CompatibleInternalVersion: $SKYOS_INTERNAL_VERSION
Filename: pool/main/base-tools.sapp

Package: net-tools
Version: $SKYOS_VERSION
InternalVersion: $SKYOS_INTERNAL_VERSION
Architecture: i386
System: $SKYOS_SYSTEM_ID
CompatibleInternalVersion: $SKYOS_INTERNAL_VERSION
Depends: base-tools (>= $SKYOS_INTERNAL_VERSION)
Filename: pool/main/net-tools.sapp"
    write_file "$ISO_ROOT/pool/main/base-tools.sapp" "SkyOS Sapp package placeholder: base-tools"
    write_file "$ISO_ROOT/pool/main/net-tools.sapp" "SkyOS Sapp package placeholder: net-tools"
    write_file "$ISO_ROOT/drivers/DRIVERS.MANIFEST" "builtin: vga ps2 ide-pio sata-ahci-probe pci e1000 pc-speaker
future: ahci-dma nvme rtl8139 virtio-net usb-hid framebuffer"
    write_file "$ISO_ROOT/firmware/FIRMWARE.MANIFEST" "No proprietary firmware blobs are bundled. Add blobs here with license and device metadata."
    write_file "$ISO_ROOT/EFI/BOOT/README.txt" "UEFI directory reserved. BOOTIA32.EFI requires a future EFI loader build."
}

move_final_iso() {
    if rm -f "$ISO" 2>/dev/null && mv "$ISO_NEW" "$ISO" 2>/dev/null; then
        printf '%s\n' "$ISO"
    else
        echo "Existing ISO is busy; new ISO kept at $ISO_NEW" >&2
        printf '%s\n' "$ISO_NEW"
    fi
}

patch_cdboot() {
    cdboot=$1
    stage_iso="$BUILD/skyos-stage.iso"
    run_cmd "$XORRISO" -as mkisofs -R -J -V SKYOS -b boot/cdboot.bin -no-emul-boot -boot-load-size 4 -o "$stage_iso" "$ISO_ROOT"
    report=$("$XORRISO" -indev "$stage_iso" -find /boot/skyos.elf -exec report_lba -- 2>&1)
    kernel_lba=$(printf '%s\n' "$report" | sed -n 's/.*File data lba:[[:space:]]*0[[:space:]]*,[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n 1)
    if [ -z "$kernel_lba" ]; then
        echo "Could not locate /boot/skyos.elf LBA" >&2
        exit 1
    fi
    kernel_size=$(wc -c < "$KERNEL_ELF" | tr -d ' ')
    kernel_sectors=$(( (kernel_size + 2047) / 2048 ))
    perl -0777 -e '
        my ($lba, $sectors) = @ARGV;
        my $data = <STDIN>;
        my $idx = index($data, "SKYPATCH");
        die "Patch marker not found in cdboot.bin\n" if $idx < 0;
        substr($data, $idx + 8, 6) = pack("Vv", $lba, $sectors);
        print $data;
    ' "$kernel_lba" "$kernel_sectors" < "$cdboot" > "$cdboot.tmp"
    mv "$cdboot.tmp" "$cdboot"
    rm -f "$stage_iso"
    PATCH_LBA=$kernel_lba
    PATCH_SECTORS=$kernel_sectors
}

build_iso() {
    require_tool "$NASM" NASM
    require_tool "$XORRISO" xorriso
    build_kernel
    initialize_iso_payload
    mkdir -p "$ISO_ROOT/boot/grub"
    cp "$KERNEL_ELF" "$ISO_ROOT/boot/skyos.elf"
    cp "$ROOT/boot/grub/grub.cfg" "$ISO_ROOT/boot/grub/grub.cfg"
    rm -f "$ISO_NEW"
    if [ -n "${SKYOS_USE_GRUB_ISO:-}" ] && { command -v "$GRUB_MKRESCUE" >/dev/null 2>&1 || [ -x "$GRUB_MKRESCUE" ]; }; then
        run_cmd "$GRUB_MKRESCUE" -o "$ISO_NEW" "$ISO_ROOT"
        final_iso=$(move_final_iso)
        echo "Built $final_iso with grub-mkrescue"
        return
    fi
    echo "Using built-in El Torito BIOS installer loader."
    cdboot="$BUILD/cdboot.bin"
    rm -f "$BUILD/skyos-stage.iso"
    run_cmd "$NASM" -f bin boot/cdboot.asm -o "$cdboot"
    cp "$cdboot" "$ISO_ROOT/boot/cdboot.bin"
    patch_cdboot "$cdboot"
    cp "$cdboot" "$ISO_ROOT/boot/cdboot.bin"
    run_cmd "$XORRISO" -as mkisofs -R -J -V SKYOS -b boot/cdboot.bin -no-emul-boot -boot-load-size 4 -o "$ISO_NEW" "$ISO_ROOT"
    final_iso=$(move_final_iso)
    echo "Built $final_iso with built-in El Torito BIOS loader"
    echo "Kernel LBA: $PATCH_LBA sectors: $PATCH_SECTORS"
}

run_kernel() {
    require_tool "$QEMU" QEMU
    build_kernel
    build_img
    run_cmd "$QEMU" $(qemu_common_args) -m 2G -kernel "$KERNEL_ELF" -drive "file=$DISK_IMG,format=raw,if=ide,index=0,media=disk" -netdev "$(user_netdev_arg)" -device "$(net_device_arg)" $(qemu_display_args) -no-reboot -no-shutdown
}

run_iso() {
    require_tool "$QEMU" QEMU
    build_iso
    build_img
    run_cmd "$QEMU" $(qemu_common_args) -m 2G -cdrom "$ISO" -drive "file=$DISK_IMG,format=raw,if=ide,index=0,media=disk" -boot d -netdev "$(user_netdev_arg)" -device "$(net_device_arg)" $(qemu_display_args) -no-reboot -no-shutdown
}

run_sata() {
    require_tool "$QEMU" QEMU
    build_img
    run_cmd "$QEMU" $(qemu_common_args) -m 2G $(sata_disk_args) -boot c -netdev "$(user_netdev_arg)" -device "$(net_device_arg)" $(qemu_display_args) -no-reboot -no-shutdown
}

run_iso_sata() {
    require_tool "$QEMU" QEMU
    build_iso
    build_img
    run_cmd "$QEMU" $(qemu_common_args) -m 2G -cdrom "$ISO" $(sata_disk_args) -boot d -netdev "$(user_netdev_arg)" -device "$(net_device_arg)" $(qemu_display_args) -no-reboot -no-shutdown
}

check_env() {
    for pair in "NASM:$NASM" "LLD:$LD" "xorriso:$XORRISO" "QEMU:$QEMU" "qemu-img:$QEMU_IMG"; do
        name=${pair%%:*}
        path=${pair#*:}
        if command -v "$path" >/dev/null 2>&1 || [ -x "$path" ]; then state=OK; else state=MISS; fi
        echo "[$state] $name: $path"
    done
    if command -v "$GRUB_MKRESCUE" >/dev/null 2>&1 || [ -x "$GRUB_MKRESCUE" ]; then
        echo "[OK] grub-mkrescue: $GRUB_MKRESCUE"
    else
        echo "[INFO] grub-mkrescue missing; ISO builder uses built-in El Torito loader"
    fi
}

clean_build() {
    rm -rf "$BUILD" "$DIST"
    echo "Cleaned build and dist."
}

show_menu() {
    while :; do
        printf '\nSkyOS Tool\n'
        echo "1. Build kernel"
        echo "2. Build disk image"
        echo "3. Build bootable ISO"
        echo "4. Run kernel"
        echo "5. Run ISO"
        echo "6. Run installed disk with SATA/AHCI"
        echo "7. Run ISO with SATA/AHCI"
        echo "8. Create blank install disk"
        echo "9. Check environment"
        echo "10. Clean"
        echo "0. Exit"
        printf 'Select: '
        IFS= read -r choice
        case "$choice" in
            1) build_kernel ;;
            2) build_img ;;
            3) build_iso ;;
            4) run_kernel ;;
            5) run_iso ;;
            6) run_sata ;;
            7) run_iso_sata ;;
            8) blank_img ;;
            9) check_env ;;
            10) clean_build ;;
            0) exit 0 ;;
            *) echo "Unknown option: $choice" ;;
        esac
    done
}

case "${1:-}" in
    "") show_menu ;;
    build) build_kernel ;;
    img) build_img ;;
    blank-img) blank_img ;;
    iso) build_iso ;;
    run) run_kernel ;;
    run-iso) run_iso ;;
    run-sata) run_sata ;;
    run-iso-sata) run_iso_sata ;;
    check) check_env ;;
    clean) clean_build ;;
    *) echo "usage: ./run.sh [build|img|blank-img|iso|run|run-iso|run-sata|run-iso-sata|check|clean]" >&2; exit 1 ;;
esac
