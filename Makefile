AS := nasm
LD := ld.lld
GRUB_MKRESCUE := grub-mkrescue
QEMU := qemu-system-i386

BUILD_DIR := build
DIST_DIR := dist
ISO_ROOT := $(BUILD_DIR)/iso

KERNEL_OBJ := $(BUILD_DIR)/kernel.o
KERNEL_ELF := $(BUILD_DIR)/skyos.elf
ISO := $(DIST_DIR)/skyos.iso

.PHONY: all clean iso run qemu qemu-elf

all: $(KERNEL_ELF)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

$(KERNEL_OBJ): src/kernel.asm | $(BUILD_DIR)
	$(AS) -f elf32 $< -o $@

$(KERNEL_ELF): $(KERNEL_OBJ) linker.ld
	$(LD) -m elf_i386 -T linker.ld -o $@ $(KERNEL_OBJ)

iso: $(ISO)

$(ISO): $(KERNEL_ELF) boot/grub/grub.cfg | $(DIST_DIR)
	mkdir -p $(ISO_ROOT)/boot/grub
	cp $(KERNEL_ELF) $(ISO_ROOT)/boot/skyos.elf
	cp boot/grub/grub.cfg $(ISO_ROOT)/boot/grub/grub.cfg
	$(GRUB_MKRESCUE) -o $@ $(ISO_ROOT)

run: qemu

qemu: $(ISO)
	$(QEMU) -machine pc,acpi=on -rtc base=localtime -m 64M -cdrom $(ISO) -boot d -serial stdio -netdev user,id=net0,net=10.0.2.0/24,dhcpstart=10.0.2.15,dns=10.0.2.3,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 -device e1000,netdev=net0 -no-reboot -no-shutdown

qemu-elf: $(KERNEL_ELF)
	$(QEMU) -machine pc,acpi=on -rtc base=localtime -m 64M -kernel $(KERNEL_ELF) -serial stdio -netdev user,id=net0,net=10.0.2.0/24,dhcpstart=10.0.2.15,dns=10.0.2.3,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 -device e1000,netdev=net0 -no-reboot -no-shutdown

clean:
	rm -rf $(BUILD_DIR) $(DIST_DIR)
