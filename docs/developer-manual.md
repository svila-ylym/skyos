# SkyOS Developer Manual

This document describes the current development layout and extension points.

## Repository Layout

```text
src/kernel.asm        Main x86 kernel source
linker.ld             ELF linker script
boot/                 GRUB ISO layout
run.bat               Windows launcher
run.ps1               PowerShell build/run/package tool
run.sh                Linux/MSYS2 launcher
docs/                 Project documentation
```

## Build Pipeline

The Windows development toolchain is expected under `H:\msys64`.

```bat
run.bat
```

Choose the build action from the interactive menu, or use `.\run.ps1 build`.

Build output:

```text
build/kernel.o
build/skyos.elf
```

ISO output:

```text
dist/skyos.iso
```

## Kernel Structure

`src/kernel.asm` is organized into:

```text
multiboot header
BSS buffers and descriptor rings
data and rodata strings
kernel entry
framebuffer/VBE console and VGA fallback
keyboard input
hardware probes
network stack
shell command dispatcher
filesystem and utilities
SkyObJect interpreter
Brainfuck interpreter
parsing helpers
```

## Boot Registry

Boot initialization is table-driven. Add new startup work by appending a record
to `boot_registry`:

```asm
dd status_text, animation_frame, init_function
```

Use `boot_init_noop` for entries that are visible but do not need code yet.

## Adding Shell Commands

1. Add a command string in the rodata command list:

```asm
cmd_example db 'example', 0
```

2. Add a match in `execute_command`:

```asm
mov edi, cmd_example
call match_token
test eax, eax
jnz command_example
```

3. Implement the command:

```asm
command_example:
    mov esi, some_message
    call print_line
    ret
```

4. Add help text to the grouped help output.

## VGA Console Rules

Use existing helpers for normal shell output:

```asm
print_string
print_line
console_newline
set_color
set_cursor
clear_screen
```

For full-screen tools like `vi`, draw fixed rows and avoid scrolling from row
24 unless leaving the full-screen mode.

## Network Stack

Current implemented pieces:

```text
PCI scan for network devices
e1000 TX/RX descriptor rings
ARP request/reply cache path
IPv4 parser and checksum helper
ICMP echo transmit path
UDP DHCP discover and lease parser
DNS query frame builder
TCP port 22 minimal SSH server handshake/banner responder
```

Disk support:

```text
IDE PIO one-sector read/write
MBR signature and partition table parsing
raw LBA read/write commands
partition-relative read/write with bounds checks
minimal MBR writer for disk0 images
SkyFS v0 superblock formatter and mount validator
live ISO installer metadata writer
hard-disk MBR stage1 + stage2 loader
fixed-LBA kernel ELF boot path
```

Install stage:

```text
install
disk install
disk mkfs 0
disk mount 0
```

The in-kernel ISO installer and `run.ps1 img` now write the same boot layout:
MBR stage1 at LBA 0, stage2 at LBA 1..15, the kernel ELF at LBA 16, and SkyFS
v0 partition metadata at LBA 2048. Use `run.ps1 blank-img`, `run.ps1 run-iso`,
choose installer option 2, then `run.ps1 run-disk` to test persistence across
an ISO-to-HDD install.

SkyFS v0 layout inside partition 0:

```text
relative LBA 0   superblock, magic SKYF
relative LBA 1   install manifest
relative LBA 2   fixed 64-byte directory entries
relative LBA 16+ file data sectors
```

The boot-time disk init probes partition 0, mounts SkyFS at `/mnt/disk0`,
loads `/sbin/init` from SkyFS, and executes it as a SkyObJect init script
before the interactive shell. The kernel `cat` command can also read installed
files such as `/mnt/disk0/etc/os-release`, `/mnt/disk0/sbin/init`, and
`/mnt/disk0/bin/skysh`.

RAMFS permissions:

```text
read bit 4
write bit 2
execute bit 1
chmod updates builtin inode mode bytes
cat/write/vi/grep/soj enforce read or write bits
```

Image viewer:

```text
PNG signature/IHDR validation
indexed-color PLTE resource
zlib stored-block scanline path
filter type 0 support
VGA 16-color background-cell renderer
```

Pending pieces:

```text
general TCP state machine
TCP retransmission/window management
TLS
full SSH KEX/auth/channel implementation
socket API
interrupt-driven network scheduling
```

## Sapp Package Manager

Sapp is the SkyOS package manager. The default source file is:

```text
/etc/sapp/sources.list
```

Default source:

```text
http://skyapps.skyu.cc.cd
```

Do not add Apt aliases. SkyOS package workflows should use `sapp`.

## Testing

Build smoke test:

```bat
run.bat
```

Choose the build action from the menu, or use `.\run.ps1 build`.

QEMU smoke test:

```bat
run.bat
```

Choose the kernel or ISO run mode.

Check inside SkyOS:

```text
version
sysinfo
netctl
ss
systemd list
soj demo.soj
```

For SSH banner testing through QEMU NAT:

```bash
nc <host-ip> 2222
```
