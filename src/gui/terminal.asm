gui_term_capture_input:
    pushad
    mov ecx, [gui_term_len]
    mov [gui_term_last_len], ecx
    mov esi, gui_term_buf
    mov edi, gui_term_last_buf
    test ecx, ecx
    jz .empty
.copy:
    lodsb
    stosb
    loop .copy
    mov byte [edi], 0
    jmp .done
.empty:
    mov byte [gui_term_last_buf], 0
.done:
    popad
    ret

gui_draw_terminal_content:
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
    mov dword [gui_rect_color], 0x00000000
    call gui_fill_rect

    mov eax, 16
    mov ebx, 44
    mov dl, 0x0A
    mov esi, msg_gui_cmd_1
    call gui_put_in_window
    mov eax, 16
    mov ebx, 64
    mov dl, 0x08
    mov esi, msg_gui_cmd_2
    call gui_put_in_window

    cmp dword [gui_term_last_len], 0
    je .skip_last_command
    mov eax, 16
    mov ebx, 96
    mov dl, 0x0F
    mov esi, msg_gui_cmd_3
    call gui_put_in_window
    mov eax, 32
    mov ebx, 96
    mov dl, 0x0F
    mov esi, gui_term_last_buf
    call gui_put_in_window
.skip_last_command:
    mov eax, 16
    mov ebx, 124
    mov dl, 0x0A
    mov esi, [gui_term_output_ptr]
    call gui_put_in_window

    mov ebx, [gui_win_h]
    sub ebx, 48
    cmp ebx, 152
    jae .input_y_ok
    mov ebx, 152
.input_y_ok:
    mov eax, 16
    mov dl, 0x0F
    mov esi, msg_gui_cmd_3
    call gui_put_in_window
    mov eax, 32
    mov dl, 0x0F
    mov esi, gui_term_buf
    call gui_put_in_window
    popad
    ret
