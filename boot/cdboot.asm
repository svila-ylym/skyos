; SkyOS El Torito BIOS CD bootloader.
; Loads /boot/skyos.elf from a patched ISO LBA, enters 32-bit protected mode,
; copies ELF PT_LOAD segments to their physical addresses, and jumps to entry.

bits 16
org 0x7C00

KERNEL_LOAD_SEG equ 0x1000
KERNEL_LOAD_OFF equ 0x0000
KERNEL_LOAD_PHYS equ 0x00010000
SKYOS_INSTALL_MAGIC equ 0x534B5949
SKYOS_CDINFO_MAGIC equ 0x44434B53
MULTIBOOT_BOOTLOADER_MAGIC equ 0x2BADB002
MB_INFO_PHYS equ 0x00006000
MB_CMDLINE_PHYS equ 0x00006100
VBE_INFO_PHYS equ 0x00007200
VBE_MODE_INFO_PHYS equ 0x00007400
FB_FONT_PHYS equ 0x00009000

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    mov [boot_drive], dl

    call boot_menu

    call copy_bios_font
    call setup_vbe
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

boot_menu:
    mov byte [boot_menu_selected], 0
.draw:
    call clear_screen
    mov si, msg_menu_title
    call print_string
    cmp byte [boot_menu_selected], 0
    jne .live_plain
    mov si, msg_menu_live_selected
    jmp .print_live
.live_plain:
    mov si, msg_menu_live
.print_live:
    call print_string
    cmp byte [boot_menu_selected], 1
    jne .install_plain
    mov si, msg_menu_install_selected
    jmp .print_install
.install_plain:
    mov si, msg_menu_install
.print_install:
    call print_string
    mov si, msg_menu_prompt
    call print_string
.read_key:
    xor ah, ah
    int 0x16
    cmp al, 13
    je .confirm
    cmp ah, 0x48
    je .select_live
    cmp ah, 0x50
    je .select_install
    cmp al, '1'
    je .live
    cmp al, '2'
    je .install
    cmp al, 'i'
    je .install
    cmp al, 'I'
    je .install
    mov si, msg_menu_invalid
    call print_string
    jmp .read_key
.select_live:
    cmp byte [boot_menu_selected], 0
    je .read_key
    mov byte [boot_menu_selected], 0
    jmp .draw
.select_install:
    cmp byte [boot_menu_selected], 1
    je .read_key
    mov byte [boot_menu_selected], 1
    jmp .draw
.confirm:
    cmp byte [boot_menu_selected], 0
    je .live
    jmp .install
.live:
    mov dword [boot_mode_magic], 0
    mov si, msg_loading_live
    call print_string
    ret
.install:
    mov dword [boot_mode_magic], SKYOS_INSTALL_MAGIC
    mov si, msg_loading_install
    call print_string
    ret

clear_screen:
    mov ax, 0x0003
    int 0x10
    ret

enable_a20:
    in al, 0x92
    or al, 0x02
    out 0x92, al
    ret

copy_bios_font:
    mov ax, 0x1130
    mov bh, 0x06
    int 0x10
    push ds
    push es
    mov ax, es
    mov ds, ax
    xor ax, ax
    mov es, ax
    mov si, bp
    mov di, FB_FONT_PHYS
    mov cx, 256 * 16
    cld
    rep movsb
    pop es
    pop ds
    xor ax, ax
    mov ds, ax
    mov es, ax
    ret

setup_vbe:
    mov word [vbe_mode_selected], 0
    mov byte [vbe_available], 0
    mov dword [VBE_INFO_PHYS], 'VBE2'
    mov ax, 0x4F00
    mov di, VBE_INFO_PHYS
    xor bx, bx
    mov es, bx
    int 0x10
    cmp ax, 0x004F
    jne .done
    cmp dword [VBE_INFO_PHYS], 'VESA'
    jne .done
    mov ax, [VBE_INFO_PHYS + 14]
    mov [vbe_list_off], ax
    mov ax, [VBE_INFO_PHYS + 16]
    mov [vbe_list_seg], ax

    mov word [vbe_target_w], 1600
    mov word [vbe_target_h], 900
    call find_vbe_mode
    jc .set_mode
    mov word [vbe_target_w], 1366
    mov word [vbe_target_h], 768
    call find_vbe_mode
    jc .set_mode
    mov word [vbe_target_w], 1280
    mov word [vbe_target_h], 720
    call find_vbe_mode
    jc .set_mode
    mov word [vbe_target_w], 1920
    mov word [vbe_target_h], 1080
    call find_vbe_mode
    jc .set_mode
    mov word [vbe_target_w], 1024
    mov word [vbe_target_h], 768
    call find_vbe_mode
    jc .set_mode
    mov word [vbe_target_w], 0
    mov word [vbe_target_h], 0
    call find_vbe_mode
    jnc .done
.set_mode:
    mov bx, [vbe_mode_candidate]
    or bx, 0x4000
    mov ax, 0x4F02
    int 0x10
    cmp ax, 0x004F
    jne .done
    call record_vbe_mode
.done:
    ret

find_vbe_mode:
    mov si, [vbe_list_off]
.scan:
    mov ax, [vbe_list_seg]
    mov fs, ax
    mov cx, [fs:si]
    cmp cx, 0xFFFF
    je .not_found
    add si, 2
    mov [vbe_mode_candidate], cx
    push si
    mov ax, 0x4F01
    mov di, VBE_MODE_INFO_PHYS
    xor bx, bx
    mov es, bx
    int 0x10
    pop si
    cmp ax, 0x004F
    jne .scan
    mov ax, [VBE_MODE_INFO_PHYS]
    test ax, 0x0001
    jz .scan
    test ax, 0x0010
    jz .scan
    test ax, 0x0080
    jz .scan
    cmp byte [VBE_MODE_INFO_PHYS + 25], 32
    jne .scan
    mov al, [VBE_MODE_INFO_PHYS + 27]
    cmp al, 6
    je .memory_model_ok
    cmp al, 4
    jne .scan
.memory_model_ok:
    cmp word [vbe_target_w], 0
    je .found
    mov ax, [VBE_MODE_INFO_PHYS + 18]
    cmp ax, [vbe_target_w]
    jne .scan
    mov ax, [VBE_MODE_INFO_PHYS + 20]
    cmp ax, [vbe_target_h]
    jne .scan
.found:
    stc
    ret
.not_found:
    clc
    ret

record_vbe_mode:
    mov byte [vbe_available], 1
    mov ax, [vbe_mode_candidate]
    mov [vbe_mode_selected], ax
    mov ax, [VBE_MODE_INFO_PHYS + 18]
    mov [vbe_width], ax
    mov ax, [VBE_MODE_INFO_PHYS + 20]
    mov [vbe_height], ax
    mov ax, [VBE_MODE_INFO_PHYS + 16]
    mov [vbe_pitch], ax
    mov al, [VBE_MODE_INFO_PHYS + 25]
    mov [vbe_bpp], al
    mov eax, [VBE_MODE_INFO_PHYS + 40]
    mov [vbe_physbase], eax
    ret

read_kernel:
    mov eax, [kernel_lba]
    mov [dap_lba], eax
    mov cx, [kernel_sectors]
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
    add bx, 2048
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
boot_mode_magic dd 0
boot_menu_selected db 0
vbe_available db 0
vbe_bpp db 0
vbe_list_off dw 0
vbe_list_seg dw 0
vbe_target_w dw 0
vbe_target_h dw 0
vbe_mode_candidate dw 0
vbe_mode_selected dw 0
vbe_width dw 0
vbe_height dw 0
vbe_pitch dw 0
vbe_physbase dd 0
msg_menu_title db 13, 10, 'SkyOS installer boot menu', 13, 10, 0
msg_menu_live_selected db '> Live system', 13, 10, 0
msg_menu_live db '  Live system', 13, 10, 0
msg_menu_install_selected db '> Install SkyOS to disk0', 13, 10, 0
msg_menu_install db '  Install SkyOS to disk0', 13, 10, 0
msg_menu_prompt db 13, 10, 'Use Up/Down to select, Enter to boot.', 13, 10, 0
msg_menu_invalid db 13, 10, 'Use Up/Down, then press Enter.', 13, 10, 0
msg_loading_live db 13, 10, 'Loading SkyOS live system...', 13, 10, 0
msg_loading_install db 13, 10, 'Loading SkyOS installer...', 13, 10, 0
msg_disk_error db 'CD read error', 13, 10, 0

; Patched by run.ps1/run.sh after xorriso places files.
patch_marker db 'SKYPATCH'
kernel_lba dd 0
kernel_sectors dw 0

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
    call build_multiboot_info
    mov eax, MULTIBOOT_BOOTLOADER_MAGIC
    mov ebx, MB_INFO_PHYS
    jmp dword [KERNEL_LOAD_PHYS + 24]

pm_halt:
    hlt
    jmp pm_halt

build_multiboot_info:
    pushad
    mov edi, MB_INFO_PHYS
    xor eax, eax
    mov ecx, 128 / 4
    rep stosd
    mov dword [MB_INFO_PHYS], 0x00001005
    mov dword [MB_INFO_PHYS + 4], 639
    mov dword [MB_INFO_PHYS + 8], 2096064
    mov dword [MB_INFO_PHYS + 16], MB_CMDLINE_PHYS
    mov dword [MB_CMDLINE_PHYS], 0
    mov dword [MB_CMDLINE_PHYS], SKYOS_CDINFO_MAGIC
    mov eax, [boot_mode_magic]
    mov [MB_CMDLINE_PHYS + 4], eax
    movzx eax, word [kernel_sectors]
    mov [MB_CMDLINE_PHYS + 8], eax
    mov dword [MB_CMDLINE_PHYS + 12], FB_FONT_PHYS
    mov dword [MB_CMDLINE_PHYS + 16], 16
    cmp byte [vbe_available], 1
    jne .done
    mov dword [MB_INFO_PHYS], 0x00001005
    mov eax, [vbe_physbase]
    mov [MB_INFO_PHYS + 88], eax
    mov dword [MB_INFO_PHYS + 92], 0
    movzx eax, word [vbe_pitch]
    mov [MB_INFO_PHYS + 96], eax
    movzx eax, word [vbe_width]
    mov [MB_INFO_PHYS + 100], eax
    movzx eax, word [vbe_height]
    mov [MB_INFO_PHYS + 104], eax
    mov al, [vbe_bpp]
    mov [MB_INFO_PHYS + 108], al
    mov byte [MB_INFO_PHYS + 109], 2
    mov byte [MB_INFO_PHYS + 110], 16
    mov byte [MB_INFO_PHYS + 111], 8
    mov byte [MB_INFO_PHYS + 112], 8
    mov byte [MB_INFO_PHYS + 113], 8
    mov byte [MB_INFO_PHYS + 114], 0
    mov byte [MB_INFO_PHYS + 115], 8
.done:
    popad
    ret

times 2048 - ($ - $$) db 0
