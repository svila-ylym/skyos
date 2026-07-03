gui_browser_navigate:
    pushad
    cmp dword [gui_browser_url_len], 0
    jne .check_about
    mov dword [gui_browser_page_ptr], msg_gui_browser_blank
    jmp .done
.check_about:
    mov esi, gui_browser_url_buf
    mov edi, gui_url_about_sky
    call cstr_equals
    test eax, eax
    jz .check_docs
    mov dword [gui_browser_page_ptr], msg_gui_browser_home
    jmp .done
.check_docs:
    mov esi, gui_browser_url_buf
    mov edi, gui_url_docs_skyos
    call cstr_equals
    test eax, eax
    jz .check_file
    mov dword [gui_browser_page_ptr], msg_gui_browser_docs
    jmp .done
.check_file:
    mov esi, gui_browser_url_buf
    mov edi, url_file_prefix
    call starts_with
    test eax, eax
    jz .check_http
    mov dword [gui_browser_page_ptr], msg_gui_browser_3
    jmp .done
.check_http:
    mov esi, gui_browser_url_buf
    mov edi, url_http_prefix
    call starts_with
    test eax, eax
    jnz .net
    mov esi, gui_browser_url_buf
    mov edi, url_https_prefix
    call starts_with
    test eax, eax
    jz .fallback
.net:
    mov dword [gui_browser_page_ptr], msg_gui_browser_net
    jmp .done
.fallback:
    mov dword [gui_browser_page_ptr], msg_gui_browser_hint
.done:
    mov byte [gui_need_redraw], 1
    popad
    ret

gui_handle_browser_key:
    pushad
    cmp al, 8
    je .backspace
    cmp al, 13
    je .enter
    cmp al, 9
    jne .printable
    mov al, ' '
.printable:
    cmp al, 32
    jb .done
    cmp al, 126
    ja .done
    mov ecx, [gui_browser_url_len]
    cmp ecx, 120
    jae .done
    mov edi, gui_browser_url_buf
    add edi, ecx
    mov [edi], al
    inc ecx
    mov [gui_browser_url_len], ecx
    mov byte [gui_browser_url_buf + ecx], 0
    mov byte [gui_need_redraw], 1
    jmp .done
.backspace:
    mov ecx, [gui_browser_url_len]
    test ecx, ecx
    jz .done
    dec ecx
    mov [gui_browser_url_len], ecx
    mov byte [gui_browser_url_buf + ecx], 0
    mov byte [gui_need_redraw], 1
    jmp .done
.enter:
    call gui_browser_navigate
.done:
    popad
    ret

gui_draw_browser_content:
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
    mov dword [gui_rect_h], 40
    mov dword [gui_rect_color], 0x00D8D8D8
    call gui_fill_rect

    mov eax, [gui_win_x]
    add eax, 84
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 40
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    sub eax, 176
    cmp eax, 80
    jae .addr_w_ok
    mov eax, 80
.addr_w_ok:
    mov [gui_rect_w], eax
    mov dword [gui_rect_h], 22
    mov dword [gui_rect_color], 0x00FFFFFF
    call gui_fill_rect

    mov eax, 16
    mov ebx, 44
    mov dl, 0x70
    mov esi, msg_gui_browser_addr
    call gui_put_in_window
    mov eax, 92
    mov ebx, 44
    mov dl, 0x70
    cmp dword [gui_browser_url_len], 0
    jne .draw_url
    mov esi, msg_gui_browser_blank
    jmp .url_ready
.draw_url:
    mov esi, gui_browser_url_buf
.url_ready:
    call gui_put_in_window

    mov eax, [gui_win_w]
    sub eax, 84
    mov ebx, 44
    mov dl, 0x70
    mov esi, msg_gui_browser_go
    call gui_put_in_window

    mov eax, 20
    mov ebx, 88
    mov dl, 0xF0
    mov esi, [gui_browser_page_ptr]
    call gui_put_in_window
    mov eax, 20
    mov ebx, 124
    mov dl, 0xF0
    mov esi, msg_gui_browser_2
    call gui_put_in_window
    popad
    ret
