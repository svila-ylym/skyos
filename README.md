# SkyOS

SkyOS is a small x86 operating system project written in NASM.

The first milestone boots through GRUB using the Multiboot specification and
opens a small interactive shell in VGA text mode.

After boot, SkyOS shows Linux-style `[ OK ]` startup lines, clears the screen,
and displays a compact system summary with the active kernel before the shell.

## Roadmap

1. Boot with GRUB into a 32-bit x86 kernel.
2. Set up a stable kernel entry point and stack.
3. Write text output helpers for VGA text mode.
4. Add keyboard input and a tiny shell.
5. Add GDT, IDT, interrupts, paging, and real storage drivers.

## Build Requirements

Install these tools before building:

- NASM
- LLVM LLD or GNU binutils with ELF `ld`
- QEMU with `qemu-system-i386`
- Optional: GRUB tools with `grub-mkrescue` and xorriso for ISO builds

On this Windows machine, the working toolchain is installed under `H:\msys64`.

Installed tools:

- `H:\msys64\usr\bin\nasm.exe`
- `H:\msys64\usr\bin\ld.lld.exe`
- `H:\msys64\usr\bin\make.exe`
- `H:\msys64\usr\bin\xorriso.exe`
- `H:\msys64\mingw64\bin\qemu-system-i386.exe`

## SkyOS Tool

```bat
run.bat
```

PowerShell and Linux/MSYS2 launchers are also available:

```powershell
.\run.ps1
```

```sh
./run.sh
```

The interactive tool handles kernel build, bootable disk image build, ISO
packaging, kernel run, hard-disk run, ISO run, environment checks, and cleanup.
Non-interactive actions are also available:

```powershell
.\run.ps1 build
.\run.ps1 img
.\run.ps1 iso
.\run.ps1 run
.\run.ps1 run-disk
.\run.ps1 run-iso
.\run.ps1 run-sata
.\run.ps1 run-iso-sata
.\run.ps1 check
.\run.ps1 clean
```

Generated files are written to `build/` and `dist/`.

The shell prompt uses a Linux-style current-directory format:

```text
root@SKY-86:/home#
```

Basic commands include `help`, `sky -h`, `version`, `sysinfo`, `clear`,
`color`, `cursor`, `pwd`, `uname`, `hostname`, `whoami`, `id`, `date`,
`timezone`, `uptime`,
`free`, `df`, `mount`, `bootinfo`, `features`, `proc`, `ipc`, `fsinfo`,
`security`, `audit`, `syscall`, `drivers`, `utils`, `ps`, `top`, `jobs`,
`kill`, `service`, `lspci`,
`dmesg`, `echo`, `disk`, `ip`, `ip a`, `ip addr`, `ifconfig`,
`route`, `netstat`, `dhclient`, `resolvectl`, `ping`, `wget`, `curl`, `ssh`,
`sftp`, `sapp`, `netctl`, `ss`, `systemd`, `systemctl`, `sudo`, `man`, `which`,
`type`, `whereis`, `env`, `printenv`, `export`, `set`, `unset`, `soj`, `run`,
`memedit`, `vi`, `imgview`, `audio`, `beep`, `reboot`, `reset`,
`shutdown`, `poweroff`, `halt`, `cd`, `ls`, `mem`, `peek`, `poke`, `cat`,
`write`, `cp`, `mv`, `rm`, `touch`, `mkdir`, `chmod`, `grep`, `du`, `nano`,
`gcc`, `make`, `login`, `passwd`, and `bf`. Use
the Up and Down arrow keys to browse recent commands.
Left and Right move within the current command line for insert/delete editing.
Home/End, Delete, Ctrl+A/E, Ctrl+U/K/W, Ctrl+P/N, and Ctrl+Left/Right provide
Linux-style line editing. Long commands stay on the prompt row and scroll
horizontally while editing.

Linux compatibility aliases:

```text
systemctl list          -> systemd list
systemctl status <unit> -> systemd status <unit>
sudo <command>          -> run as root shell command
poweroff | halt         -> shutdown
reset                   -> reboot
ip route                -> route
ip link                 -> ifconfig
```

SkyOS package management uses Sapp only:

```text
sapp update
sapp install <pkg>
sapp remove <pkg>
```

Environment variables are built in for this kernel stage:

```text
env
printenv HOME
echo $USER $PWD $IP
```

Timezone defaults to UTC. Use an interactive Up/Down menu to switch UTC-12
through UTC+12. `date` applies the selected timezone hour offset and handles
previous/next-day rollover, including month lengths and leap years:

```text
timezone
timezone set
date
```

Display settings are exposed in the shell and installer. The GRUB boot path
requests a 1024x768x32 Multiboot VBE framebuffer, and the built-in El Torito ISO
loader now also sets a VBE linear framebuffer and hands it to the kernel through
a Multiboot-style info block. The kernel switches the console to a 32 bpp linear
framebuffer when one is exposed. VGA text mode remains the fallback for launchers
that do not provide framebuffer info:

```text
display
display test
fbtest
sudo settings display auto
sudo settings display 1024x768
sudo settings display 1280x720
```

Relative file names are resolved in the current RAM directory. For example,
`soj demo.soj` only works in `/home`; use `/home/demo.soj` from other
directories.

`vi <file>` opens a RAM file and displays its content immediately. Supported
files include `/home/note`, `/home/script.soj`, and `/home/demo.soj`; relative
names such as `note` or `script.soj` work only from `/home`. In `vi`, type
directly to edit writable files, press `Ctrl+S` to save/update the internal
clipboard, `Ctrl+V` to paste that clipboard, Backspace to delete, and Esc to
quit. `/home/demo.soj` is read-only.

`imgview <file.png|file.jpg>` opens the VGA text image viewer. The current RAM
filesystem includes `/home/logo.png` and `/home/photo.jpg` sample entries. This
stage decodes the built-in indexed-color PNG sample, reads its IHDR/PLTE/IDAT
stored zlib block, and renders palette colors as VGA color cells. JPEG and
general DEFLATE-compressed PNG decoding are pending.

Help is grouped by topic:

```text
help
help system
help fs
help disk
help net
help dev
help script
help all
```

## Capability Matrix

Use `features` inside SkyOS for the live matrix. Current stage status:

- Boot and initialization: BIOS/QEMU GRUB Multiboot boot works. UEFI is planned
  through a GRUB EFI ISO path. CPU, Multiboot memory/framebuffer, VGA fallback,
  keyboard, IDE/SATA disk probing, PCI, and e1000 probes run during startup. Use `bootinfo`,
  `sysinfo`, `dmesg`.
- Process management: `ps`, `top`, `jobs`, `kill`, `proc`, `systemd`, and
  `service` expose a kernel service task table. Full fork/exec/wait, user
  address spaces, and preemptive scheduling are pending.
- Memory management: Multiboot memory detection, a 2 GiB boot cap, `mem`,
  `free`, `peek`, `poke`, and `memedit` are present. Paging, malloc/free,
  mmap/brk, page replacement, and user/kernel isolation are pending.
- File system: fixed RAMFS directories and files are available under `/`,
  `/bin`, `/etc`, `/home`, and `/dev`. `cat`, `write`, `vi`, `grep`, `du`, and
  directory-aware path checks work. `cp`, `mv`, `rm`, `touch`, `mkdir`, and
  `chmod` have command entrypoints. `disk fs <part>` identifies common MBR
  partition filesystems by signature, including ext-family, FAT12/16, FAT32,
  NTFS, and SkyFS markers. Dynamic VFS mounting, journaling filesystem writes,
  and general ext4/FAT32/NTFS file access are pending.
- Device drivers and I/O: Multiboot VBE framebuffer console, VGA text fallback,
  PS/2 keyboard, IDE PIO disk sectors, SATA/AHCI PCI discovery, PC speaker audio
  through PIT channel 2, PCI scan, and e1000 TX/RX rings are implemented. Use `drivers`, `lspci`, `disk`,
  `audio`, `beep`, `netctl`. AHCI DMA port read/write, IDT/PIC timer IRQ
  handling, and I/O scheduling are pending.
- CLI: `skysh` supports builtins, prompt, history, cursor movement, env vars,
  Linux-style aliases, and SkyObJect scripts. Redirection and pipes are pending.
- Security and permissions: root UID/GID identity, `su`, `sudo`, `login`,
  `passwd`, `security`, and `audit` entrypoints exist. The default root
  password is `skyos`. System mutation commands such as service start/stop,
  disk writes/install, network configuration, memory writes, and RAMFS writes
  require root. Power commands (`shutdown`, `poweroff`, `halt`, `reboot`,
  `reset`) are available to normal users.
- Networking: QEMU/physical e1000 networking, ARP/IPv4/ICMP/UDP/DHCP minimal
  paths, DNS A query frame generation, dynamic e1000 MAC reading, DHCP lease
  parsing, `ip`, `ifconfig`, `route`, `netstat`, `ss`, `dhclient`, `ping`,
  `wget`, `curl`, and `sapp` integration exist. Full TCP streams, DNS response
  parsing, TLS, and sockets API are pending.
- System calls: `syscall` documents the planned i386 `int 0x80` ABI and table
  names for file/process/memory/device calls. The actual user/kernel syscall
  dispatcher is pending.
- Utilities: common Linux command names are present as builtins or compatibility
  entrypoints. Native `gcc`/`make` execution requires the future ELF loader and
  process ABI.

## ISO Distribution Layout

`run.bat iso`, `.\run.ps1 iso`, and `./run.sh iso` build a fuller distribution
ISO. Besides `/boot/skyos.elf`, the ISO now includes:

```text
/boot/initramfs.img
/rootfs/rootfs.tar.gz
/bin /sbin /etc /usr /lib /var /home /dev /proc /sys
/dists/skyos/main/binary-i386/Packages
/pool/main/*.sapp
/install/install.soj
/drivers/DRIVERS.MANIFEST
/firmware/FIRMWARE.MANIFEST
/EFI/BOOT/README.txt
```

This is a staged production layout for the next kernel milestones. The current
kernel does not yet mount `rootfs.tar.gz`, execute ELF userland programs, or run
the installer as PID 1. Those require VFS mounts, initramfs unpacking, process
creation, ELF loading, syscall dispatch, and filesystem drivers.

Disk commands can read and write the attached QEMU IDE/SATA-compatible raw disk
image:

```text
disk
disk map
disk part
disk verify
disk root
disk select 0
disk partition 4
disk format 0
disk fs 0
disk read 0x0
disk hexdump 0x0
disk write 0x10 0x41
disk pread 0 0x0
disk phex 0 0x0
disk pwrite 0 0x1 0x41
disk mkfs 0
disk mount 0
install
unskyos
disk burn mbr
```

`disk map` shows the boot/rootfs layout, `disk verify` checks MBR/stage2/kernel
and SkyFS markers, and `disk root` lists installed SkyFS root entries.
`disk part` reads the MBR and lists partitions 0..3. `drivers` and `lspci`
also report AHCI/SATA controller detection when booted with SATA hardware or
`.\run.ps1 run-sata`. `disk pread`, `disk phex`,
and `disk pwrite` operate on partition-relative LBAs and reject accesses outside
the selected partition. `disk select 0` chooses the current IDE install target,
`disk partition 4` creates the installer MBR layout, and `disk format 0`
formats `/dev/disk0p0` as SkyFS before installing. Partitions are exposed as
`/dev/disk0p0` through `/dev/disk0p3` in SkyOS. `disk write` writes one raw
512-byte sector filled with the given byte. `.\run.ps1 img` writes a bootable
hard-disk image with MBR
stage1 at LBA 0, stage2 at LBA 1..15, the kernel ELF at LBA 16, and SkyFS v0
metadata at LBA 2048. Use `.\run.ps1 run-disk` to boot it directly. During
boot, the kernel mounts SkyFS at `/mnt/disk0` when present, so installed files
can be read with `cat`, and `/sbin/init` is loaded from SkyFS and executed as a
SkyObJect init script before the interactive shell:

```text
cat /mnt/disk0/etc/os-release
cat /mnt/disk0/sbin/init
cat /mnt/disk0/bin/skysh
cat /mnt/disk0/etc/passwd
cat /mnt/disk0/boot/loader.conf
```

Inside the live ISO, `installer` shows the display, timezone, and disk install
workflow. `install` now recreates the MBR partition table, formats the target
SkyFS partition, writes rootfs files to `/dev/disk0p0`, and writes the hard-disk
boot chain so the disk can boot after the ISO is removed.

`unskyos` is a root-only destructive removal command. It erases the SkyOS MBR,
stage2, kernel boot area, partition table, and SkyFS root metadata/files from
`disk0`. It will not run until the confirmation text is entered exactly:

```text
Yes,delete skyos
```

RAMFS files have simple permission bits: read `4`, write `2`, execute `1`.
`chmod <mode> <file>` updates the mode used by `cat`, `write`, `vi`, `grep`,
and `soj`.

SkyOS can execute SkyObJect scripts with `soj <file.soj>` or `run <file.soj>`.
The current RAM filesystem includes `/home/demo.soj` and a writable
`/home/script.soj`; run one with:

```text
cd /home
soj demo.soj
soj ./demo.soj
```

SkyObJect is a tiny shell-like script layer. Statements are separated by `;`
or newlines. Supported statements include `#` comments, `echo <text>`,
`set <name> <value>`, `print $name`, `input <name>`, `label <name>`,
`goto <name>`, `inc <name>`, `dec <name>`,
`if $name ==|!= value then <statement|goto label>`, `exec <SkyOS command>`,
and `exit`. SOJ can also call the built-in `bf` command for tape-machine style
computation.
For a custom script inside SkyOS:

```text
write script.soj set n 0;label loop;echo tick $n;inc n;if $n == 3 then goto done;goto loop;label done
soj script.soj
```

The root launcher starts SkyOS with 2 GiB RAM and attaches
`build\disk0.img` as an IDE HDD/SSD-compatible raw disk image. `run-disk`
boots from that image through the MBR/stage2 loader, while `run-iso` boots the
live ISO and attaches the same disk as the install target. `run-sata` and
`run-iso-sata` attach the same image behind QEMU `ich9-ahci` so the kernel can
detect an AHCI/SATA controller. Current sector I/O still uses the compatibility
disk path; full AHCI DMA read/write is a later driver milestone. The launcher
also exposes an e1000 network card through QEMU user networking. SkyOS scans PCI
config space, enables the e1000 MMIO BAR, reads the adapter MAC address, sets up
TX/RX descriptor rings, parses ARP/DHCP/DNS replies, updates IP/gateway/DNS
lease state, replies to ICMP echo requests, tracks TCP flags, and provides a
minimal ARP/IPv4/ICMP/UDP/DHCP/DNS/TCP diagnostic path.

The launcher display defaults are `-vga virtio` and
`-display gtk,zoom-to-fit=on,show-tabs=off,full-screen=on`. Override them with
`SKYOS_VGA` and `SKYOS_DISPLAY` when testing another QEMU backend. The GRUB ISO
sets `gfxpayload=1024x768x32`; the built-in El Torito ISO loader scans VBE modes
and prefers 1920x1080x32, 1600x900x32, 1366x768x32, 1280x720x32, then
1024x768x32 before falling back to any 32 bpp linear framebuffer. The
framebuffer console derives its rows and columns from the selected mode and
automatically scales the BIOS 8x8 font on high-resolution displays. Use
`display` to inspect framebuffer address, pitch, resolution, bpp, and VBE
availability, or `fbtest` to draw a color-band test pattern.

## Physical Networking Status

SkyOS can use the same e1000 MMIO driver path outside QEMU when the machine has
a PCI e1000-compatible NIC exposed to the kernel. DHCP Discover frames are sent
to the LAN, DHCP replies update the in-kernel IP/gateway/DNS fields, ARP
replies cache the gateway MAC, and ICMP/DNS frames use the cached gateway MAC
when available.

Production physical-machine networking still needs these pieces before it can
be treated as reliable: a genuinely bootable BIOS/UEFI image, interrupt-driven
RX instead of polling-only RX, broader NIC drivers such as RTL8139/virtio-net,
TCP state management, and packet retransmission/timeouts.

QEMU launchers forward host TCP `2222` to guest TCP `22` and host TCP `8080`
to guest TCP `80` for protocol testing. `ping localhost` and `ping 127.0.0.1`
are handled locally. Other hostnames are converted into DNS A queries only after
DHCP or explicit configuration provides a DNS server. In QEMU user networking,
public ICMP replies can still time out because the emulator/NAT path may not
deliver raw ICMP replies back to this minimal guest stack. Use `netctl` counters
to inspect RX/TX activity, last received protocol, ICMP request/reply counters,
DNS packets, and TCP flag counters.

NAT, bridge/TAP, and audio are managed inside SkyOS through `systemd`/service
commands. The host launcher only starts the kernel or ISO with a minimal QEMU
device set.

This uses:

```text
-netdev user,id=net0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22
-device e1000,netdev=net0
```

Set `SKYOS_MAC` before running the launcher if a fixed adapter MAC is required
by the deployment environment.

Inside SkyOS, use:

```text
ip
ip a
ip addr
dhclient
resolvectl
settings
route
netstat
netctl
ssh user@host
sftp user@host:/path
```

`ssh` and `sftp` are command/service entrypoints at this stage. They check the
network stack and expose `ssh.service` and `sftp.service`, but full SSH key
exchange, encryption, authentication, channels, and SFTP file transfer require
the future TCP stream and crypto layers.

SkyApps package manager source defaults to `https://skyapps.skyu.cc.cd`.
Deployment notes are in `docs/skyapps-repository.md`; the full Sapp source
deployment guide is in `docs/sapp-source-deployment.md`. 中文包编写教程见
`docs/sapp-package-authoring.zh-CN.md`。
The local Sapp server includes a web management panel:

```powershell
cd sappserver
.\manage-sapp-source.ps1
```

Linux:

```sh
cd sappserver
chmod +x *.sh
./sapp-onekey.sh
```

Open `http://127.0.0.1:8090/` to manage package names, versions, compatible
SkyOS system ids, dependencies, and descriptions.

TCP/HTTPS currently has a kernel service management layer (`netctl`, `ss`,
`systemd`) and command integration for `wget`, `curl`, and `sapp`. TCP headers
are counted by the receive dispatcher, but full TCP connection state,
retransmission, streams, DNS response parsing, and TLS are still pending.
