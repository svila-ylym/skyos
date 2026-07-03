; SkyOS hard disk MBR stage1.
; Loads stage2 from LBA 1 to 0000:8000 and jumps there.

bits 16
org 0x7C00

STAGE2_SEG equ 0x0800
STAGE2_OFF equ 0x0000
STAGE2_LBA equ 1
STAGE2_SECTORS equ 15

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
    call read_stage2
    mov dl, [boot_drive]
    jmp STAGE2_SEG:STAGE2_OFF

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

read_stage2:
    mov dword [dap_lba], STAGE2_LBA
    mov word [dap_count], STAGE2_SECTORS
    mov word [dap_offset], STAGE2_OFF
    mov word [dap_segment], STAGE2_SEG
    mov si, dap
    mov dl, [boot_drive]
    mov ah, 0x42
    int 0x13
    jc disk_error
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
    dw 0
dap_offset:
    dw 0
dap_segment:
    dw 0
dap_lba:
    dq 0

boot_drive db 0
msg_loading db 'SkyOS MBR...', 13, 10, 0
msg_disk_error db 'Stage2 read error', 13, 10, 0

times 446 - ($ - $$) db 0

; SkyOS installer partition layout. run.ps1 and the kernel keep this table in sync.
db 0x80
db 0, 2, 0
db 0x7F
db 0xFE, 0xFF, 0xFF
dd 2048
dd 65536

db 0x00
db 0, 0, 0
db 0x7F
db 0xFE, 0xFF, 0xFF
dd 67584
dd 2048

db 0x00
db 0, 0, 0
db 0x7F
db 0xFE, 0xFF, 0xFF
dd 69632
dd 2048

db 0x00
db 0, 0, 0
db 0x7F
db 0xFE, 0xFF, 0xFF
dd 71680
dd 2048

times 510 - ($ - $$) db 0
dw 0xAA55
