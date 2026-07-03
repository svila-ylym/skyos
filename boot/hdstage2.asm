; SkyOS hard disk stage2 loader.
; Loaded by MBR stage1 at 0000:8000. Reads skyos.elf from fixed disk LBAs,
; loads ELF PT_LOAD segments, and jumps to the kernel entry.

bits 16
org 0x8000

KERNEL_LOAD_SEG equ 0x1000
KERNEL_LOAD_OFF equ 0x0000
KERNEL_LOAD_PHYS equ 0x00010000
KERNEL_LBA equ 16
KERNEL_MAX_SECTORS equ 512

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    mov [boot_drive], dl

    mov si, msg_loading
    call print_string
    call enable_a20
    call read_kernel

    cli
    lgdt [gdt_desc]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:protected_entry

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    jmp print_string
.done:
    ret

enable_a20:
    in al, 0x92
    or al, 0x02
    out 0x92, al
    ret

read_kernel:
    mov dword [dap_lba], KERNEL_LBA
    mov cx, KERNEL_MAX_SECTORS
    mov bx, KERNEL_LOAD_OFF
    mov ax, KERNEL_LOAD_SEG
    mov es, ax
.next:
    test cx, cx
    jz .done
    mov word [dap_count], 1
    mov word [dap_offset], bx
    mov word [dap_segment], es
    mov si, dap
    mov dl, [boot_drive]
    mov ah, 0x42
    int 0x13
    jc disk_error
    add bx, 512
    jnc .same_segment
    mov ax, es
    add ax, 0x1000
    mov es, ax
.same_segment:
    inc dword [dap_lba]
    dec cx
    jmp .next
.done:
    ret

disk_error:
    mov si, msg_disk_error
    call print_string
.halt:
    hlt
    jmp .halt

align 4
dap:
    db 16
    db 0
dap_count:
    dw 1
dap_offset:
    dw 0
dap_segment:
    dw KERNEL_LOAD_SEG
dap_lba:
    dq 0

boot_drive db 0
msg_loading db 'SkyOS HD loader...', 13, 10, 0
msg_disk_error db 'Kernel read error', 13, 10, 0

gdt:
    dq 0
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_desc:
    dw gdt_desc - gdt - 1
    dd gdt

bits 32
protected_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    mov esi, KERNEL_LOAD_PHYS
    cmp dword [esi], 0x464C457F
    jne pm_halt

    mov ebx, [esi + 28]
    add ebx, esi
    movzx ecx, word [esi + 44]
.ph_loop:
    test ecx, ecx
    jz .jump_kernel
    cmp dword [ebx], 1
    jne .next_ph
    push ecx
    push ebx
    mov esi, KERNEL_LOAD_PHYS
    add esi, [ebx + 4]
    mov edi, [ebx + 12]
    mov ecx, [ebx + 16]
    rep movsb
    mov ecx, [ebx + 20]
    sub ecx, [ebx + 16]
    xor eax, eax
    rep stosb
    pop ebx
    pop ecx
.next_ph:
    movzx eax, word [KERNEL_LOAD_PHYS + 42]
    add ebx, eax
    dec ecx
    jmp .ph_loop
.jump_kernel:
    mov eax, 0
    mov ebx, 0
    jmp dword [KERNEL_LOAD_PHYS + 24]

pm_halt:
    hlt
    jmp pm_halt

times 15 * 512 - ($ - $$) db 0
