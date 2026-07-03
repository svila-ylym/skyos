gui_draw_task_manager_content:
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
    mov dword [gui_rect_color], 0x00F5F5F5
    call gui_fill_rect

    mov eax, 16
    mov ebx, 40
    mov dl, 0x70
    mov esi, msg_gui_task_menu
    call gui_put_in_window
    mov eax, 16
    mov ebx, 68
    mov dl, 0x70
    mov esi, msg_gui_task_tab_proc
    call gui_put_in_window
    mov eax, 112
    mov ebx, 68
    mov dl, 0x70
    mov esi, msg_gui_task_tab_perf
    call gui_put_in_window
    mov eax, 216
    mov ebx, 68
    mov dl, 0x70
    mov esi, msg_gui_task_tab_app
    call gui_put_in_window
    mov eax, 328
    mov ebx, 68
    mov dl, 0x70
    mov esi, msg_gui_task_tab_start
    call gui_put_in_window
    mov eax, 408
    mov ebx, 68
    mov dl, 0x70
    mov esi, msg_gui_task_tab_users
    call gui_put_in_window
    mov eax, 472
    mov ebx, 68
    mov dl, 0x70
    mov esi, msg_gui_task_tab_details
    call gui_put_in_window
    mov eax, 544
    mov ebx, 68
    mov dl, 0x70
    mov esi, msg_gui_task_tab_services
    call gui_put_in_window

    mov eax, [gui_win_x]
    add eax, 16
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 92
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    sub eax, 32
    mov [gui_rect_w], eax
    mov dword [gui_rect_h], 24
    mov dword [gui_rect_color], 0x00E6E6E6
    call gui_fill_rect

    mov eax, 24
    mov ebx, 98
    mov dl, 0x70
    mov esi, msg_gui_task_hdr_name
    call gui_put_in_window
    mov eax, 24
    mov ebx, 128
    mov dl, 0x70
    mov esi, msg_gui_task_app_1
    call gui_put_in_window
    mov eax, 24
    mov ebx, 154
    mov dl, 0x70
    mov esi, msg_gui_task_app_2
    call gui_put_in_window
    mov eax, 24
    mov ebx, 180
    mov dl, 0x70
    mov esi, msg_gui_task_app_3
    call gui_put_in_window
    mov eax, 24
    mov ebx, 206
    mov dl, 0x70
    mov esi, msg_gui_task_app_4
    call gui_put_in_window

    mov eax, [gui_win_x]
    add eax, 16
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 250
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 160
    mov dword [gui_rect_h], 24
    mov dword [gui_rect_color], 0x00EAEAEA
    call gui_fill_rect
    mov eax, 24
    mov ebx, 256
    mov dl, 0x70
    mov esi, msg_gui_task_cpu
    call gui_put_in_window
    mov eax, 24
    mov ebx, 288
    mov dl, 0x70
    mov esi, msg_gui_task_mem
    call gui_put_in_window
    mov eax, 24
    mov ebx, 320
    mov dl, 0x70
    mov esi, msg_gui_task_disk
    call gui_put_in_window
    mov eax, 24
    mov ebx, 352
    mov dl, 0x70
    mov esi, msg_gui_task_net
    call gui_put_in_window

    mov eax, [gui_win_x]
    add eax, 200
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 248
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    sub eax, 232
    mov [gui_rect_w], eax
    mov dword [gui_rect_h], 112
    mov dword [gui_rect_color], 0x00FFFFFF
    call gui_fill_rect

    mov eax, [gui_win_x]
    add eax, 216
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 326
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 52
    mov dword [gui_rect_h], 18
    mov dword [gui_rect_color], 0x0060A0E0
    call gui_fill_rect
    mov eax, [gui_win_x]
    add eax, 276
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 300
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 52
    mov dword [gui_rect_h], 44
    mov dword [gui_rect_color], 0x0060A0E0
    call gui_fill_rect
    mov eax, [gui_win_x]
    add eax, 336
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 286
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 52
    mov dword [gui_rect_h], 58
    mov dword [gui_rect_color], 0x0060A0E0
    call gui_fill_rect
    popad
    ret
