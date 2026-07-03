gui_handle_file_row_open:
    pushad
    movzx eax, bl
    mov ecx, [gui_file_dir]
    cmp byte [gui_file_selected_row], bl
    jne .select
    cmp [gui_file_selected_dir], ecx
    jne .select
    mov byte [gui_file_selected_row], 255
    cmp ecx, GUI_DIR_HOME
    je .home_open
    cmp ecx, GUI_DIR_ETC
    je .open_notepad
    cmp ecx, GUI_DIR_BIN
    je .open_terminal
    jmp .open_terminal

.home_open:
    cmp bl, 0
    je .open_soj
    cmp bl, 1
    je .open_soj
    cmp bl, 2
    je .open_notepad
    cmp bl, 3
    je .open_media
    cmp bl, 4
    je .open_notepad
    jmp .open_terminal
.open_soj:
    mov al, GUI_WIN_CMD
    call gui_open_window
    mov dword [gui_term_output_ptr], msg_gui_term_run_soj
    jmp .opened
.open_terminal:
    mov al, GUI_WIN_CMD
    call gui_open_window
    mov dword [gui_term_output_ptr], msg_gui_term_open_file
    jmp .opened
.open_notepad:
    mov al, GUI_WIN_NOTEPAD
    call gui_open_window
    cmp dword [gui_note_len], 0
    jne .opened
    mov esi, msg_gui_note_loaded
    mov edi, gui_note_buf
    xor ecx, ecx
.copy_note:
    lodsb
    mov [edi], al
    test al, al
    jz .note_copied
    inc edi
    inc ecx
    cmp ecx, 240
    jb .copy_note
    mov byte [edi], 0
.note_copied:
    mov [gui_note_len], ecx
    jmp .opened
.open_media:
    mov al, GUI_WIN_MEDIA
    call gui_open_window
.opened:
    mov byte [gui_need_redraw], 1
    jmp .done

.select:
    mov [gui_file_selected_row], bl
    mov [gui_file_selected_dir], ecx
    mov byte [gui_need_redraw], 1
.done:
    popad
    ret
