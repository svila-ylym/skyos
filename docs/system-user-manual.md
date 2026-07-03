# SkyOS System User Manual

SkyOS is an experimental x86 NASM operating system loaded by GRUB/Multiboot.
It boots into a VGA text console and opens the `skysh` root shell.

## SkyOS Tool

```bat
run.bat
```

Use the interactive menu to build the kernel, build the disk image, build the
ISO, run the kernel, run the ISO, check the environment, or clean build output.
NAT, bridge/TAP, and audio are SkyOS `systemd`/service concerns, not host
launcher modes.

## Shell

The prompt is Linux-style:

```text
root@SKY-86:/#
```

Useful discovery commands:

```text
help
sky -h
man <command>
which <command>
type <command>
whereis <command>
```

Command-line editing supports Left/Right cursor movement and Up/Down history.
Home/End, Delete, Ctrl+A/E, Ctrl+U/K/W, Ctrl+P/N, and Ctrl+Left/Right provide
Linux-style editing. Long commands stay on one prompt row and scroll
horizontally while editing.

## Core Commands

System:

```text
version
sysinfo
bootinfo
features
drivers
date
timezone
uptime
reboot
shutdown
poweroff
halt
reset
```

Files and directories:

```text
pwd
cd <dir>
ls
cat <file>
write note|script.soj <text>
cp <src> <dst>
mv <src> <dst>
rm <file>
touch <file>
mkdir <dir>
chmod <mode> <file>
grep <text> <file>
du
```

Memory and disk:

```text
mem
free
peek <hex-address>
poke <hex-address> <hex-byte>
memedit <hex-address>
disk
disk map
disk part
disk verify
disk root
disk select 0
disk partition 4
disk format 0
disk read <lba>
disk hexdump <lba>
disk write <lba> <hex-byte>
disk pread <part> <rel-lba>
disk phex <part> <rel-lba>
disk pwrite <part> <rel-lba> <hex-byte>
disk fs <part>
disk mkfs <part>
disk mount <part>
disk install
install
unskyos
disk burn mbr
```

`disk map` shows the boot/rootfs layout. `disk verify` checks the MBR, stage2,
kernel ELF, and SkyFS markers. `disk root` lists installed SkyFS root entries.
`disk part` lists MBR partitions. `disk pread`, `disk phex`, and `disk pwrite`
use partition-relative LBAs and perform bounds checks against the selected MBR
partition.

The installer disk model exposes the current IDE disk as `/dev/disk0` and its
MBR entries as `/dev/disk0p0` through `/dev/disk0p3`. `disk select 0` selects
the target disk, `disk partition 4` creates the four-entry installer layout,
and `disk format 0` formats the root SkyFS partition before installation.
When booted with SATA hardware or `.\run.ps1 run-sata`, `drivers` and `lspci`
show the AHCI/SATA PCI controller, ABAR, and implemented ports. Current sector
I/O still uses the compatibility disk path; full AHCI DMA read/write is pending.

Disk mutation commands such as `disk pwrite`, `disk write`, `disk mkfs`,
`disk mount`, `disk install`, `install`, `unskyos`, and `disk burn mbr` require root.
Read-only inspection commands are available to normal users. `reboot`,
`shutdown`, `poweroff`, `halt`, and `reset` are also available to normal users.
Use `su root` or `sudo <command>` for disk mutation and enter the root password
`skyos`.

`unskyos` removes SkyOS from `disk0` by erasing the boot chain, partition table,
and SkyFS metadata/file sectors. It requires root and a second confirmation
typed exactly as `Yes,delete skyos`.

SkyOS uses SkyFS v0 for the current install target. `installer` shows the
display, timezone, disk target, partition, format, and install checklist.
`disk mkfs 0` writes a SkyFS superblock to partition 0, `disk mount 0`
validates it, and `install` performs the live-ISO install path: create the MBR
partition table, format partition 0 as SkyFS, write MBR stage1, write HDD
stage2 to LBA 1..15, copy the current kernel ELF to LBA 16, and write rootfs
files such as
`/etc/os-release`, `/sbin/init`, `/bin/skysh`, `/etc/passwd`, `/etc/shadow`,
`/etc/sudoers`, `/boot/loader.conf`, and `/etc/sapp/sources.list`.

To test a real ISO install path, start from a blank disk image, boot the ISO,
choose option 2, then boot the installed disk:

```powershell
.\run.ps1 blank-img
.\run.ps1 run-iso
.\run.ps1 run-disk
.\run.ps1 run-sata
```

The host build tool can still create a directly bootable hard disk image with
`.\run.ps1 img`; that is the faster preinstalled-disk debug path.

The disk image uses MBR stage1 at LBA 0, stage2 at LBA 1..15, the kernel ELF at
LBA 16, and SkyFS v0 partition metadata at LBA 2048. The ISO remains directly
bootable with `.\run.ps1 run-iso`.

The QEMU launchers default to full-screen zoom-to-fit display output. The GRUB
boot path requests a 1024x768x32 Multiboot VBE framebuffer, and the built-in El
Torito ISO loader prefers 16:9 VBE linear framebuffer modes before falling back
to 1024x768 or any usable 32 bpp mode. It passes a Multiboot-style framebuffer
block to the kernel. SkyOS uses the linear framebuffer console when the
bootloader provides it, derives rows and columns from the selected resolution,
and scales the BIOS 8x8 font on high-resolution displays. VGA text mode is still
available as fallback for boot paths without framebuffer metadata. Inside SkyOS,
use `display` to inspect framebuffer address, pitch, resolution, bpp, and VBE
status; use `display test` or `fbtest` to draw a color-band test pattern.
`sudo settings display auto`, `sudo settings display 1024x768`, and
`sudo settings display 1280x720` store the installer display preference.

`timezone set` now cycles through UTC-12 to UTC+12 with Up/Down and Enter.

On boot, the kernel probes disk0 partition 0 for SkyFS, mounts it at
`/mnt/disk0`, loads `/sbin/init` from SkyFS, and runs it before the interactive
shell. These installed files can also be read from SkyFS:

```text
cat /mnt/disk0/etc/os-release
cat /mnt/disk0/sbin/init
cat /mnt/disk0/bin/skysh
cat /mnt/disk0/etc/passwd
cat /mnt/disk0/boot/loader.conf
```

Permissions use simple mode bits: read `4`, write `2`, execute `1`.
Examples:

```text
chmod 4 script.soj
chmod 6 note
```

Editors and scripts:

```text
vi <file>
nano <file>
imgview <file.png|file.jpg>
soj <file.soj>
run <file.soj>
bf <program>
audio
beep [hex-frequency] [hex-delay-ticks]
```

`imgview /home/logo.png` decodes the built-in indexed-color PNG sample and
renders its palette colors in VGA text mode. General compressed PNG and JPEG
decoding are pending.

`audio` shows the current PC speaker driver state. `beep` programs PIT channel
2 and port `0x61` to play a short tone. Example: `beep 3E8 60000`.

`vi <file>` opens a direct editor similar to Notepad for RAM files. Type to
edit, use Backspace to delete, `Ctrl+S` to save/update the editor clipboard,
`Ctrl+V` to paste that clipboard, and Esc to quit.

Networking:

```text
ip addr
ip route
ifconfig
route
netstat
ss
dhclient
resolvectl
settings
ping <ipv4|host>
wget <url>
curl <url>
ssh <user@host>
sftp <user@host[:path]>
netctl
```

Package management uses Sapp:

```text
sapp update
sapp list
sapp search <name>
sapp install <pkg>
sapp remove <pkg>
sapp source
```

SkyOS does not use Apt as its package manager.

## Services

SkyOS exposes service-style state through `systemd` and `systemctl`:

```text
systemd list
systemd status ssh.service
systemd start ssh.service
systemd stop ssh.service
```

`systemd list` and `systemd status` are available to normal users. `systemd
start`, `systemd stop`, `service start`, and `service stop` require root.

Current service units include:

```text
network.service
tcpip.service
https.service
sapp.service
ssh.service
sftp.service
```

## SSH Server

`ssh.service` listens on TCP port 22 and sends this SSH banner:

```text
SSH-2.0-SkyOS_1.0.3.0.GSOSYGP
```

With QEMU NAT, host port `2222` forwards to SkyOS port `22`:

```bash
nc <host-ip> 2222
ssh -p 2222 root@<host-ip>
```

This is a server entry point and banner responder. Full SSH key exchange,
authentication, encryption, PTY, and shell session channels are pending.

## Filesystem

The current filesystem is RAM-backed and built into the kernel. Common paths:

```text
/
/bin
/etc
/home
/dev
/home/note
/home/script.soj
/home/demo.soj
/etc/sapp/sources.list
```

Relative file names are checked against the current directory. For example,
`soj demo.soj` works from `/home`; use `/home/demo.soj` elsewhere.
