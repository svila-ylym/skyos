# Step 02: Interactive Shell

This step turns SkyOS into a tiny interactive system.

Boot now shows Linux-style `[ OK ]` status lines, clears the screen after boot,
then displays a compact system summary with the current kernel before opening
the root shell.

## Prompt

```text
root@SKY-86:/home#
```

## Commands

- `help`: Show available commands with usage and descriptions.
- `help system|fs|disk|net|dev|script|all`: Show grouped help.
- `sky -h`: Show available SkyOS shell commands with usage and descriptions.
- `man <command>`, `which <command>`, `type <command>`, `whereis <command>`:
  Linux-style discovery helpers.
- `env`, `printenv <name>`, `echo $NAME`: Show built-in environment variables.
- `version`: Show the OS version.
- `sysinfo`: Show CPU, memory, video, boot, and disk information.
- `pwd`, `uname`, `hostname`, `whoami`, `id`, `date`: Linux-style identity
  and clock commands.
- `uptime`, `free`, `df`, `mount`, `ps`, `top`, `jobs`, `kill`, `service`,
  `lspci`, `dmesg`: Show memory, RAM filesystem, service-backed tasks, PCI,
  and boot log information.
- `echo <text>`: Print text.
- `clear`: Clear the VGA text screen.
- `color <hex-attr>`: Change the VGA text color attribute.
- `cursor <x> <y>`: Move the VGA cursor.
- `reboot`: Reset through the PS/2 controller.
- `shutdown`: Send common emulator power-off requests.
  Shutdown displays `[ OK ]` service-stop lines before powering off.
- `poweroff`, `halt`: Aliases for `shutdown`.
- `reset`: Alias for `reboot`.
- `cd`: Change the current directory in the RAM filesystem. Supports no
  argument, `.`, `..`, `-`, `~`, and absolute paths such as `/home`.
- `ls`: List files in the current directory.
- `mem`: Show Multiboot lower and upper memory values.
- `peek <hex-address>`: Read one byte from memory.
- `poke <hex-address> <hex-byte>`: Write one byte to memory.
- `cat <file>`: Read a built-in RAM file.
- `write note|script.soj <text>`: Write to a writable RAM file.
- `disk`: Read IDE disk LBA0 and show MBR partition information.
- `disk read <lba>`: Read one raw IDE sector and print the first 16 bytes.
- `disk write <lba> <hex-byte>`: Fill one raw sector and write it to disk0.
- `disk burn mbr`: Write a minimal MBR to disk0 sector 0.
- `ip`, `ip a`, `ip addr`: Show Linux-style network interface information.
- `ip link`: Alias for interface information.
- `ip route`: Alias for the route table.
- `ifconfig`: Show network interface information.
- `route`: Show the IPv4 route table.
- `dhclient`: Queue a minimal DHCP discover frame and show the QEMU
  user-network lease used by SkyOS.
- `resolvectl`: Show DNS information.
- `netstat`: Show network socket table placeholder plus `ss`.
- `ping <ipv4|host>`: Handles localhost locally, resolves common hostnames
  through built-in cache or DNS A queries, then queues ARP and ICMP echo frames
  through the e1000 TX ring.
- `wget <url>`: Download command entry point. HTTPS transfer awaits TCP/TLS.
- `sapp update|search|list|install|remove|source`: SkyOS package
  manager command set.
- `netctl`: Show network, TCP, and TLS service state.
- `ss`: Show socket table placeholder.
- `systemd list|status|start <unit>|stop <unit>`: Manage kernel service state.
- `systemctl list|status|start <unit>|stop <unit>`: Alias for `systemd`.
- `sudo <command>`: Run a command as root after entering the root password.
- `su [root|user]`: Switch between the user and root shell; root password is
  `skyos`.
- `soj <file.soj>` or `run <file.soj>`: Execute a SkyObJect script.
- `memedit <hex-address>`: Interactively edit memory bytes.
- `vi note`: Edit `/home/note` directly; use `Ctrl+S` to save and Esc to quit.
- `audio`: Show PC speaker/PIT audio driver state.
- `beep [hex-frequency] [hex-delay-ticks]`: Play a short PC speaker tone.
- `bf <program>`: Run a tiny Brainfuck interpreter.

## Filesystem

The current filesystem is RAM-backed and built into the kernel:

```text
/
  bin/
  etc/
    skyos.conf
  home/
    note
    demo.soj
    script.soj
  dev/
    mem
    disk0
  sky.txt
```

Relative file names are resolved against the current RAM directory. Absolute
paths such as `/home/demo.soj` work from any directory; relative names such as
`demo.soj` only work when the current directory is `/home`.

## SkyObJect Scripts

SkyObJect (`*.soj`) is the first SkyOS script language. It is intentionally
shell-like:

```text
# comments start with #
echo SkyObJect script online
set name SkyOS
print $name
if $name == SkyOS then echo condition-ok
exec version
exit
```

Statements can be separated by newlines or `;`. The interpreter currently
supports one string variable slot, variable expansion in `echo`, simple
equality/inequality checks, and `exec` for calling SkyOS shell commands. A SOJ
script can call `bf` through `exec bf <program>` when tape-machine style
computation is needed. The built-in RAM file `/home/demo.soj` can be viewed
with `cat demo.soj` and run with:

```text
cd /home
soj demo.soj
```

`/home/script.soj` is writable through the existing RAM file command:

```text
write script.soj echo hi from soj;set name SkyOS;print $name
soj script.soj
```

## SkyOS Tool

Use the root interactive launcher:

```bat
run.bat
```

The menu handles kernel build, disk image build, ISO packaging, kernel run, ISO
run, environment checks, and cleanup. NAT, bridge/TAP, and audio are managed by
SkyOS services through `systemd`, not by separate host launch modes.

The input line supports Up and Down arrow command history. The main keyboard
and numeric keypad digits/operators are both mapped. Left and Right move within
the current line so text can be inserted or deleted before the end of the
command. Home/End, Delete, Ctrl+A/E, Ctrl+U/K/W, Ctrl+P/N, and Ctrl+Left/Right
provide Linux-style editing. Long commands stay on one prompt row and scroll
horizontally while editing.

Linux user compatibility examples:

```text
sapp update
sapp install base-tools
systemctl status network.service
sudo sysinfo
sudo systemctl start network.service
man disk
which sapp
type ip
cd ~
cat /home/demo.soj
ip route
ip link
poweroff
```

The interactive launcher uses GTK by default because it accepts keyboard focus
reliably.

Current hardware stage:

- Memory is configured up to 2 GiB in QEMU and reported through Multiboot data.
- `sysinfo` reports CPUID vendor/model/feature registers, Multiboot memory,
  available memory estimate, storage estimate, disk, and NIC state. Memory
  frequency still requires SMBIOS/SPD parsing and is reported as pending.
- Disk support uses IDE/ATA PIO reads and MBR partition information.
- Disk write support uses IDE/ATA PIO writes for explicit `disk write` and
  `disk burn mbr` commands against the attached raw QEMU disk image.
- The GRUB path requests a 1024x768x32 Multiboot VBE framebuffer. The built-in
  El Torito ISO loader prefers widescreen VBE modes such as 1920x1080,
  1600x900, 1366x768, and 1280x720 before fallback modes, then hands the
  framebuffer to the kernel through a Multiboot-style info block. The kernel
  uses the 32 bpp linear framebuffer console when present, derives text geometry
  from the selected resolution, scales the BIOS 8x8 font on high-resolution
  displays, and falls back to VGA text mode when framebuffer metadata is
  unavailable.
- QEMU exposes an e1000 NIC via user networking. SkyOS scans PCI config space,
  enables the MMIO BAR, initializes e1000 TX/RX descriptor rings, and has a
  minimal ARP/IPv4/ICMP/UDP/DHCP path. TCP is currently a receive parser and
  counter; full TCP state, retransmission, sockets, DNS, and TLS are pending.
- Networking modes are controlled inside SkyOS through service state. Host QEMU
  startup stays minimal.
- TCP/HTTPS service state is manageable with `systemd`, but actual HTTPS
  transfer still awaits TCP state machines, DNS, and TLS records.
- SkyApps package source defaults to `http://skyapps.skyu.cc.cd`; repository
  deployment notes live in `docs/skyapps-repository.md`.
