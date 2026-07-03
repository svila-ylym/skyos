gui_draw_notepad_content:
    pushad
    mov eax, [gui_win_x]
    add eax, 8
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 32
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    sub eax, 16
    mov [gui_rect_w], eax
    mov eax, [gui_win_h]
    sub eax, 40
    mov [gui_rect_h], eax
    mov dword [gui_rect_color], 0x00FFFFFF
    call gui_fill_rect

    mov eax, [gui_win_x]
    add eax, 8
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 32
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    sub eax, 16
    mov [gui_rect_w], eax
    mov dword [gui_rect_h], 22
    mov dword [gui_rect_color], 0x00E8E8E8
    call gui_fill_rect

    mov eax, 16
    mov ebx, 36
    mov dl, 0x70
    mov esi, msg_gui_note_menu
    call gui_put_in_window
    mov eax, 16
    mov ebx, 64
    mov dl, 0xF0
    mov esi, msg_gui_note_1
    call gui_put_in_window
    mov eax, 16
    mov ebx, 96
    mov dl, 0xF0
    cmp dword [gui_note_len], 0
    jne .note_text
    mov esi, msg_gui_note_empty
    jmp .draw_note
.note_text:
    mov esi, gui_note_buf
.draw_note:
    call gui_put_in_window
    popad
    ret
