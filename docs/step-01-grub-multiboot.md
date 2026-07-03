# Step 01: GRUB Multiboot Kernel

This step creates the first bootable SkyOS kernel.

GRUB loads `build/skyos.elf` through Multiboot v1, jumps to `_start`, and the
kernel writes directly to VGA text memory at `0xB8000`.

## Files

- `src/kernel.asm`: 32-bit NASM kernel entry point.
- `linker.ld`: Places the kernel at 1 MiB and keeps the Multiboot header early.
- `boot/grub/grub.cfg`: GRUB menu entry for SkyOS.
- `Makefile`: Builds the kernel, ISO image, and QEMU run target.

## Expected Result

When booted, the screen should show:

```text
SkyOS kernel loaded
Booted with GRUB Multiboot
```

## Next Step

Add a reusable VGA text writer with cursor positioning, colors, and newline
handling.
