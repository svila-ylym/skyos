; SkyOS x86 kernel entry point.
; GRUB loads this file through the Multiboot v1 specification.

bits 32

%define DIR_ROOT 0
%define DIR_BIN  1
%define DIR_ETC  2
%define DIR_HOME 3
%define DIR_DEV  4

%define SAPP_PKG_NAME     0
%define SAPP_PKG_VERSION  4
%define SAPP_PKG_INTERNAL 8
%define SAPP_PKG_DEPENDS  12
%define SAPP_PKG_FILE     16
%define SAPP_PKG_SIZE     20
%define SAPP_PKG_DESC     24
%define SAPP_PKG_FORMAT   28
%define SAPP_PKG_STATE    32
%define SAPP_PKG_STRIDE   36

%define SAPP_CMD_NAME     0
%define SAPP_CMD_PACKAGE  4
%define SAPP_CMD_HANDLER  8
%define SAPP_CMD_FILE     12
%define SAPP_CMD_STATE    16
%define SAPP_CMD_STRIDE   20

%define E1000_REG_CTRL    0x0000
%define E1000_REG_STATUS  0x0008
%define E1000_REG_EERD    0x0014
%define E1000_REG_ICR     0x00C0
%define E1000_REG_IMS     0x00D0
%define E1000_REG_RCTL    0x0100
%define E1000_REG_TCTL    0x0400
%define E1000_REG_RDBAL   0x2800
%define E1000_REG_RDBAH   0x2804
%define E1000_REG_RDLEN   0x2808
%define E1000_REG_RDH     0x2810
%define E1000_REG_RDT     0x2818
%define E1000_REG_TDBAL   0x3800
%define E1000_REG_TDBAH   0x3804
%define E1000_REG_TDLEN   0x3808
%define E1000_REG_TDH     0x3810
%define E1000_REG_TDT     0x3818
%define E1000_REG_MTA     0x5200
%define E1000_REG_RAL     0x5400
%define E1000_REG_RAH     0x5404

%define E1000_RX_COUNT    8
%define E1000_TX_COUNT    8
%define E1000_RX_BUF_SIZE 2048
%define E1000_TX_BUF_SIZE 2048
%define ETH_TYPE_ARP      0x0806
%define ETH_TYPE_IPV4     0x0800
%define IP_PROTO_ICMP     1
%define IP_PROTO_TCP      6
%define IP_PROTO_UDP      17
%define TCP_PORT_SSH      22
%define TCP_FLAG_FIN      0x01
%define TCP_FLAG_SYN      0x02
%define TCP_FLAG_RST      0x04
%define TCP_FLAG_PSH      0x08
%define TCP_FLAG_ACK      0x10
%define UDP_PORT_DHCP_S   67
%define UDP_PORT_DHCP_C   68
%define UDP_PORT_DNS      53
%define PIT_BASE_HZ       1193182
%define ARP_WAIT_POLLS    384
%define DHCP_WAIT_POLLS   64
%define DNS_WAIT_POLLS    4096
%define ICMP_WAIT_POLLS   8192
%define DNS_RETRY_POLLS   512
%define ICMP_RETRY_POLLS  512
%define DHCP_RETRY_POLLS  16
%define PING_WAIT_DELAY   0x00010000
%define SKYOS_INSTALL_MAGIC 0x534B5949
%define SKYOS_CDINFO_MAGIC 0x44434B53
%define CD_KERNEL_LOAD_PHYS 0x00010000
%define HD_KERNEL_LBA 16
%define HD_STAGE2_LBA 1
%define HD_STAGE2_SECTORS 15
%define KBD_RING_MASK 255
%define FB_TEXT_MAX_COLS 256
%define FB_TEXT_MAX_ROWS 128
%define FB_TEXT_MAX_CELLS (FB_TEXT_MAX_COLS * FB_TEXT_MAX_ROWS)
%define FB_GLYPH_STRIDE 16
%define GUI_WIN_COUNT 7
%define GUI_WIN_NONE 255
%define GUI_WIN_FILES 0
%define GUI_WIN_CMD 1
%define GUI_WIN_TASK 2
%define GUI_WIN_MEDIA 3
%define GUI_WIN_NOTEPAD 4
%define GUI_WIN_BROWSER 5
%define GUI_WIN_SETTINGS 6
%define GUI_TITLE_H 24
%define GUI_TASKBAR_H 32
%define GUI_RESIZE_GRIP 16
%define GUI_MIN_WIN_W 180
%define GUI_MIN_WIN_H 120
%define GUI_DIR_ROOT DIR_ROOT
%define GUI_DIR_BIN DIR_BIN
%define GUI_DIR_ETC DIR_ETC
%define GUI_DIR_HOME DIR_HOME
%define GUI_DIR_DEV DIR_DEV

MBALIGN  equ 1 << 0
MEMINFO  equ 1 << 1
VIDEO    equ 1 << 2
MBFLAGS  equ MBALIGN | MEMINFO | VIDEO
MAGIC    equ 0x1BADB002
CHECKSUM equ -(MAGIC + MBFLAGS)

section .multiboot
align 4
    dd MAGIC
    dd MBFLAGS
    dd CHECKSUM
    dd 0
    dd 0
    dd 0
    dd 0
    dd 0
    dd 0
    dd 1024
    dd 768
    dd 32

section .bss
alignb 16
stack_bottom:
    resb 16384
stack_top:

input_buffer:
    resb 256
auth_buffer:
    resb 64
sudo_cmd_buffer:
    resb 256
soj_line_buffer:
    resb 256
soj_var_name:
    resb 32
soj_var_value:
    resb 96
history_buffer:
    resb 1024
history_draft_buffer:
    resb 256
kbd_ring:
    resb 256
alignb 8
idt_table:
    resb 256 * 8
bf_tape:
    resb 256
vi_clipboard:
    resb 256
fs_tmp:
    resb 256
dns_query_buf:
    resb 64
url_host_buf:
    resb 128
http_response_buf:
    resb 4096
sapp_index_buf:
    resb 4096
sapp_field_buf:
    resb 256
fb_text_chars:
    resb FB_TEXT_MAX_CELLS
fb_text_attrs:
    resb FB_TEXT_MAX_CELLS
fb_dirty_cells:
    resb FB_TEXT_MAX_CELLS
fb_glyph_cache:
    resb 256 * FB_GLYPH_STRIDE
gui_note_buf:
    resb 256
gui_term_buf:
    resb 128
gui_term_last_buf:
    resb 128
gui_browser_url_buf:
    resb 128
disk_buffer:
    resb 512
skyfs_init_buffer:
    resb 512
cpu_vendor:
    resb 13
cpu_brand:
    resb 49
alignb 16
e1000_rx_desc:
    resb E1000_RX_COUNT * 16
alignb 16
e1000_tx_desc:
    resb E1000_TX_COUNT * 16
alignb 16
e1000_rx_bufs:
    resb E1000_RX_COUNT * E1000_RX_BUF_SIZE
alignb 16
e1000_tx_bufs:
    resb E1000_TX_COUNT * E1000_TX_BUF_SIZE

section .data
cursor_x      dd 0
cursor_y      dd 0
console_cols  dd 80
console_rows  dd 25
input_start_x dd 0
input_start_y dd 0
input_len     dd 0
input_pos     dd 0
input_view_start dd 0
current_dir   dd DIR_ROOT
previous_dir  dd DIR_ROOT
history_count dd 0
history_view  dd -1
history_draft_valid db 0
mb_magic      dd 0
mb_info_addr  dd 0
boot_mode_install db 0
boot_kernel_cd_sectors dd 0
current_uid dd 1000
current_gid dd 1000
shift_state   db 0
ctrl_state    db 0
command_cancelled db 0
text_attr     db 0x0F
timezone_index db 12
display_mode_index db 0
fb_available db 0
fb_vbe_available db 0
fb_addr_low dd 0
fb_addr_high dd 0
fb_pitch dd 0
fb_width dd 0
fb_height dd 0
fb_bpp db 0
fb_type db 0
fb_font_ptr dd 0
fb_font_height dd 16
fb_char_scale_x dd 1
fb_char_scale_y dd 1
fb_origin_x dd 0
fb_origin_y dd 0
fb_text_width_bytes dd 2560
fb_text_row_height dd 16
fb_fg_color dd 0
fb_bg_color dd 0
fb_glyph_bits db 0
fb_cursor_visible db 0
fb_cursor_ticks dd 0
fb_cursor_draw_x dd 0
fb_cursor_draw_y dd 0
fb_dirty_any db 0
fb_draw_char db 0
fb_draw_attr db 0
kbd_idle_poll_ticks dd 0
kbd_ring_head dd 0
kbd_ring_tail dd 0
kbd_irq_enabled db 0
idt_descriptor:
    dw (256 * 8) - 1
    dd idt_table
fb_test_palette dd 0x00D32F2F, 0x00F57C00, 0x00FBC02D, 0x00388E3C
                dd 0x001976D2, 0x007B1FA2, 0x0000907A, 0x00FFFFFF
install_target_disk db 0
install_target_part db 0
dt_year       db 0
dt_month      db 0
dt_day        db 0
dt_hour       db 0
dt_minute     db 0
dt_second     db 0
vi_file_ptr   dd 0
vi_file_name_ptr dd 0
vi_status_ptr dd 0
vi_body_cursor_x dd 0
vi_body_cursor_y dd 1
vi_clipboard_ptr dd 0
vi_clipboard_len dd 0
vi_perm_ptr dd 0
vi_readonly   db 0
boot_phase_ptr dd 0
boot_status_ptr dd 0
boot_orbit_ptr dd 0
grep_needle   dd 0
net_found     db 0
net_any_found db 0
net_bus       db 0
net_slot      db 0
net_func      db 0
net_class     db 0
net_subclass  db 0
net_vendor    dw 0
net_device    dw 0
net_bar0      dd 0
net_any_bus       db 0
net_any_slot      db 0
net_any_func      db 0
net_any_class     db 0
net_any_subclass  db 0
net_any_vendor    dw 0
net_any_device    dw 0
net_any_bar0      dd 0
sata_found    db 0
sata_bus      db 0
sata_slot     db 0
sata_func     db 0
sata_class    db 0
sata_subclass db 0
sata_prog_if  db 0
sata_vendor   dw 0
sata_device   dw 0
sata_bar5     dd 0
sata_abar     dd 0
sata_pi       dd 0
e1000_mmio    dd 0
e1000_rx_tail dd 0
e1000_tx_tail dd 0
e1000_inited  db 0
net_stack_inited db 0
net_mac0      db 0
net_mac1      db 0
net_mac2      db 0
net_mac3      db 0
net_mac4      db 0
net_mac5      db 0
net_ip_addr   dd 0
net_subnet_mask dd 0
net_gateway_ip dd 0
net_dns_ip    dd 0x72727272
net_dhcp_dns_ip dd 0
net_dns_fallback_ip dd 0x08080808
net_dns_saved_ip dd 0
net_qemu_fallback_enabled db 1
net_ping_target_ip dd 0
net_next_hop_ip dd 0
net_dns_resolved_ip dd 0
net_dns_query_ptr dd dns_query_buf
net_dns_query_len dd 0
net_gateway_mac db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
net_last_rx_src_mac db 0,0,0,0,0,0
net_gateway_mac_valid db 0
dhcp_lease_valid db 0
net_rx_packets dd 0
net_tx_packets dd 0
net_arp_packets dd 0
net_ipv4_packets dd 0
net_icmp_packets dd 0
net_udp_packets dd 0
net_tcp_packets dd 0
net_dhcp_packets dd 0
net_dns_packets dd 0
net_dns_rx_valid db 0
net_ping_reply_received db 0
net_last_proto db 0
net_icmp_echo_requests dd 0
net_icmp_echo_replies dd 0
net_tcp_syn_packets dd 0
net_tcp_ack_packets dd 0
net_tcp_psh_packets dd 0
net_tcp_rst_packets dd 0
http_tcp_state db 0
http_client_port dw 40000
http_client_seq dd 0x48545450
http_server_seq dd 0
http_next_server_seq dd 0
http_ack_seq dd 0
http_response_len dd 0
http_response_done db 0
http_response_overflow db 0
ssh_rx_syn_packets dd 0
ssh_tx_banner_packets dd 0
ssh_client_ip dd 0
ssh_client_seq dd 0
ssh_server_seq dd 0x53590001
ssh_client_port dw 0
ssh_connected db 0
ping_wait_counter dd 0
ping_rx_before dd 0
ping_sent_count dd 0
ping_recv_count dd 0
ping_rtt_current dd 0
ping_rtt_min dd 0
ping_rtt_max dd 0
ping_rtt_sum dd 0
ping_reply_ttl db 0
ping_seq dw 0
ping_pit_last db 0
ping_pit_divisor dw 1193
ping_loop_remaining dd 0
svc_net       db 0
svc_tcp       db 0
svc_tls       db 0
svc_sapp      db 0
svc_ssh       db 0
svc_sftp      db 0
sapp_installed_base db 0
sapp_installed_calc db 0
sapp_installed_net db 0
sapp_installed_editor db 0
sapp_installed_utils db 0
sapp_installed_skycrt db 0
sapp_installed_skyui db 0
sapp_remote_index_ready db 0
sapp_remote_pkg_found db 0
sapp_remote_pkg_ptr dd 0
sapp_index_len dd 0
sapp_index_count dd 0
soj_ptr       dd 0
soj_base_ptr  dd 0
soj_stop      db 0
soj_if_not    db 0
sapp_arg_ptr  dd 0
sapp_pkg_ptr  dd 0
sapp_cmd_ptr  dd 0
calc_lhs      dd 0
calc_rhs      dd 0
calc_result   dd 0
calc_op       db 0
calc_negative db 0
gui_rect_x    dd 0
gui_rect_y    dd 0
gui_rect_w    dd 0
gui_rect_h    dd 0
gui_rect_color dd 0
gui_win_x     dd 0
gui_win_y     dd 0
gui_win_w     dd 0
gui_win_h     dd 0
gui_saved_attr db 0
mouse_irq_enabled db 0
mouse_packet_index db 0
mouse_packet0 db 0
mouse_packet1 db 0
mouse_packet2 db 0
mouse_buttons db 0
mouse_event_pending db 0
mouse_x dd 320
mouse_y dd 240
gui_prev_mouse_buttons db 0
gui_active_win db GUI_WIN_NONE
gui_drag_win db GUI_WIN_NONE
gui_resize_win db GUI_WIN_NONE
gui_start_menu_open db 0
gui_context_menu_open db 0
gui_power_menu_open db 0
gui_created_file db 0
gui_file_selected_row db 255
gui_settings_page db 0
gui_need_redraw db 0
gui_cursor_drawn db 0
gui_autostart_done db 0
gui_cursor_x dd 0
gui_cursor_y dd 0
gui_drag_offset_x dd 0
gui_drag_offset_y dd 0
gui_hit_win db GUI_WIN_NONE
gui_file_row_type db 0
gui_note_len dd 0
gui_term_len dd 0
gui_term_last_len dd 0
gui_term_output_ptr dd msg_gui_term_empty
gui_browser_url_len dd 0
gui_browser_page_ptr dd msg_gui_browser_3
gui_file_dir dd GUI_DIR_ROOT
gui_file_selected_dir dd GUI_DIR_ROOT
gui_context_x dd 0
gui_context_y dd 0
gui_drag_preview_active db 0
align 4
gui_drag_preview_x dd 0
gui_drag_preview_y dd 0
gui_drag_preview_w dd 0
gui_drag_preview_h dd 0
gui_icon_x dd 0
gui_icon_y dd 0
gui_win_visible db 1, 1, 1, 1, 1, 1, 0
gui_z_order db GUI_WIN_FILES, GUI_WIN_TASK, GUI_WIN_CMD, GUI_WIN_MEDIA, GUI_WIN_NOTEPAD, GUI_WIN_BROWSER, GUI_WIN_SETTINGS
align 4
gui_winx dd 96, 160, 0, 0, 120, 220, 180
gui_winy dd 64, 380, 64, 360, 120, 160, 110
gui_winw dd 500, 560, 360, 440, 520, 560, 560
gui_winh dd 260, 230, 220, 230, 300, 320, 360
gui_cursor_bits dw 0x8000, 0xC000, 0xE000, 0xF000, 0xF800, 0xFC00, 0xFE00, 0xFF00
                dw 0xFE00, 0xDC00, 0x8E00, 0x0600, 0x0300, 0x0300, 0x0000, 0x0000
random_state dd 0x13579BDF
float_22 dd 0x41B00000
float_7 dd 0x40E00000
float_result dd 0
pci_bus_tmp   dd 0
pci_slot_tmp  dd 0
pci_func_tmp  dd 0
pci_id_tmp    dd 0
pci_class_tmp dd 0
cpu_max_ext   dd 0
cpu_sig       dd 0
cpu_feat_ecx  dd 0
cpu_feat_edx  dd 0
disk_part_index dd 0
disk_rel_lba dd 0
disk_fs_lba dd 0
disk_wipe_lba dd 0
disk_wipe_sectors dd 0
disk_mount_part dd 0
disk_mount_lba dd 0
disk_mount_sectors dd 0
disk_mount_valid db 0
disk_write_byte db 0
disk_partition_preset dd 0
skyfs_init_ran db 0
skyfs_file_lba dd 0
skyfs_file_size dd 0
skyfs_file_sectors dd 0
chmod_perm db 0
fs_src_ptr dd 0
fs_dst_ptr dd 0
fs_perm_ptr dd 0
fs_size dd 0
audio_last_freq dd 0
audio_last_ticks dd 0
audio_enabled db 0
monitor_frame dd 0
monitor_load dd 0
monitor_spin dd 0
acpi_rsdp_addr dd 0
acpi_rsdt_addr dd 0
acpi_fadt_addr dd 0
acpi_dsdt_addr dd 0
acpi_pm1a_cnt dd 0
acpi_pm1b_cnt dd 0
acpi_smi_cmd dd 0
acpi_enable db 0
acpi_pm1_cnt_len db 0
acpi_slp_typa db 0xFF
acpi_slp_typb db 0xFF
perm_note db 6
perm_script db 6
perm_demo db 4
perm_sky db 4
perm_conf db 4
perm_sources db 4
perm_logo db 4
perm_photo db 4

home_note:
    db 'SkyOS RAM note', 0
    times 241 db 0
home_script_soj:
    db 'echo user SkyObJect script;exec version', 0
    times 217 db 0

section .rodata
welcome_message db 'SkyOS kernel loaded', 0
status_message  db 'Interactive shell ready', 0
os_version db 'SkyOS 1.0.3.0.GSOSYGP', 0
os_internal_version db '10015', 0
prompt_host_sep db '@sky:', 0
prompt_root_suffix db '# ', 0
prompt_user_suffix db '$ ', 0

help_title db 'SkyOS shell commands', 0
help_head  db 'Usage: help [system|fs|disk|net|dev|script|pkg|power|all]', 0
help_sep   db 'Examples: help disk, help net, sky -h all', 0
help_system_title db 'System commands:', 0
help_fs_title db 'Filesystem commands:', 0
help_disk_title db 'Disk commands:', 0
help_net_title db 'Network commands:', 0
help_dev_title db 'Developer commands:', 0
help_script_title db 'Script/package commands:', 0
help_power_title db 'Power commands:', 0
help_01 db 'help | sky -h                 Show this help page', 0
help_02 db 'version                       Show OS version', 0
help_03 db 'sysinfo                       Show machine details', 0
help_04 db 'clear                         Clear the screen', 0
help_05 db 'color <hex-attr>              Set VGA text color attribute, example 0A', 0
help_06 db 'cursor <x> <y> | display      Move cursor or show display mode', 0
help_07 db 'reboot | shutdown             Restart or power off', 0
help_08 db 'cd [dir] | ls                 Navigate the RAM filesystem', 0
help_09 db 'mem | memedit <addr>          Show memory or edit bytes interactively', 0
help_10 db 'peek <addr> | poke <addr> <b> Read or write one memory byte', 0
help_11 db 'disk [help|fs|mkfs|mount|install] Manage IDE disk/SkyFS', 0
help_12 db 'cat <file> | write <file> <txt> Read or write RAM files', 0
help_13 db 'vi <file>                    Direct RAM file editor; Ctrl+S save, Esc quit', 0
help_14 db 'imgview <jpg|png> | bf <prog> View image preview or run Brainfuck', 0
help_15 db 'ip|ip a|ip addr|ifconfig      Show eth0 interface information', 0
help_16 db 'route | netstat               Show IPv4 route/socket tables', 0
help_17 db 'ping <ipv4|host>              Send ICMP or queue DNS A query', 0
help_18 db 'wget|curl <url>               HTTP client entrypoints', 0
help_19 db 'sapp update|install|files     Manage SPK packages and installed commands', 0
help_20 db 'netctl | ss | ssh | sftp      Show network stack or secure shell clients', 0
help_21 db 'systemd <cmd>                 Manage kernel services', 0
help_22 db 'soj|run <file.soj>            Run a SkyObJect script', 0
help_23 db 'pwd | uname | hostname        Show shell/system identity', 0
help_24 db 'whoami | id | date | timezone Show user, uid, CMOS time, timezone', 0
help_25 db 'free | df | mount             Show memory, filesystem, and mounts', 0
help_26 db 'ps | lspci | dmesg            Show services, PCI, and boot log', 0
help_27 db 'echo <text>                   Print text', 0
help_28 db 'top | jobs | kill <pid>       Realtime monitor or stop service-backed tasks', 0
help_29 db 'service <unit> <action>       Manage service: status/start/stop', 0
help_30 db 'dhclient|resolvectl|settings  Show or change network/DNS/display configuration', 0
help_31 db 'systemctl|sudo|man            Linux-compatible command helpers', 0
help_32 db 'env|printenv|export|set       Show built-in environment variables', 0
help_33 db 'bootinfo | features           Show OS capability matrix', 0
help_34 db 'proc | ipc                    Show process scheduler and IPC status', 0
help_35 db 'fsinfo                        Show filesystem/inode support status', 0
help_36 db 'security | audit              Show users, permissions, audit status', 0
help_37 db 'syscall                       Show syscall ABI and syscall table', 0
help_38 db 'drivers                       Show device driver and interrupt status', 0
help_39 db 'cp|mv|rm|touch|mkdir|chmod    Modify RAMFS files and permissions', 0
help_40 db 'grep|du|nano|gcc|make         Utility/toolchain compatibility entrypoints', 0
help_41 db 'history | stat | wc | head    Inspect shell history and RAMFS files', 0
help_42 db 'who | groups                  Show login session and group membership', 0
help_43 db 'audio | beep [hz] [ticks]     Show PC speaker state or play a tone', 0
help_44 db 'unskyos                       Remove SkyOS boot/rootfs from disk; root only', 0
help_45 db 'line editing                  Home/End/Delete, Ctrl+A/E/W/U/K, Ctrl+Left/Right', 0
help_46 db 'gui|desktop|startx            Start interactive framebuffer desktop', 0

msg_unknown_prefix db 'sky: command not found: ', 0
msg_internal_version db 'InternalVersion: ', 0
msg_no_file db 'no such file or directory', 0
msg_usage_cd db 'usage: cd [/, .., bin, etc, home, dev]', 0
msg_usage_peek db 'usage: peek <hex-address>', 0
msg_usage_poke db 'usage: poke <hex-address> <hex-byte>', 0
msg_usage_disk db 'usage: disk [help|map|part|verify|root|fs <p>|mkfs <p>|mount <p>|read <lba>|hexdump <lba>|pread <p> <lba>|phex <p> <lba>|write <lba> <b>|pwrite <p> <lba> <b>|install|burn mbr]', 0
msg_usage_cat db 'usage: cat <file>', 0
msg_usage_write db 'usage: write note|script.soj <text>', 0
msg_usage_color db 'usage: color <hex-attribute>', 0
msg_usage_cursor db 'usage: cursor <hex-x> <hex-y>', 0
msg_usage_memedit db 'usage: memedit <hex-address>', 0
msg_usage_vi db 'usage: vi <sky.txt|note|script.soj|demo.soj|/home/...>', 0
msg_usage_imgview db 'usage: imgview <file.png|file.jpg>', 0
msg_usage_beep db 'usage: beep [hex-frequency] [hex-delay-ticks]', 0
msg_audio_title db 'audio: PC speaker / PIT channel 2', 0
msg_audio_driver db 'driver: i8253 PIT + port 0x61 speaker gate', 0
msg_audio_last_freq db 'last frequency hz: ', 0
msg_audio_last_ticks db 'last duration ticks: ', 0
msg_audio_qemu db 'qemu: audio backend is managed by SkyOS systemd services', 0
msg_beep_done db 'beep: tone played', 0
msg_img_title db 'SkyOS image viewer', 0
msg_img_format_png db 'format: PNG', 0
msg_img_format_jpg db 'format: JPEG', 0
msg_img_size_png db 'size: decoded from PNG IHDR', 0
msg_img_size_jpg db 'size: 80x45 sample, VGA text preview', 0
msg_img_decode_note db 'decoder: PNG indexed-color + zlib stored block + VGA color renderer', 0
msg_img_png_bad db 'png: unsupported or invalid PNG data', 0
msg_img_png_wh db 'png dimensions: ', 0
msg_img_png_palette db 'png palette colors: ', 0
msg_img_preview_1 db '+----------------+', 0
msg_img_preview_2 db '|   ####  SKY    |', 0
msg_img_preview_3 db '|  ##  ##  OS    |', 0
msg_img_preview_4 db '|   ####  IMG    |', 0
msg_img_preview_5 db '+----------------+', 0
msg_write_done db 'note written', 0
msg_permission_denied db 'permission denied', 0
msg_auth_password db 'Password for root (default: skyos): ', 0
msg_auth_failure db 'Authentication failure: expected root password', 0
msg_auth_root_required db 'permission denied: root privileges required', 0
msg_su_usage db 'usage: su [root|user]', 0
msg_su_root db 'su: switched to root', 0
msg_su_user db 'su: switched to user', 0
msg_login_usage db 'usage: login root|user', 0
msg_login_user db 'login: user session active', 0
msg_passwd_note db 'passwd: root password is built in for this stage; default is skyos', 0
msg_sudo_usage db 'usage: sudo <command>', 0
msg_sudo_prompt db '[sudo] password for root (default: skyos): ', 0
msg_sudo_running db 'sudo: executing as root', 0
msg_chmod_done db 'mode updated', 0
msg_chmod_usage db 'usage: chmod <octal-mode> <file>', 0
msg_perm_prefix db 'mode ', 0
msg_done db 'done', 0
msg_reboot db 'rebooting...', 0
msg_shutdown db 'shutting down...', 0
msg_shutdown_fail db 'shutdown request failed; returned to shell', 0
msg_mem_lower db 'lower memory KB: ', 0
msg_mem_upper db 'upper memory KB: ', 0
msg_mem_none db 'multiboot memory map unavailable', 0
msg_peek_value db 'value: ', 0
msg_poke_done db 'written', 0
msg_bf_done db 10, 'bf done', 0
msg_machine_id db 'machine id: SKY-86', 0
msg_arch db 'architecture: x86 32-bit protected mode', 0
msg_boot db 'boot: QEMU Multiboot ELF / GRUB-ready', 0
msg_video db 'video: Multiboot VBE framebuffer with VGA text fallback', 0
msg_mem_cap db 'memory support cap bytes: ', 0
msg_cpu_vendor db 'cpu vendor: ', 0
msg_cpu_brand db 'cpu model: ', 0
msg_cpu_sig db 'cpu signature: ', 0
msg_cpu_features_ecx db 'cpu features ecx: ', 0
msg_cpu_features_edx db 'cpu features edx: ', 0
msg_mem_available db 'available memory KB: ', 0
msg_mem_freq db 'memory frequency: SMBIOS/SPD pending', 0
msg_storage_available db 'available storage KB: ', 0
msg_disk_title db 'disk0: IDE/SATA-compatible boot disk', 0
msg_disk_status db 'ata status: ', 0
msg_disk_mbr_ok db 'mbr signature: valid 0xAA55', 0
msg_disk_mbr_bad db 'mbr signature: missing', 0
msg_disk_part0 db 'partition0 type: ', 0
msg_disk_start db 'partition0 lba start: ', 0
msg_disk_size db 'partition0 sectors: ', 0
msg_disk_note db 'partition scheme: MBR, raw IDE/SATA HDD/SSD-compatible image', 0
msg_disk_bus_ide db 'bus: legacy IDE PIO path active', 0
msg_disk_bus_sata db 'bus: SATA/AHCI controller detected; compatibility disk path active', 0
msg_disk_help_1 db 'disk                  show disk0 and MBR summary', 0
msg_disk_help_2 db 'disk read <lba>       read one sector and print first 16 bytes', 0
msg_disk_help_3 db 'disk write <lba> <b>  fill one sector with byte b and write it', 0
msg_disk_help_4 db 'disk burn mbr         write a minimal MBR to sector 0', 0
msg_disk_help_5 db 'disk part             list MBR partitions 0..3', 0
msg_disk_help_6 db 'disk pread <p> <lba>  read partition-relative sector', 0
msg_disk_help_7 db 'disk pwrite <p> <lba> <b> write partition-relative sector', 0
msg_disk_help_8 db 'disk fs <p>           identify common filesystem signatures in partition', 0
msg_disk_help_9 db 'disk mkfs <p>         create SkyFS v0 on partition', 0
msg_disk_help_10 db 'disk mount <p>        validate and mount SkyFS partition', 0
msg_disk_help_11 db 'disk install          format, partition, and install SkyOS to disk0', 0
msg_disk_help_12 db 'disk map              show boot chain and SkyFS layout', 0
msg_disk_help_13 db 'disk verify           verify MBR, stage2, kernel, and SkyFS markers', 0
msg_disk_help_14 db 'disk hexdump <lba>    print first 64 bytes of raw sector', 0
msg_disk_help_15 db 'disk phex <p> <lba>   print first 64 bytes partition-relative', 0
msg_disk_help_16 db 'disk root             show installed SkyFS root entries', 0
msg_disk_help_17 db 'disk select <n>       select installer target disk (current driver: disk0)', 0
msg_disk_help_18 db 'disk partition <n>    create installer MBR layout preset on disk0', 0
msg_disk_help_19 db 'disk format <p>       format partition as SkyFS v0', 0
msg_disk_part_head db 'idx boot type start sectors', 0
msg_disk_part_idx db 'part ', 0
msg_disk_part_oob db 'disk: partition lba outside partition bounds', 0
msg_disk_part_empty db 'disk: partition is empty', 0
msg_disk_lba db 'lba: ', 0
msg_disk_first16 db 'first 16 bytes: ', 0
msg_disk_first64 db 'first 64 bytes:', 0
msg_disk_map_1 db 'boot layout: MBR stage1 LBA0, stage2 LBA1..15, kernel ELF LBA16..2047', 0
msg_disk_map_2 db 'rootfs layout: partition0 type 0x7F at LBA2048, SkyFS super/manifest/dir/data', 0
msg_disk_verify_title db 'disk verify:', 0
msg_disk_verify_mbr_ok db '  MBR: ok', 0
msg_disk_verify_mbr_bad db '  MBR: missing or invalid', 0
msg_disk_verify_stage2_ok db '  stage2: ok', 0
msg_disk_verify_stage2_bad db '  stage2: missing', 0
msg_disk_verify_stage2_probe db 'SkyOS HD loader', 0
msg_disk_verify_kernel_ok db '  kernel ELF: ok', 0
msg_disk_verify_kernel_bad db '  kernel ELF: missing', 0
msg_disk_verify_skyfs_ok db '  SkyFS: ok', 0
msg_disk_verify_skyfs_bad db '  SkyFS: missing', 0
msg_disk_root_title db 'SkyFS root entries:', 0
msg_disk_write_warn db 'disk: writing one raw sector to disk0', 0
msg_disk_burn_warn db 'disk: burning minimal MBR to disk0 sector 0', 0
msg_disk_write_done db 'disk: write complete, status ', 0
msg_disk_burn_done db 'disk: MBR burned, status ', 0
msg_disk_fs_title db 'filesystem probe: ', 0
msg_disk_fs_mbr_type db 'mbr partition type: ', 0
msg_disk_fs_ext db 'ext-family superblock signature detected', 0
msg_disk_fs_fat32 db 'FAT32 boot sector signature detected', 0
msg_disk_fs_fat16 db 'FAT12/16 boot sector signature detected', 0
msg_disk_fs_exfat db 'exFAT boot sector signature detected', 0
msg_disk_fs_ntfs db 'NTFS boot sector signature detected', 0
msg_disk_fs_skyfs db 'SkyFS/rootfs marker detected', 0
msg_disk_fs_unknown db 'unknown or unsupported filesystem signature', 0
msg_disk_skyfs_format db 'disk: formatting partition as SkyFS v0', 0
msg_disk_skyfs_mount db 'disk: mounted SkyFS partition at /mnt/disk0', 0
msg_disk_skyfs_bad db 'disk: SkyFS signature not found', 0
msg_disk_install_start db 'SkyOS installer: target /dev/disk0p0, format before install, SkyFS v0', 0
msg_disk_install_mbr db 'SkyOS installer: MBR stage1 and partition table written', 0
msg_disk_install_stage2 db 'SkyOS installer: HDD stage2 written to LBA 1..15', 0
msg_disk_install_kernel db 'SkyOS installer: kernel ELF written to HDD boot area', 0
msg_disk_install_done db 'SkyOS installer: SkyFS rootfs files written to disk0p0', 0
msg_disk_install_note db 'SkyOS installer: reboot without ISO and boot from HDD', 0
msg_disk_install_no_kernel db 'SkyOS installer: kernel image unavailable; boot the ISO installer entry', 0
msg_disk_select_ok db 'disk: selected install target /dev/disk0', 0
msg_disk_select_unsupported db 'disk: only /dev/disk0 is available with the current IDE driver', 0
msg_disk_partitioning db 'disk: creating MBR partition table for /dev/disk0', 0
msg_disk_partition_done db 'disk: partitions ready: /dev/disk0p0 root SkyFS, p1 home, p2 data, p3 reserved', 0
msg_disk_format_warn db 'disk: formatting will overwrite the selected partition', 0
msg_unskyos_warning db 'unskyos: this will erase SkyOS boot sectors, partitions, and SkyFS files from disk0', 0
msg_unskyos_prompt db 'Type exactly "Yes,delete skyos" to continue: ', 0
msg_unskyos_confirm db 'Yes,delete skyos', 0
msg_unskyos_abort db 'unskyos: confirmation mismatch; aborted', 0
msg_unskyos_wiping db 'unskyos: wiping SkyOS boot chain and SkyFS areas...', 0
msg_unskyos_done db 'unskyos: SkyOS removed from disk0; reboot or reinstall as needed', 0
msg_disk_root_marker db 'root marker: /etc/os-release /sbin/init /bin/skysh /etc/passwd /etc/shadow /etc/sudoers /boot/loader.conf', 0
msg_skyfs_root_found db 'rootfs: SkyFS partition mounted from disk0p0', 0
msg_skyfs_init_found db 'init: /sbin/init found on SkyFS root', 0
msg_skyfs_init_run db 'init: executing /sbin/init from SkyFS', 0
msg_skyfs_init_missing db 'init: SkyFS /sbin/init not found; using kernel shell', 0
msg_skyfs_no_file db 'skyfs: file not found', 0
skyfs_label db 'SkyOS root disk0p0', 0
skyfs_super_note db 'SkyFS v0 superblock: sector 0 super, sector 1 install manifest, data follows', 0
skyfs_install_manifest db 'SkyOS installed root metadata; files=/etc/os-release,/sbin/init,/bin/skysh; source=live ISO; fs=SkyFS-v0', 0
skyfs_file_os_release db 'NAME=SkyOS', 10, 'VERSION=1.0.3.0.GSOSYGP', 10, 'VERSION_ID=1.0.3.0.GSOSYGP', 10, 'BUILD_ID=10015', 10, 'ID=skyos', 10, 'ARCH=i386', 10, 'ROOTFS=skyfs', 10, 0
skyfs_file_init db '#!/bin/soj', 10, 'echo SkyOS init from SkyFS', 10, 'exec mount', 10, 'exec features', 10, 0
skyfs_file_skysh db 'SkyOS builtin shell entrypoint loaded from SkyFS metadata.', 10, 0
skyfs_file_passwd db 'root:x:0:0:root:/root:/bin/skysh', 10, 'user:x:1000:1000:SkyOS User:/home/user:/bin/skysh', 10, 0
skyfs_file_shadow db 'root:skyos:0:0:99999:7:::', 10, 'user:skyuser:0:0:99999:7:::', 10, 0
skyfs_file_sudoers db 'root ALL=(ALL) ALL', 10, '%wheel ALL=(ALL) ALL', 10, 'user ALL=(root) ALL', 10, 0
skyfs_file_loader db 'bootloader=skyos-hdstage2', 10, 'kernel_lba=16', 10, 'root=/dev/disk0p0', 10, 'rootfstype=skyfs', 10, 'init=/sbin/init', 10, 0
skyfs_file_sources db 'deb http://skyapps.skyu.cc.cd skyos main', 10, 0
msg_memedit_intro db 'memedit: enter hex bytes, q to quit', 0
msg_memedit_addr db 'addr ', 0
msg_memedit_value db ' current ', 0
msg_memedit_prompt db 'memedit> ', 0
msg_vi_title db 'SkyOS vi editor', 0
msg_vi_help db 'type to edit directly', 0
msg_vi_prompt db 'vi: ', 0
msg_vi_saved db 'written', 0
msg_vi_readonly db 'readonly: open content can be viewed but not modified', 0
msg_vi_edit_prompt db '', 0
msg_vi_file db 'file: ', 0
msg_vi_status db 'type text  Ctrl+S save  Ctrl+V paste  Backspace delete  Esc quit', 0
msg_vi_editing db 'editing', 0
msg_vi_pasted db 'pasted', 0
msg_vi_empty db '~', 0
msg_net_iface db 'eth0: flags=UP,BROADCAST,RUNNING mtu 1500', 0
msg_net_mac db '    link/ether ', 0
msg_net_ip db '    inet ', 0
msg_net_scope db ' scope global eth0', 0
msg_net_gateway db 'default via ', 0
msg_net_gateway_suffix db ' dev eth0', 0
msg_net_dns db 'dns ', 0
msg_net_mode db 'network: e1000 link; address from DHCP or settings', 0
msg_net_mode_2 db 'network: DNS, ARP, IPv4, ICMP, UDP active', 0
msg_net_driver db 'driver: e1000 MMIO TX/RX ring driver', 0
msg_net_dhcp db 'dhcp: discover sent; using lease ACK or QEMU user-network fallback', 0
msg_resolv_head db 'Global DNS Servers:', 0
msg_resolv_domain db 'DNS Domain: unconfigured', 0
msg_net_unconfigured db 'unconfigured', 0
msg_settings_title db 'SkyOS settings', 0
msg_settings_usage db 'usage: settings [dns <ipv4>|qemu on|qemu off|net reset|display auto|display 1024x768|display 1280x720]', 0
msg_settings_dns db 'network.dns=', 0
msg_settings_dns_fallback db 'network.dns.fallback=', 0
msg_settings_qemu db 'network.qemuFallback=', 0
msg_settings_updated db 'settings: updated', 0
msg_settings_reset db 'settings: network state reset; DHCP will run again', 0
msg_settings_invalid db 'settings: invalid value', 0
msg_display_title db 'Display settings', 0
msg_display_mode db 'display.mode=', 0
msg_display_note db 'display: framebuffer console uses a fixed 80x25 dirty shadow text layer; VGA text fallback remains available', 0
msg_display_status db 'framebuffer.status=', 0
msg_display_on db 'active', 0
msg_display_off db 'fallback-vga', 0
msg_display_addr db 'framebuffer.addr=', 0
msg_display_res db 'framebuffer.resolution=', 0
msg_display_pitch db ' pitch=', 0
msg_display_bpp db ' bpp=', 0
msg_display_type db ' type=', 0
msg_display_vbe db 'vbe.info=', 0
msg_display_test_ok db 'framebuffer: test pattern drawn', 0
msg_display_test_none db 'framebuffer: unavailable or unsupported; using VGA fallback', 0
msg_display_auto db 'auto-fit', 0
msg_display_1024 db '1024x768', 0
msg_display_1280 db '1280x720', 0
msg_installer_title db 'SkyOS installer', 0
msg_installer_1 db '1. display/timezone: use sudo settings display <mode> and timezone set', 0
msg_installer_2 db '2. disk target: sudo disk select 0; devices appear as /dev/disk0p0..p3', 0
msg_installer_3 db '3. partition/format/install: sudo disk partition 4; sudo disk format 0; sudo install', 0
msg_installer_4 db 'install command performs partition table write, SkyFS format, boot chain install, rootfs copy', 0
msg_net_pci_none db 'driver: no PCI network controller detected', 0
msg_net_pci_detected db 'driver: PCI network controller detected', 0
msg_sata_pci_none db 'sata: no AHCI/SATA PCI controller detected', 0
msg_sata_pci_detected db 'sata: AHCI/SATA PCI controller detected', 0
msg_sata_pci_addr db '    sata pci ', 0
msg_sata_pci_vendor db '    sata vendor:device ', 0
msg_sata_pci_class db '    sata class:subclass:prog-if ', 0
msg_sata_pci_abar db '    abar ', 0
msg_sata_pci_pi db '    ports implemented ', 0
msg_net_pci_addr db '    pci ', 0
msg_net_pci_vendor db '    vendor:device ', 0
msg_net_pci_class db '    class:subclass ', 0
msg_net_pci_bar0 db '    bar0 ', 0
msg_net_stack_pending db '    link: e1000 rings initialized', 0
msg_net_stack_pending_2 db '    stack: ARP/IPv4/ICMP/UDP/DHCP/DNS', 0
msg_route_head db 'Destination     Gateway        Genmask         Iface', 0
msg_route_default db 'default via ', 0
msg_route_lan db 'connected ', 0
msg_route_suffix db ' dev eth0', 0
msg_usage_ping db 'Usage: ping [-t] [-a] [-n count] [-l size] [-w timeout] [-4] target_name', 0
msg_usage_ping_1 db 'Options:', 0
msg_usage_ping_2 db '    -t             Ping the specified host until stopped (planned).', 0
msg_usage_ping_3 db '    -a             Resolve addresses to hostnames (planned).', 0
msg_usage_ping_4 db '    -n count       Number of echo requests to send; default is 4.', 0
msg_usage_ping_5 db '    -l size        Send buffer size; default is 32 bytes (planned).', 0
msg_usage_ping_6 db '    -w timeout     Timeout in milliseconds to wait for each reply (planned).', 0
msg_usage_ping_7 db '    -4             Force IPv4.', 0
msg_ping_intro db 'Pinging ', 0
msg_ping_intro_mid db ' with 32 bytes of data:', 0
msg_ping_intro_addr_open db ' [', 0
msg_ping_intro_addr_close_mid db '] with 32 bytes of data:', 0
msg_ping_reply_from db 'Reply from ', 0
msg_ping_reply_bytes db ': bytes=32 time=', 0
msg_ping_reply_time_lt db '<1', 0
msg_ping_reply_ms_ttl db 'ms TTL=', 0
msg_ping_loopback_tail db ': bytes=32 time<1ms TTL=128', 0
msg_ping_timeout_line db 'Request timed out.', 0
msg_ping_tx_fail db 'ICMP transmit failed: e1000 driver is not initialized.', 0
msg_ping_no_address db 'Network address is not configured. Run dhclient or configure eth0 first.', 0
msg_ping_arp_timeout db 'ARP timeout: next-hop MAC was not resolved.', 0
msg_ping_localhost_dns db 'Resolved localhost to 127.0.0.1', 0
msg_ping_dns_query db 'DNS A response parsed.', 0
msg_ping_dns_addr db 'Resolved address: ', 0
msg_ping_dns_timeout db 'DNS request timed out.', 0
msg_ping_dns_retry db 'DNS query timed out; retrying fallback resolver ', 0
msg_ping_host_not_found_1 db 'Ping request could not find host ', 0
msg_ping_host_not_found_2 db '. Please check the name and try again.', 0
msg_ping_stats_1 db 'Ping statistics for ', 0
msg_ping_stats_packets db ': Packets: Sent = ', 0
msg_ping_stats_received db ', Received = ', 0
msg_ping_stats_lost db ', Lost = ', 0
msg_ping_stats_loss_open db ' (', 0
msg_ping_stats_loss_close db '% loss)', 0
msg_ping_approx db 'Approximate round trip times in milli-seconds:', 0
msg_ping_times_min db '    Minimum = ', 0
msg_ping_times_max db 'ms, Maximum = ', 0
msg_ping_times_avg db 'ms, Average = ', 0
msg_ping_times_end db 'ms', 0
msg_usage_wget db 'usage: wget <url|host>', 0
msg_wget_start db 'wget: resolving source ', 0
msg_wget_default_scheme db 'wget: no scheme supplied; using http://', 0
msg_wget_resolved db 'wget: resolved address ', 0
msg_wget_connect db 'wget: connecting to ', 0
msg_wget_port80 db ':80', 0
msg_wget_syn_sent db 'wget: TCP SYN sent', 0
msg_wget_tcp_open db 'wget: TCP port 80 reachable; HTTP body download awaits stream reassembly', 0
msg_wget_tcp_reset db 'wget: TCP connection reset by peer', 0
msg_wget_tcp_timeout db 'wget: TCP connect timed out', 0
msg_wget_dns_timeout db 'wget: DNS lookup failed', 0
msg_wget_bad_host db 'wget: invalid host name', 0
msg_wget_arp_timeout db 'wget: ARP timeout while resolving next hop', 0
msg_wget_http_pending db 'wget: HTTP client started; TCP stream reassembly pending', 0
msg_wget_https_pending db 'wget: HTTPS download needs TCP stream and TLS handshake support', 0
msg_wget_https_ready db 'wget: https.service active; TLS handshake waits for TCP packet engine', 0
msg_wget_network_down db 'wget: network.service inactive or no e1000 link', 0
msg_usage_curl db 'usage: curl <http-url|https-url>', 0
msg_curl_start db 'curl: requesting ', 0
msg_curl_network_down db 'curl: network.service inactive or no e1000 link', 0
msg_curl_tcp_pending db 'curl: TCP stream engine pending; request queued only', 0
msg_curl_tls_pending db 'curl: HTTPS needs TLS engine; request queued only', 0
msg_curl_ready db 'curl: transport services active; response body pending TCP/TLS implementation', 0
msg_usage_ssh db 'usage: ssh user@host', 0
msg_usage_sftp db 'usage: sftp user@host[:path]', 0
msg_ssh_start db 'ssh: connecting ', 0
msg_sftp_start db 'sftp: connecting ', 0
msg_ssh_pending db 'ssh: client mode pending; server listens on tcp/22 and sends SSH banner', 0
msg_sftp_pending db 'sftp: requires SSH subsystem; transfer engine pending', 0
msg_ssh_net_down db 'ssh: network.service inactive or no e1000 link', 0
ssh_server_banner db 'SSH-2.0-SkyOS_1.0.3.0.GSOSYGP', 13, 10, 0
ssh_server_note db 'ssh.service: server tcp/22 banner responder active; KEX/auth/session pending', 0
msg_sapp_usage db 'usage: sapp update|search <name>|list|install <pkg>|remove <pkg>|files <pkg>|info <pkg>|run <pkg>|source', 0
msg_sapp_source_title db 'sapp source:', 0
msg_sapp_source_path db 'source list: /etc/sapp/sources.list', 0
msg_sapp_update_1 db 'Get:1 http://skyapps.skyu.cc.cd skyos/main i386 Packages', 0
msg_sapp_update_2 db 'Reading package lists... Done', 0
msg_sapp_update_3 db 'Binary SPK package index ready', 0
msg_sapp_list_title db 'Listing packages...', 0
msg_sapp_name_1 db 'base-tools', 0
msg_sapp_name_2 db 'net-tools', 0
msg_sapp_name_3 db 'editor-vi', 0
msg_sapp_name_4 db 'sapp-utils', 0
msg_sapp_name_5 db 'calc', 0
msg_sapp_name_6 db 'skycrt', 0
msg_sapp_name_7 db 'skyui', 0
msg_sapp_version db '1.0.3.0.GSOSYGP', 0
msg_sapp_internal db '10015', 0
msg_sapp_dep_none db 0
msg_sapp_dep_base_internal db 'base-tools (>= 10015)', 0
msg_sapp_dep_base_net_internal db 'base-tools (>= 10015), net-tools (>= 10015)', 0
msg_sapp_file_1 db 'pool/main/base-tools_1.0.3.0.GSOSYGP_skyos-i386.spk', 0
msg_sapp_file_2 db 'pool/main/net-tools_1.0.3.0.GSOSYGP_skyos-i386.spk', 0
msg_sapp_file_3 db 'pool/main/editor-vi_1.0.3.0.GSOSYGP_skyos-i386.spk', 0
msg_sapp_file_4 db 'pool/main/sapp-utils_1.0.3.0.GSOSYGP_skyos-i386.spk', 0
msg_sapp_file_5 db 'pool/main/calc_1.0.3.0.GSOSYGP_skyos-i386.spk', 0
msg_sapp_file_6 db 'pool/main/skycrt_1.0.3.0.GSOSYGP_skyos-i386.sxr', 0
msg_sapp_file_7 db 'pool/main/skyui_1.0.3.0.GSOSYGP_skyos-i386.sxr', 0
msg_sapp_size_1 db '1131', 0
msg_sapp_size_2 db '1170', 0
msg_sapp_size_3 db '1168', 0
msg_sapp_size_4 db '1206', 0
msg_sapp_size_5 db '1213', 0
msg_sapp_size_6 db '603', 0
msg_sapp_size_7 db '597', 0
msg_sapp_desc_1 db 'Base SkyOS shell tools', 0
msg_sapp_desc_2 db 'Network commands for SkyOS', 0
msg_sapp_desc_3 db 'SkyOS vi editor package', 0
msg_sapp_desc_4 db 'Sapp package manager utilities', 0
msg_sapp_desc_5 db 'Calc for SkyOS', 0
msg_sapp_desc_6 db 'SkyOS native runtime SXR', 0
msg_sapp_desc_7 db 'SkyOS GUI runtime SXR', 0
msg_sapp_format_binary db 'spk-binary-v1', 0
msg_sapp_format_spk_v2 db 'spk-binary-v2', 0
msg_sapp_format_sxr db 'sxr-binary-v1', 0
msg_sapp_state_available db 'available', 0
msg_sapp_state_installed db 'installed', 0
msg_sapp_pkg_1 db 'base-tools/skyos 1.0.3.0.GSOSYGP i386 spk-binary-v1', 0
msg_sapp_pkg_2 db 'net-tools/skyos 1.0.3.0.GSOSYGP i386 spk-binary-v1 depends=base-tools (>= 10015)', 0
msg_sapp_pkg_3 db 'editor-vi/skyos 1.0.3.0.GSOSYGP i386 spk-binary-v1 depends=base-tools (>= 10015)', 0
msg_sapp_pkg_4 db 'sapp-utils/skyos 1.0.3.0.GSOSYGP i386 spk-binary-v1 depends=base-tools (>= 10015), net-tools (>= 10015)', 0
msg_sapp_cache_count_prefix db 'Package index cache: ', 0
msg_sapp_cache_suffix db ' packages', 0
msg_sapp_fetch_index db 'sapp: fetching index http://skyapps.skyu.cc.cd/dists/skyos/main/binary-i386/Packages', 0
msg_sapp_index_downloaded db 'sapp: remote Packages index downloaded', 0
msg_sapp_index_failed db 'sapp: remote index fetch failed; keeping built-in fallback cache', 0
msg_sapp_search_title db 'Search results:', 0
msg_sapp_no_match db 'sapp: no matching package', 0
msg_sapp_unknown_pkg db 'sapp: unknown package: ', 0
msg_sapp_dep_prefix db 'sapp: installing dependency ', 0
msg_sapp_installed db 'sapp: installed binary SPK package into package database', 0
msg_sapp_removed db 'sapp: removed from package database', 0
msg_sapp_install_prefix db 'sapp: installing ', 0
msg_sapp_remove_prefix db 'sapp: removing ', 0
msg_sapp_done db 'sapp: done', 0
msg_sapp_transport db 'sapp: HTTP body storage pending; using binary SPK index cache', 0
msg_sapp_transport_ready db 'sapp: tcp.service active; remote binary fetch path selected', 0
msg_sapp_version_sep db '/skyos ', 0
msg_sapp_arch_tail db ' i386 ', 0
msg_sapp_internal_prefix db '  InternalVersion: ', 0
msg_sapp_depends_prefix db '  Depends: ', 0
msg_sapp_file_prefix db '  Filename: ', 0
msg_sapp_size_prefix db '  Size: ', 0
msg_sapp_bytes_tail db ' bytes', 0
msg_sapp_desc_prefix db '  Description: ', 0
msg_sapp_fetch_prefix db 'sapp: fetching binary package ', 0
msg_sapp_cache_prefix db 'sapp: cache target /var/cache/sapp/archives/', 0
msg_sapp_http_get_prefix db 'sapp: GET http://skyapps.skyu.cc.cd/', 0
msg_sapp_spk_magic db 'sapp: verified SPK1 binary header and metadata', 0
msg_sapp_unpack db 'sapp: unpacked tar.gz payload into package database', 0
msg_sapp_status_prefix db '  Status: ', 0
msg_sapp_registered_prefix db 'sapp: registered command ', 0
msg_sapp_unregistered_prefix db 'sapp: removed command ', 0
msg_sapp_files_prefix db 'sapp: files for ', 0
msg_sapp_files_none db 'sapp: package has no registered command files in this kernel stage', 0
msg_sapp_not_installed db 'sapp: package is not installed: ', 0
msg_type_pkg_mid db ' is ', 0
msg_type_pkg_suffix db ' from SAPP package ', 0
msg_pkg_calc_title db 'calc: /usr/bin/calc from SAPP package calc', 0
msg_pkg_calc_usage db 'usage: calc <a> +|-|*|/ <b>', 0
msg_pkg_calc_div_zero db 'calc: division by zero', 0
msg_sapp_runtime_prefix db '  Runtime: ', 0
msg_sapp_entry_prefix db '  EntryPoint: ', 0
msg_sapp_sxr_prefix db '  SXR-Depends: ', 0
msg_sapp_pkg_type_prefix db '  PackageType: ', 0
msg_sapp_commands_prefix db '  Commands: ', 0
msg_sapp_permissions_prefix db '  Permissions: ', 0
msg_sapp_tc db '  TuringComplete: yes', 0
msg_sapp_calc_runtime db '  Runtime: native-i386 shim', 0
msg_sapp_calc_entry db '  EntryPoint: /usr/bin/calc', 0
msg_sapp_calc_sxr db '  SXR-Depends: skycrt (>= 10015)', 0
msg_sapp_calc_type db '  PackageType: cli-app', 0
msg_sapp_calc_permissions db '  Permissions: read=/home write=/home/user', 0
msg_sapp_sxr_type db '  PackageType: sxr-library', 0
msg_sapp_skycrt_runtime db '  Runtime: sxr native support library', 0
msg_sapp_skyui_runtime db '  Runtime: sxr gui support library', 0
msg_sapp_run_prefix db 'sapp: running package entry ', 0
msg_sapp_run_no_entry db 'sapp: installed package has no executable entry in this kernel stage', 0
msg_gui_no_fb db 'gui: framebuffer unavailable; use display/fbtest or boot VBE mode', 0
msg_gui_hint db 'SkyOS desktop - right click for menu; Esc exits', 0
msg_gui_start db 'Start', 0
msg_gui_title_files db 'File Manager', 0
msg_gui_title_cmd db 'Terminal', 0
msg_gui_title_task db 'Task Manager', 0
msg_gui_title_media db 'Media Viewer', 0
msg_gui_title_notepad db 'Notepad', 0
msg_gui_title_browser db 'HTML Browser', 0
msg_gui_title_settings db 'Settings', 0
msg_gui_icon_computer db 'Computer', 0
msg_gui_icon_files db 'Files', 0
msg_gui_icon_cmd db 'CMD', 0
msg_gui_icon_media db 'Media', 0
msg_gui_icon_sapp db 'SAPP', 0
msg_gui_icon_note db 'Note', 0
msg_gui_icon_html db 'HTML', 0
msg_gui_icon_terminal db 'Terminal', 0
msg_gui_icon_settings db 'Settings', 0
msg_gui_icon_browser db 'Browser', 0
msg_gui_menu_1 db 'Programs', 0
msg_gui_menu_2 db 'File Manager', 0
msg_gui_menu_3 db 'Terminal', 0
msg_gui_menu_4 db 'Task Manager', 0
msg_gui_menu_5 db 'Notepad', 0
msg_gui_menu_6 db 'Settings', 0
msg_gui_menu_7 db 'Media Viewer', 0
msg_gui_menu_8 db 'Browser', 0
msg_gui_menu_9 db 'Power', 0
msg_gui_files_root_path db '/', 0
msg_gui_files_bin_path db '/bin', 0
msg_gui_files_etc_path db '/etc', 0
msg_gui_files_home_path db '/home', 0
msg_gui_files_dev_path db '/dev', 0
msg_gui_files_toolbar db 'Path: ', 0
msg_gui_file_hdr_name db 'Name', 0
msg_gui_file_hdr_date db 'Modified', 0
msg_gui_file_hdr_type db 'Type', 0
msg_gui_file_hdr_size db 'Size', 0
msg_gui_file_type_dir db 'dir', 0
msg_gui_file_type_file db 'file', 0
msg_gui_file_date_1 db '2026/7/3', 0
msg_gui_file_date_2 db '2026/7/2', 0
msg_gui_file_size_dash db '-', 0
msg_gui_file_size_1k db '1K', 0
msg_gui_file_up db '..', 0
msg_gui_file_created db 'new-file.txt', 0
msg_gui_files_root_1 db 'bin', 0
msg_gui_files_root_2 db 'etc', 0
msg_gui_files_root_3 db 'home', 0
msg_gui_files_root_4 db 'dev', 0
msg_gui_files_root_5 db 'mnt', 0
msg_gui_files_root_6 db 'usr', 0
msg_gui_files_root_7 db 'var', 0
msg_gui_files_bin_1 db 'skysh', 0
msg_gui_files_bin_2 db 'calc', 0
msg_gui_files_bin_3 db 'soj', 0
msg_gui_files_bin_4 db 'vi', 0
msg_gui_files_etc_1 db 'os-release', 0
msg_gui_files_etc_2 db 'skyos.conf', 0
msg_gui_files_etc_3 db 'passwd', 0
msg_gui_files_home_1 db 'demo.soj', 0
msg_gui_files_home_2 db 'script.soj', 0
msg_gui_files_home_3 db 'note', 0
msg_gui_files_home_4 db 'logo.png', 0
msg_gui_files_dev_1 db 'disk0', 0
msg_gui_files_dev_2 db 'disk0p0', 0
msg_gui_files_dev_3 db 'fb0', 0
msg_gui_files_dev_4 db 'console', 0
msg_gui_cmd_1 db 'SkyOS terminal', 0
msg_gui_cmd_2 db 'Commands: help ls cd pwd date uname sapp settings shutdown clear exit', 0
msg_gui_cmd_3 db '$ ', 0
msg_gui_term_empty db '(type a command)', 0
msg_gui_term_help db 'help ls cd pwd date uname sapp settings shutdown clear exit', 0
msg_gui_term_ls_root db 'bin etc home dev mnt usr var', 0
msg_gui_term_uname db 'SkyOS 1.0 i386 framebuffer desktop', 0
msg_gui_term_sapp db 'sapp: use package manager from shell; GUI runtime loaded', 0
msg_gui_term_unknown db 'command not implemented in GUI terminal', 0
msg_gui_term_cd_root db 'changed directory to /', 0
msg_gui_term_cd_home db 'changed directory to /home', 0
msg_gui_term_settings db 'opening Settings', 0
msg_gui_term_shutdown db 'opening Power menu', 0
msg_gui_term_open_file db 'opened file from File Manager', 0
msg_gui_term_run_soj db 'running SOJ script from /home', 0
msg_gui_time db '09:59', 0
msg_gui_context_refresh db 'Refresh', 0
msg_gui_context_new_file db 'Create file', 0
msg_gui_context_terminal db 'Open Terminal', 0
msg_gui_context_settings db 'Settings', 0
msg_gui_context_power db 'Power', 0
msg_gui_power_title db 'Power menu', 0
msg_gui_power_shutdown db 'Shutdown', 0
msg_gui_power_reboot db 'Reboot', 0
msg_gui_power_cancel db 'Cancel', 0
msg_gui_settings_1 db 'System', 0
msg_gui_settings_2 db 'Display: framebuffer 1024x768x32', 0
msg_gui_settings_3 db 'Input: PS/2 keyboard + mouse', 0
msg_gui_settings_4 db 'Network: e1000 DHCP path', 0
msg_gui_settings_5 db 'Packages: SPK/SXR enabled', 0
msg_gui_settings_6 db 'Time: CMOS + timezone', 0
msg_gui_task_1 db 'PID  UNIT              STATE', 0
msg_gui_task_2 db '1    sky-shell         RUNNING', 0
msg_gui_task_3 db '2    network.service   ACTIVE', 0
msg_gui_task_4 db '3    sapp.service      ACTIVE', 0
msg_gui_task_menu db 'File Options View', 0
msg_gui_task_tab_app db 'App history', 0
msg_gui_task_tab_start db 'Startup', 0
msg_gui_task_tab_users db 'Users', 0
msg_gui_task_tab_details db 'Details', 0
msg_gui_task_tab_services db 'Services', 0
msg_gui_media_1 db 'Images: PNG/JPEG preview via imgview', 0
msg_gui_media_2 db 'Video: frame surface placeholder', 0
msg_gui_media_3 db '[thumbnail] [play] [stop]', 0
msg_gui_note_1 db 'Type here when Notepad is active:', 0
msg_gui_note_empty db '(empty)', 0
msg_gui_note_menu db 'File  Edit  Format  View  Help', 0
msg_gui_note_loaded db 'Text file opened. You can edit this buffer.', 0
msg_gui_browser_1 db 'file:///home/user/index.html', 0
msg_gui_browser_2 db '<html><h1>SkyOS</h1><p>SPK + SXR desktop runtime</p></html>', 0
msg_gui_browser_3 db 'Rendered: SkyOS - SPK + SXR desktop runtime', 0
msg_gui_browser_addr db 'Address:', 0
msg_gui_browser_go db 'Enter = Go', 0
msg_gui_browser_blank db 'about:blank', 0
msg_gui_browser_home db 'SkyOS Home - SPK, SXR, framebuffer GUI', 0
msg_gui_browser_docs db 'Docs - commands, packages, settings', 0
msg_gui_browser_net db 'Network fetch pending: TCP stream reassembly needed', 0
msg_gui_browser_hint db 'Try about:sky, docs://skyos, or http://skyapps.skyu.cc.cd', 0
gui_url_about_sky db 'about:sky', 0
gui_url_docs_skyos db 'docs://skyos', 0
url_file_prefix db 'file://', 0
msg_gui_task_tab_proc db 'Processes', 0
msg_gui_task_tab_perf db 'Performance', 0
msg_gui_task_hdr_name db 'Name       Status    CPU   Memory   Disk   Network', 0
msg_gui_task_app_1 db 'Desktop    Running   2%    24 MB    0      0 Mbps', 0
msg_gui_task_app_2 db 'Terminal   Running   1%    12 MB    0      0 Mbps', 0
msg_gui_task_app_3 db 'Browser    Idle      3%    18 MB    0      0 Mbps', 0
msg_gui_task_app_4 db 'SAPP       Active    4%    10 MB    0      0 Mbps', 0
msg_gui_task_cpu db 'CPU 43%', 0
msg_gui_task_mem db 'Memory 73%', 0
msg_gui_task_disk db 'Disk 7%', 0
msg_gui_task_net db 'Network 1%', 0
msg_rand_title db 'rand: RDTSC/CMOS mixed value ', 0
msg_bigint_title db 'bigint: 4294967295 + 4294967295 = 8589934590', 0
msg_float_title db 'float: 22 / 7 ~= 3.142857', 0
msg_fault_title db 'fault: exception handlers installed for CPU faults 0..31', 0
msg_exception_prefix db 'CPU exception: vector ', 0
msg_gui_close db 'X', 0
sapp_packages_url db 'http://skyapps.skyu.cc.cd/dists/skyos/main/binary-i386/Packages', 0
http_get_sapp_index:
    db 'GET /dists/skyos/main/binary-i386/Packages HTTP/1.0', 13, 10
    db 'Host: skyapps.skyu.cc.cd', 13, 10
    db 'Connection: close', 13, 10
    db 13, 10, 0
http_status_prefix db 'HTTP/1.', 0
sapp_field_package db 'Package: ', 0
sapp_field_version db 'Version: ', 0
sapp_field_internal db 'InternalVersion: ', 0
sapp_field_depends db 'Depends: ', 0
sapp_field_filename db 'Filename: ', 0
sapp_field_size db 'Size: ', 0
sapp_field_format db 'Format: ', 0
sapp_field_description db 'Description: ', 0
sapp_field_sxr_depends db 'SXR-Depends: ', 0
sapp_field_runtime db 'Runtime: ', 0
sapp_field_entry db 'EntryPoint: ', 0
sapp_field_commands db 'Commands: ', 0
sapp_field_package_type db 'PackageType: ', 0
sapp_field_permissions db 'Permissions: ', 0
sapp_field_turing db 'TuringComplete: ', 0
sapp_pkg_table:
    dd msg_sapp_name_1, msg_sapp_version, msg_sapp_internal, msg_sapp_dep_none
    dd msg_sapp_file_1, msg_sapp_size_1, msg_sapp_desc_1, msg_sapp_format_binary, sapp_installed_base
    dd msg_sapp_name_5, msg_sapp_version, msg_sapp_internal, msg_sapp_dep_none
    dd msg_sapp_file_5, msg_sapp_size_5, msg_sapp_desc_5, msg_sapp_format_spk_v2, sapp_installed_calc
    dd msg_sapp_name_6, msg_sapp_version, msg_sapp_internal, msg_sapp_dep_none
    dd msg_sapp_file_6, msg_sapp_size_6, msg_sapp_desc_6, msg_sapp_format_sxr, sapp_installed_skycrt
    dd msg_sapp_name_7, msg_sapp_version, msg_sapp_internal, msg_sapp_dep_none
    dd msg_sapp_file_7, msg_sapp_size_7, msg_sapp_desc_7, msg_sapp_format_sxr, sapp_installed_skyui
    dd msg_sapp_name_2, msg_sapp_version, msg_sapp_internal, msg_sapp_dep_base_internal
    dd msg_sapp_file_2, msg_sapp_size_2, msg_sapp_desc_2, msg_sapp_format_binary, sapp_installed_net
    dd msg_sapp_name_3, msg_sapp_version, msg_sapp_internal, msg_sapp_dep_base_internal
    dd msg_sapp_file_3, msg_sapp_size_3, msg_sapp_desc_3, msg_sapp_format_binary, sapp_installed_editor
    dd msg_sapp_name_4, msg_sapp_version, msg_sapp_internal, msg_sapp_dep_base_net_internal
    dd msg_sapp_file_4, msg_sapp_size_4, msg_sapp_desc_4, msg_sapp_format_binary, sapp_installed_utils
    dd 0
align 4
sapp_cmd_table:
    dd cmd_calc, msg_sapp_name_5, command_pkg_calc, path_usr_bin_calc, sapp_installed_calc
    dd 0
msg_netctl_title db 'SkyOS network stack', 0
msg_netctl_link db 'link/e1000: ', 0
msg_netctl_tcp db 'tcp/ipv4: ', 0
msg_netctl_tls db 'tls/https: ', 0
msg_netctl_e1000 db 'e1000/rings: ', 0
msg_netctl_arp db 'arp: minimal request/reply handler', 0
msg_netctl_ipv4 db 'ipv4: minimal parser/checksum/dispatcher', 0
msg_netctl_icmp db 'icmp: echo request/reply path', 0
msg_netctl_udp db 'udp: parser + dhcp client + dns query frame builder', 0
msg_netctl_tcp_note db 'tcp: port 22 server SYN/SYN-ACK plus SSH banner; full stream/KEX pending', 0
msg_net_stats_rx db 'rx packets: ', 0
msg_net_stats_tx db 'tx packets: ', 0
msg_net_stats_arp db 'arp packets: ', 0
msg_net_stats_ipv4 db 'ipv4 packets: ', 0
msg_net_stats_icmp db 'icmp packets: ', 0
msg_net_stats_udp db 'udp packets: ', 0
msg_net_stats_tcp db 'tcp packets: ', 0
msg_net_stats_dhcp db 'dhcp packets: ', 0
msg_net_stats_dns db 'dns packets: ', 0
msg_net_stats_icmp_req db 'icmp echo requests: ', 0
msg_net_stats_icmp_reply db 'icmp echo replies: ', 0
msg_net_stats_tcp_syn db 'tcp syn packets: ', 0
msg_net_stats_tcp_ack db 'tcp ack packets: ', 0
msg_net_stats_tcp_psh db 'tcp psh packets: ', 0
msg_net_stats_tcp_rst db 'tcp rst packets: ', 0
msg_net_stats_ssh_syn db 'ssh syn packets: ', 0
msg_net_stats_ssh_banner db 'ssh banner packets: ', 0
msg_net_lease db 'dhcp lease: ', 0
msg_net_gwmac db 'gateway mac: ', 0
msg_net_last_proto db 'last rx protocol: ', 0
msg_net_proto_none db 'none', 0
msg_net_proto_arp db 'arp', 0
msg_net_proto_icmp db 'icmp', 0
msg_net_proto_udp db 'udp', 0
msg_net_proto_tcp db 'tcp', 0
msg_e1000_init_ok db 'e1000: TX/RX descriptor rings initialized', 0
msg_e1000_init_fail db 'e1000: no usable MMIO BAR found', 0
msg_net_any_detected db 'driver: unsupported PCI network controller seen', 0
msg_svc_active db 'active', 0
msg_svc_inactive db 'inactive', 0
msg_ss_head db 'Netid State      Local Address:Port    Peer Address:Port', 0
msg_ss_ssh db 'tcp   LISTEN     0.0.0.0:22            0.0.0.0:*       ssh.service', 0
msg_netstat_head db 'Proto Recv-Q Send-Q Local Address           Foreign Address         State', 0
msg_netstat_tcp db 'tcp        0      0 0.0.0.0:22             0.0.0.0:*               LISTEN', 0
msg_systemd_usage db 'usage: systemd list|status|start <unit>|stop <unit>', 0
msg_systemd_units db 'UNIT              LOAD   ACTIVE   DESCRIPTION', 0
msg_unit_net db 'network.service   loaded ', 0
msg_unit_tcp db 'tcpip.service     loaded ', 0
msg_unit_tls db 'https.service     loaded ', 0
msg_unit_sapp db 'sapp.service      loaded ', 0
msg_unit_ssh db 'ssh.service       loaded ', 0
msg_unit_sftp db 'sftp.service      loaded ', 0
msg_unit_net_desc db ' Network hardware and link manager', 0
msg_unit_tcp_desc db ' IPv4 TCP stack manager', 0
msg_unit_tls_desc db ' HTTPS/TLS transport manager', 0
msg_unit_sapp_desc db ' SkyApps package manager', 0
msg_unit_ssh_desc db ' SSH client/server protocol manager', 0
msg_unit_sftp_desc db ' SFTP file transfer subsystem', 0
msg_systemd_started db 'systemd: started ', 0
msg_systemd_stopped db 'systemd: stopped ', 0
msg_systemd_unknown db 'systemd: unknown unit', 0
msg_usage_soj db 'usage: soj <file.soj> | run <file.soj>', 0
msg_usage_soj_set db 'soj: usage: set <name> <value>', 0
msg_usage_soj_goto db 'soj: usage: goto <label>', 0
msg_usage_soj_input db 'soj: usage: input <name>', 0
msg_usage_soj_math db 'soj: usage: inc|dec <name>', 0
msg_soj_start db 'SkyObJect: running ', 0
msg_soj_done db 'SkyObJect: done', 0
msg_soj_unknown db 'soj: unknown statement: ', 0
msg_soj_if_usage db 'soj: usage: if $name ==|!= value then <statement|goto label>', 0
msg_soj_var_missing db 'soj: unset variable', 0
msg_soj_label_missing db 'soj: label not found: ', 0
msg_soj_input_prompt db 'soj input> ', 0
msg_pwd db '/', 0
msg_hostname db 'SKY-86', 0
user_root_name db 'root', 0
user_user_name db 'user', 0
root_password db 'skyos', 0
user_password db 'skyuser', 0
msg_id_root db 'uid=0(root) gid=0(root) groups=0(root),10(wheel)', 0
msg_id_user db 'uid=1000(user) gid=1000(user) groups=1000(user),10(wheel)', 0
msg_who_root db 'root     tty0         console  skysh', 0
msg_who_user db 'user     tty0         console  skysh', 0
msg_groups_root db 'root wheel', 0
msg_groups_user db 'user wheel', 0
msg_uname db 'SkyOS SKY-86 1.0.3.0.GSOSYGP i386 sky-kernel', 0
msg_date_prefix db '20', 0
msg_timezone_usage db 'usage: timezone [set]', 0
msg_timezone_current db 'timezone: ', 0
msg_timezone_menu db 'Select timezone with Up/Down, Enter to apply:', 0
msg_timezone_selected db 'timezone set to ', 0
msg_timezone_hint db '> ', 0
msg_df_head db 'Filesystem     1K-blocks Used Available Mounted on', 0
msg_df_root db 'ramfs               256    24       232 /', 0
msg_df_disk db 'disk0             65536     1     65535 /dev/disk0', 0
msg_mount_root db 'ramfs on / type ramfs (rw,builtin)', 0
msg_mount_disk db 'disk0 on /dev/disk0 type raw-ide (rw,sector)', 0
msg_mount_skyfs db 'disk0p0 on /mnt/disk0 type skyfs (rw,installed)', 0
msg_ps_head db 'PID TTY  STAT UNIT              CMD', 0
msg_ps_shell db '1   tty0 S    sky-shell         /bin/skysh', 0
msg_ps_net db '2   tty0 S    network.service   kernel network manager', 0
msg_ps_sapp db '3   tty0 S    sapp.service      package manager', 0
msg_top_title db 'SkyOS realtime process and performance monitor', 0
msg_top_hint db 'Press q, Esc, or Ctrl+C to exit. Refresh: live polling.', 0
msg_top_frame db 'frame=', 0
msg_top_load db ' load=', 0
msg_top_mem db ' mem_kb=', 0
msg_top_disk db ' disk=', 0
msg_top_net db ' net rx/tx=', 0
msg_top_services db ' services net/tcp/tls/sapp/ssh/sftp=', 0
msg_top_proc_head db 'PID USER STAT CPU% MEM% UNIT              COMMAND', 0
msg_top_shell db '1   root R    03   10   sky-shell         /bin/skysh', 0
msg_top_net_proc db '2   root S    01   05   network.service   e1000 dhcp dns tcp', 0
msg_top_sapp_proc db '3   root S    00   04   sapp.service      package manager', 0
msg_top_disk_proc db '4   root S    00   03   disk0.service     ide/sata skyfs', 0
msg_top_perf_head db 'PERF cpu/load mem disk network', 0
msg_jobs_none db '[1] running sky-shell', 0
msg_kill_usage db 'usage: kill <pid>', 0
msg_kill_done db 'kill: stopped pid ', 0
msg_kill_bad db 'kill: no such pid or protected task', 0
msg_service_usage db 'usage: service <unit> status|start|stop', 0
msg_uptime db 'up 0 min, 1 user, load average: 0.00, 0.00, 0.00', 0
msg_man_usage db 'usage: man <command>', 0
msg_man_prefix db 'Manual entry: ', 0
msg_which_prefix db '/bin/', 0
msg_which_not_found db 'which: no command in PATH', 0
msg_type_prefix db ' is a SkyOS shell builtin', 0
msg_alias_systemctl db 'systemctl is aliased to systemd', 0
msg_env_readonly db 'environment is built-in/read-only in this kernel stage', 0
msg_export_usage db 'usage: export NAME=value', 0
msg_features_title db 'SkyOS capability matrix', 0
msg_feature_boot db 'boot: BIOS GRUB/Multiboot supported; UEFI planned through GRUB EFI chainload', 0
msg_feature_init db 'init: CPU, Multiboot memory/framebuffer, keyboard, IDE, PCI/e1000 probes run at boot', 0
msg_feature_proc db 'process: kernel task table prototype; shell/network/sapp service tasks visible', 0
msg_feature_mem db 'memory: 2 GiB boot cap, Multiboot map, raw peek/poke, memedit; VM paging pending', 0
msg_feature_fs db 'filesystem: RAMFS, SkyFS, MBR I/O; ext/FAT32/exFAT/NTFS signature probes', 0
msg_feature_io db 'drivers: framebuffer/VBE, VGA fallback, PS/2, IDE PIO, SATA/AHCI probe, PCI scan, e1000 TX/RX', 0
msg_feature_cli db 'cli: skysh builtins, history, cursor editing, env, SkyObJect scripts', 0
msg_feature_sec db 'security: root UID/GID model, chmod-backed RAMFS permissions; login database pending', 0
msg_feature_net db 'network: e1000, ARP/IPv4/ICMP/UDP/DHCP minimal path; TCP streams/TLS pending', 0
msg_feature_syscall db 'syscall: int 0x80 ABI documented; kernel/user split and syscall dispatcher pending', 0
msg_bootinfo_1 db 'bootloader: GRUB Multiboot v1 ELF kernel image', 0
msg_bootinfo_2 db 'firmware: BIOS path works in QEMU; UEFI path requires GRUB EFI ISO stage', 0
msg_bootinfo_3 db 'kernel entry: 32-bit protected mode _start, stack initialized before shell', 0
msg_bootinfo_4 db 'init order: framebuffer/VGA -> CPU -> memory cap -> disk0/SATA probe -> PCI/e1000 -> skysh', 0
msg_proc_1 db 'scheduler: cooperative service table now; round-robin timer scheduler pending', 0
msg_proc_2 db 'states: RUNNING shell, SLEEPING kernel services, STOPPED when killed', 0
msg_proc_3 db 'fork/exec/wait: syscall names reserved; user address spaces pending', 0
msg_ipc_1 db 'ipc: pipe, signal, message queue, shared memory entrypoints reserved', 0
msg_ipc_2 db 'pipe: shell redirection parser pending; in-kernel ring buffer design selected', 0
msg_ipc_3 db 'signal: kill command can stop service-backed tasks; POSIX signals pending', 0
msg_fsinfo_1 db 'fs: ramfs fixed directories / /bin /etc /home /dev', 0
msg_fsinfo_2 db 'inode: builtin metadata table for note, demo.soj, script.soj, sky.txt, skyos.conf', 0
msg_fsinfo_3 db 'disk fs: MBR partition inspect/write plus probes for ext/FAT/exFAT/NTFS/SkyFS', 0
msg_fsinfo_4 db 'permissions: root-owned RAMFS mode bits enforced by cat/write/vi/grep/soj', 0
msg_fsinfo_5 db 'iso layout: /boot kernel+initramfs, /rootfs rootfs.tar.gz, /pool and /dists Sapp repo', 0
msg_fsinfo_6 db 'installer: /install/install.soj; drivers in /lib/modules and firmware manifest in /lib/firmware', 0
msg_fsinfo_7 db 'production gap: dynamic VFS mount, journaling FS write support, ELF userland exec pending', 0
msg_security_1 db 'auth: root and user accounts active; sudo/su require root password', 0
msg_security_2 db 'uid/gid: default uid=1000(user); su/sudo raise to uid=0(root)', 0
msg_security_3 db 'access control: root-gated install/disk/power commands plus RAMFS mode bits', 0
msg_security_4 db 'audit: boot, disk, network, shell command events visible through dmesg/audit', 0
msg_audit_1 db 'audit: boot ok, shell active, disk0 attached, eth0 probe complete', 0
msg_syscall_1 db 'ABI: int 0x80 planned for i386 syscall entry', 0
msg_syscall_2 db 'file syscalls: open read write close ioctl names reserved', 0
msg_syscall_3 db 'process syscalls: fork exec wait signal names reserved', 0
msg_syscall_4 db 'memory syscalls: brk mmap munmap names reserved; allocator pending', 0
msg_drivers_1 db 'char: framebuffer/VBE console, VGA fallback, and PS/2 keyboard driver active', 0
msg_drivers_2 db 'block: IDE PIO disk0 read/write active; SATA/AHCI probe available', 0
msg_drivers_3 db 'net: PCI e1000 MMIO TX/RX descriptor driver active when device present', 0
msg_drivers_4 db 'interrupts: IDT/PIC keyboard and PS/2 mouse IRQ active; timer IRQ layer pending', 0
msg_drivers_5 db 'audio: PC speaker via PIT channel 2 and port 0x61 active', 0
msg_drivers_6 db 'sata: AHCI PCI discovery active; DMA port driver pending', 0
msg_utils_1 db 'utils: ls cat write vi nano grep du cp mv rm touch mkdir chmod gcc make entrypoints', 0
msg_nano_title db 'SkyOS nano editor', 0
msg_nano_note db 'nano: separate editor entrypoint; line-buffer editing backend pending', 0
msg_utils_2 db 'toolchain: native gcc/make execution pending ELF loader and process ABI', 0
msg_fsop_usage db 'usage: cp|mv|rm|touch|mkdir|chmod <args>', 0
msg_fsop_status db 'ramfs: fixed inode table; cp/mv/rm/touch operate on writable builtin files', 0
msg_cp_usage db 'usage: cp <source> <dest>', 0
msg_mv_usage db 'usage: mv <source> <dest>', 0
msg_rm_usage db 'usage: rm <file>', 0
msg_touch_usage db 'usage: touch <file>', 0
msg_mkdir_usage db 'usage: mkdir <dir>', 0
msg_mkdir_fixed db 'mkdir: ramfs directories are fixed in this kernel stage', 0
msg_fsop_done db 'ramfs: operation complete', 0
msg_fsop_readonly db 'ramfs: destination is readonly or not writable', 0
msg_stat_usage db 'usage: stat <file>', 0
msg_stat_file db '  File: ', 0
msg_stat_size db '  Size: ', 0
msg_stat_mode db '  Mode: ', 0
msg_stat_type db '  Type: ramfs builtin file', 0
msg_wc_usage db 'usage: wc <file>', 0
msg_wc_prefix db 'bytes ', 0
msg_head_usage db 'usage: head <file>', 0
msg_history_empty db 'history: empty', 0
msg_who_line db 'root     tty0         console  skysh', 0
msg_groups_line db 'root', 0
msg_tool_pending db 'utility exists as SkyOS builtin entrypoint; full external program pending ELF exec', 0
msg_command_cancelled db '^C', 0
msg_grep_usage db 'usage: grep <text> <file>', 0
msg_du_head db '4       /home', 0
env_01 db 'USER=', 0
env_02 db 'HOME=/home', 0
env_03 db 'SHELL=/bin/skysh', 0
env_04 db 'HOSTNAME=SKY-86', 0
env_05 db 'PATH=/bin:/sbin:/usr/bin', 0
env_06 db 'TERM=sky-vga', 0
env_07 db 'ARCH=i386', 0
env_08 db 'OS=SkyOS', 0
env_09 db 'NETDEV=eth0', 0
env_10 db 'IP=', 0
env_11 db 'GATEWAY=', 0
env_12 db 'DNS=', 0
env_name_user db 'USER', 0
env_name_home db 'HOME', 0
env_name_shell db 'SHELL', 0
env_name_hostname db 'HOSTNAME', 0
env_name_path db 'PATH', 0
env_name_term db 'TERM', 0
env_name_arch db 'ARCH', 0
env_name_os db 'OS', 0
env_name_netdev db 'NETDEV', 0
env_name_ip db 'IP', 0
env_name_gateway db 'GATEWAY', 0
env_name_dns db 'DNS', 0
env_name_pwd db 'PWD', 0
env_value_user db 'root', 0
env_value_home db '/home', 0
env_value_shell db '/bin/skysh', 0
env_value_hostname db 'SKY-86', 0
env_value_path db '/bin:/sbin:/usr/bin', 0
env_value_term db 'sky-vga', 0
env_value_arch db 'i386', 0
env_value_os db 'SkyOS', 0
env_value_netdev db 'eth0', 0
msg_dmesg_1 db '[    0.000000] SkyOS kernel loaded', 0
msg_dmesg_2 db '[    0.010000] VGA console initialized', 0
msg_dmesg_3 db '[    0.020000] CPU vendor detected', 0
msg_dmesg_4 db '[    0.030000] IDE disk0 attached', 0
msg_dmesg_5 db '[    0.040000] PCI network scan complete', 0
msg_lspci_none db '00:00.0 Host bridge: QEMU/Bochs virtual machine', 0
file_sapp_sources db 'deb http://skyapps.skyu.cc.cd skyos main', 0
file_demo_soj db '# SkyObJect demo;echo SkyObJect script online;set name SkyOS;print $name;if $name == SkyOS then echo condition-ok;set n 0;label loop;echo tick $n;inc n;if $n == 3 then goto done;goto loop;label done;exec version', 0
file_logo_png db 'PNG image: /home/logo.png (sample image for imgview)', 0
file_photo_jpg db 'JPEG image: /home/photo.jpg (sample image for imgview)', 0
logo_png_data:
    db 0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52
    db 0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x0C,0x08,0x03,0x00,0x00,0x00,0x34,0xCA,0x4F
    db 0x8B,0x00,0x00,0x00,0x18,0x50,0x4C,0x54,0x45,0x00,0x00,0x00,0x00,0x28,0x64,0x00
    db 0x5A,0xDC,0x00,0xB4,0xFF,0x78,0xE6,0xFF,0xFF,0xFF,0xFF,0x50,0x50,0x50,0x00,0x78
    db 0xFF,0xD0,0x69,0xAD,0xA4,0x00,0x00,0x01,0x97,0x49,0x44,0x41,0x54,0x78,0x01,0x01
    db 0x8C,0x01,0x73,0xFE,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x03,0x03,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x03,0x03,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x03,0x03,0x04,0x04,0x04,0x04,0x05,0x05,0x05,0x05,0x04,0x04,0x04,0x04,0x03,0x03
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03
    db 0x03,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04
    db 0x03,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x03
    db 0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04
    db 0x04,0x04,0x03,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x03,0x03
    db 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03
    db 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02
    db 0x02,0x02,0x02,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07
    db 0x07,0x07,0x07,0x07,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x02,0x02,0x02,0x00,0x02,0x02,0x02,0x00,0x02,0x02,0x02
    db 0x02,0x00,0x02,0x02,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x02,0x00,0x02,0x00,0x02,0x00
    db 0x00,0x02,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    db 0xBB,0x51,0x02,0x3F,0x62,0x2D,0x14,0xF6,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44
    db 0xAE,0x42,0x60,0x82
logo_png_end:
home_title db 'Welcome to SkyOS 1.0.3.0.GSOSYGP (sky-kernel 10015 i386)', 0
home_doc db '* Documentation:  https://skyos.skyu.cc.cd/docs', 0
home_manage db '* Management:     sapp source, sapp update, settings, systemctl', 0
home_support db '* Support:        https://skyos.skyu.cc.cd', 0
home_min_1 db 'This system is a development build with kernel, SkyFS, SAPP, network, disk,', 0
home_min_2 db 'and installer components enabled for testing.', 0
home_restore db 'Use help, man, features, top, netctl, disk, and sapp to inspect the system.', 0
home_last_login db 'Last login: ', 0
home_last_login_tail db ' on tty0', 0
boot_banner db 'SkyOS 1.0.3.0.GSOSYGP x86', 0
boot_ok db '[ OK ] ', 0
boot_step_01 db 'Initializing VGA text console', 0
boot_step_02 db 'Loading reusable console functions', 0
boot_step_03 db 'Detecting CPU vendor', 0
boot_step_04 db 'Configuring 2 GiB memory map support', 0
boot_step_05 db 'Attaching IDE disk0', 0
boot_step_06 db 'Starting Sky shell', 0
boot_phase_start db 'start', 0
boot_phase_loading db 'loading', 0
boot_phase_done db 'done', 0
boot_status_start db 'starting SkyOS bootstrap sequence', 0
boot_status_console db 'preparing vga console and shell renderer', 0
boot_status_cpu db 'probing cpu vendor and feature flags', 0
boot_status_mem db 'building 2 GiB memory capability map', 0
boot_status_disk db 'attaching disk0 and ramfs catalogue', 0
boot_status_systemd db 'loading systemd units: network tcpip https sapp ssh sftp', 0
boot_status_net db 'probing pci bus and e1000 network adapter', 0
boot_status_shell db 'starting skysh root console', 0
boot_status_ready db 'boot complete, entering tty0', 0
boot_orbit_start0 db '        .--.        ', 0
boot_orbit_start1 db '     .-(    )-.     ', 0
boot_orbit_start2 db '  --(  SKYOS  )--   ', 0
boot_orbit_start3 db '      `-.__.-`      ', 0
boot_orbit_load0 db '      /========>    ', 0
boot_orbit_load1 db '      -========>    ', 0
boot_orbit_load2 db '      \========>    ', 0
boot_orbit_load3 db '      <========-    ', 0
boot_orbit_end0 db '     <=========>    ', 0
boot_orbit_end1 db '   <== SkyOS ==>    ', 0
boot_orbit_end2 db '      <=======>     ', 0
boot_logo_line1 db '        .--.        ', 0
boot_logo_line2 db '    .-(      )-.    ', 0
boot_logo_line3 db '  _(   SKYOS   )_   ', 0
boot_logo_line4 db ' /__\_.------._/__\ ', 0
boot_logo_line5 db '     /  sky   \     ', 0
boot_logo_line6 db '        SkyOS       ', 0
boot_bottom_phase db '[phase] ', 0
boot_bottom_status db '[init ] ', 0
boot_bottom_services db '[unit ] ', 0
boot_services_text db 'boot-registry: autoload entries active; append feature records to extend boot', 0
boot_services_ready db 'systemd: all core units loaded; skysh.service active', 0
boot_registry:
    dd boot_status_console, boot_orbit_load0, boot_init_noop
    dd boot_status_mem, boot_orbit_load1, boot_init_noop
    dd boot_status_cpu, boot_orbit_load2, detect_cpu_vendor
    dd boot_status_disk, boot_orbit_load3, boot_init_noop
    dd boot_status_systemd, boot_orbit_load0, boot_init_noop
    dd boot_status_net, boot_orbit_load1, detect_network_pci
    dd boot_status_systemd, boot_orbit_load2, init_network_boot_services
    dd boot_status_shell, boot_orbit_load3, boot_init_noop
    dd 0, 0, 0
shutdown_banner db 'SkyOS is shutting down', 0
shutdown_step_01 db 'Stopping Sky shell', 0
shutdown_step_02 db 'Syncing RAM filesystem', 0
shutdown_step_03 db 'Flushing console output', 0
shutdown_step_04 db 'Detaching disk0', 0
shutdown_step_05 db 'Powering off machine', 0

root_listing db 'bin/ etc/ home/ dev/ sky.txt', 0
bin_listing  db 'reboot shutdown bf vi memedit', 0
etc_listing  db 'skyos.conf', 0
etc_sapp_listing db 'sources.list', 0
home_listing db 'note demo.soj script.soj logo.png photo.jpg', 0
dev_listing  db 'mem disk0 disk0p0 disk0p1 disk0p2 disk0p3 console vga fb0', 0

file_sky db 'SkyOS: x86 NASM kernel with GRUB boot.', 0
file_conf db 'name=SkyOS arch=x86 boot=grub shell=skysh pkg=sapp', 0

cmd_help     db 'help', 0
cmd_sky      db 'sky', 0
arg_help     db '-h', 0
cmd_version  db 'version', 0
cmd_sysinfo  db 'sysinfo', 0
cmd_clear    db 'clear', 0
cmd_color    db 'color', 0
cmd_cursor   db 'cursor', 0
cmd_display  db 'display', 0
cmd_fbtest   db 'fbtest', 0
cmd_gui      db 'gui', 0
cmd_desktop  db 'desktop', 0
cmd_startx   db 'startx', 0
cmd_reboot   db 'reboot', 0
cmd_shutdown db 'shutdown', 0
cmd_cd       db 'cd', 0
cmd_ls       db 'ls', 0
cmd_mem      db 'mem', 0
cmd_free     db 'free', 0
cmd_peek     db 'peek', 0
cmd_poke     db 'poke', 0
cmd_cat      db 'cat', 0
cmd_write    db 'write', 0
cmd_disk     db 'disk', 0
cmd_install  db 'install', 0
cmd_installer db 'installer', 0
cmd_unskyos  db 'unskyos', 0
cmd_memedit  db 'memedit', 0
cmd_vi       db 'vi', 0
cmd_imgview  db 'imgview', 0
cmd_audio    db 'audio', 0
cmd_beep     db 'beep', 0
cmd_bf       db 'bf', 0
cmd_ip       db 'ip', 0
cmd_a        db 'a', 0
cmd_addr     db 'addr', 0
cmd_ifconfig db 'ifconfig', 0
cmd_route    db 'route', 0
cmd_netstat  db 'netstat', 0
cmd_dhclient db 'dhclient', 0
cmd_resolvectl db 'resolvectl', 0
cmd_settings db 'settings', 0
cmd_Settings db 'Settings', 0
cmd_ping     db 'ping', 0
cmd_wget     db 'wget', 0
cmd_curl     db 'curl', 0
cmd_ssh      db 'ssh', 0
cmd_sftp     db 'sftp', 0
cmd_sapp     db 'sapp', 0
cmd_netctl   db 'netctl', 0
cmd_ss       db 'ss', 0
cmd_systemd  db 'systemd', 0
cmd_soj      db 'soj', 0
cmd_run      db 'run', 0
cmd_pwd      db 'pwd', 0
cmd_uname    db 'uname', 0
cmd_hostname db 'hostname', 0
cmd_whoami   db 'whoami', 0
cmd_id       db 'id', 0
cmd_date     db 'date', 0
cmd_timezone db 'timezone', 0
cmd_df       db 'df', 0
cmd_mount    db 'mount', 0
cmd_ps       db 'ps', 0
cmd_lspci    db 'lspci', 0
cmd_dmesg    db 'dmesg', 0
cmd_echo     db 'echo', 0
cmd_top      db 'top', 0
cmd_kill     db 'kill', 0
cmd_service  db 'service', 0
cmd_jobs     db 'jobs', 0
cmd_uptime   db 'uptime', 0
cmd_systemctl db 'systemctl', 0
cmd_sudo     db 'sudo', 0
cmd_su       db 'su', 0
cmd_man      db 'man', 0
cmd_which    db 'which', 0
cmd_type     db 'type', 0
cmd_whereis  db 'whereis', 0
cmd_poweroff db 'poweroff', 0
cmd_halt     db 'halt', 0
cmd_reset    db 'reset', 0
arg_dns      db 'dns', 0
arg_qemu     db 'qemu', 0
arg_net      db 'net', 0
arg_display  db 'display', 0
arg_test     db 'test', 0
arg_auto     db 'auto', 0
arg_1024x768 db '1024x768', 0
arg_1280x720 db '1280x720', 0
arg_on       db 'on', 0
arg_off      db 'off', 0
cmd_link     db 'link', 0
cmd_env      db 'env', 0
cmd_printenv db 'printenv', 0
cmd_export   db 'export', 0
cmd_set      db 'set', 0
cmd_unset    db 'unset', 0
cmd_bootinfo db 'bootinfo', 0
cmd_features db 'features', 0
cmd_proc     db 'proc', 0
cmd_ipc      db 'ipc', 0
cmd_fsinfo   db 'fsinfo', 0
cmd_security db 'security', 0
cmd_audit    db 'audit', 0
cmd_syscall  db 'syscall', 0
cmd_drivers  db 'drivers', 0
cmd_utils    db 'utils', 0
cmd_history  db 'history', 0
cmd_who      db 'who', 0
cmd_groups   db 'groups', 0
cmd_stat     db 'stat', 0
cmd_wc       db 'wc', 0
cmd_head     db 'head', 0
cmd_cp       db 'cp', 0
cmd_mv       db 'mv', 0
cmd_rm       db 'rm', 0
cmd_touch    db 'touch', 0
cmd_mkdir    db 'mkdir', 0
cmd_chmod    db 'chmod', 0
cmd_grep     db 'grep', 0
cmd_du       db 'du', 0
cmd_nano     db 'nano', 0
cmd_gcc      db 'gcc', 0
cmd_make     db 'make', 0
cmd_login    db 'login', 0
cmd_passwd   db 'passwd', 0
cmd_calc     db 'calc', 0
cmd_rand     db 'rand', 0
cmd_bigint   db 'bigint', 0
cmd_float    db 'float', 0
cmd_fault    db 'fault', 0
align 4
shell_builtin_cmd_table:
    dd cmd_help, cmd_man, cmd_sky, cmd_version, cmd_sysinfo, cmd_pwd, cmd_uname, cmd_hostname
    dd cmd_whoami, cmd_id, cmd_date, cmd_timezone, cmd_df, cmd_mount, cmd_ps, cmd_lspci
    dd cmd_dmesg, cmd_echo, cmd_env, cmd_set, cmd_printenv, cmd_export, cmd_unset, cmd_bootinfo
    dd cmd_features, cmd_proc, cmd_ipc, cmd_fsinfo, cmd_security, cmd_audit, cmd_syscall, cmd_drivers
    dd cmd_utils, cmd_history, cmd_who, cmd_groups, cmd_which, cmd_type, cmd_whereis, cmd_sudo
    dd cmd_su, cmd_top, cmd_jobs, cmd_kill, cmd_service, cmd_uptime, cmd_clear, cmd_color
    dd cmd_cursor, cmd_display, cmd_fbtest, cmd_gui, cmd_desktop, cmd_startx, cmd_reboot, cmd_reset
    dd cmd_shutdown, cmd_poweroff, cmd_halt
    dd cmd_cd, cmd_ls, cmd_mem, cmd_free, cmd_peek, cmd_poke, cmd_cat, cmd_write
    dd cmd_cp, cmd_mv, cmd_rm, cmd_touch, cmd_mkdir, cmd_chmod, cmd_stat, cmd_wc
    dd cmd_head, cmd_grep, cmd_du, cmd_disk, cmd_install, cmd_installer, cmd_unskyos, cmd_memedit
    dd cmd_vi, cmd_imgview, cmd_audio, cmd_beep, cmd_nano, cmd_gcc, cmd_make, cmd_ip
    dd cmd_ifconfig, cmd_route, cmd_netstat, cmd_dhclient, cmd_resolvectl, cmd_settings, cmd_Settings, cmd_ping
    dd cmd_wget, cmd_curl, cmd_ssh, cmd_sftp, cmd_sapp, cmd_netctl, cmd_ss, cmd_systemd
    dd cmd_systemctl, cmd_soj, cmd_run, cmd_bf, cmd_login, cmd_passwd
    dd 0
help_topic_system db 'system', 0
help_topic_fs db 'fs', 0
help_topic_disk db 'disk', 0
help_topic_net db 'net', 0
help_topic_dev db 'dev', 0
help_topic_script db 'script', 0
help_topic_pkg db 'pkg', 0
help_topic_power db 'power', 0
help_topic_all db 'all', 0
disk_arg_help db 'help', 0
disk_arg_part db 'part', 0
disk_arg_fs db 'fs', 0
disk_arg_mkfs db 'mkfs', 0
disk_arg_mount db 'mount', 0
disk_arg_install db 'install', 0
disk_arg_pread db 'pread', 0
disk_arg_pwrite db 'pwrite', 0
disk_arg_read db 'read', 0
disk_arg_write db 'write', 0
disk_arg_burn db 'burn', 0
disk_arg_mbr db 'mbr', 0
disk_arg_map db 'map', 0
disk_arg_verify db 'verify', 0
disk_arg_hexdump db 'hexdump', 0
disk_arg_phex db 'phex', 0
disk_arg_root db 'root', 0
disk_arg_select db 'select', 0
disk_arg_partition db 'partition', 0
disk_arg_format db 'format', 0
soj_kw_echo  db 'echo', 0
soj_kw_print db 'print', 0
soj_kw_set   db 'set', 0
soj_kw_if    db 'if', 0
soj_kw_then  db 'then', 0
soj_kw_exec  db 'exec', 0
soj_kw_exit  db 'exit', 0
soj_kw_label db 'label', 0
soj_kw_goto  db 'goto', 0
soj_kw_inc   db 'inc', 0
soj_kw_dec   db 'dec', 0
soj_kw_input db 'input', 0
soj_op_eq    db '==', 0
soj_op_ne    db '!=', 0
sapp_update  db 'update', 0
sapp_search  db 'search', 0
sapp_list    db 'list', 0
sapp_install db 'install', 0
sapp_remove  db 'remove', 0
sapp_files   db 'files', 0
sapp_info    db 'info', 0
sapp_run     db 'run', 0
sapp_source  db 'source', 0
systemd_list db 'list', 0
systemd_status db 'status', 0
systemd_start db 'start', 0
systemd_stop db 'stop', 0
unit_network db 'network.service', 0
unit_tcpip db 'tcpip.service', 0
unit_https db 'https.service', 0
unit_sapp db 'sapp.service', 0
unit_ssh db 'ssh.service', 0
unit_sftp db 'sftp.service', 0
name_root   db '/', 0
name_parent db '..', 0
name_current db '.', 0
name_dash   db '-', 0
name_tilde  db '~', 0
name_bin    db 'bin', 0
name_etc    db 'etc', 0
name_home   db 'home', 0
name_dev    db 'dev', 0
name_note   db 'note', 0
name_demo_soj db 'demo.soj', 0
name_script_soj db 'script.soj', 0
name_logo_png db 'logo.png', 0
name_photo_jpg db 'photo.jpg', 0
name_sky    db 'sky.txt', 0
name_conf   db 'skyos.conf', 0
name_sources db 'sources.list', 0
path_sapp_sources db '/etc/sapp/sources.list', 0
path_usr_bin_calc db '/usr/bin/calc', 0
path_mnt_disk0_prefix db '/mnt/disk0/', 0
url_http_prefix db 'http://', 0
url_https_prefix db 'https://', 0
domain_skyapps db 'skyapps.skyu.cc.cd', 0
path_skyfs_os_release db '/etc/os-release', 0
path_skyfs_init db '/sbin/init', 0
path_skyfs_skysh db '/bin/skysh', 0
path_skyfs_passwd db '/etc/passwd', 0
path_skyfs_shadow db '/etc/shadow', 0
path_skyfs_sudoers db '/etc/sudoers', 0
path_skyfs_loader db '/boot/loader.conf', 0
path_skyfs_sources db '/etc/sapp/sources.list', 0
path_demo_soj db '/home/demo.soj', 0
path_script_soj db '/home/script.soj', 0
path_logo_png db '/home/logo.png', 0
path_photo_jpg db '/home/photo.jpg', 0
path_dot_demo_soj db './demo.soj', 0
path_dot_script_soj db './script.soj', 0
path_dot_logo_png db './logo.png', 0
path_dot_photo_jpg db './photo.jpg', 0
path_home_note db '/home/note', 0
path_home_sky db '/sky.txt', 0
path_etc_conf db '/etc/skyos.conf', 0
path_bin    db '/bin', 0
path_etc    db '/etc', 0
path_home   db '/home', 0
path_dev    db '/dev', 0
domain_localhost db 'localhost', 0
timezone_set_arg db 'set', 0
tz_utc db 'UTC', 0

hex_prefix db '0x', 0
hex_digits db '0123456789ABCDEF'
net_broadcast_mac db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF

align 4
hd_mbr_template:
    incbin "build/hdboot.bin"
hd_mbr_template_end:

align 4
hd_stage2_blob:
    incbin "build/hdstage2.bin"
hd_stage2_blob_end:

scancode_lower:
    db 0, 0, '1', '2', '3', '4', '5', '6'
    db '7', '8', '9', '0', '-', '=', 8, 9
    db 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'
    db 'o', 'p', '[', ']', 13, 0, 'a', 's'
    db 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';'
    db 39, '`', 0, 92, 'z', 'x', 'c', 'v'
    db 'b', 'n', 'm', ',', '.', '/', 0, '*'
    db 0, ' ', 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, '7'
    db '8', '9', '-', '4', '5', '6', '+', '1'
    db '2', '3', '0', '.', 0
    times 41 db 0

scancode_shift:
    db 0, 0, '!', '@', '#', '$', '%', '^'
    db '&', '*', '(', ')', '_', '+', 8, 9
    db 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'
    db 'O', 'P', '{', '}', 13, 0, 'A', 'S'
    db 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':'
    db '"', '~', 0, '|', 'Z', 'X', 'C', 'V'
    db 'B', 'N', 'M', '<', '>', '?', 0, '*'
    db 0, ' ', 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, '7'
    db '8', '9', '-', '4', '5', '6', '+', '1'
    db '2', '3', '0', '.', 0
    times 41 db 0

section .text
global _start

_start:
    mov esp, stack_top
    call init_interrupts
    cmp eax, 0x2BADB002
    je .multiboot_entry
    cmp eax, 0
    jne .check_install
    cmp ebx, 0
    je .check_install
    cmp ebx, 512
    ja .check_install
    mov [boot_kernel_cd_sectors], ebx
.check_install:
    cmp eax, SKYOS_INSTALL_MAGIC
    jne .normal_boot
    mov byte [boot_mode_install], 1
    mov [boot_kernel_cd_sectors], ebx
    xor eax, eax
    xor ebx, ebx
.normal_boot:
    mov [mb_magic], eax
    mov [mb_info_addr], ebx
    jmp .entry_ready
.multiboot_entry:
    mov [mb_magic], eax
    mov [mb_info_addr], ebx
    test ebx, ebx
    jz .entry_ready
    mov edx, [ebx]
    test edx, 1 << 2
    jz .entry_ready
    mov esi, [ebx + 16]
    test esi, esi
    jz .entry_ready
    cmp dword [esi], SKYOS_CDINFO_MAGIC
    jne .entry_ready
    cmp dword [esi + 4], SKYOS_INSTALL_MAGIC
    jne .check_cd_sectors
    mov byte [boot_mode_install], 1
.check_cd_sectors:
    mov edx, [esi + 8]
    cmp edx, 0
    je .entry_ready
    cmp edx, 512
    ja .entry_ready
    mov [boot_kernel_cd_sectors], edx
    mov edx, [esi + 12]
    test edx, edx
    jz .entry_ready
    mov [fb_font_ptr], edx
    mov edx, [esi + 16]
    cmp edx, 8
    je .store_font_height
    cmp edx, 16
    jne .entry_ready
.store_font_height:
    mov [fb_font_height], edx
.entry_ready:
    call init_framebuffer

    call clear_screen
    call boot_animation
    call clear_screen
    call show_home_screen
    cmp byte [boot_mode_install], 1
    jne shell_loop
    mov dword [current_uid], 0
    mov dword [current_gid], 0
    call command_install
    jmp shell_loop

shell_loop:
.prompt:
    call net_poll_rx_burst
    call prepare_prompt_line
    call print_prompt
    call read_line
    call execute_command
    jmp shell_loop

halt_forever:
    cli
    hlt
    jmp halt_forever

init_interrupts:
    pushad
    cli
    mov edi, idt_table
    xor eax, eax
    mov ecx, (256 * 8) / 4
    rep stosd

    xor ecx, ecx
.fault_idt_loop:
    cmp ecx, 32
    jae .fault_idt_done
    mov edi, idt_table
    mov eax, ecx
    shl eax, 3
    add edi, eax
    mov eax, cpu_exception_handler
    mov [edi], ax
    mov ax, cs
    mov [edi + 2], ax
    mov byte [edi + 4], 0
    mov byte [edi + 5], 0x8E
    mov eax, cpu_exception_handler
    shr eax, 16
    mov [edi + 6], ax
    inc ecx
    jmp .fault_idt_loop
.fault_idt_done:

    mov edi, idt_table + (0x21 * 8)
    mov eax, keyboard_irq_handler
    mov [edi], ax
    mov ax, cs
    mov [edi + 2], ax
    mov byte [edi + 4], 0
    mov byte [edi + 5], 0x8E
    mov eax, keyboard_irq_handler
    shr eax, 16
    mov [edi + 6], ax

    mov edi, idt_table + (0x2C * 8)
    mov eax, mouse_irq_handler
    mov [edi], ax
    mov ax, cs
    mov [edi + 2], ax
    mov byte [edi + 4], 0
    mov byte [edi + 5], 0x8E
    mov eax, mouse_irq_handler
    shr eax, 16
    mov [edi + 6], ax

    lidt [idt_descriptor]
    call pic_init_keyboard_mouse
    call kbd_flush_controller
    call ps2_init_mouse
    mov dword [kbd_ring_head], 0
    mov dword [kbd_ring_tail], 0
    mov byte [kbd_irq_enabled], 1
    sti
    popad
    ret

pic_init_keyboard_mouse:
    push eax
    mov al, 0x11
    out 0x20, al
    call pic_io_wait
    out 0xA0, al
    call pic_io_wait
    mov al, 0x20
    out 0x21, al
    call pic_io_wait
    mov al, 0x28
    out 0xA1, al
    call pic_io_wait
    mov al, 0x04
    out 0x21, al
    call pic_io_wait
    mov al, 0x02
    out 0xA1, al
    call pic_io_wait
    mov al, 0x01
    out 0x21, al
    call pic_io_wait
    out 0xA1, al
    call pic_io_wait
    mov al, 0xF9
    out 0x21, al
    mov al, 0xEF
    out 0xA1, al
    pop eax
    ret

pic_io_wait:
    push eax
    xor al, al
    out 0x80, al
    pop eax
    ret

kbd_flush_controller:
    push eax
    push ecx
    mov ecx, 32
.loop:
    in al, 0x64
    test al, 1
    jz .done
    in al, 0x60
    loop .loop
.done:
    pop ecx
    pop eax
    ret

ps2_wait_input_clear:
    push ecx
    mov ecx, 100000
.loop:
    in al, 0x64
    test al, 2
    jz .done
    loop .loop
.done:
    pop ecx
    ret

ps2_read_data_timeout:
    push ecx
    mov ecx, 100000
.loop:
    in al, 0x64
    test al, 1
    jnz .read
    loop .loop
    xor al, al
    pop ecx
    ret
.read:
    in al, 0x60
    pop ecx
    ret

ps2_write_command:
    push edx
    mov dl, al
    call ps2_wait_input_clear
    mov al, dl
    out 0x64, al
    call pic_io_wait
    pop edx
    ret

ps2_write_data:
    push edx
    mov dl, al
    call ps2_wait_input_clear
    mov al, dl
    out 0x60, al
    call pic_io_wait
    pop edx
    ret

ps2_write_mouse_command:
    push edx
    mov dl, al
    mov al, 0xD4
    call ps2_write_command
    mov al, dl
    call ps2_write_data
    call ps2_read_data_timeout
    pop edx
    ret

ps2_init_mouse:
    pushad
    mov byte [mouse_irq_enabled], 0
    mov byte [mouse_packet_index], 0
    mov byte [mouse_buttons], 0
    mov byte [mouse_event_pending], 0
    mov al, 0xA8
    call ps2_write_command
    mov al, 0x20
    call ps2_write_command
    call ps2_read_data_timeout
    or al, 0x03
    and al, 0xDF
    mov bl, al
    mov al, 0x60
    call ps2_write_command
    mov al, bl
    call ps2_write_data
    mov al, 0xF6
    call ps2_write_mouse_command
    mov al, 0xF4
    call ps2_write_mouse_command
    mov byte [mouse_irq_enabled], 1
    popad
    ret

mouse_handle_byte:
    pushad
    mov bl, [mouse_packet_index]
    cmp bl, 0
    jne .byte1
    test al, 0x08
    jz .done
    mov [mouse_packet0], al
    mov byte [mouse_packet_index], 1
    jmp .done
.byte1:
    cmp bl, 1
    jne .byte2
    mov [mouse_packet1], al
    mov byte [mouse_packet_index], 2
    jmp .done
.byte2:
    mov [mouse_packet2], al
    mov byte [mouse_packet_index], 0
    mov al, [mouse_packet0]
    and al, 7
    mov [mouse_buttons], al

    movsx eax, byte [mouse_packet1]
    mov ebx, [mouse_x]
    add ebx, eax
    cmp ebx, 0
    jge .x_nonnegative
    xor ebx, ebx
.x_nonnegative:
    mov ecx, [fb_width]
    test ecx, ecx
    jnz .x_have_width
    mov ecx, 1024
.x_have_width:
    dec ecx
    cmp ebx, ecx
    jle .x_store
    mov ebx, ecx
.x_store:
    mov [mouse_x], ebx

    movsx eax, byte [mouse_packet2]
    mov ebx, [mouse_y]
    sub ebx, eax
    cmp ebx, 0
    jge .y_nonnegative
    xor ebx, ebx
.y_nonnegative:
    mov ecx, [fb_height]
    test ecx, ecx
    jnz .y_have_height
    mov ecx, 768
.y_have_height:
    dec ecx
    cmp ebx, ecx
    jle .y_store
    mov ebx, ecx
.y_store:
    mov [mouse_y], ebx
    mov byte [mouse_event_pending], 1
.done:
    popad
    ret

keyboard_irq_handler:
    pushad
    push ds
    push es
    mov ax, ss
    mov ds, ax
    mov es, ax
.read_more:
    in al, 0x64
    test al, 1
    jz .eoi
    mov ah, al
    in al, 0x60
    test ah, 0x20
    jz .keyboard_byte
    call mouse_handle_byte
    jmp .read_more
.keyboard_byte:
    mov bl, al
    mov eax, [kbd_ring_head]
    mov edx, eax
    inc edx
    and edx, KBD_RING_MASK
    cmp edx, [kbd_ring_tail]
    je .drop
    mov edi, kbd_ring
    add edi, eax
    mov [edi], bl
    mov [kbd_ring_head], edx
.drop:
    jmp .read_more
.eoi:
    mov al, 0x20
    out 0x20, al
    pop es
    pop ds
    popad
    iretd

mouse_irq_handler:
    pushad
    push ds
    push es
    mov ax, ss
    mov ds, ax
    mov es, ax
.read_more:
    in al, 0x64
    test al, 1
    jz .eoi
    test al, 0x20
    jz .eoi
    in al, 0x60
    call mouse_handle_byte
    jmp .read_more
.eoi:
    mov al, 0x20
    out 0xA0, al
    out 0x20, al
    pop es
    pop ds
    popad
    iretd

cpu_exception_handler:
    cli
    pushad
    mov esi, msg_exception_prefix
    call print_string
    mov eax, 0
    call print_dec32
    call console_newline
.halt:
    hlt
    jmp .halt

boot_animation:
    call clear_screen
    mov esi, boot_banner
    call print_line
    call console_newline
    call boot_run_registry
    mov esi, boot_status_ready
    call print_boot_ok
    ret

boot_run_registry:
    pushad
    mov edi, boot_registry
.next:
    mov esi, [edi]
    test esi, esi
    jz .done
    push edi
    push esi
    call dword [edi + 8]
    pop esi
    call print_boot_ok
    pop edi
    add edi, 12
    jmp .next
.done:
    popad
    ret

boot_init_noop:
    ret

init_framebuffer:
    pushad
    mov byte [fb_available], 0
    mov byte [fb_vbe_available], 0
    cmp dword [mb_magic], 0x2BADB002
    jne .done
    mov ebx, [mb_info_addr]
    test ebx, ebx
    jz .done
    mov eax, [ebx]
    test eax, 1 << 11
    jz .check_fb
    mov byte [fb_vbe_available], 1
.check_fb:
    test eax, 1 << 12
    jz .done
    mov eax, [ebx + 88]
    test eax, eax
    jz .done
    mov [fb_addr_low], eax
    mov eax, [ebx + 92]
    mov [fb_addr_high], eax
    mov eax, [ebx + 96]
    mov [fb_pitch], eax
    mov eax, [ebx + 100]
    mov [fb_width], eax
    mov eax, [ebx + 104]
    mov [fb_height], eax
    mov al, [ebx + 108]
    mov [fb_bpp], al
    mov al, [ebx + 109]
    mov [fb_type], al
    cmp byte [fb_bpp], 32
    jne .done
    cmp byte [fb_type], 2
    je .type_ok
    cmp byte [fb_type], 1
    jne .done
.type_ok:
    cmp dword [fb_font_ptr], 0
    jne .font_ready
    mov dword [fb_font_ptr], 0x000FFA6E
    mov dword [fb_font_height], 16
.font_ready:
    mov byte [fb_available], 1
    call fb_update_geometry
    call fb_init_text_layer
.done:
    popad
    ret

boot_draw_screen:
    pushad
    mov ebx, 5
    mov al, 0x0F
    call vi_clear_row
    mov ebx, 6
    mov al, 0x0F
    call vi_clear_row
    mov ebx, 7
    mov al, 0x0F
    call vi_clear_row
    mov ebx, 8
    mov al, 0x0F
    call vi_clear_row
    mov ebx, 9
    mov al, 0x0F
    call vi_clear_row
    mov ebx, 10
    mov al, 0x0F
    call vi_clear_row
    mov ebx, 12
    mov al, 0x0F
    call vi_clear_row
    mov al, 0x0B
    call set_color
    mov eax, 29
    mov ebx, 5
    call set_cursor
    mov esi, boot_logo_line1
    call print_string
    mov eax, 29
    mov ebx, 6
    call set_cursor
    mov esi, boot_logo_line2
    call print_string
    mov eax, 29
    mov ebx, 7
    call set_cursor
    mov esi, boot_logo_line3
    call print_string
    mov eax, 29
    mov ebx, 8
    call set_cursor
    mov esi, boot_logo_line4
    call print_string
    mov eax, 29
    mov ebx, 9
    call set_cursor
    mov esi, boot_logo_line5
    call print_string
    mov al, 0x09
    call set_color
    mov eax, 29
    mov ebx, 10
    call set_cursor
    mov esi, boot_logo_line6
    call print_string
    mov al, 0x0F
    call set_color
    mov eax, 29
    mov ebx, 12
    call set_cursor
    mov esi, [boot_orbit_ptr]
    call print_string
    call boot_draw_bottom
    popad
    ret

boot_draw_bottom:
    pushad
    mov ebx, 21
    mov al, 0x0F
    call vi_clear_row
    mov ebx, 22
    mov al, 0x0F
    call vi_clear_row
    mov ebx, 23
    mov al, 0x0F
    call vi_clear_row
    mov eax, 2
    mov ebx, 21
    call set_cursor
    mov al, 0x0A
    call set_color
    mov esi, boot_bottom_phase
    call print_string
    mov al, 0x0F
    call set_color
    mov esi, [boot_phase_ptr]
    call print_string
    mov eax, 2
    mov ebx, 22
    call set_cursor
    mov al, 0x0E
    call set_color
    mov esi, boot_bottom_status
    call print_string
    mov al, 0x0F
    call set_color
    mov esi, [boot_status_ptr]
    call print_string
    mov eax, 2
    mov ebx, 23
    call set_cursor
    mov al, 0x0B
    call set_color
    mov esi, boot_bottom_services
    call print_string
    mov al, 0x0F
    call set_color
    mov esi, boot_services_text
    cmp dword [boot_phase_ptr], boot_phase_done
    jne .print
    mov esi, boot_services_ready
.print:
    call print_string
    popad
    ret

show_home_screen:
    mov esi, home_title
    call print_line
    call console_newline
    mov esi, home_doc
    call print_line
    mov esi, home_manage
    call print_line
    mov esi, home_support
    call print_line
    call console_newline
    mov esi, home_min_1
    call print_line
    mov esi, home_min_2
    call print_line
    call console_newline
    mov esi, home_restore
    call print_line
    call console_newline
    mov esi, home_last_login
    call print_string
    call print_motd_login_time
    mov esi, home_last_login_tail
    call print_line
    call console_newline
    ret

shutdown_animation:
    call clear_screen
    mov al, 0x0F
    call set_color
    mov esi, shutdown_banner
    call print_line
    call console_newline
    mov esi, shutdown_step_01
    call print_boot_ok
    mov esi, shutdown_step_02
    call print_boot_ok
    mov esi, shutdown_step_03
    call print_boot_ok
    mov esi, shutdown_step_04
    call print_boot_ok
    mov esi, shutdown_step_05
    call print_boot_ok
    call console_newline
    ret

print_boot_ok:
    push esi
    mov al, 0x0A
    call set_color
    mov esi, boot_ok
    call print_string
    mov al, 0x0F
    call set_color
    pop esi
    call print_line
    ret

clear_screen:
    pushad
    cmp byte [fb_available], 1
    jne .vga
    mov byte [fb_cursor_visible], 0
    call fb_clear_console_text
    call fb_flush_dirty
    mov dword [cursor_x], 0
    mov dword [cursor_y], 0
    call update_cursor
    popad
    ret
.vga:
    mov edi, 0xB8000
    mov ecx, 80 * 25
    mov ax, 0x0F20
    rep stosw
    mov dword [cursor_x], 0
    mov dword [cursor_y], 0
    call update_cursor
    popad
    ret

console_newline:
    pushad
    call fb_cursor_hide
    mov dword [cursor_x], 0
    inc dword [cursor_y]
    call scroll_if_needed
    call update_cursor
    cmp byte [fb_available], 1
    jne .no_flush
    call fb_flush_dirty
.no_flush:
    popad
    ret

console_putc:
    pushad
    push eax
    call fb_cursor_hide
    pop eax
    cmp al, 10
    je .newline
    cmp al, 13
    je .newline

    cmp byte [fb_available], 1
    jne .vga_char
    mov bl, al
    call fb_putc_raw
    jmp .advance

.vga_char:
    movzx ebx, al
    mov eax, [cursor_y]
    mov ecx, 80
    mul ecx
    add eax, [cursor_x]
    shl eax, 1
    mov edi, 0xB8000
    add edi, eax
    mov al, bl
    mov ah, [text_attr]
    mov [edi], ax

.advance:
    inc dword [cursor_x]
    mov eax, [console_cols]
    cmp [cursor_x], eax
    jb .done
    mov dword [cursor_x], 0
    inc dword [cursor_y]
    call scroll_if_needed
    jmp .done

.newline:
    mov dword [cursor_x], 0
    inc dword [cursor_y]
    call scroll_if_needed

.done:
    call update_cursor
    popad
    ret

console_backspace:
    pushad
    call fb_cursor_hide
    cmp dword [cursor_x], 0
    je .done
    dec dword [cursor_x]

    cmp byte [fb_available], 1
    jne .vga
    mov bl, ' '
    call fb_putc_raw
    jmp .done

.vga:
    mov eax, [cursor_y]
    mov ecx, 80
    mul ecx
    add eax, [cursor_x]
    shl eax, 1
    mov edi, 0xB8000
    add edi, eax
    mov ax, 0x0F20
    mov [edi], ax

.done:
    call update_cursor
    popad
    ret

scroll_if_needed:
    mov eax, [console_rows]
    cmp [cursor_y], eax
    jb .done

    cmp byte [fb_available], 1
    jne .vga
    call fb_scroll
    mov eax, [console_rows]
    dec eax
    mov [cursor_y], eax
    jmp .done

.vga:
    mov esi, 0xB8000 + 160
    mov edi, 0xB8000
    mov ecx, 80 * 24
    rep movsw

    mov edi, 0xB8000 + (80 * 24 * 2)
    mov ecx, 80
    mov ax, 0x0F20
    rep stosw
    mov eax, [console_rows]
    dec eax
    mov [cursor_y], eax

.done:
    ret

update_cursor:
    cmp byte [fb_available], 1
    je .done
    push eax
    push ebx
    push edx

    mov eax, [cursor_y]
    mov ebx, 80
    mul ebx
    add eax, [cursor_x]
    mov bx, ax

    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    mov dx, 0x3D5
    mov al, bl
    out dx, al

    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al
    mov dx, 0x3D5
    mov al, bh
    out dx, al

    pop edx
    pop ebx
    pop eax
.done:
    ret

fb_cursor_tick:
    cmp byte [fb_available], 1
    jne .done
    in al, 0x64
    test al, 1
    jnz .done
    inc dword [fb_cursor_ticks]
    mov eax, [fb_cursor_ticks]
    and eax, 0x0007FFFF
    jnz .done
    cmp byte [fb_cursor_visible], 1
    je fb_cursor_hide
    jmp fb_cursor_show
.done:
    ret

fb_cursor_hide:
    cmp byte [fb_available], 1
    jne .done
    cmp byte [fb_cursor_visible], 1
    jne .done
    push eax
    push ebx
    mov eax, [fb_cursor_draw_x]
    mov ebx, [fb_cursor_draw_y]
    call fb_mark_cell_dirty_xy
    mov byte [fb_cursor_visible], 0
    call fb_flush_dirty
    pop ebx
    pop eax
.done:
    ret

fb_cursor_show:
    cmp byte [fb_available], 1
    jne .done
    cmp byte [fb_cursor_visible], 1
    jne .draw
    mov eax, [fb_cursor_draw_x]
    cmp eax, [cursor_x]
    jne .move
    mov eax, [fb_cursor_draw_y]
    cmp eax, [cursor_y]
    jne .move
    cmp byte [fb_dirty_any], 1
    jne .done
    call fb_cursor_hide
    jmp .draw
.move:
    call fb_cursor_hide
.draw:
    call fb_flush_dirty
    mov eax, [cursor_x]
    mov [fb_cursor_draw_x], eax
    mov eax, [cursor_y]
    mov [fb_cursor_draw_y], eax
    mov dword [fb_cursor_ticks], 0
    mov eax, 1
    call fb_draw_cursor_bar
    mov byte [fb_cursor_visible], 1
.done:
    ret

fb_draw_cursor_bar:
    pushad
    mov eax, [fb_cursor_draw_y]
    imul eax, [fb_text_row_height]
    add eax, [fb_origin_y]
    mov ebx, [fb_text_row_height]
    cmp ebx, 2
    jbe .bar_top
    sub ebx, 2
    add eax, ebx
.bar_top:
    mov ebx, [fb_pitch]
    mul ebx
    mov edi, [fb_addr_low]
    add edi, eax
    mov eax, [fb_origin_x]
    shl eax, 2
    add edi, eax
    mov eax, [fb_cursor_draw_x]
    shl eax, 5
    imul eax, [fb_char_scale_x]
    add edi, eax
    mov edx, 2
.row:
    push edi
    mov ecx, 8
    imul ecx, [fb_char_scale_x]
.pixel:
    xor dword [edi], 0x00FFFFFF
    add edi, 4
    loop .pixel
    pop edi
    add edi, [fb_pitch]
    dec edx
    jnz .row
    popad
    ret

fb_attr_to_rgb:
    push ebx
    mov bl, al
    and bl, 0x0F
    xor eax, eax
    cmp bl, 0
    je .done
    cmp bl, 1
    je .blue
    cmp bl, 2
    je .green
    cmp bl, 3
    je .cyan
    cmp bl, 4
    je .red
    cmp bl, 5
    je .magenta
    cmp bl, 6
    je .brown
    cmp bl, 7
    je .light_gray
    cmp bl, 8
    je .dark_gray
    cmp bl, 9
    je .light_blue
    cmp bl, 10
    je .light_green
    cmp bl, 11
    je .light_cyan
    cmp bl, 12
    je .light_red
    cmp bl, 13
    je .light_magenta
    cmp bl, 14
    je .yellow
    mov eax, 0x00FFFFFF
    jmp .done
.blue:
    mov eax, 0x000000AA
    jmp .done
.green:
    mov eax, 0x0000AA00
    jmp .done
.cyan:
    mov eax, 0x0000AAAA
    jmp .done
.red:
    mov eax, 0x00AA0000
    jmp .done
.magenta:
    mov eax, 0x00AA00AA
    jmp .done
.brown:
    mov eax, 0x00AA5500
    jmp .done
.light_gray:
    mov eax, 0x00AAAAAA
    jmp .done
.dark_gray:
    mov eax, 0x00555555
    jmp .done
.light_blue:
    mov eax, 0x005555FF
    jmp .done
.light_green:
    mov eax, 0x0055FF55
    jmp .done
.light_cyan:
    mov eax, 0x0055FFFF
    jmp .done
.light_red:
    mov eax, 0x00FF5555
    jmp .done
.light_magenta:
    mov eax, 0x00FF55FF
    jmp .done
.yellow:
    mov eax, 0x00FFFF55
.done:
    pop ebx
    ret

fb_clear_screen:
    pushad
    mov edi, [fb_addr_low]
    mov eax, 0x00000000
    mov ecx, [fb_pitch]
    imul ecx, [fb_height]
    shr ecx, 2
    rep stosd
    popad
    ret

fb_clear_console_text:
    pushad
    mov eax, [console_cols]
    imul eax, [console_rows]
    mov edi, fb_text_chars
    mov ecx, eax
    mov al, ' '
    rep stosb
    mov eax, [console_cols]
    imul eax, [console_rows]
    mov edi, fb_text_attrs
    mov ecx, eax
    mov al, [text_attr]
    rep stosb
    call fb_mark_all_dirty
.done:
    popad
    ret

fb_init_text_layer:
    pushad
    call fb_cache_glyphs
    call fb_clear_screen
    call fb_clear_console_text
    popad
    ret

fb_cache_glyphs:
    pushad
    mov edi, fb_glyph_cache
    xor eax, eax
    mov ecx, (256 * FB_GLYPH_STRIDE) / 4
    rep stosd
    mov esi, [fb_font_ptr]
    test esi, esi
    jz .done
    xor ebx, ebx
.glyph_loop:
    cmp ebx, 256
    jae .done
    mov edi, fb_glyph_cache
    mov eax, ebx
    shl eax, 4
    add edi, eax
    mov ecx, [fb_font_height]
    cmp ecx, FB_GLYPH_STRIDE
    jbe .rows_ok
    mov ecx, FB_GLYPH_STRIDE
.rows_ok:
    test ecx, ecx
    jz .next_glyph
    rep movsb
.next_glyph:
    inc ebx
    jmp .glyph_loop
.done:
    popad
    ret

fb_update_geometry:
    pushad
    cmp byte [fb_available], 1
    jne .vga
    mov dword [fb_font_height], 16
    mov dword [fb_char_scale_x], 1
    mov dword [fb_char_scale_y], 1
    mov dword [fb_text_row_height], 16

    mov eax, [fb_width]
    shr eax, 3
    cmp eax, 80
    jae .cols_min_ok
    mov eax, 80
.cols_min_ok:
    cmp eax, FB_TEXT_MAX_COLS
    jbe .cols_cap_ok
    mov eax, FB_TEXT_MAX_COLS
.cols_cap_ok:
    mov [console_cols], eax

    mov eax, [fb_height]
    shr eax, 4
    cmp eax, 25
    jae .rows_min_ok
    mov eax, 25
.rows_min_ok:
    cmp eax, FB_TEXT_MAX_ROWS
    jbe .rows_cap_ok
    mov eax, FB_TEXT_MAX_ROWS
.rows_cap_ok:
    mov [console_rows], eax

    mov eax, [console_cols]
    shl eax, 5
    mov [fb_text_width_bytes], eax
    shr eax, 2
    mov ebx, [fb_width]
    cmp ebx, eax
    jbe .origin_x_zero
    sub ebx, eax
    shr ebx, 1
    mov [fb_origin_x], ebx
    jmp .origin_y
.origin_x_zero:
    mov dword [fb_origin_x], 0
.origin_y:
    mov eax, [console_rows]
    shl eax, 4
    mov ebx, [fb_height]
    cmp ebx, eax
    jbe .origin_y_zero
    sub ebx, eax
    shr ebx, 1
    mov [fb_origin_y], ebx
    jmp .done
.origin_y_zero:
    mov dword [fb_origin_y], 0
    jmp .done
.vga:
    mov dword [console_cols], 80
    mov dword [console_rows], 25
    mov dword [fb_char_scale_x], 1
    mov dword [fb_char_scale_y], 1
    mov dword [fb_origin_x], 0
    mov dword [fb_origin_y], 0
    mov dword [fb_text_width_bytes], 2560
    mov dword [fb_text_row_height], 16
.done:
    popad
    ret

fb_putc_raw:
    pushad
    mov dl, bl
    mov eax, [cursor_x]
    cmp eax, [console_cols]
    jae .done
    mov ebx, [cursor_y]
    cmp ebx, [console_rows]
    jae .done
    imul ebx, [console_cols]
    add ebx, eax
    mov [fb_text_chars + ebx], dl
    mov dl, [text_attr]
    mov [fb_text_attrs + ebx], dl
    mov byte [fb_dirty_cells + ebx], 1
    mov byte [fb_dirty_any], 1
.done:
    popad
    ret

fb_clear_text_row:
    pushad
    cmp ebx, [console_rows]
    jae .done
    mov edx, ebx
    imul edx, [console_cols]
    mov edi, fb_text_chars
    add edi, edx
    mov ecx, [console_cols]
    mov al, ' '
    rep stosb
    mov edi, fb_text_attrs
    add edi, edx
    mov ecx, [console_cols]
    mov al, [text_attr]
    rep stosb
    mov edi, fb_dirty_cells
    add edi, edx
    mov ecx, [console_cols]
    mov al, 1
    rep stosb
    mov byte [fb_dirty_any], 1
.done:
    popad
    ret

fb_clear_text_from:
    pushad
    mov esi, eax
    cmp ebx, [console_rows]
    jae .done
    cmp esi, [console_cols]
    jae .done
    mov edx, ebx
    imul edx, [console_cols]
    add edx, esi
    mov eax, [console_cols]
    sub eax, esi
    mov ebp, eax
    mov edi, fb_text_chars
    add edi, edx
    mov ecx, ebp
    mov al, ' '
    rep stosb
    mov edi, fb_text_attrs
    add edi, edx
    mov ecx, ebp
    mov al, [text_attr]
    rep stosb
    mov edi, fb_dirty_cells
    add edi, edx
    mov ecx, ebp
    mov al, 1
    rep stosb
    mov byte [fb_dirty_any], 1
.done:
    popad
    ret

fb_scroll:
    pushad
    mov esi, fb_text_chars
    add esi, [console_cols]
    mov edi, fb_text_chars
    mov ecx, [console_rows]
    dec ecx
    imul ecx, [console_cols]
    rep movsb
    mov esi, fb_text_attrs
    add esi, [console_cols]
    mov edi, fb_text_attrs
    mov ecx, [console_rows]
    dec ecx
    imul ecx, [console_cols]
    rep movsb
    mov ebx, [console_rows]
    dec ebx
    call fb_clear_text_row
    call fb_mark_all_dirty
    popad
    ret

fb_mark_all_dirty:
    pushad
    mov edi, fb_dirty_cells
    mov ecx, [console_cols]
    imul ecx, [console_rows]
    mov al, 1
    rep stosb
    mov byte [fb_dirty_any], 1
    popad
    ret

fb_mark_cell_dirty_xy:
    pushad
    cmp eax, [console_cols]
    jae .done
    cmp ebx, [console_rows]
    jae .done
    imul ebx, [console_cols]
    add ebx, eax
    mov byte [fb_dirty_cells + ebx], 1
    mov byte [fb_dirty_any], 1
.done:
    popad
    ret

fb_flush_dirty:
    pushad
    cmp byte [fb_available], 1
    jne .done
    cmp byte [fb_dirty_any], 1
    jne .done
    cmp byte [fb_cursor_visible], 1
    jne .scan
    mov eax, [fb_cursor_draw_x]
    mov ebx, [fb_cursor_draw_y]
    call fb_mark_cell_dirty_xy
    mov byte [fb_cursor_visible], 0
.scan:
    mov esi, fb_dirty_cells
    xor ebx, ebx
.row_loop:
    cmp ebx, [console_rows]
    jae .finish
    xor edx, edx
.col_loop:
    cmp edx, [console_cols]
    jae .next_row
    cmp byte [esi], 0
    je .skip_cell
    mov byte [esi], 0
    push esi
    push ebx
    push edx
    mov eax, edx
    call fb_draw_cell_xy
    pop edx
    pop ebx
    pop esi
.skip_cell:
    inc esi
    inc edx
    jmp .col_loop
.next_row:
    inc ebx
    jmp .row_loop
.finish:
    mov byte [fb_dirty_any], 0
.done:
    popad
    ret

fb_draw_cell_xy:
    pushad
    cmp eax, [console_cols]
    jae .done
    cmp ebx, [console_rows]
    jae .done
    mov esi, ebx
    imul esi, [console_cols]
    add esi, eax
    mov dl, [fb_text_chars + esi]
    mov [fb_draw_char], dl
    mov dl, [fb_text_attrs + esi]
    mov [fb_draw_attr], dl
    mov al, [fb_draw_attr]
    call fb_attr_to_rgb
    mov [fb_fg_color], eax
    mov al, [fb_draw_attr]
    shr al, 4
    call fb_attr_to_rgb
    mov [fb_bg_color], eax

    mov eax, [esp + 16]
    imul eax, [fb_text_row_height]
    add eax, [fb_origin_y]
    mov ebx, [fb_pitch]
    mul ebx
    mov edi, [fb_addr_low]
    add edi, eax
    mov eax, [fb_origin_x]
    shl eax, 2
    add edi, eax
    mov eax, [esp + 28]
    shl eax, 5
    imul eax, [fb_char_scale_x]
    add edi, eax

    movzx eax, byte [fb_draw_char]
    shl eax, 4
    mov ebx, fb_glyph_cache
    add ebx, eax
    mov ecx, [fb_font_height]
    cmp ecx, FB_GLYPH_STRIDE
    jbe .height_ok
    mov ecx, FB_GLYPH_STRIDE
.height_ok:
    test ecx, ecx
    jz .done
.draw_row:
    push ecx
    mov al, [ebx]
    inc ebx
    mov [fb_glyph_bits], al
    mov esi, edi
    mov ebp, [fb_char_scale_y]
.scale_y:
    mov edi, esi
    mov al, [fb_glyph_bits]
    mov ecx, 8
.pixel:
    shl al, 1
    jc .fg
    mov edx, [fb_bg_color]
    jmp .next_pixel
.fg:
    mov edx, [fb_fg_color]
.next_pixel:
    push ecx
    mov ecx, [fb_char_scale_x]
.scale_x:
    mov [edi], edx
    add edi, 4
    loop .scale_x
    pop ecx
    loop .pixel
    add esi, [fb_pitch]
    dec ebp
    jnz .scale_y
    mov edi, esi
    pop ecx
    loop .draw_row
.done:
    popad
    ret

fb_draw_test_pattern:
    cmp byte [fb_available], 1
    jne .none
    pushad
    mov ebx, [fb_height]
    shr ebx, 3
    cmp ebx, 1
    ja .bands_ok
    mov ebx, 1
.bands_ok:
    xor esi, esi
.band_loop:
    cmp esi, [fb_height]
    jae .done
    mov eax, esi
    xor edx, edx
    div ebx
    and eax, 7
    mov eax, [fb_test_palette + eax * 4]
    mov ebp, eax
    mov eax, esi
    mov ecx, [fb_pitch]
    mul ecx
    mov edi, [fb_addr_low]
    add edi, eax
    mov ecx, [fb_width]
.pixel_loop:
    mov [edi], ebp
    add edi, 4
    loop .pixel_loop
    inc esi
    jmp .band_loop
.done:
    popad
    mov eax, 1
    ret
.none:
    xor eax, eax
    ret

fb_reset_dirty_flags:
    pushad
    mov edi, fb_dirty_cells
    mov ecx, [console_cols]
    imul ecx, [console_rows]
    xor eax, eax
    rep stosb
    mov byte [fb_dirty_any], 0
    popad
    ret

gui_fill_rect:
    pushad
    cmp byte [fb_available], 1
    jne .done
    mov eax, [gui_rect_x]
    cmp eax, [fb_width]
    jae .done
    mov ebx, [gui_rect_y]
    cmp ebx, [fb_height]
    jae .done
    mov ecx, [gui_rect_w]
    test ecx, ecx
    jz .done
    mov edx, [fb_width]
    sub edx, eax
    cmp ecx, edx
    jbe .width_ok
    mov ecx, edx
.width_ok:
    mov edx, [gui_rect_h]
    test edx, edx
    jz .done
    mov eax, [fb_height]
    sub eax, ebx
    cmp edx, eax
    jbe .height_ok
    mov edx, eax
.height_ok:
    mov esi, ecx
    mov ebp, edx
.row_loop:
    mov eax, ebx
    mul dword [fb_pitch]
    mov edi, [fb_addr_low]
    add edi, eax
    mov eax, [gui_rect_x]
    shl eax, 2
    add edi, eax
    mov eax, [gui_rect_color]
    mov ecx, esi
    rep stosd
    inc ebx
    dec ebp
    jnz .row_loop
.done:
    popad
    ret

gui_draw_window:
    pushad
    mov eax, [gui_win_x]
    add eax, 4
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 4
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    mov [gui_rect_w], eax
    mov eax, [gui_win_h]
    mov [gui_rect_h], eax
    mov dword [gui_rect_color], 0x00404040
    call gui_fill_rect

    mov eax, [gui_win_x]
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    mov [gui_rect_w], eax
    mov eax, [gui_win_h]
    mov [gui_rect_h], eax
    mov dword [gui_rect_color], 0x00C0C0C0
    call gui_fill_rect

    mov eax, [gui_win_x]
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    mov [gui_rect_w], eax
    mov dword [gui_rect_h], 2
    mov dword [gui_rect_color], 0x00FFFFFF
    call gui_fill_rect

    mov eax, [gui_win_x]
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 2
    mov eax, [gui_win_h]
    mov [gui_rect_h], eax
    mov dword [gui_rect_color], 0x00FFFFFF
    call gui_fill_rect

    mov eax, [gui_win_x]
    add eax, [gui_win_w]
    sub eax, 2
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 2
    mov eax, [gui_win_h]
    mov [gui_rect_h], eax
    mov dword [gui_rect_color], 0x00808080
    call gui_fill_rect

    mov eax, [gui_win_x]
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, [gui_win_h]
    sub eax, 2
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    mov [gui_rect_w], eax
    mov dword [gui_rect_h], 2
    mov dword [gui_rect_color], 0x00808080
    call gui_fill_rect

    mov eax, [gui_win_x]
    add eax, 4
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 4
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    sub eax, 8
    mov [gui_rect_w], eax
    mov dword [gui_rect_h], 20
    mov dword [gui_rect_color], 0x00000080
    call gui_fill_rect
    popad
    ret

gui_put_at:
    pushad
    mov [text_attr], dl
    call set_cursor
    call print_string
    popad
    ret

gui_put_at_pixel:
    pushad
    shr eax, 3
    shr ebx, 4
    mov [text_attr], dl
    call set_cursor
    call print_string
    popad
    ret

gui_put_in_window:
    push eax
    push ebx
    add eax, [gui_win_x]
    add ebx, [gui_win_y]
    call gui_put_at_pixel
    pop ebx
    pop eax
    ret

gui_draw_icon:
    pushad
    mov [gui_rect_x], eax
    mov [gui_rect_y], ebx
    mov dword [gui_rect_w], 32
    mov dword [gui_rect_h], 32
    mov dword [gui_rect_color], 0x00C0C0C0
    call gui_fill_rect

    mov eax, [gui_rect_x]
    add eax, 2
    mov [gui_rect_x], eax
    mov eax, [gui_rect_y]
    add eax, 2
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 28
    mov dword [gui_rect_h], 5
    mov dword [gui_rect_color], 0x00FFFFFF
    call gui_fill_rect

    mov eax, [gui_rect_x]
    add eax, 6
    mov [gui_rect_x], eax
    mov eax, [gui_rect_y]
    add eax, 6
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 20
    mov dword [gui_rect_h], 20
    mov dword [gui_rect_color], 0x00000080
    call gui_fill_rect

    mov eax, [gui_rect_x]
    add eax, 3
    mov [gui_rect_x], eax
    mov eax, [gui_rect_y]
    add eax, 3
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 14
    mov dword [gui_rect_h], 3
    mov dword [gui_rect_color], 0x0000FFFF
    call gui_fill_rect

    mov eax, [gui_rect_x]
    mov [gui_rect_x], eax
    mov eax, [gui_rect_y]
    add eax, 7
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 14
    mov dword [gui_rect_h], 8
    mov dword [gui_rect_color], 0x00FFFFFF
    call gui_fill_rect
    popad
    ret

gui_clear_text_shadow:
    pushad
    mov eax, [console_cols]
    imul eax, [console_rows]
    mov edi, fb_text_chars
    mov ecx, eax
    mov al, ' '
    rep stosb
    mov eax, [console_cols]
    imul eax, [console_rows]
    mov edi, fb_text_attrs
    mov ecx, eax
    xor al, al
    rep stosb
    popad
    ret

gui_draw_cursor_xor:
    pushad
    cmp byte [fb_available], 1
    jne .done
    xor ebp, ebp
.row_loop:
    cmp ebp, 16
    jae .done
    mov ebx, [gui_cursor_y]
    add ebx, ebp
    cmp ebx, [fb_height]
    jae .next_row
    mov eax, ebx
    mul dword [fb_pitch]
    mov edi, [fb_addr_low]
    add edi, eax
    movzx esi, word [gui_cursor_bits + ebp * 2]
    mov edx, 0x8000
    xor ecx, ecx
.col_loop:
    cmp ecx, 16
    jae .next_row
    test esi, edx
    jz .skip_pixel
    mov eax, [gui_cursor_x]
    add eax, ecx
    cmp eax, [fb_width]
    jae .skip_pixel
    push edi
    lea edi, [edi + eax * 4]
    xor dword [edi], 0x00FFFFFF
    pop edi
.skip_pixel:
    shr edx, 1
    inc ecx
    jmp .col_loop
.next_row:
    inc ebp
    jmp .row_loop
.done:
    popad
    ret

gui_erase_cursor_if_drawn:
    cmp byte [gui_cursor_drawn], 1
    jne .done
    call gui_draw_cursor_xor
    mov byte [gui_cursor_drawn], 0
.done:
    ret

gui_draw_cursor_current:
    mov eax, [mouse_x]
    mov [gui_cursor_x], eax
    mov eax, [mouse_y]
    mov [gui_cursor_y], eax
    call gui_draw_cursor_xor
    mov byte [gui_cursor_drawn], 1
    ret

gui_file_dir_path_ptr:
    mov eax, [gui_file_dir]
    cmp eax, GUI_DIR_BIN
    je .bin
    cmp eax, GUI_DIR_ETC
    je .etc
    cmp eax, GUI_DIR_HOME
    je .home
    cmp eax, GUI_DIR_DEV
    je .dev
    mov esi, msg_gui_files_root_path
    ret
.bin:
    mov esi, msg_gui_files_bin_path
    ret
.etc:
    mov esi, msg_gui_files_etc_path
    ret
.home:
    mov esi, msg_gui_files_home_path
    ret
.dev:
    mov esi, msg_gui_files_dev_path
    ret

gui_draw_taskbar_clock:
    pushad
    mov eax, [fb_width]
    sub eax, 64
    mov ebx, [fb_height]
    sub ebx, 24
    mov dl, 0x70
    mov esi, msg_gui_time
    call gui_put_at_pixel
    popad
    ret

gui_draw_file_row:
    pushad
    ; Inputs: esi=name, eax=row y, dl=type attr: 0 dir, 1 file.
    mov [gui_file_row_type], dl
    push esi
    mov [gui_rect_y], eax
    mov eax, [gui_win_x]
    add eax, 8
    mov [gui_rect_x], eax
    mov eax, [gui_win_w]
    sub eax, 16
    mov [gui_rect_w], eax
    mov dword [gui_rect_h], 20
    mov dword [gui_rect_color], 0x001E1E1E
    call gui_fill_rect

    mov eax, [gui_win_x]
    add eax, 18
    mov ebx, [gui_rect_y]
    add ebx, 2
    mov dl, 0x0F
    pop esi
    call gui_put_at_pixel

    mov eax, [gui_win_x]
    add eax, 280
    mov ebx, [gui_rect_y]
    add ebx, 2
    mov dl, 0x0F
    mov esi, msg_gui_file_date_1
    call gui_put_at_pixel

    mov eax, [gui_win_x]
    add eax, 420
    mov ebx, [gui_rect_y]
    add ebx, 2
    mov dl, 0x0F
    cmp byte [gui_file_row_type], 1
    jne .draw_dir_type
    mov esi, msg_gui_file_type_file
    jmp .draw_type
.draw_dir_type:
    mov esi, msg_gui_file_type_dir
.draw_type:
    call gui_put_at_pixel

    mov eax, [gui_win_x]
    add eax, 520
    mov ebx, [gui_rect_y]
    add ebx, 2
    mov dl, 0x0F
    mov esi, msg_gui_file_size_dash
    call gui_put_at_pixel
    popad
    ret

gui_draw_xor_rect:
    pushad
    cmp byte [fb_available], 1
    jne .done
    mov eax, [gui_drag_preview_w]
    test eax, eax
    jz .done
    mov eax, [gui_drag_preview_h]
    test eax, eax
    jz .done

    mov ebx, [gui_drag_preview_x]
    mov ecx, [gui_drag_preview_w]
    mov edx, [gui_drag_preview_y]
    call .xor_hline
    mov edx, [gui_drag_preview_y]
    add edx, [gui_drag_preview_h]
    dec edx
    call .xor_hline

    mov ebx, [gui_drag_preview_x]
    mov ecx, [gui_drag_preview_h]
    mov edx, [gui_drag_preview_y]
    call .xor_vline
    mov ebx, [gui_drag_preview_x]
    add ebx, [gui_drag_preview_w]
    dec ebx
    mov ecx, [gui_drag_preview_h]
    mov edx, [gui_drag_preview_y]
    call .xor_vline
    jmp .done

.xor_hline:
    pushad
    cmp edx, [fb_height]
    jae .h_done
    mov eax, edx
    mul dword [fb_pitch]
    mov edi, [fb_addr_low]
    add edi, eax
    xor esi, esi
.h_loop:
    cmp esi, ecx
    jae .h_done
    mov eax, ebx
    add eax, esi
    cmp eax, [fb_width]
    jae .h_next
    xor dword [edi + eax * 4], 0x00FFFFFF
.h_next:
    inc esi
    jmp .h_loop
.h_done:
    popad
    ret

.xor_vline:
    pushad
    cmp ebx, [fb_width]
    jae .v_done
    xor esi, esi
.v_loop:
    cmp esi, ecx
    jae .v_done
    mov eax, edx
    add eax, esi
    cmp eax, [fb_height]
    jae .v_next
    push edx
    mul dword [fb_pitch]
    mov edi, [fb_addr_low]
    add edi, eax
    xor dword [edi + ebx * 4], 0x00FFFFFF
    pop edx
.v_next:
    inc esi
    jmp .v_loop
.v_done:
    popad
    ret
.done:
    popad
    ret

gui_erase_drag_preview_if_drawn:
    cmp byte [gui_drag_preview_active], 1
    jne .done
    call gui_draw_xor_rect
    mov byte [gui_drag_preview_active], 0
.done:
    ret

gui_init_windows:
    pushad
    mov byte [gui_win_visible + GUI_WIN_FILES], 1
    mov byte [gui_win_visible + GUI_WIN_CMD], 0
    mov byte [gui_win_visible + GUI_WIN_TASK], 0
    mov byte [gui_win_visible + GUI_WIN_MEDIA], 0
    mov byte [gui_win_visible + GUI_WIN_NOTEPAD], 0
    mov byte [gui_win_visible + GUI_WIN_BROWSER], 0
    mov byte [gui_win_visible + GUI_WIN_SETTINGS], 0
    mov byte [gui_z_order + 0], GUI_WIN_FILES
    mov byte [gui_z_order + 1], GUI_WIN_TASK
    mov byte [gui_z_order + 2], GUI_WIN_CMD
    mov byte [gui_z_order + 3], GUI_WIN_MEDIA
    mov byte [gui_z_order + 4], GUI_WIN_NOTEPAD
    mov byte [gui_z_order + 5], GUI_WIN_BROWSER
    mov byte [gui_z_order + 6], GUI_WIN_SETTINGS
    mov byte [gui_active_win], GUI_WIN_FILES
    mov byte [gui_drag_win], GUI_WIN_NONE
    mov byte [gui_resize_win], GUI_WIN_NONE
    mov byte [gui_start_menu_open], 0
    mov byte [gui_context_menu_open], 0
    mov byte [gui_power_menu_open], 0
    mov byte [gui_prev_mouse_buttons], 0
    mov byte [gui_cursor_drawn], 0
    mov byte [mouse_event_pending], 0
    mov dword [gui_note_len], 0
    mov byte [gui_note_buf], 0
    mov dword [gui_term_len], 0
    mov byte [gui_term_buf], 0
    mov dword [gui_term_last_len], 0
    mov byte [gui_term_last_buf], 0
    mov dword [gui_term_output_ptr], msg_gui_term_empty
    mov dword [gui_browser_url_len], 0
    mov byte [gui_browser_url_buf], 0
    mov dword [gui_browser_page_ptr], msg_gui_browser_hint
    mov dword [gui_file_dir], GUI_DIR_ROOT
    mov byte [gui_file_selected_row], 255
    mov dword [gui_file_selected_dir], GUI_DIR_ROOT
    mov byte [gui_created_file], 0
    mov byte [gui_drag_preview_active], 0

    mov dword [gui_winx + GUI_WIN_FILES * 4], 96
    mov dword [gui_winy + GUI_WIN_FILES * 4], 64
    mov dword [gui_winw + GUI_WIN_FILES * 4], 620
    mov dword [gui_winh + GUI_WIN_FILES * 4], 360

    mov dword [gui_winx + GUI_WIN_CMD * 4], 160
    mov eax, [fb_height]
    cmp eax, 420
    jae .cmd_y_bottom
    mov eax, 280
    jmp .cmd_y_store
.cmd_y_bottom:
    sub eax, 340
.cmd_y_store:
    mov [gui_winy + GUI_WIN_CMD * 4], eax
    mov dword [gui_winw + GUI_WIN_CMD * 4], 560
    mov dword [gui_winh + GUI_WIN_CMD * 4], 230

    mov eax, [fb_width]
    cmp eax, 800
    jae .task_x_right
    mov eax, 20
    jmp .task_x_store
.task_x_right:
    sub eax, 760
.task_x_store:
    mov [gui_winx + GUI_WIN_TASK * 4], eax
    mov dword [gui_winy + GUI_WIN_TASK * 4], 64
    mov dword [gui_winw + GUI_WIN_TASK * 4], 720
    mov dword [gui_winh + GUI_WIN_TASK * 4], 420

    mov eax, [fb_width]
    cmp eax, 620
    jae .media_x_right
    mov eax, 240
    jmp .media_x_store
.media_x_right:
    sub eax, 500
.media_x_store:
    mov [gui_winx + GUI_WIN_MEDIA * 4], eax
    mov eax, [fb_height]
    cmp eax, 420
    jae .media_y_bottom
    mov eax, 280
    jmp .media_y_store
.media_y_bottom:
    sub eax, 340
.media_y_store:
    mov [gui_winy + GUI_WIN_MEDIA * 4], eax
    mov dword [gui_winw + GUI_WIN_MEDIA * 4], 440
    mov dword [gui_winh + GUI_WIN_MEDIA * 4], 230

    mov dword [gui_winx + GUI_WIN_NOTEPAD * 4], 120
    mov dword [gui_winy + GUI_WIN_NOTEPAD * 4], 120
    mov dword [gui_winw + GUI_WIN_NOTEPAD * 4], 520
    mov dword [gui_winh + GUI_WIN_NOTEPAD * 4], 300

    mov dword [gui_winx + GUI_WIN_BROWSER * 4], 220
    mov dword [gui_winy + GUI_WIN_BROWSER * 4], 160
    mov dword [gui_winw + GUI_WIN_BROWSER * 4], 560
    mov dword [gui_winh + GUI_WIN_BROWSER * 4], 320

    mov dword [gui_winx + GUI_WIN_SETTINGS * 4], 180
    mov dword [gui_winy + GUI_WIN_SETTINGS * 4], 110
    mov dword [gui_winw + GUI_WIN_SETTINGS * 4], 560
    mov dword [gui_winh + GUI_WIN_SETTINGS * 4], 360

    mov eax, [fb_width]
    shr eax, 1
    mov [mouse_x], eax
    mov eax, [fb_height]
    shr eax, 1
    mov [mouse_y], eax
    mov byte [gui_need_redraw], 1
    popad
    ret

gui_bring_to_front:
    pushad
    mov bl, al
    mov [gui_active_win], bl
    xor ecx, ecx
.find:
    cmp ecx, GUI_WIN_COUNT
    jae .done
    cmp [gui_z_order + ecx], bl
    je .found
    inc ecx
    jmp .find
.found:
    cmp ecx, GUI_WIN_COUNT - 1
    jae .place
    mov edx, ecx
.shift:
    cmp edx, GUI_WIN_COUNT - 1
    jae .place
    mov al, [gui_z_order + edx + 1]
    mov [gui_z_order + edx], al
    inc edx
    jmp .shift
.place:
    mov [gui_z_order + GUI_WIN_COUNT - 1], bl
.done:
    popad
    ret

gui_open_window:
    pushad
    movzx ebx, al
    cmp ebx, GUI_WIN_COUNT
    jae .done
    mov byte [gui_win_visible + ebx], 1
    call gui_bring_to_front
    mov byte [gui_need_redraw], 1
.done:
    popad
    ret

gui_draw_desktop:
    pushad
    mov dword [gui_rect_x], 0
    mov dword [gui_rect_y], 0
    mov eax, [fb_width]
    mov [gui_rect_w], eax
    mov eax, [fb_height]
    mov [gui_rect_h], eax
    mov dword [gui_rect_color], 0x00008080
    call gui_fill_rect

    mov dword [gui_rect_x], 0
    mov eax, [fb_height]
    sub eax, GUI_TASKBAR_H
    mov [gui_rect_y], eax
    mov eax, [fb_width]
    mov [gui_rect_w], eax
    mov dword [gui_rect_h], GUI_TASKBAR_H
    mov dword [gui_rect_color], 0x00C0C0C0
    call gui_fill_rect

    mov dword [gui_rect_x], 4
    mov eax, [fb_height]
    sub eax, 28
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 72
    mov dword [gui_rect_h], 24
    mov dword [gui_rect_color], 0x00E0E0E0
    call gui_fill_rect

    mov eax, 16
    mov ebx, 24
    call gui_draw_icon
    mov eax, 8
    mov ebx, 60
    mov dl, 0x3F
    mov esi, msg_gui_icon_files
    call gui_put_at_pixel

    mov eax, 16
    mov ebx, 96
    call gui_draw_icon
    mov eax, 8
    mov ebx, 132
    mov dl, 0x3F
    mov esi, msg_gui_icon_terminal
    call gui_put_at_pixel

    mov eax, 16
    mov ebx, 168
    call gui_draw_icon
    mov eax, 8
    mov ebx, 204
    mov dl, 0x3F
    mov esi, msg_gui_icon_media
    call gui_put_at_pixel

    mov eax, 16
    mov ebx, 240
    call gui_draw_icon
    mov eax, 8
    mov ebx, 276
    mov dl, 0x3F
    mov esi, msg_gui_icon_note
    call gui_put_at_pixel

    mov eax, 16
    mov ebx, 312
    call gui_draw_icon
    mov eax, 8
    mov ebx, 348
    mov dl, 0x3F
    mov esi, msg_gui_icon_settings
    call gui_put_at_pixel

    mov eax, 16
    mov ebx, 384
    call gui_draw_icon
    mov eax, 8
    mov ebx, 420
    mov dl, 0x3F
    mov esi, msg_gui_title_task
    call gui_put_at_pixel

    mov eax, 16
    mov ebx, 456
    call gui_draw_icon
    mov eax, 8
    mov ebx, 492
    mov dl, 0x3F
    mov esi, msg_gui_icon_browser
    call gui_put_at_pixel

    mov eax, 14
    mov ebx, [fb_height]
    sub ebx, 25
    mov dl, 0x70
    mov esi, msg_gui_start
    call gui_put_at_pixel

    mov eax, 96
    mov ebx, [fb_height]
    sub ebx, 24
    mov dl, 0x70
    mov esi, msg_gui_hint
    call gui_put_at_pixel
    call gui_draw_taskbar_clock
    popad
    ret

gui_draw_start_menu:
    pushad
    cmp byte [gui_start_menu_open], 1
    jne .done
    mov ebx, [fb_height]
    cmp ebx, 302
    jae .menu_y_ok
    xor ebx, ebx
    jmp .menu_y_ready
.menu_y_ok:
    sub ebx, 302
.menu_y_ready:
    mov dword [gui_rect_x], 0
    mov [gui_rect_y], ebx
    mov dword [gui_rect_w], 220
    mov dword [gui_rect_h], 270
    mov dword [gui_rect_color], 0x00C0C0C0
    call gui_fill_rect

    mov eax, 8
    mov dl, 0x70
    mov esi, msg_gui_menu_1
    call gui_put_at_pixel
    mov eax, 24
    mov ebx, [gui_rect_y]
    add ebx, 34
    mov dl, 0x70
    mov esi, msg_gui_menu_2
    call gui_put_at_pixel
    mov eax, 24
    mov ebx, [gui_rect_y]
    add ebx, 64
    mov dl, 0x70
    mov esi, msg_gui_menu_3
    call gui_put_at_pixel
    mov eax, 24
    mov ebx, [gui_rect_y]
    add ebx, 94
    mov dl, 0x70
    mov esi, msg_gui_menu_4
    call gui_put_at_pixel
    mov eax, 24
    mov ebx, [gui_rect_y]
    add ebx, 124
    mov dl, 0x70
    mov esi, msg_gui_menu_5
    call gui_put_at_pixel
    mov eax, 24
    mov ebx, [gui_rect_y]
    add ebx, 154
    mov dl, 0x70
    mov esi, msg_gui_menu_6
    call gui_put_at_pixel
    mov eax, 24
    mov ebx, [gui_rect_y]
    add ebx, 184
    mov dl, 0x70
    mov esi, msg_gui_menu_7
    call gui_put_at_pixel
    mov eax, 24
    mov ebx, [gui_rect_y]
    add ebx, 214
    mov dl, 0x70
    mov esi, msg_gui_menu_8
    call gui_put_at_pixel
    mov eax, 24
    mov ebx, [gui_rect_y]
    add ebx, 244
    mov dl, 0x70
    mov esi, msg_gui_menu_9
    call gui_put_at_pixel
.done:
    popad
    ret

gui_draw_context_menu:
    pushad
    cmp byte [gui_context_menu_open], 1
    jne .done
    mov eax, [gui_context_x]
    mov [gui_rect_x], eax
    mov eax, [gui_context_y]
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 160
    mov dword [gui_rect_h], 132
    mov dword [gui_rect_color], 0x00C0C0C0
    call gui_fill_rect
    mov eax, [gui_context_x]
    add eax, 12
    mov ebx, [gui_context_y]
    add ebx, 10
    mov dl, 0x70
    mov esi, msg_gui_context_refresh
    call gui_put_at_pixel
    mov eax, [gui_context_x]
    add eax, 12
    mov ebx, [gui_context_y]
    add ebx, 36
    mov dl, 0x70
    mov esi, msg_gui_context_new_file
    call gui_put_at_pixel
    mov eax, [gui_context_x]
    add eax, 12
    mov ebx, [gui_context_y]
    add ebx, 62
    mov dl, 0x70
    mov esi, msg_gui_context_terminal
    call gui_put_at_pixel
    mov eax, [gui_context_x]
    add eax, 12
    mov ebx, [gui_context_y]
    add ebx, 88
    mov dl, 0x70
    mov esi, msg_gui_context_settings
    call gui_put_at_pixel
    mov eax, [gui_context_x]
    add eax, 12
    mov ebx, [gui_context_y]
    add ebx, 114
    mov dl, 0x70
    mov esi, msg_gui_context_power
    call gui_put_at_pixel
.done:
    popad
    ret

gui_draw_power_menu:
    pushad
    cmp byte [gui_power_menu_open], 1
    jne .done
    mov dword [gui_rect_w], 240
    mov dword [gui_rect_h], 132
    mov eax, [fb_width]
    sub eax, 240
    shr eax, 1
    mov [gui_rect_x], eax
    mov eax, [fb_height]
    sub eax, 132
    shr eax, 1
    mov [gui_rect_y], eax
    mov dword [gui_rect_color], 0x00C0C0C0
    call gui_fill_rect
    mov eax, [gui_rect_x]
    add eax, 16
    mov ebx, [gui_rect_y]
    add ebx, 14
    mov dl, 0x70
    mov esi, msg_gui_power_title
    call gui_put_at_pixel
    mov eax, [gui_rect_x]
    add eax, 28
    mov ebx, [gui_rect_y]
    add ebx, 48
    mov dl, 0x70
    mov esi, msg_gui_power_shutdown
    call gui_put_at_pixel
    mov eax, [gui_rect_x]
    add eax, 28
    mov ebx, [gui_rect_y]
    add ebx, 76
    mov dl, 0x70
    mov esi, msg_gui_power_reboot
    call gui_put_at_pixel
    mov eax, [gui_rect_x]
    add eax, 28
    mov ebx, [gui_rect_y]
    add ebx, 104
    mov dl, 0x70
    mov esi, msg_gui_power_cancel
    call gui_put_at_pixel
.done:
    popad
    ret

gui_draw_window_controls:
    pushad
    mov eax, [gui_win_x]
    add eax, [gui_win_w]
    sub eax, 22
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 6
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 14
    mov dword [gui_rect_h], 14
    mov dword [gui_rect_color], 0x00C0C0C0
    call gui_fill_rect
    mov eax, [gui_win_x]
    add eax, [gui_win_w]
    sub eax, 18
    mov ebx, [gui_win_y]
    add ebx, 5
    mov dl, 0x70
    mov esi, msg_gui_close
    call gui_put_at_pixel

    mov eax, [gui_win_x]
    add eax, [gui_win_w]
    sub eax, 18
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, [gui_win_h]
    sub eax, 18
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 12
    mov dword [gui_rect_h], 12
    mov dword [gui_rect_color], 0x00808080
    call gui_fill_rect
    popad
    ret

gui_draw_window_by_id:
    pushad
    mov [gui_hit_win], al
    movzx edi, al
    cmp edi, GUI_WIN_COUNT
    jae .done
    cmp byte [gui_win_visible + edi], 1
    jne .done
    mov eax, [gui_winx + edi * 4]
    mov [gui_win_x], eax
    mov eax, [gui_winy + edi * 4]
    mov [gui_win_y], eax
    mov eax, [gui_winw + edi * 4]
    mov [gui_win_w], eax
    mov eax, [gui_winh + edi * 4]
    mov [gui_win_h], eax
    call gui_draw_window
    call gui_draw_window_controls

    mov al, [gui_hit_win]
    cmp al, GUI_WIN_FILES
    je .title_files
    cmp al, GUI_WIN_CMD
    je .title_cmd
    cmp al, GUI_WIN_TASK
    je .title_task
    cmp al, GUI_WIN_MEDIA
    je .title_media
    cmp al, GUI_WIN_NOTEPAD
    je .title_notepad
    cmp al, GUI_WIN_BROWSER
    je .title_browser
    mov esi, msg_gui_title_settings
    jmp .draw_title
.title_browser:
    mov esi, msg_gui_title_browser
    jmp .draw_title
.title_files:
    mov esi, msg_gui_title_files
    jmp .draw_title
.title_cmd:
    mov esi, msg_gui_title_cmd
    jmp .draw_title
.title_task:
    mov esi, msg_gui_title_task
    jmp .draw_title
.title_media:
    mov esi, msg_gui_title_media
    jmp .draw_title
.title_notepad:
    mov esi, msg_gui_title_notepad
.draw_title:
    mov eax, [gui_win_x]
    add eax, 12
    mov ebx, [gui_win_y]
    add ebx, 6
    mov dl, 0x1F
    call gui_put_at_pixel

    mov al, [gui_hit_win]
    cmp al, GUI_WIN_FILES
    je .content_files
    cmp al, GUI_WIN_CMD
    je .content_cmd
    cmp al, GUI_WIN_TASK
    je .content_task
    cmp al, GUI_WIN_MEDIA
    je .content_media
    cmp al, GUI_WIN_NOTEPAD
    je .content_notepad
    cmp al, GUI_WIN_BROWSER
    je .content_browser
    jmp .content_settings

.content_files:
    mov eax, [gui_win_x]
    add eax, 6
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 30
    mov [gui_rect_y], eax
    mov eax, [gui_win_w]
    sub eax, 12
    mov [gui_rect_w], eax
    mov eax, [gui_win_h]
    sub eax, 38
    mov [gui_rect_h], eax
    mov dword [gui_rect_color], 0x001A1A1A
    call gui_fill_rect

    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 38
    mov dl, 0x0F
    mov esi, msg_gui_files_toolbar
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 72
    mov ebx, [gui_win_y]
    add ebx, 38
    mov dl, 0x0F
    call gui_file_dir_path_ptr
    mov eax, [gui_win_x]
    add eax, 72
    mov ebx, [gui_win_y]
    add ebx, 38
    mov dl, 0x0F
    call gui_put_at_pixel

    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 70
    mov dl, 0x0F
    mov esi, msg_gui_file_hdr_name
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 280
    mov ebx, [gui_win_y]
    add ebx, 70
    mov dl, 0x0F
    mov esi, msg_gui_file_hdr_date
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 420
    mov ebx, [gui_win_y]
    add ebx, 70
    mov dl, 0x0F
    mov esi, msg_gui_file_hdr_type
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 520
    mov ebx, [gui_win_y]
    add ebx, 70
    mov dl, 0x0F
    mov esi, msg_gui_file_hdr_size
    call gui_put_at_pixel

    mov eax, [gui_file_dir]
    cmp eax, GUI_DIR_BIN
    je .files_bin
    cmp eax, GUI_DIR_ETC
    je .files_etc
    cmp eax, GUI_DIR_HOME
    je .files_home
    cmp eax, GUI_DIR_DEV
    je .files_dev
.files_root:
    mov eax, [gui_win_x]
    mov eax, [gui_win_y]
    add eax, 100
    xor dl, dl
    mov esi, msg_gui_files_root_1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 122
    mov esi, msg_gui_files_root_2
    xor dl, dl
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 144
    mov esi, msg_gui_files_root_3
    xor dl, dl
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 166
    mov esi, msg_gui_files_root_4
    xor dl, dl
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 188
    mov esi, msg_gui_files_root_5
    xor dl, dl
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 210
    mov esi, msg_gui_files_root_6
    xor dl, dl
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 232
    mov esi, msg_gui_files_root_7
    xor dl, dl
    call gui_draw_file_row
    jmp .done
.files_bin:
    mov eax, [gui_win_y]
    add eax, 100
    mov esi, msg_gui_files_bin_1
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 122
    mov esi, msg_gui_files_bin_2
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 144
    mov esi, msg_gui_files_bin_3
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 166
    mov esi, msg_gui_files_bin_4
    mov dl, 1
    call gui_draw_file_row
    jmp .done
.files_etc:
    mov eax, [gui_win_y]
    add eax, 100
    mov esi, msg_gui_files_etc_1
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 122
    mov esi, msg_gui_files_etc_2
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 144
    mov esi, msg_gui_files_etc_3
    mov dl, 1
    call gui_draw_file_row
    jmp .done
.files_home:
    mov eax, [gui_win_y]
    add eax, 100
    mov esi, msg_gui_files_home_1
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 122
    mov esi, msg_gui_files_home_2
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 144
    mov esi, msg_gui_files_home_3
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 166
    mov esi, msg_gui_files_home_4
    mov dl, 1
    call gui_draw_file_row
    cmp byte [gui_created_file], 1
    jne .home_done
    mov eax, [gui_win_y]
    add eax, 188
    mov esi, msg_gui_file_created
    mov dl, 1
    call gui_draw_file_row
.home_done:
    jmp .done
.files_dev:
    mov eax, [gui_win_y]
    add eax, 100
    mov esi, msg_gui_files_dev_1
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 122
    mov esi, msg_gui_files_dev_2
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 144
    mov esi, msg_gui_files_dev_3
    mov dl, 1
    call gui_draw_file_row
    mov eax, [gui_win_y]
    add eax, 166
    mov esi, msg_gui_files_dev_4
    mov dl, 1
    call gui_draw_file_row
    jmp .done

.content_cmd:
    call gui_draw_terminal_content
    jmp .done
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
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 48
    mov dl, 0x0F
    mov esi, msg_gui_cmd_1
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 80
    mov dl, 0x0A
    mov esi, msg_gui_cmd_2
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 112
    mov dl, 0x0F
    mov esi, msg_gui_cmd_3
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 32
    mov ebx, [gui_win_y]
    add ebx, 112
    mov dl, 0x0F
    cmp dword [gui_term_len], 0
    jne .cmd_draw_input
    mov esi, msg_gui_term_empty
    jmp .cmd_draw_line
.cmd_draw_input:
    mov esi, gui_term_buf
.cmd_draw_line:
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 152
    mov dl, 0x0A
    mov esi, [gui_term_output_ptr]
    call gui_put_at_pixel
    jmp .done

.content_task:
    call gui_draw_task_manager_content
    jmp .done
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 48
    mov dl, 0x70
    mov esi, msg_gui_task_1
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 80
    mov dl, 0x70
    mov esi, msg_gui_task_2
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 112
    mov dl, 0x70
    mov esi, msg_gui_task_3
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 144
    mov dl, 0x70
    mov esi, msg_gui_task_4
    call gui_put_at_pixel
    jmp .done

.content_media:
    mov eax, [gui_win_x]
    add eax, 20
    mov [gui_rect_x], eax
    mov eax, [gui_win_y]
    add eax, 48
    mov [gui_rect_y], eax
    mov dword [gui_rect_w], 120
    mov dword [gui_rect_h], 80
    mov dword [gui_rect_color], 0x00000080
    call gui_fill_rect
    mov eax, [gui_win_x]
    add eax, 156
    mov ebx, [gui_win_y]
    add ebx, 56
    mov dl, 0x70
    mov esi, msg_gui_media_1
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 156
    mov ebx, [gui_win_y]
    add ebx, 88
    mov dl, 0x70
    mov esi, msg_gui_media_2
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 156
    mov ebx, [gui_win_y]
    add ebx, 120
    mov dl, 0x70
    mov esi, msg_gui_media_3
    call gui_put_at_pixel
    jmp .done

.content_notepad:
    call gui_draw_notepad_content
    jmp .done
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
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 48
    mov dl, 0xF0
    mov esi, msg_gui_note_1
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 88
    mov dl, 0xF0
    cmp dword [gui_note_len], 0
    jne .note_text
    mov esi, msg_gui_note_empty
    jmp .draw_note
.note_text:
    mov esi, gui_note_buf
.draw_note:
    call gui_put_at_pixel
    jmp .done

.content_browser:
    call gui_draw_browser_content
    jmp .done
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
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 44
    mov dl, 0x70
    mov esi, msg_gui_browser_1
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 84
    mov dl, 0xF0
    mov esi, msg_gui_browser_2
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 16
    mov ebx, [gui_win_y]
    add ebx, 132
    mov dl, 0xF0
    mov esi, msg_gui_browser_3
    call gui_put_at_pixel
    jmp .done

.content_settings:
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
    mov dword [gui_rect_color], 0x00F0F0F0
    call gui_fill_rect
    mov eax, [gui_win_x]
    add eax, 24
    mov ebx, [gui_win_y]
    add ebx, 52
    mov dl, 0x70
    mov esi, msg_gui_settings_1
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 24
    mov ebx, [gui_win_y]
    add ebx, 92
    mov dl, 0x70
    mov esi, msg_gui_settings_2
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 24
    mov ebx, [gui_win_y]
    add ebx, 124
    mov dl, 0x70
    mov esi, msg_gui_settings_3
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 24
    mov ebx, [gui_win_y]
    add ebx, 156
    mov dl, 0x70
    mov esi, msg_gui_settings_4
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 24
    mov ebx, [gui_win_y]
    add ebx, 188
    mov dl, 0x70
    mov esi, msg_gui_settings_5
    call gui_put_at_pixel
    mov eax, [gui_win_x]
    add eax, 24
    mov ebx, [gui_win_y]
    add ebx, 220
    mov dl, 0x70
    mov esi, msg_gui_settings_6
    call gui_put_at_pixel
.done:
    popad
    ret

gui_draw_all_windows:
    pushad
    xor ecx, ecx
.loop:
    cmp ecx, GUI_WIN_COUNT
    jae .done
    mov al, [gui_z_order + ecx]
    push ecx
    call gui_draw_window_by_id
    pop ecx
    inc ecx
    jmp .loop
.done:
    popad
    ret

gui_redraw:
    pushad
    call fb_reset_dirty_flags
    call gui_clear_text_shadow
    call gui_draw_desktop
    call gui_draw_all_windows
    call gui_draw_start_menu
    call gui_draw_context_menu
    call gui_draw_power_menu
    call fb_flush_dirty
    mov byte [gui_need_redraw], 0
    popad
    ret

gui_find_window_at:
    push ebx
    push ecx
    push edx
    push esi
    mov ecx, GUI_WIN_COUNT
.loop:
    cmp ecx, 0
    je .none
    dec ecx
    movzx esi, byte [gui_z_order + ecx]
    cmp byte [gui_win_visible + esi], 1
    jne .loop
    mov eax, [mouse_x]
    mov ebx, [gui_winx + esi * 4]
    cmp eax, ebx
    jb .loop
    mov edx, ebx
    add edx, [gui_winw + esi * 4]
    cmp eax, edx
    jae .loop
    mov eax, [mouse_y]
    mov ebx, [gui_winy + esi * 4]
    cmp eax, ebx
    jb .loop
    mov edx, ebx
    add edx, [gui_winh + esi * 4]
    cmp eax, edx
    jae .loop
    mov eax, esi
    jmp .ret
.none:
    mov eax, GUI_WIN_NONE
.ret:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

gui_handle_start_menu_click:
    push ebx
    push ecx
    push edx
    xor eax, eax
    cmp byte [gui_start_menu_open], 1
    jne .ret
    mov ebx, [mouse_x]
    cmp ebx, 220
    jae .ret
    mov ebx, [fb_height]
    cmp ebx, 302
    jae .menu_y_ok
    xor ebx, ebx
    jmp .menu_y_ready
.menu_y_ok:
    sub ebx, 302
.menu_y_ready:
    mov edx, [mouse_y]
    cmp edx, ebx
    jb .ret
    sub edx, ebx
    cmp edx, 30
    jb .handled_only
    cmp edx, 60
    jb .open_files
    cmp edx, 90
    jb .open_cmd
    cmp edx, 120
    jb .open_task
    cmp edx, 150
    jb .open_notepad
    cmp edx, 180
    jb .open_settings
    cmp edx, 210
    jb .open_media
    cmp edx, 240
    jb .open_browser
    cmp edx, 270
    jb .open_power
    jmp .ret
.open_files:
    mov al, GUI_WIN_FILES
    jmp .open
.open_cmd:
    mov al, GUI_WIN_CMD
    jmp .open
.open_task:
    mov al, GUI_WIN_TASK
    jmp .open
.open_notepad:
    mov al, GUI_WIN_NOTEPAD
    jmp .open
.open_settings:
    mov al, GUI_WIN_SETTINGS
    jmp .open
.open_media:
    mov al, GUI_WIN_MEDIA
    jmp .open
.open_browser:
    mov al, GUI_WIN_BROWSER
    jmp .open
.open_power:
    mov byte [gui_power_menu_open], 1
    mov byte [gui_start_menu_open], 0
    mov byte [gui_need_redraw], 1
    mov eax, 1
    jmp .ret
.open:
    call gui_open_window
    mov byte [gui_start_menu_open], 0
    mov eax, 1
    jmp .ret
.handled_only:
    mov eax, 1
.ret:
    pop edx
    pop ecx
    pop ebx
    ret

gui_handle_desktop_icon_click:
    push ebx
    push edx
    xor eax, eax
    mov ebx, [mouse_x]
    cmp ebx, 8
    jb .ret
    cmp ebx, 88
    jae .ret
    mov edx, [mouse_y]
    cmp edx, 16
    jb .ret
    cmp edx, 80
    jb .open_files
    cmp edx, 88
    jb .ret
    cmp edx, 152
    jb .open_cmd
    cmp edx, 160
    jb .ret
    cmp edx, 224
    jb .open_media
    cmp edx, 232
    jb .ret
    cmp edx, 296
    jb .open_notepad
    cmp edx, 304
    jb .ret
    cmp edx, 368
    jb .open_settings
    cmp edx, 376
    jb .ret
    cmp edx, 440
    jb .open_task
    cmp edx, 448
    jb .ret
    cmp edx, 512
    jb .open_browser
    jmp .ret
.open_files:
    mov al, GUI_WIN_FILES
    jmp .open
.open_cmd:
    mov al, GUI_WIN_CMD
    jmp .open
.open_media:
    mov al, GUI_WIN_MEDIA
    jmp .open
.open_notepad:
    mov al, GUI_WIN_NOTEPAD
    jmp .open
.open_settings:
    mov al, GUI_WIN_SETTINGS
    jmp .open
.open_task:
    mov al, GUI_WIN_TASK
    jmp .open
.open_browser:
    mov al, GUI_WIN_BROWSER
.open:
    call gui_open_window
    mov eax, 1
.ret:
    pop edx
    pop ebx
    ret

gui_handle_file_click:
    pushad
    movzx esi, byte [gui_hit_win]
    cmp esi, GUI_WIN_FILES
    jne .done
    mov eax, [mouse_x]
    sub eax, [gui_winx + GUI_WIN_FILES * 4]
    cmp eax, 0
    jl .done
    mov ebx, [mouse_y]
    sub ebx, [gui_winy + GUI_WIN_FILES * 4]
    cmp ebx, 36
    jb .done
    cmp ebx, 70
    jae .check_rows
    cmp eax, 72
    jae .done
    mov dword [gui_file_dir], GUI_DIR_ROOT
    mov byte [gui_file_selected_row], 255
    mov byte [gui_need_redraw], 1
    jmp .done
.check_rows:
    cmp dword [gui_file_dir], GUI_DIR_ROOT
    jne .file_rows
    cmp ebx, 100
    jb .done
    cmp ebx, 122
    jb .enter_bin
    cmp ebx, 144
    jb .enter_etc
    cmp ebx, 166
    jb .enter_home
    cmp ebx, 188
    jb .enter_dev
    jmp .done
.enter_bin:
    mov dword [gui_file_dir], GUI_DIR_BIN
    mov byte [gui_file_selected_row], 255
    mov byte [gui_need_redraw], 1
    jmp .done
.enter_etc:
    mov dword [gui_file_dir], GUI_DIR_ETC
    mov byte [gui_file_selected_row], 255
    mov byte [gui_need_redraw], 1
    jmp .done
.enter_home:
    mov dword [gui_file_dir], GUI_DIR_HOME
    mov byte [gui_file_selected_row], 255
    mov byte [gui_need_redraw], 1
    jmp .done
.enter_dev:
    mov dword [gui_file_dir], GUI_DIR_DEV
    mov byte [gui_file_selected_row], 255
    mov byte [gui_need_redraw], 1
    jmp .done
.file_rows:
    cmp ebx, 100
    jb .done
    mov eax, ebx
    sub eax, 100
    xor edx, edx
    mov ecx, 22
    div ecx
    cmp eax, 5
    jae .done
    mov bl, al
    mov ecx, [gui_file_dir]
    cmp ecx, GUI_DIR_ETC
    jne .check_home_rows
    cmp bl, 3
    jae .done
    jmp .open_file_row
.check_home_rows:
    cmp ecx, GUI_DIR_HOME
    jne .check_four_rows
    cmp bl, 4
    jne .open_file_row
    cmp byte [gui_created_file], 1
    jne .done
    jmp .open_file_row
.check_four_rows:
    cmp bl, 4
    jae .done
.open_file_row:
    call gui_handle_file_row_open
.done:
    popad
    ret

gui_handle_context_menu_click:
    push ebx
    push edx
    xor eax, eax
    cmp byte [gui_context_menu_open], 1
    jne .ret
    mov ebx, [mouse_x]
    cmp ebx, [gui_context_x]
    jb .close
    mov edx, [gui_context_x]
    add edx, 160
    cmp ebx, edx
    jae .close
    mov edx, [mouse_y]
    cmp edx, [gui_context_y]
    jb .close
    sub edx, [gui_context_y]
    cmp edx, 26
    jb .refresh
    cmp edx, 52
    jb .new_file
    cmp edx, 78
    jb .terminal
    cmp edx, 104
    jb .settings
    cmp edx, 132
    jb .power
    jmp .close
.refresh:
    mov byte [gui_context_menu_open], 0
    mov byte [gui_need_redraw], 1
    mov eax, 1
    jmp .ret
.new_file:
    mov byte [gui_created_file], 1
    mov dword [gui_file_dir], GUI_DIR_HOME
    mov byte [gui_context_menu_open], 0
    mov byte [gui_need_redraw], 1
    mov eax, 1
    jmp .ret
.terminal:
    mov al, GUI_WIN_CMD
    call gui_open_window
    mov byte [gui_context_menu_open], 0
    mov eax, 1
    jmp .ret
.settings:
    mov al, GUI_WIN_SETTINGS
    call gui_open_window
    mov byte [gui_context_menu_open], 0
    mov eax, 1
    jmp .ret
.power:
    mov byte [gui_power_menu_open], 1
    mov byte [gui_context_menu_open], 0
    mov byte [gui_need_redraw], 1
    mov eax, 1
    jmp .ret
.close:
    mov byte [gui_context_menu_open], 0
    mov byte [gui_need_redraw], 1
    mov eax, 1
.ret:
    pop edx
    pop ebx
    ret

gui_handle_power_menu_click:
    push ebx
    push edx
    xor eax, eax
    cmp byte [gui_power_menu_open], 1
    jne .ret
    mov ebx, [fb_width]
    sub ebx, 240
    shr ebx, 1
    mov edx, [mouse_x]
    cmp edx, ebx
    jb .close
    add ebx, 240
    cmp edx, ebx
    jae .close
    mov ebx, [fb_height]
    sub ebx, 132
    shr ebx, 1
    mov edx, [mouse_y]
    cmp edx, ebx
    jb .close
    sub edx, ebx
    cmp edx, 44
    jb .handled
    cmp edx, 72
    jb .shutdown
    cmp edx, 100
    jb .reboot
    cmp edx, 132
    jb .close
    jmp .close
.shutdown:
    mov byte [gui_power_menu_open], 0
    mov eax, 1
    call command_shutdown
    jmp .ret
.reboot:
    mov byte [gui_power_menu_open], 0
    mov eax, 1
    call command_reboot
    jmp .ret
.handled:
    mov eax, 1
    jmp .ret
.close:
    mov byte [gui_power_menu_open], 0
    mov byte [gui_need_redraw], 1
    mov eax, 1
.ret:
    pop edx
    pop ebx
    ret

gui_mouse_down:
    pushad
    mov eax, [mouse_x]
    cmp eax, 4
    jb .not_start
    cmp eax, 76
    jae .not_start
    mov ebx, [fb_height]
    sub ebx, 28
    mov eax, [mouse_y]
    cmp eax, ebx
    jb .not_start
    mov ebx, [fb_height]
    sub ebx, 4
    cmp eax, ebx
    jae .not_start
    xor byte [gui_start_menu_open], 1
    mov byte [gui_need_redraw], 1
    jmp .done

.not_start:
    call gui_handle_power_menu_click
    test eax, eax
    jnz .done
    call gui_handle_context_menu_click
    test eax, eax
    jnz .done
    cmp byte [gui_start_menu_open], 1
    jne .no_menu
    call gui_handle_start_menu_click
    test eax, eax
    jnz .done
.no_menu:
    call gui_find_window_at
    cmp al, GUI_WIN_NONE
    je .desktop_click
    mov [gui_hit_win], al
    cmp byte [gui_start_menu_open], 1
    jne .menu_closed
    mov byte [gui_start_menu_open], 0
.menu_closed:
    call gui_bring_to_front
    mov byte [gui_need_redraw], 1
    movzx esi, byte [gui_hit_win]

    mov eax, [gui_winx + esi * 4]
    add eax, [gui_winw + esi * 4]
    sub eax, 24
    cmp [mouse_x], eax
    jb .check_resize
    mov eax, [gui_winx + esi * 4]
    add eax, [gui_winw + esi * 4]
    sub eax, 4
    cmp [mouse_x], eax
    jae .check_resize
    mov eax, [gui_winy + esi * 4]
    add eax, 4
    cmp [mouse_y], eax
    jb .check_resize
    mov eax, [gui_winy + esi * 4]
    add eax, GUI_TITLE_H
    cmp [mouse_y], eax
    jae .check_resize
    mov byte [gui_win_visible + esi], 0
    mov byte [gui_active_win], GUI_WIN_NONE
    mov byte [gui_drag_win], GUI_WIN_NONE
    mov byte [gui_resize_win], GUI_WIN_NONE
    jmp .done

.check_resize:
    mov eax, [gui_winx + esi * 4]
    add eax, [gui_winw + esi * 4]
    sub eax, GUI_RESIZE_GRIP
    cmp [mouse_x], eax
    jb .check_title
    mov eax, [gui_winy + esi * 4]
    add eax, [gui_winh + esi * 4]
    sub eax, GUI_RESIZE_GRIP
    cmp [mouse_y], eax
    jb .check_title
    mov al, [gui_hit_win]
    mov [gui_resize_win], al
    mov byte [gui_drag_win], GUI_WIN_NONE
    jmp .done

.check_title:
    mov eax, [mouse_y]
    mov ebx, [gui_winy + esi * 4]
    cmp eax, ebx
    jb .content_click
    add ebx, GUI_TITLE_H
    cmp eax, ebx
    jae .content_click
    mov al, [gui_hit_win]
    mov [gui_drag_win], al
    mov byte [gui_resize_win], GUI_WIN_NONE
    mov eax, [mouse_x]
    sub eax, [gui_winx + esi * 4]
    mov [gui_drag_offset_x], eax
    mov eax, [mouse_y]
    sub eax, [gui_winy + esi * 4]
    mov [gui_drag_offset_y], eax
    jmp .done

.content_click:
    call gui_handle_file_click
    jmp .done

.desktop_click:
    cmp byte [gui_start_menu_open], 1
    jne .try_icons
    mov byte [gui_start_menu_open], 0
    mov byte [gui_need_redraw], 1
.try_icons:
    call gui_handle_desktop_icon_click
    test eax, eax
    jnz .done
    mov byte [gui_active_win], GUI_WIN_NONE
.done:
    popad
    ret

gui_mouse_drag:
    pushad
    movzx esi, byte [gui_resize_win]
    cmp esi, GUI_WIN_NONE
    je .check_drag
    mov eax, [mouse_x]
    sub eax, [gui_winx + esi * 4]
    add eax, 4
    cmp eax, GUI_MIN_WIN_W
    jge .resize_w_min_ok
    mov eax, GUI_MIN_WIN_W
.resize_w_min_ok:
    mov ebx, [fb_width]
    sub ebx, [gui_winx + esi * 4]
    cmp ebx, GUI_MIN_WIN_W
    jge .resize_w_max_ok
    mov ebx, GUI_MIN_WIN_W
.resize_w_max_ok:
    cmp eax, ebx
    jle .resize_w_store
    mov eax, ebx
.resize_w_store:
    mov [gui_winw + esi * 4], eax

    mov eax, [mouse_y]
    sub eax, [gui_winy + esi * 4]
    add eax, 4
    cmp eax, GUI_MIN_WIN_H
    jge .resize_h_min_ok
    mov eax, GUI_MIN_WIN_H
.resize_h_min_ok:
    mov ebx, [fb_height]
    sub ebx, [gui_winy + esi * 4]
    sub ebx, GUI_TASKBAR_H
    cmp ebx, GUI_MIN_WIN_H
    jge .resize_h_max_ok
    mov ebx, GUI_MIN_WIN_H
.resize_h_max_ok:
    cmp eax, ebx
    jle .resize_h_store
    mov eax, ebx
.resize_h_store:
    mov [gui_winh + esi * 4], eax
    mov byte [gui_need_redraw], 1
    jmp .done

.check_drag:
    movzx esi, byte [gui_drag_win]
    cmp esi, GUI_WIN_NONE
    je .done
    call gui_erase_drag_preview_if_drawn
    mov eax, [mouse_x]
    sub eax, [gui_drag_offset_x]
    cmp eax, 0
    jge .drag_x_min_ok
    xor eax, eax
.drag_x_min_ok:
    mov ebx, [fb_width]
    sub ebx, [gui_winw + esi * 4]
    cmp ebx, 0
    jge .drag_x_max_ok
    xor ebx, ebx
.drag_x_max_ok:
    cmp eax, ebx
    jle .drag_x_store
    mov eax, ebx
.drag_x_store:
    mov [gui_drag_preview_x], eax

    mov eax, [mouse_y]
    sub eax, [gui_drag_offset_y]
    cmp eax, 0
    jge .drag_y_min_ok
    xor eax, eax
.drag_y_min_ok:
    mov ebx, [fb_height]
    sub ebx, GUI_TASKBAR_H
    sub ebx, [gui_winh + esi * 4]
    cmp ebx, 0
    jge .drag_y_max_ok
    xor ebx, ebx
.drag_y_max_ok:
    cmp eax, ebx
    jle .drag_y_store
    mov eax, ebx
.drag_y_store:
    mov [gui_drag_preview_y], eax
    mov eax, [gui_winw + esi * 4]
    mov [gui_drag_preview_w], eax
    mov eax, [gui_winh + esi * 4]
    mov [gui_drag_preview_h], eax
    call gui_draw_xor_rect
    mov byte [gui_drag_preview_active], 1
    mov byte [gui_need_redraw], 0
.done:
    popad
    ret

gui_process_mouse:
    pushad
    mov al, [mouse_buttons]
    mov bl, [gui_prev_mouse_buttons]
    mov cl, al
    and cl, 2
    mov dl, bl
    and dl, 2
    cmp cl, 2
    jne .check_left
    cmp dl, 0
    jne .check_left
    mov eax, [mouse_x]
    mov [gui_context_x], eax
    mov eax, [mouse_y]
    mov [gui_context_y], eax
    mov byte [gui_context_menu_open], 1
    mov byte [gui_start_menu_open], 0
    mov byte [gui_power_menu_open], 0
    mov byte [gui_need_redraw], 1
    jmp .store_prev
.check_left:
    mov cl, al
    and cl, 1
    mov dl, bl
    and dl, 1
    cmp cl, 1
    jne .left_up
    cmp dl, 1
    je .dragging
    call gui_mouse_down
    jmp .store_prev
.dragging:
    call gui_mouse_drag
    jmp .store_prev
.left_up:
    cmp dl, 1
    jne .store_prev
    movzx esi, byte [gui_drag_win]
    cmp esi, GUI_WIN_NONE
    je .release_resize
    call gui_erase_drag_preview_if_drawn
    mov eax, [gui_drag_preview_x]
    mov [gui_winx + esi * 4], eax
    mov eax, [gui_drag_preview_y]
    mov [gui_winy + esi * 4], eax
    mov byte [gui_need_redraw], 1
.release_resize:
    mov byte [gui_drag_win], GUI_WIN_NONE
    mov byte [gui_resize_win], GUI_WIN_NONE
.store_prev:
    mov al, [mouse_buttons]
    mov [gui_prev_mouse_buttons], al
    popad
    ret

gui_term_execute:
    pushad
    call gui_term_capture_input
    mov esi, gui_term_buf
    call skip_spaces
    cmp byte [esi], 0
    je .empty
    mov edi, cmd_help
    call match_token
    test eax, eax
    jnz .help
    mov edi, cmd_ls
    call match_token
    test eax, eax
    jnz .ls
    mov edi, cmd_cd
    call match_token
    test eax, eax
    jnz .cd
    mov edi, cmd_pwd
    call match_token
    test eax, eax
    jnz .pwd
    mov edi, cmd_date
    call match_token
    test eax, eax
    jnz .date
    mov edi, cmd_uname
    call match_token
    test eax, eax
    jnz .uname
    mov edi, cmd_sapp
    call match_token
    test eax, eax
    jnz .sapp
    mov edi, cmd_clear
    call match_token
    test eax, eax
    jnz .clear
    mov edi, cmd_settings
    call match_token
    test eax, eax
    jnz .settings
    mov edi, cmd_shutdown
    call match_token
    test eax, eax
    jnz .shutdown
    mov edi, soj_kw_exit
    call match_token
    test eax, eax
    jnz .exit
    mov dword [gui_term_output_ptr], msg_gui_term_unknown
    jmp .reset_input
.empty:
    mov dword [gui_term_output_ptr], msg_gui_term_empty
    jmp .reset_input
.help:
    mov dword [gui_term_output_ptr], msg_gui_term_help
    jmp .reset_input
.ls:
    mov dword [gui_term_output_ptr], msg_gui_term_ls_root
    jmp .reset_input
.cd:
    mov esi, gui_term_buf
    call first_arg
    mov edi, name_root
    call match_token
    test eax, eax
    jnz .cd_root
    mov edi, path_home
    call match_token
    test eax, eax
    jnz .cd_home
    mov edi, name_home
    call match_token
    test eax, eax
    jnz .cd_home
    mov edi, name_bin
    call match_token
    test eax, eax
    jnz .cd_bin
    mov edi, name_etc
    call match_token
    test eax, eax
    jnz .cd_etc
    mov edi, name_dev
    call match_token
    test eax, eax
    jnz .cd_dev
    mov dword [gui_term_output_ptr], msg_no_file
    jmp .reset_input
.cd_root:
    mov dword [gui_file_dir], GUI_DIR_ROOT
    mov dword [gui_term_output_ptr], msg_gui_term_cd_root
    jmp .reset_input
.cd_home:
    mov dword [gui_file_dir], GUI_DIR_HOME
    mov dword [gui_term_output_ptr], msg_gui_term_cd_home
    jmp .reset_input
.cd_bin:
    mov dword [gui_file_dir], GUI_DIR_BIN
    mov dword [gui_term_output_ptr], msg_gui_files_bin_path
    jmp .reset_input
.cd_etc:
    mov dword [gui_file_dir], GUI_DIR_ETC
    mov dword [gui_term_output_ptr], msg_gui_files_etc_path
    jmp .reset_input
.cd_dev:
    mov dword [gui_file_dir], GUI_DIR_DEV
    mov dword [gui_term_output_ptr], msg_gui_files_dev_path
    jmp .reset_input
.pwd:
    call gui_file_dir_path_ptr
    mov [gui_term_output_ptr], esi
    jmp .reset_input
.date:
    mov dword [gui_term_output_ptr], msg_gui_time
    jmp .reset_input
.uname:
    mov dword [gui_term_output_ptr], msg_gui_term_uname
    jmp .reset_input
.sapp:
    mov dword [gui_term_output_ptr], msg_gui_term_sapp
    jmp .reset_input
.clear:
    mov dword [gui_term_output_ptr], msg_gui_term_empty
    jmp .reset_input
.settings:
    mov al, GUI_WIN_SETTINGS
    call gui_open_window
    mov dword [gui_term_output_ptr], msg_gui_term_settings
    jmp .reset_input
.shutdown:
    mov byte [gui_power_menu_open], 1
    mov dword [gui_term_output_ptr], msg_gui_term_shutdown
    jmp .reset_input
.exit:
    mov byte [gui_win_visible + GUI_WIN_CMD], 0
    mov byte [gui_active_win], GUI_WIN_NONE
.reset_input:
    mov dword [gui_term_len], 0
    mov byte [gui_term_buf], 0
    mov byte [gui_need_redraw], 1
    popad
    ret

gui_handle_term_key:
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
    mov ecx, [gui_term_len]
    cmp ecx, 112
    jae .done
    mov edi, gui_term_buf
    add edi, ecx
    mov [edi], al
    inc ecx
    mov [gui_term_len], ecx
    mov byte [gui_term_buf + ecx], 0
    mov byte [gui_need_redraw], 1
    jmp .done
.backspace:
    mov ecx, [gui_term_len]
    test ecx, ecx
    jz .done
    dec ecx
    mov [gui_term_len], ecx
    mov byte [gui_term_buf + ecx], 0
    mov byte [gui_need_redraw], 1
    jmp .done
.enter:
    call gui_term_execute
.done:
    popad
    ret

%include "src/gui/terminal.asm"
%include "src/gui/browser.asm"
%include "src/gui/taskmgr.asm"
%include "src/gui/notepad.asm"
%include "src/gui/files.asm"

gui_handle_key:
    pushad
    cmp byte [gui_active_win], GUI_WIN_CMD
    jne .check_notepad
    call gui_handle_term_key
    jmp .done
.check_notepad:
    cmp byte [gui_active_win], GUI_WIN_NOTEPAD
    jne .check_browser
    cmp al, 8
    je .backspace
    cmp al, 13
    jne .not_enter
    mov al, ' '
    jmp .append
.not_enter:
    cmp al, 9
    jne .printable
    mov al, ' '
.printable:
    cmp al, 32
    jb .done
    cmp al, 126
    ja .done
.append:
    mov ecx, [gui_note_len]
    cmp ecx, 240
    jae .done
    mov edi, gui_note_buf
    add edi, ecx
    mov [edi], al
    inc ecx
    mov [gui_note_len], ecx
    mov byte [gui_note_buf + ecx], 0
    mov byte [gui_need_redraw], 1
    jmp .done
.backspace:
    mov ecx, [gui_note_len]
    test ecx, ecx
    jz .done
    dec ecx
    mov [gui_note_len], ecx
    mov byte [gui_note_buf + ecx], 0
    mov byte [gui_need_redraw], 1
    jmp .done
.check_browser:
    cmp byte [gui_active_win], GUI_WIN_BROWSER
    jne .done
    call gui_handle_browser_key
.done:
    popad
    ret

command_gui:
    cmp byte [fb_available], 1
    jne .no_fb
    pushad
    mov al, [text_attr]
    mov [gui_saved_attr], al
    call fb_cursor_hide
    call gui_init_windows
    call gui_redraw
    call gui_draw_cursor_current
.event_loop:
    call read_key_nonblocking
    test al, al
    jz .check_mouse
    cmp al, 27
    je .leave
    cmp byte [gui_active_win], GUI_WIN_CMD
    je .handle_key
    cmp byte [gui_active_win], GUI_WIN_NOTEPAD
    je .handle_key
    cmp byte [gui_active_win], GUI_WIN_BROWSER
    je .handle_key
    cmp al, 'q'
    je .leave
    cmp al, 'Q'
    je .leave
.handle_key:
    call gui_erase_cursor_if_drawn
    call gui_handle_key
    cmp byte [gui_need_redraw], 1
    jne .redraw_after_key_done
    call gui_redraw
.redraw_after_key_done:
    call gui_draw_cursor_current
    jmp .event_loop

.check_mouse:
    cmp byte [mouse_event_pending], 1
    jne .idle
    call gui_erase_cursor_if_drawn
    mov byte [mouse_event_pending], 0
    call gui_process_mouse
    cmp byte [gui_need_redraw], 1
    jne .mouse_cursor_only
    call gui_redraw
.mouse_cursor_only:
    call gui_draw_cursor_current
    jmp .event_loop
.idle:
    hlt
    jmp .event_loop
.leave:
    call gui_erase_cursor_if_drawn
    mov al, [gui_saved_attr]
    mov [text_attr], al
    popad
    call clear_screen
    ret
.no_fb:
    mov esi, msg_gui_no_fb
    call print_line
    ret

print_string:
    pushad
.next:
    lodsb
    test al, al
    jz .done
    call console_putc
    jmp .next
.done:
    popad
    ret

print_line:
    call print_string
    call console_newline
    ret

require_root:
    cmp dword [current_uid], 0
    je .ok
    mov esi, msg_auth_root_required
    call print_line
    xor eax, eax
    ret
.ok:
    mov eax, 1
    ret

prepare_prompt_line:
    ret

print_prompt:
    call print_current_user
    mov esi, prompt_host_sep
    call print_string
    call print_current_path
    cmp dword [current_uid], 0
    je .root
    mov esi, prompt_user_suffix
    jmp .print_suffix
.root:
    mov esi, prompt_root_suffix
.print_suffix:
    call print_string
    ret

print_current_user:
    cmp dword [current_uid], 0
    je .root
    mov esi, user_user_name
    jmp print_string
.root:
    mov esi, user_root_name
    jmp print_string

print_current_path:
    mov eax, [current_dir]
    cmp eax, DIR_ROOT
    je .root
    cmp eax, DIR_BIN
    je .bin
    cmp eax, DIR_ETC
    je .etc
    cmp eax, DIR_HOME
    je .home
    cmp eax, DIR_DEV
    je .dev
.root:
    mov esi, name_root
    jmp .print
.bin:
    mov esi, path_bin
    jmp .print
.etc:
    mov esi, path_etc
    jmp .print
.home:
    mov esi, path_home
    jmp .print
.dev:
    mov esi, path_dev
.print:
    call print_string
    ret

print_hex32:
    pushad
    mov ebx, eax
    mov esi, hex_prefix
    call print_string
    mov ecx, 8
.digit:
    rol ebx, 4
    mov eax, ebx
    and eax, 0x0F
    mov al, [hex_digits + eax]
    call console_putc
    loop .digit
    popad
    ret

print_hex8:
    pushad
    mov bl, al
    mov esi, hex_prefix
    call print_string
    mov al, bl
    shr al, 4
    and eax, 0x0F
    mov al, [hex_digits + eax]
    call console_putc
    mov al, bl
    and eax, 0x0F
    mov al, [hex_digits + eax]
    call console_putc
    popad
    ret

print_mac_addr:
    pushad
    mov al, [net_mac0]
    call print_hex8_plain
    mov al, ':'
    call console_putc
    mov al, [net_mac1]
    call print_hex8_plain
    mov al, ':'
    call console_putc
    mov al, [net_mac2]
    call print_hex8_plain
    mov al, ':'
    call console_putc
    mov al, [net_mac3]
    call print_hex8_plain
    mov al, ':'
    call console_putc
    mov al, [net_mac4]
    call print_hex8_plain
    mov al, ':'
    call console_putc
    mov al, [net_mac5]
    call print_hex8_plain
    popad
    ret

print_hex8_plain:
    pushad
    mov bl, al
    shr al, 4
    and eax, 0x0F
    mov al, [hex_digits + eax]
    call console_putc
    mov al, bl
    and eax, 0x0F
    mov al, [hex_digits + eax]
    call console_putc
    popad
    ret

print_ipv4:
    pushad
    mov ebx, eax
    mov al, bl
    call print_dec8
    mov al, '.'
    call console_putc
    mov eax, ebx
    shr eax, 8
    call print_dec8
    mov al, '.'
    call console_putc
    mov eax, ebx
    shr eax, 16
    call print_dec8
    mov al, '.'
    call console_putc
    mov eax, ebx
    shr eax, 24
    call print_dec8
    popad
    ret

print_ipv4_or_unconfigured:
    cmp eax, 0
    je .unconfigured
    call print_ipv4
    ret
.unconfigured:
    mov esi, msg_net_unconfigured
    call print_string
    ret

print_net_prefix:
    pushad
    mov eax, [net_subnet_mask]
    cmp eax, 0
    je .done
    xor ecx, ecx
.loop:
    test eax, 1
    jz .shift
    inc ecx
.shift:
    shr eax, 1
    test eax, eax
    jnz .loop
    mov al, '/'
    call console_putc
    mov eax, ecx
    call print_dec8
.done:
    popad
    ret

print_dec8:
    pushad
    movzx eax, al
    cmp eax, 100
    jb .maybe_tens
    xor edx, edx
    mov ebx, 100
    div ebx
    mov cl, al
    mov eax, edx
    mov al, cl
    add al, '0'
    call console_putc
    mov eax, edx
    xor edx, edx
    mov ebx, 10
    div ebx
    mov cl, al
    mov ch, dl
    mov al, cl
    add al, '0'
    call console_putc
    mov al, ch
    jmp .digit
.maybe_tens:
    cmp eax, 10
    jb .digit
    xor edx, edx
    mov ebx, 10
    div ebx
    mov cl, al
    mov ch, dl
    mov al, cl
    add al, '0'
    call console_putc
    mov al, ch
.digit:
    add al, '0'
    call console_putc
    popad
    ret

print_dec32:
    pushad
    cmp eax, 0
    jne .convert
    mov al, '0'
    call console_putc
    jmp .done
.convert:
    xor ecx, ecx
    mov ebx, 10
.div_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    inc ecx
    test eax, eax
    jnz .div_loop
.print_loop:
    pop eax
    call console_putc
    loop .print_loop
.done:
    popad
    ret

cmos_read_reg:
    out 0x70, al
    jmp $+2
    in al, 0x71
    ret

cmos_print_bcd:
    push eax
    mov ah, al
    shr al, 4
    and al, 0x0F
    add al, '0'
    call console_putc
    mov al, ah
    and al, 0x0F
    add al, '0'
    call console_putc
    pop eax
    ret

cmos_bcd_to_bin:
    push ebx
    mov bl, al
    and bl, 0x0F
    shr al, 4
    and al, 0x0F
    mov ah, 10
    mul ah
    add al, bl
    pop ebx
    ret

cmos_read_datetime:
    mov al, 0x09
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_year], al
    mov al, 0x08
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_month], al
    mov al, 0x07
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_day], al
    mov al, 0x04
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_hour], al
    mov al, 0x02
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_minute], al
    mov al, 0x00
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_second], al
    call apply_timezone_offset

    mov esi, msg_date_prefix
    call print_string
    mov al, [dt_year]
    call print_dec2
    mov al, '-'
    call console_putc
    mov al, [dt_month]
    call print_dec2
    mov al, '-'
    call console_putc
    mov al, [dt_day]
    call print_dec2
    mov al, ' '
    call console_putc
    mov al, [dt_hour]
    call print_dec2
    mov al, ':'
    call console_putc
    mov al, [dt_minute]
    call print_dec2
    mov al, ':'
    call console_putc
    mov al, [dt_second]
    call print_dec2
    mov al, ' '
    call console_putc
    call print_timezone_name
    call console_newline
    ret

print_motd_login_time:
    mov al, 0x09
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_year], al
    mov al, 0x08
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_month], al
    mov al, 0x07
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_day], al
    mov al, 0x04
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_hour], al
    mov al, 0x02
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_minute], al
    mov al, 0x00
    call cmos_read_reg
    call cmos_bcd_to_bin
    mov [dt_second], al
    call apply_timezone_offset
    mov esi, msg_date_prefix
    call print_string
    mov al, [dt_year]
    call print_dec2
    mov al, '-'
    call console_putc
    mov al, [dt_month]
    call print_dec2
    mov al, '-'
    call console_putc
    mov al, [dt_day]
    call print_dec2
    mov al, ' '
    call console_putc
    mov al, [dt_hour]
    call print_dec2
    mov al, ':'
    call console_putc
    mov al, [dt_minute]
    call print_dec2
    mov al, ':'
    call console_putc
    mov al, [dt_second]
    call print_dec2
    mov al, ' '
    call console_putc
    call print_timezone_name
    ret

print_dec2:
    pushad
    movzx eax, al
    xor edx, edx
    mov ebx, 10
    div ebx
    mov cl, al
    mov ch, dl
    mov al, cl
    add al, '0'
    call console_putc
    mov al, ch
    add al, '0'
    call console_putc
    popad
    ret

apply_timezone_offset:
    call timezone_offset_hours
    movsx eax, al
    movzx ebx, byte [dt_hour]
    add ebx, eax
.underflow:
    cmp ebx, 0
    jge .overflow
    add ebx, 24
    call date_prev_day
    jmp .underflow
.overflow:
    cmp ebx, 24
    jl .done
    sub ebx, 24
    call date_next_day
    jmp .overflow
.done:
    mov [dt_hour], bl
    ret

timezone_offset_hours:
    mov al, [timezone_index]
    sub al, 12
    ret

date_next_day:
    inc byte [dt_day]
    call days_in_current_month
    cmp [dt_day], al
    jbe .done
    mov byte [dt_day], 1
    inc byte [dt_month]
    cmp byte [dt_month], 12
    jbe .done
    mov byte [dt_month], 1
    inc byte [dt_year]
.done:
    ret

date_prev_day:
    cmp byte [dt_day], 1
    jne .same_month
    cmp byte [dt_month], 1
    jne .prev_month
    mov byte [dt_month], 12
    dec byte [dt_year]
    call days_in_current_month
    mov [dt_day], al
    ret
.prev_month:
    dec byte [dt_month]
    call days_in_current_month
    mov [dt_day], al
    ret
.same_month:
    dec byte [dt_day]
    ret

days_in_current_month:
    mov al, [dt_month]
    cmp al, 2
    je .feb
    cmp al, 4
    je .thirty
    cmp al, 6
    je .thirty
    cmp al, 9
    je .thirty
    cmp al, 11
    je .thirty
    mov al, 31
    ret
.thirty:
    mov al, 30
    ret
.feb:
    call is_current_year_leap
    cmp al, 1
    je .feb29
    mov al, 28
    ret
.feb29:
    mov al, 29
    ret

is_current_year_leap:
    push ebx
    push edx
    movzx eax, byte [dt_year]
    add eax, 2000
    xor edx, edx
    mov ebx, 400
    div ebx
    cmp edx, 0
    je .yes
    movzx eax, byte [dt_year]
    add eax, 2000
    xor edx, edx
    mov ebx, 100
    div ebx
    cmp edx, 0
    je .no
    movzx eax, byte [dt_year]
    add eax, 2000
    xor edx, edx
    mov ebx, 4
    div ebx
    cmp edx, 0
    je .yes
.no:
    xor al, al
    jmp .done
.yes:
    mov al, 1
.done:
    pop edx
    pop ebx
    ret

print_timezone_name:
    mov esi, tz_utc
    call print_string
    call timezone_offset_hours
    cmp al, 0
    je .done
    push eax
    cmp al, 0
    jl .minus
    mov al, '+'
    call console_putc
    pop eax
    jmp .abs_ready
.minus:
    mov al, '-'
    call console_putc
    pop eax
    neg al
.abs_ready:
    call print_dec2
.done:
    ret

set_color:
    mov [text_attr], al
    ret

set_cursor:
    mov ecx, [console_cols]
    dec ecx
    cmp eax, ecx
    jbe .x_ok
    mov eax, ecx
.x_ok:
    mov ecx, [console_rows]
    dec ecx
    cmp ebx, ecx
    jbe .y_ok
    mov ebx, ecx
.y_ok:
    mov [cursor_x], eax
    mov [cursor_y], ebx
    call update_cursor
    ret

detect_cpu_vendor:
    pushad
    xor eax, eax
    cpuid
    mov [cpu_vendor], ebx
    mov [cpu_vendor + 4], edx
    mov [cpu_vendor + 8], ecx
    mov byte [cpu_vendor + 12], 0

    mov eax, 1
    cpuid
    mov [cpu_sig], eax
    mov [cpu_feat_ecx], ecx
    mov [cpu_feat_edx], edx

    mov eax, 0x80000000
    cpuid
    mov [cpu_max_ext], eax
    cmp eax, 0x80000004
    jb .no_brand
    mov eax, 0x80000002
    cpuid
    mov [cpu_brand], eax
    mov [cpu_brand + 4], ebx
    mov [cpu_brand + 8], ecx
    mov [cpu_brand + 12], edx
    mov eax, 0x80000003
    cpuid
    mov [cpu_brand + 16], eax
    mov [cpu_brand + 20], ebx
    mov [cpu_brand + 24], ecx
    mov [cpu_brand + 28], edx
    mov eax, 0x80000004
    cpuid
    mov [cpu_brand + 32], eax
    mov [cpu_brand + 36], ebx
    mov [cpu_brand + 40], ecx
    mov [cpu_brand + 44], edx
    mov byte [cpu_brand + 48], 0
    jmp .done
.no_brand:
    mov dword [cpu_brand], 'x86 '
    mov dword [cpu_brand + 4], 'CPU '
    mov byte [cpu_brand + 8], 0
.done:
    popad
    ret

pci_config_read32:
    push ebx
    push ecx
    push edx
    mov eax, 0x80000000
    mov ebx, [pci_bus_tmp]
    shl ebx, 16
    or eax, ebx
    mov ebx, [pci_slot_tmp]
    shl ebx, 11
    or eax, ebx
    mov ebx, [pci_func_tmp]
    shl ebx, 8
    or eax, ebx
    and ecx, 0xFC
    or eax, ecx
    mov dx, 0xCF8
    out dx, eax
    mov dx, 0xCFC
    in eax, dx
    pop edx
    pop ecx
    pop ebx
    ret

pci_config_write32:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    mov esi, eax
    mov eax, 0x80000000
    mov ebx, [pci_bus_tmp]
    shl ebx, 16
    or eax, ebx
    mov ebx, [pci_slot_tmp]
    shl ebx, 11
    or eax, ebx
    mov ebx, [pci_func_tmp]
    shl ebx, 8
    or eax, ebx
    and ecx, 0xFC
    or eax, ecx
    mov dx, 0xCF8
    out dx, eax
    mov eax, esi
    mov dx, 0xCFC
    out dx, eax
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

e1000_read:
    mov edx, [e1000_mmio]
    add edx, eax
    mov eax, [edx]
    ret

e1000_write:
    mov edx, [e1000_mmio]
    add edx, eax
    mov [edx], ebx
    ret

e1000_read_mac:
    pushad
    mov eax, E1000_REG_EERD
    mov ebx, 0x00000001
    call e1000_write
    call e1000_wait_eerd
    mov [net_mac0], bl
    mov [net_mac1], bh
    mov eax, E1000_REG_EERD
    mov ebx, 0x00000101
    call e1000_write
    call e1000_wait_eerd
    mov [net_mac2], bl
    mov [net_mac3], bh
    mov eax, E1000_REG_EERD
    mov ebx, 0x00000201
    call e1000_write
    call e1000_wait_eerd
    mov [net_mac4], bl
    mov [net_mac5], bh
    mov al, [net_mac0]
    or al, [net_mac1]
    or al, [net_mac2]
    or al, [net_mac3]
    or al, [net_mac4]
    or al, [net_mac5]
    jz .read_regs
    cmp byte [net_mac0], 0xFF
    jne .done
    cmp byte [net_mac1], 0xFF
    jne .done
    cmp byte [net_mac2], 0xFF
    jne .done
    cmp byte [net_mac3], 0xFF
    jne .done
    cmp byte [net_mac4], 0xFF
    jne .done
    cmp byte [net_mac5], 0xFF
    jne .done
.read_regs:
    mov eax, E1000_REG_RAL
    call e1000_read
    mov [net_mac0], al
    mov [net_mac1], ah
    shr eax, 16
    mov [net_mac2], al
    mov [net_mac3], ah
    mov eax, E1000_REG_RAH
    call e1000_read
    mov [net_mac4], al
    mov [net_mac5], ah
.done:
    popad
    ret

e1000_wait_eerd:
    mov ecx, 100000
.wait:
    mov eax, E1000_REG_EERD
    call e1000_read
    test eax, 0x10
    jnz .ready
    loop .wait
    ret
.ready:
    shr eax, 16
    mov ebx, eax
    ret

detect_network_pci:
    pushad
    mov byte [net_found], 0
    mov byte [net_any_found], 0
    mov dword [e1000_mmio], 0
    mov dword [pci_bus_tmp], 0
.bus_loop:
    cmp dword [pci_bus_tmp], 256
    jae .done
    mov dword [pci_slot_tmp], 0
.slot_loop:
    cmp dword [pci_slot_tmp], 32
    jae .next_bus
    mov dword [pci_func_tmp], 0
.func_loop:
    cmp dword [pci_func_tmp], 8
    jae .next_slot

    xor ecx, ecx
    call pci_config_read32
    cmp ax, 0xFFFF
    je .next_func
    mov [pci_id_tmp], eax

    mov ecx, 0x08
    call pci_config_read32
    mov [pci_class_tmp], eax
    mov ebx, eax
    shr ebx, 24
    cmp bl, 0x02
    jne .check_supported
    cmp byte [net_any_found], 1
    je .check_supported
    call record_any_network_pci

.check_supported:
    mov eax, [pci_id_tmp]
    cmp ax, 0x8086
    jne .next_func
    shr eax, 16
    cmp ax, 0x100E
    je .found
    cmp ax, 0x100F
    je .found
    cmp ax, 0x10D3
    je .found

.next_func:
    inc dword [pci_func_tmp]
    jmp .func_loop
.next_slot:
    inc dword [pci_slot_tmp]
    jmp .slot_loop
.next_bus:
    inc dword [pci_bus_tmp]
    jmp .bus_loop

.found:
    mov byte [net_found], 1
    mov eax, [pci_bus_tmp]
    mov [net_bus], al
    mov eax, [pci_slot_tmp]
    mov [net_slot], al
    mov eax, [pci_func_tmp]
    mov [net_func], al
    mov eax, [pci_id_tmp]
    mov [net_vendor], ax
    shr eax, 16
    mov [net_device], ax
    mov eax, [pci_class_tmp]
    shr eax, 24
    mov [net_class], al
    mov eax, [pci_class_tmp]
    shr eax, 16
    mov [net_subclass], al
    mov ecx, 0x10
    call pci_config_read32
    mov [net_bar0], eax
    and eax, 0xFFFFFFF0
    mov [e1000_mmio], eax
    mov ecx, 0x04
    call pci_config_read32
    or eax, 0x00000006
    mov ecx, 0x04
    call pci_config_write32
.done:
    popad
    ret

record_any_network_pci:
    push eax
    push ecx
    mov byte [net_any_found], 1
    mov eax, [pci_bus_tmp]
    mov [net_any_bus], al
    mov eax, [pci_slot_tmp]
    mov [net_any_slot], al
    mov eax, [pci_func_tmp]
    mov [net_any_func], al
    mov eax, [pci_id_tmp]
    mov [net_any_vendor], ax
    shr eax, 16
    mov [net_any_device], ax
    mov eax, [pci_class_tmp]
    shr eax, 24
    mov [net_any_class], al
    mov eax, [pci_class_tmp]
    shr eax, 16
    mov [net_any_subclass], al
    mov ecx, 0x10
    call pci_config_read32
    mov [net_any_bar0], eax
    pop ecx
    pop eax
    ret

detect_storage_pci:
    pushad
    mov byte [sata_found], 0
    mov dword [sata_bar5], 0
    mov dword [sata_abar], 0
    mov dword [sata_pi], 0
    mov dword [pci_bus_tmp], 0
.bus_loop:
    cmp dword [pci_bus_tmp], 256
    jae .done
    mov dword [pci_slot_tmp], 0
.slot_loop:
    cmp dword [pci_slot_tmp], 32
    jae .next_bus
    mov dword [pci_func_tmp], 0
.func_loop:
    cmp dword [pci_func_tmp], 8
    jae .next_slot

    xor ecx, ecx
    call pci_config_read32
    cmp ax, 0xFFFF
    je .next_func
    mov [pci_id_tmp], eax

    mov ecx, 0x08
    call pci_config_read32
    mov [pci_class_tmp], eax
    mov ebx, eax
    shr ebx, 24
    cmp bl, 0x01
    jne .next_func
    mov ebx, eax
    shr ebx, 16
    cmp bl, 0x06
    jne .next_func
    call record_sata_pci
    jmp .done

.next_func:
    inc dword [pci_func_tmp]
    jmp .func_loop
.next_slot:
    inc dword [pci_slot_tmp]
    jmp .slot_loop
.next_bus:
    inc dword [pci_bus_tmp]
    jmp .bus_loop
.done:
    popad
    ret

record_sata_pci:
    push eax
    push ecx
    mov byte [sata_found], 1
    mov eax, [pci_bus_tmp]
    mov [sata_bus], al
    mov eax, [pci_slot_tmp]
    mov [sata_slot], al
    mov eax, [pci_func_tmp]
    mov [sata_func], al
    mov eax, [pci_id_tmp]
    mov [sata_vendor], ax
    shr eax, 16
    mov [sata_device], ax
    mov eax, [pci_class_tmp]
    shr eax, 24
    mov [sata_class], al
    mov eax, [pci_class_tmp]
    shr eax, 16
    mov [sata_subclass], al
    mov eax, [pci_class_tmp]
    shr eax, 8
    mov [sata_prog_if], al
    mov ecx, 0x24
    call pci_config_read32
    mov [sata_bar5], eax
    and eax, 0xFFFFFFF0
    mov [sata_abar], eax
.done:
    pop ecx
    pop eax
    ret

init_network_boot_services:
    cmp byte [net_found], 0
    je .down
    mov byte [svc_net], 1
    mov byte [svc_tcp], 1
    mov byte [svc_tls], 1
    mov byte [svc_sapp], 1
    mov byte [svc_ssh], 1
    mov byte [svc_sftp], 1
    cmp dword [net_ip_addr], 0
    jne .done
    call apply_qemu_dhcp_fallback
.done:
    ret
.down:
    mov byte [svc_net], 0
    mov byte [svc_tcp], 0
    mov byte [svc_tls], 0
    mov byte [svc_sapp], 0
    mov byte [svc_ssh], 0
    mov byte [svc_sftp], 0
    ret

init_network_services:
    cmp byte [net_found], 0
    je .down
    call e1000_init
    cmp byte [e1000_inited], 1
    jne .down
    mov byte [svc_net], 1
    mov byte [svc_tcp], 1
    mov byte [svc_tls], 1
    mov byte [svc_sapp], 1
    mov byte [svc_ssh], 1
    mov byte [svc_sftp], 1
    cmp dword [net_ip_addr], 0
    jne .done
    call net_send_dhcp_discover
    call net_poll_dhcp_lease
    cmp dword [net_ip_addr], 0
    jne .done
    call apply_qemu_dhcp_fallback
.done:
    ret
.down:
    mov byte [svc_net], 0
    mov byte [svc_tcp], 0
    mov byte [svc_tls], 0
    mov byte [svc_sapp], 0
    mov byte [svc_ssh], 0
    mov byte [svc_sftp], 0
    ret

e1000_init:
    pushad
    cmp byte [e1000_inited], 1
    je .done
    cmp dword [e1000_mmio], 0
    je .fail

    mov edi, e1000_rx_desc
    mov ecx, (E1000_RX_COUNT * 16) / 4
    xor eax, eax
    rep stosd
    mov edi, e1000_tx_desc
    mov ecx, (E1000_TX_COUNT * 16) / 4
    xor eax, eax
    rep stosd

    xor ecx, ecx
.rx_setup:
    cmp ecx, E1000_RX_COUNT
    jae .tx_setup_start
    mov eax, ecx
    imul eax, E1000_RX_BUF_SIZE
    add eax, e1000_rx_bufs
    mov ebx, ecx
    shl ebx, 4
    mov [e1000_rx_desc + ebx], eax
    mov dword [e1000_rx_desc + ebx + 4], 0
    mov word [e1000_rx_desc + ebx + 8], 0
    mov byte [e1000_rx_desc + ebx + 12], 0
    inc ecx
    jmp .rx_setup

.tx_setup_start:
    xor ecx, ecx
.tx_setup:
    cmp ecx, E1000_TX_COUNT
    jae .regs
    mov eax, ecx
    imul eax, E1000_TX_BUF_SIZE
    add eax, e1000_tx_bufs
    mov ebx, ecx
    shl ebx, 4
    mov [e1000_tx_desc + ebx], eax
    mov dword [e1000_tx_desc + ebx + 4], 0
    mov byte [e1000_tx_desc + ebx + 12], 1
    inc ecx
    jmp .tx_setup

.regs:
    mov eax, E1000_REG_RCTL
    xor ebx, ebx
    call e1000_write
    mov eax, E1000_REG_TCTL
    xor ebx, ebx
    call e1000_write

    mov eax, E1000_REG_RDBAL
    mov ebx, e1000_rx_desc
    call e1000_write
    mov eax, E1000_REG_RDBAH
    xor ebx, ebx
    call e1000_write
    mov eax, E1000_REG_RDLEN
    mov ebx, E1000_RX_COUNT * 16
    call e1000_write
    mov eax, E1000_REG_RDH
    xor ebx, ebx
    call e1000_write
    mov eax, E1000_REG_RDT
    mov ebx, E1000_RX_COUNT - 1
    call e1000_write
    mov dword [e1000_rx_tail], E1000_RX_COUNT - 1

    mov eax, E1000_REG_TDBAL
    mov ebx, e1000_tx_desc
    call e1000_write
    mov eax, E1000_REG_TDBAH
    xor ebx, ebx
    call e1000_write
    mov eax, E1000_REG_TDLEN
    mov ebx, E1000_TX_COUNT * 16
    call e1000_write
    mov eax, E1000_REG_TDH
    xor ebx, ebx
    call e1000_write
    mov eax, E1000_REG_TDT
    xor ebx, ebx
    call e1000_write
    mov dword [e1000_tx_tail], 0

    mov eax, E1000_REG_IMS
    xor ebx, ebx
    call e1000_write
    mov eax, E1000_REG_RCTL
    mov ebx, 0x0000801A
    call e1000_write
    mov eax, E1000_REG_TCTL
    mov ebx, 0x010400FA
    call e1000_write
    call e1000_read_mac
    mov byte [e1000_inited], 1
    mov byte [net_stack_inited], 1
.done:
    popad
    ret
.fail:
    mov byte [e1000_inited], 0
    mov byte [net_stack_inited], 0
    popad
    ret

e1000_send_frame:
    pushad
    cmp byte [e1000_inited], 1
    jne .done
    mov ebx, [e1000_tx_tail]
    mov edx, ebx
    imul edx, E1000_TX_BUF_SIZE
    add edx, e1000_tx_bufs
    mov edi, edx
    mov esi, disk_buffer
    movzx ecx, cx
    push ecx
    rep movsb
    pop ecx

    mov edx, ebx
    shl edx, 4
    mov word [e1000_tx_desc + edx + 8], cx
    mov byte [e1000_tx_desc + edx + 11], 0x0B
    mov byte [e1000_tx_desc + edx + 12], 0
    inc ebx
    cmp ebx, E1000_TX_COUNT
    jb .tail_ok
    xor ebx, ebx
.tail_ok:
    mov [e1000_tx_tail], ebx
    mov eax, E1000_REG_TDT
    call e1000_write
    inc dword [net_tx_packets]
.done:
    popad
    ret

e1000_poll_rx:
    pushad
    cmp byte [e1000_inited], 1
    jne .done
    mov ebx, [e1000_rx_tail]
    inc ebx
    cmp ebx, E1000_RX_COUNT
    jb .idx_ok
    xor ebx, ebx
.idx_ok:
    mov edx, ebx
    shl edx, 4
    test byte [e1000_rx_desc + edx + 12], 1
    jz .done
    mov esi, [e1000_rx_desc + edx]
    call net_handle_ethernet
    mov byte [e1000_rx_desc + edx + 12], 0
    mov [e1000_rx_tail], ebx
    mov eax, E1000_REG_RDT
    call e1000_write
    inc dword [net_rx_packets]
.done:
    popad
    ret

net_handle_ethernet:
    pushad
    mov al, [esi + 6]
    mov [net_last_rx_src_mac], al
    mov al, [esi + 7]
    mov [net_last_rx_src_mac + 1], al
    mov al, [esi + 8]
    mov [net_last_rx_src_mac + 2], al
    mov al, [esi + 9]
    mov [net_last_rx_src_mac + 3], al
    mov al, [esi + 10]
    mov [net_last_rx_src_mac + 4], al
    mov al, [esi + 11]
    mov [net_last_rx_src_mac + 5], al
    mov ax, [esi + 12]
    xchg al, ah
    cmp ax, ETH_TYPE_ARP
    je .arp
    cmp ax, ETH_TYPE_IPV4
    je .ipv4
    jmp .done
.arp:
    mov byte [net_last_proto], 1
    inc dword [net_arp_packets]
    call net_handle_arp
    jmp .done
.ipv4:
    inc dword [net_ipv4_packets]
    mov al, [esi + 14 + 9]
    cmp al, IP_PROTO_ICMP
    je .icmp
    cmp al, IP_PROTO_UDP
    je .udp
    cmp al, IP_PROTO_TCP
    je .tcp
    jmp .done
.icmp:
    mov byte [net_last_proto], IP_PROTO_ICMP
    inc dword [net_icmp_packets]
    call net_handle_icmp
    jmp .done
.udp:
    mov byte [net_last_proto], IP_PROTO_UDP
    inc dword [net_udp_packets]
    mov ax, [esi + 14 + 20 + 2]
    xchg al, ah
    cmp ax, UDP_PORT_DHCP_C
    je .dhcp
    mov ax, [esi + 14 + 20]
    xchg al, ah
    cmp ax, UDP_PORT_DNS
    je .dns
    jmp .done
.dhcp:
    inc dword [net_dhcp_packets]
    call net_handle_dhcp
    jmp .done
.dns:
    inc dword [net_dns_packets]
    call net_handle_dns
    jmp .done
.tcp:
    mov byte [net_last_proto], IP_PROTO_TCP
    inc dword [net_tcp_packets]
    call net_handle_tcp
.done:
    popad
    ret

net_handle_arp:
    pushad
    mov ax, [esi + 14 + 6]
    xchg al, ah
    cmp ax, 2
    jne .done
    mov eax, [esi + 14 + 14]
    cmp eax, [net_next_hop_ip]
    jne .done
    mov al, [esi + 14 + 8]
    mov [net_gateway_mac], al
    mov al, [esi + 14 + 9]
    mov [net_gateway_mac + 1], al
    mov al, [esi + 14 + 10]
    mov [net_gateway_mac + 2], al
    mov al, [esi + 14 + 11]
    mov [net_gateway_mac + 3], al
    mov al, [esi + 14 + 12]
    mov [net_gateway_mac + 4], al
    mov al, [esi + 14 + 13]
    mov [net_gateway_mac + 5], al
    mov byte [net_gateway_mac_valid], 1
.done:
    popad
    ret

net_handle_icmp:
    pushad
    mov al, [esi + 14 + 20]
    cmp al, 8
    je .echo_request
    cmp al, 0
    je .echo_reply
    jmp .done
.echo_request:
    inc dword [net_icmp_echo_requests]
    call net_send_icmp_echo_reply
    jmp .done
.echo_reply:
    mov eax, [esi + 14 + 12]
    cmp eax, [net_ping_target_ip]
    jne .done
    mov eax, [esi + 14 + 16]
    cmp eax, [net_ip_addr]
    jne .done
    mov ax, [esi + 14 + 20 + 6]
    xchg al, ah
    cmp ax, [ping_seq]
    jne .done
    mov al, [esi + 14 + 8]
    mov [ping_reply_ttl], al
    mov byte [net_ping_reply_received], 1
    inc dword [net_icmp_echo_replies]
.done:
    popad
    ret

net_handle_dhcp:
    pushad
    movzx ecx, word [esi + 14 + 20 + 4]
    xchg cl, ch
    cmp ecx, 248
    jb .done
    cmp ecx, 1500 - 14 - 20
    ja .done
    mov eax, [esi + 14 + 20 + 8 + 16]
    cmp eax, 0
    je .done
    mov [net_ip_addr], eax
    mov byte [dhcp_lease_valid], 1
    lea ebp, [esi + 14 + 20 + ecx]
    mov edi, esi
    add edi, 14 + 20 + 8 + 240
.options:
    cmp edi, ebp
    jae .done
    mov al, [edi]
    cmp al, 255
    je .done
    cmp al, 0
    je .pad
    lea edx, [edi + 1]
    cmp edx, ebp
    jae .done
    mov bl, [edi + 1]
    movzx ebx, bl
    lea edx, [edi + ebx + 2]
    cmp edx, ebp
    ja .done
    cmp al, 1
    je .mask
    cmp al, 3
    je .router
    cmp al, 6
    je .dns
    add edi, ebx
    add edi, 2
    jmp .options
.pad:
    inc edi
    jmp .options
.mask:
    cmp ebx, 4
    jb .skip
    mov eax, [edi + 2]
    mov [net_subnet_mask], eax
    jmp .skip
.router:
    cmp ebx, 4
    jb .skip
    mov eax, [edi + 2]
    mov [net_gateway_ip], eax
    mov byte [net_gateway_mac_valid], 0
    jmp .skip
.dns:
    cmp ebx, 4
    jb .skip
    mov eax, [edi + 2]
    mov [net_dns_ip], eax
    mov [net_dhcp_dns_ip], eax
.skip:
    add edi, ebx
    add edi, 2
    jmp .options
.done:
    popad
    ret

net_handle_dns:
    pushad
    movzx ecx, word [esi + 14 + 20 + 4]
    xchg cl, ch
    cmp ecx, 28
    jb .done
    mov edi, esi
    add edi, 14 + 20 + 8
    mov ax, [edi]
    cmp ax, 0x4B53
    jne .done
    mov al, [edi + 3]
    and al, 0x0F
    jz .rcode_ok
    mov byte [net_dns_rx_valid], 2
    jmp .done
.rcode_ok:
    mov ax, [edi + 6]
    xchg al, ah
    test ax, ax
    jz .done
    movzx ecx, ax
    mov eax, [net_dns_query_len]
    add eax, 16
    mov ebp, edi
    movzx edx, word [esi + 14 + 20 + 4]
    xchg dl, dh
    add ebp, edx
    cmp eax, edx
    jae .done
    mov ebx, edi
    add ebx, eax
.answer_loop:
    test ecx, ecx
    jz .done
    dec ecx
.skip_name:
    cmp ebx, ebp
    jae .done
    mov al, [ebx]
    test al, 0xC0
    jnz .compressed_name
    test al, al
    jz .name_done
    movzx eax, al
    inc ebx
    add ebx, eax
    jmp .skip_name
.compressed_name:
    add ebx, 2
    jmp .fields
.name_done:
    inc ebx
.fields:
    mov edx, ebx
    add edx, 10
    cmp edx, ebp
    ja .done
    mov ax, [ebx + 8]
    xchg al, ah
    movzx edx, ax
    mov edi, ebx
    add edi, 10
    add edi, edx
    cmp edi, ebp
    ja .done
    mov ax, [ebx]
    xchg al, ah
    cmp ax, 1
    jne .next_answer
    mov ax, [ebx + 2]
    xchg al, ah
    cmp ax, 1
    jne .next_answer
    cmp edx, 4
    jne .next_answer
    mov eax, [ebx + 10]
    mov [net_dns_resolved_ip], eax
    mov byte [net_dns_rx_valid], 1
    jmp .done
.next_answer:
    mov ebx, edi
    jmp .answer_loop
.done:
    popad
    ret

net_handle_tcp:
    pushad
    mov ax, [esi + 14 + 20 + 2]
    xchg al, ah
    cmp ax, [http_client_port]
    jne .check_ssh_service
    mov eax, [esi + 14 + 12]
    cmp eax, [net_ping_target_ip]
    jne .check_ssh_service
    test byte [esi + 14 + 20 + 13], TCP_FLAG_RST
    jz .http_not_rst
    mov byte [http_tcp_state], 3
    jmp .done
.http_not_rst:
    test byte [esi + 14 + 20 + 13], TCP_FLAG_SYN
    jz .http_data
    test byte [esi + 14 + 20 + 13], TCP_FLAG_ACK
    jz .check_ssh_service
    mov eax, [esi + 14 + 20 + 4]
    bswap eax
    mov [http_server_seq], eax
    inc eax
    mov [http_next_server_seq], eax
    mov [http_ack_seq], eax
    mov byte [http_tcp_state], 2
    jmp .done
.http_data:
    mov eax, [esi + 14 + 20 + 4]
    bswap eax
    cmp eax, [http_next_server_seq]
    jne .http_maybe_fin
    movzx ecx, word [esi + 14 + 2]
    xchg cl, ch
    sub ecx, 20
    movzx edx, byte [esi + 14 + 20 + 12]
    shr edx, 4
    shl edx, 2
    cmp ecx, edx
    jbe .http_maybe_fin
    sub ecx, edx
    push esi
    mov esi, esi
    add esi, 14 + 20
    add esi, edx
    mov edi, http_response_buf
    add edi, [http_response_len]
    mov eax, 4095
    sub eax, [http_response_len]
    cmp ecx, eax
    jbe .http_copy_len_ok
    mov ecx, eax
    mov byte [http_response_overflow], 1
.http_copy_len_ok:
    test ecx, ecx
    jz .http_copied
    add [http_response_len], ecx
    rep movsb
    mov byte [edi], 0
.http_copied:
    pop esi
    movzx ecx, word [esi + 14 + 2]
    xchg cl, ch
    sub ecx, 20
    movzx edx, byte [esi + 14 + 20 + 12]
    shr edx, 4
    shl edx, 2
    sub ecx, edx
    add [http_next_server_seq], ecx
    mov eax, [http_next_server_seq]
    mov [http_ack_seq], eax
    call net_send_http_ack
.http_maybe_fin:
    test byte [esi + 14 + 20 + 13], TCP_FLAG_FIN
    jz .done
    inc dword [http_next_server_seq]
    mov eax, [http_next_server_seq]
    mov [http_ack_seq], eax
    call net_send_http_ack
    mov byte [http_response_done], 1
    mov byte [http_tcp_state], 4
    jmp .done
.check_ssh_service:
    cmp byte [svc_ssh], 1
    jne .done
    test byte [esi + 14 + 20 + 13], TCP_FLAG_SYN
    jz .not_syn_count
    inc dword [net_tcp_syn_packets]
.not_syn_count:
    test byte [esi + 14 + 20 + 13], TCP_FLAG_ACK
    jz .not_ack_count
    inc dword [net_tcp_ack_packets]
.not_ack_count:
    test byte [esi + 14 + 20 + 13], TCP_FLAG_PSH
    jz .not_psh_count
    inc dword [net_tcp_psh_packets]
.not_psh_count:
    test byte [esi + 14 + 20 + 13], TCP_FLAG_RST
    jz .not_rst_count
    inc dword [net_tcp_rst_packets]
.not_rst_count:
    mov ax, [esi + 14 + 20 + 2]
    xchg al, ah
    cmp ax, TCP_PORT_SSH
    jne .done
    mov ax, [esi + 14 + 20]
    xchg al, ah
    mov [ssh_client_port], ax
    mov eax, [esi + 14 + 12]
    mov [ssh_client_ip], eax
    mov eax, [esi + 14 + 20 + 4]
    bswap eax
    mov [ssh_client_seq], eax
    test byte [esi + 14 + 20 + 13], TCP_FLAG_SYN
    jz .maybe_ack
    inc dword [ssh_rx_syn_packets]
    mov byte [ssh_connected], 0
    call net_send_ssh_synack
    jmp .done
.maybe_ack:
    test byte [esi + 14 + 20 + 13], TCP_FLAG_ACK
    jz .done
    cmp byte [ssh_connected], 1
    je .done
    mov byte [ssh_connected], 1
    call net_send_ssh_banner
.done:
    popad
    ret

net_build_eth_header:
    push esi
    push edi
    push ecx
    mov edi, disk_buffer
    mov ecx, 6
    rep movsb
    mov al, [net_mac0]
    stosb
    mov al, [net_mac1]
    stosb
    mov al, [net_mac2]
    stosb
    mov al, [net_mac3]
    stosb
    mov al, [net_mac4]
    stosb
    mov al, [net_mac5]
    stosb
    mov ax, bx
    xchg al, ah
    stosw
    pop ecx
    pop edi
    pop esi
    ret

net_ipv4_checksum:
    push ebx
    push ecx
    push edx
    xor edx, edx
    mov ecx, 10
.loop:
    movzx ebx, word [esi]
    xchg bl, bh
    add edx, ebx
    adc edx, 0
    add esi, 2
    loop .loop
.fold:
    mov eax, edx
    shr eax, 16
    and edx, 0xFFFF
    add edx, eax
    cmp edx, 0xFFFF
    ja .fold
    mov eax, edx
    not ax
    xchg al, ah
    pop edx
    pop ecx
    pop ebx
    ret

net_tcp_checksum:
    push ebx
    push ecx
    push edx
    push edi
    xor edx, edx
    movzx eax, word [esi + 12]
    xchg al, ah
    add edx, eax
    adc edx, 0
    movzx eax, word [esi + 14]
    xchg al, ah
    add edx, eax
    adc edx, 0
    movzx eax, word [esi + 16]
    xchg al, ah
    add edx, eax
    adc edx, 0
    movzx eax, word [esi + 18]
    xchg al, ah
    add edx, eax
    adc edx, 0
    movzx eax, byte [esi + 9]
    add edx, eax
    adc edx, 0
    mov eax, ebx
    xchg al, ah
    add edx, eax
    adc edx, 0
    mov edi, esi
    add edi, 20
    mov ecx, ebx
.loop:
    cmp ecx, 1
    jb .fold
    movzx eax, word [edi]
    xchg al, ah
    add edx, eax
    adc edx, 0
    add edi, 2
    sub ecx, 2
    jmp .loop
.fold:
    cmp ecx, 0
    je .fold_loop
    movzx eax, byte [edi]
    shl eax, 8
    add edx, eax
    adc edx, 0
.fold_loop:
    mov eax, edx
    shr eax, 16
    and edx, 0xFFFF
    add edx, eax
    cmp edx, 0xFFFF
    ja .fold_loop
    mov eax, edx
    not ax
    xchg al, ah
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret

net_icmp_checksum:
    push ebx
    push ecx
    push edx
    push esi
    xor edx, edx
.loop:
    cmp ecx, 1
    jb .fold
    movzx ebx, word [esi]
    xchg bl, bh
    add edx, ebx
    adc edx, 0
    add esi, 2
    sub ecx, 2
    jmp .loop
.fold:
    cmp ecx, 0
    je .fold_loop
    movzx ebx, byte [esi]
    shl ebx, 8
    add edx, ebx
    adc edx, 0
.fold_loop:
    mov eax, edx
    shr eax, 16
    and edx, 0xFFFF
    add edx, eax
    cmp edx, 0xFFFF
    ja .fold_loop
    mov eax, edx
    not ax
    xchg al, ah
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

net_select_next_hop:
    push eax
    push ebx
    cmp dword [net_subnet_mask], 0
    je .gateway
    mov eax, [net_ping_target_ip]
    and eax, [net_subnet_mask]
    mov ebx, [net_ip_addr]
    and ebx, [net_subnet_mask]
    cmp eax, ebx
    jne .gateway
    mov eax, [net_ping_target_ip]
    jmp .store
.gateway:
    mov eax, [net_gateway_ip]
.store:
    cmp eax, [net_next_hop_ip]
    je .done
    mov [net_next_hop_ip], eax
    mov byte [net_gateway_mac_valid], 0
.done:
    pop ebx
    pop eax
    ret

net_select_dns_next_hop:
    push eax
    push ebx
    cmp dword [net_subnet_mask], 0
    je .gateway
    mov eax, [net_dns_ip]
    and eax, [net_subnet_mask]
    mov ebx, [net_ip_addr]
    and ebx, [net_subnet_mask]
    cmp eax, ebx
    jne .gateway
    mov eax, [net_dns_ip]
    jmp .store
.gateway:
    mov eax, [net_gateway_ip]
.store:
    cmp eax, [net_next_hop_ip]
    je .done
    mov [net_next_hop_ip], eax
    mov byte [net_gateway_mac_valid], 0
.done:
    pop ebx
    pop eax
    ret

net_send_arp_request:
    pushad
    mov esi, net_broadcast_mac
    mov bx, ETH_TYPE_ARP
    call net_build_eth_header
    mov edi, disk_buffer + 14
    mov ax, 0x0100
    stosw
    mov ax, 0x0008
    stosw
    mov al, 6
    stosb
    mov al, 4
    stosb
    mov ax, 0x0100
    stosw
    mov al, [net_mac0]
    stosb
    mov al, [net_mac1]
    stosb
    mov al, [net_mac2]
    stosb
    mov al, [net_mac3]
    stosb
    mov al, [net_mac4]
    stosb
    mov al, [net_mac5]
    stosb
    mov eax, [net_ip_addr]
    stosd
    xor eax, eax
    stosd
    stosw
    mov eax, [net_next_hop_ip]
    stosd
    mov cx, 60
    call e1000_send_frame
    popad
    ret

net_await_next_hop_mac:
    push ecx
    cmp byte [net_gateway_mac_valid], 1
    je .done
    call net_send_arp_request
    mov ecx, ARP_WAIT_POLLS
.loop:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .done
    call net_poll_rx_burst
    cmp byte [net_gateway_mac_valid], 1
    je .done
    call ping_wait_delay
    loop .loop
.done:
    pop ecx
    mov al, [net_gateway_mac_valid]
    ret

net_send_icmp_echo:
    pushad
    call net_select_next_hop
    cmp byte [net_gateway_mac_valid], 1
    je .known_mac
    call net_await_next_hop_mac
    cmp al, 1
    jne .done
.known_mac:
    mov esi, net_gateway_mac
.build:
    mov bx, ETH_TYPE_IPV4
    call net_build_eth_header
    mov edi, disk_buffer + 14
    mov al, 0x45
    stosb
    xor al, al
    stosb
    mov ax, 0x1C00
    stosw
    mov ax, 0x0100
    stosw
    xor ax, ax
    stosw
    mov al, 64
    stosb
    mov al, IP_PROTO_ICMP
    stosb
    xor ax, ax
    stosw
    mov eax, [net_ip_addr]
    stosd
    mov eax, [net_ping_target_ip]
    stosd
    mov esi, disk_buffer + 14
    call net_ipv4_checksum
    mov [disk_buffer + 14 + 10], ax
    mov edi, disk_buffer + 14 + 20
    mov al, 8
    stosb
    xor al, al
    stosb
    xor ax, ax
    stosw
    mov ax, 0x0100
    stosw
    mov ax, [ping_seq]
    xchg al, ah
    stosw
    mov esi, disk_buffer + 14 + 20
    mov ecx, 8
    call net_icmp_checksum
    mov [disk_buffer + 14 + 20 + 2], ax
    mov cx, 60
    call e1000_send_frame
.done:
    popad
    ret

net_send_icmp_echo_reply:
    pushad
    mov ebp, esi
    mov esi, net_last_rx_src_mac
    mov bx, ETH_TYPE_IPV4
    call net_build_eth_header
    mov edi, disk_buffer + 14
    mov al, 0x45
    stosb
    xor al, al
    stosb
    mov ax, 0x1C00
    stosw
    mov ax, 0x1100
    stosw
    xor ax, ax
    stosw
    mov al, 64
    stosb
    mov al, IP_PROTO_ICMP
    stosb
    xor ax, ax
    stosw
    mov eax, [net_ip_addr]
    stosd
    mov eax, [ebp + 14 + 12]
    stosd
    mov esi, disk_buffer + 14
    call net_ipv4_checksum
    mov [disk_buffer + 14 + 10], ax
    mov edi, disk_buffer + 14 + 20
    xor al, al
    stosb
    xor al, al
    stosb
    xor ax, ax
    stosw
    mov ax, [ebp + 14 + 20 + 4]
    stosw
    mov ax, [ebp + 14 + 20 + 6]
    stosw
    mov esi, disk_buffer + 14 + 20
    mov ecx, 8
    call net_icmp_checksum
    mov [disk_buffer + 14 + 20 + 2], ax
    mov cx, 60
    call e1000_send_frame
    popad
    ret

net_send_dhcp_discover:
    pushad
    mov esi, net_broadcast_mac
    mov bx, ETH_TYPE_IPV4
    call net_build_eth_header
    mov edi, disk_buffer + 14
    mov al, 0x45
    stosb
    xor al, al
    stosb
    mov ax, 0x4F01
    stosw
    mov ax, 0x0200
    stosw
    xor ax, ax
    stosw
    mov al, 64
    stosb
    mov al, IP_PROTO_UDP
    stosb
    xor ax, ax
    stosw
    xor eax, eax
    stosd
    mov eax, 0xFFFFFFFF
    stosd
    mov esi, disk_buffer + 14
    call net_ipv4_checksum
    mov [disk_buffer + 14 + 10], ax

    mov edi, disk_buffer + 14 + 20
    mov ax, 0x4400
    stosw
    mov ax, 0x4300
    stosw
    mov ax, 0x3B01
    stosw
    xor ax, ax
    stosw
    mov al, 1
    stosb
    mov al, 1
    stosb
    mov al, 6
    stosb
    xor al, al
    stosb
    mov eax, 0x12345678
    stosd
    xor eax, eax
    mov ecx, 5
    rep stosd
    mov al, [net_mac0]
    stosb
    mov al, [net_mac1]
    stosb
    mov al, [net_mac2]
    stosb
    mov al, [net_mac3]
    stosb
    mov al, [net_mac4]
    stosb
    mov al, [net_mac5]
    stosb
    mov ecx, 202
    xor al, al
    rep stosb
    mov eax, 0x63538263
    stosd
    mov al, 53
    stosb
    mov al, 1
    stosb
    mov al, 1
    stosb
    mov al, 55
    stosb
    mov al, 3
    stosb
    mov al, 1
    stosb
    mov al, 3
    stosb
    mov al, 6
    stosb
    mov al, 255
    stosb
    mov cx, 349
    call e1000_send_frame
    popad
    ret

net_poll_dhcp_lease:
    push ecx
    mov ecx, DHCP_WAIT_POLLS
.loop:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .done
    call net_poll_rx_burst
    cmp dword [net_ip_addr], 0
    jne .done
    mov eax, ecx
    and eax, DHCP_RETRY_POLLS - 1
    cmp eax, 0
    jne .delay
    call net_send_dhcp_discover
.delay:
    call ping_wait_delay
    loop .loop
.done:
    pop ecx
    ret

apply_qemu_dhcp_fallback:
    cmp byte [svc_net], 1
    jne .done
    cmp byte [net_qemu_fallback_enabled], 1
    jne .done
    cmp dword [net_ip_addr], 0
    jne .done
    mov dword [net_ip_addr], 0x0F02000A
    mov dword [net_subnet_mask], 0x00FFFFFF
    mov dword [net_gateway_ip], 0x0202000A
    mov dword [net_dns_ip], 0x0302000A
    mov dword [net_dhcp_dns_ip], 0x0302000A
    mov byte [net_gateway_mac_valid], 0
    mov byte [dhcp_lease_valid], 1
.done:
    ret

net_send_dns_query:
    pushad
    call net_select_dns_next_hop
    cmp byte [net_gateway_mac_valid], 1
    je .known_mac
    call net_await_next_hop_mac
    cmp al, 1
    jne .done
.known_mac:
    mov esi, net_gateway_mac
.build:
    mov bx, ETH_TYPE_IPV4
    call net_build_eth_header
    mov edi, disk_buffer + 14
    mov al, 0x45
    stosb
    xor al, al
    stosb
    mov eax, [net_dns_query_len]
    add eax, 44
    xchg al, ah
    stosw
    mov ax, 0x0300
    stosw
    xor ax, ax
    stosw
    mov al, 64
    stosb
    mov al, IP_PROTO_UDP
    stosb
    xor ax, ax
    stosw
    mov eax, [net_ip_addr]
    stosd
    mov eax, [net_dns_ip]
    stosd
    mov esi, disk_buffer + 14
    call net_ipv4_checksum
    mov [disk_buffer + 14 + 10], ax

    mov edi, disk_buffer + 14 + 20
    mov ax, 0x3930
    stosw
    mov ax, 0x3500
    stosw
    mov eax, [net_dns_query_len]
    add eax, 24
    xchg al, ah
    stosw
    xor ax, ax
    stosw

    mov ax, 0x4B53
    stosw
    mov ax, 0x0001
    stosw
    mov ax, 0x0100
    stosw
    xor ax, ax
    stosw
    xor ax, ax
    stosw
    xor ax, ax
    stosw

    mov esi, [net_dns_query_ptr]
    mov ecx, [net_dns_query_len]
    rep movsb
    mov ax, 0x0100
    stosw
    mov ax, 0x0100
    stosw

    mov ecx, [net_dns_query_len]
    add ecx, 58
    call e1000_send_frame
.done:
    popad
    ret

net_send_http_syn:
    pushad
    call net_select_next_hop
    cmp byte [net_gateway_mac_valid], 1
    je .known_mac
    call net_await_next_hop_mac
    cmp al, 1
    jne .done
.known_mac:
    mov esi, net_gateway_mac
    mov bx, ETH_TYPE_IPV4
    call net_build_eth_header
    mov edi, disk_buffer + 14
    mov al, 0x45
    stosb
    xor al, al
    stosb
    mov ax, 0x2800
    stosw
    mov ax, 0x4000
    stosw
    xor ax, ax
    stosw
    mov al, 64
    stosb
    mov al, IP_PROTO_TCP
    stosb
    xor ax, ax
    stosw
    mov eax, [net_ip_addr]
    stosd
    mov eax, [net_ping_target_ip]
    stosd
    mov esi, disk_buffer + 14
    call net_ipv4_checksum
    mov [disk_buffer + 14 + 10], ax

    mov edi, disk_buffer + 14 + 20
    mov ax, [http_client_port]
    xchg al, ah
    stosw
    mov ax, 0x5000
    stosw
    mov eax, [http_client_seq]
    bswap eax
    stosd
    xor eax, eax
    stosd
    mov al, 0x50
    stosb
    mov al, TCP_FLAG_SYN
    stosb
    mov ax, 0x0020
    stosw
    xor ax, ax
    stosw
    xor ax, ax
    stosw
    mov ebx, 20
    mov esi, disk_buffer + 14
    call net_tcp_checksum
    mov [disk_buffer + 14 + 20 + 16], ax
    mov cx, 54
    call e1000_send_frame
    mov byte [http_tcp_state], 1
.done:
    popad
    ret

net_build_http_tcp_base:
    pushad
    mov esi, net_gateway_mac
    mov bx, ETH_TYPE_IPV4
    call net_build_eth_header
    mov edi, disk_buffer + 14
    mov al, 0x45
    stosb
    xor al, al
    stosb
    xor ax, ax
    stosw
    mov ax, 0x4100
    stosw
    xor ax, ax
    stosw
    mov al, 64
    stosb
    mov al, IP_PROTO_TCP
    stosb
    xor ax, ax
    stosw
    mov eax, [net_ip_addr]
    stosd
    mov eax, [net_ping_target_ip]
    stosd
    popad
    ret

net_send_http_ack:
    pushad
    call net_build_http_tcp_base
    mov ax, 0x2800
    mov [disk_buffer + 14 + 2], ax
    mov esi, disk_buffer + 14
    call net_ipv4_checksum
    mov [disk_buffer + 14 + 10], ax
    mov edi, disk_buffer + 14 + 20
    mov ax, [http_client_port]
    xchg al, ah
    stosw
    mov ax, 0x5000
    stosw
    mov eax, [http_client_seq]
    bswap eax
    stosd
    mov eax, [http_ack_seq]
    bswap eax
    stosd
    mov al, 0x50
    stosb
    mov al, TCP_FLAG_ACK
    stosb
    mov ax, 0x0020
    stosw
    xor ax, ax
    stosw
    xor ax, ax
    stosw
    mov ebx, 20
    mov esi, disk_buffer + 14
    call net_tcp_checksum
    mov [disk_buffer + 14 + 20 + 16], ax
    mov cx, 54
    call e1000_send_frame
    popad
    ret

net_send_http_get_sapp_index:
    pushad
    call net_build_http_tcp_base
    mov edi, disk_buffer + 14 + 20
    mov ax, [http_client_port]
    xchg al, ah
    stosw
    mov ax, 0x5000
    stosw
    mov eax, [http_client_seq]
    inc eax
    bswap eax
    stosd
    mov eax, [http_next_server_seq]
    bswap eax
    stosd
    mov al, 0x50
    stosb
    mov al, TCP_FLAG_PSH | TCP_FLAG_ACK
    stosb
    mov ax, 0x0020
    stosw
    xor ax, ax
    stosw
    xor ax, ax
    stosw
    mov esi, http_get_sapp_index
    xor edx, edx
.copy:
    lodsb
    test al, al
    jz .copied
    stosb
    inc edx
    jmp .copy
.copied:
    mov eax, [http_client_seq]
    inc eax
    add eax, edx
    mov [http_client_seq], eax
    mov eax, edx
    add eax, 40
    xchg al, ah
    mov [disk_buffer + 14 + 2], ax
    mov esi, disk_buffer + 14
    call net_ipv4_checksum
    mov [disk_buffer + 14 + 10], ax
    mov eax, edx
    add eax, 20
    mov ebx, eax
    mov esi, disk_buffer + 14
    call net_tcp_checksum
    mov [disk_buffer + 14 + 20 + 16], ax
    mov ecx, edx
    add ecx, 54
    call e1000_send_frame
    popad
    ret

net_send_ssh_synack:
    pushad
    call net_build_ssh_tcp_base
    mov ax, 0x2800
    mov [disk_buffer + 14 + 2], ax
    mov esi, disk_buffer + 14
    call net_ipv4_checksum
    mov [disk_buffer + 14 + 10], ax
    mov edi, disk_buffer + 14 + 20
    mov ax, 0x1600
    stosw
    mov ax, [ssh_client_port]
    xchg al, ah
    stosw
    mov eax, [ssh_server_seq]
    bswap eax
    stosd
    mov eax, [ssh_client_seq]
    inc eax
    bswap eax
    stosd
    mov al, 0x50
    stosb
    mov al, TCP_FLAG_SYN | TCP_FLAG_ACK
    stosb
    mov ax, 0x0020
    stosw
    xor ax, ax
    stosw
    xor ax, ax
    stosw
    mov ebx, 20
    mov esi, disk_buffer + 14
    call net_tcp_checksum
    mov [disk_buffer + 14 + 20 + 16], ax
    mov cx, 54
    call e1000_send_frame
    popad
    ret

net_send_ssh_banner:
    pushad
    call net_build_ssh_tcp_base
    mov edi, disk_buffer + 14 + 20
    mov ax, 0x1600
    stosw
    mov ax, [ssh_client_port]
    xchg al, ah
    stosw
    mov eax, [ssh_server_seq]
    inc eax
    bswap eax
    stosd
    mov eax, [ssh_client_seq]
    bswap eax
    stosd
    mov al, 0x50
    stosb
    mov al, TCP_FLAG_PSH | TCP_FLAG_ACK
    stosb
    mov ax, 0x0020
    stosw
    xor ax, ax
    stosw
    xor ax, ax
    stosw
    mov esi, ssh_server_banner
.copy:
    lodsb
    test al, al
    jz .copied
    stosb
    jmp .copy
.copied:
    mov ebx, edi
    sub ebx, disk_buffer + 14 + 20
    mov eax, ebx
    add eax, 20
    xchg al, ah
    mov [disk_buffer + 14 + 2], ax
    mov esi, disk_buffer + 14
    call net_ipv4_checksum
    mov [disk_buffer + 14 + 10], ax
    mov esi, disk_buffer + 14
    call net_tcp_checksum
    mov [disk_buffer + 14 + 20 + 16], ax
    mov ecx, edi
    sub ecx, disk_buffer
    call e1000_send_frame
    inc dword [ssh_tx_banner_packets]
    popad
    ret

net_build_ssh_tcp_base:
    pushad
    mov esi, net_last_rx_src_mac
    mov bx, ETH_TYPE_IPV4
    call net_build_eth_header
    mov edi, disk_buffer + 14
    mov al, 0x45
    stosb
    xor al, al
    stosb
    mov ax, 0x2800
    stosw
    mov ax, 0x2200
    stosw
    xor ax, ax
    stosw
    mov al, 64
    stosb
    mov al, IP_PROTO_TCP
    stosb
    xor ax, ax
    stosw
    mov eax, [net_ip_addr]
    stosd
    mov eax, [ssh_client_ip]
    stosd
    popad
    ret

read_line:
    push edi
    push ecx
    mov edi, input_buffer
    xor ecx, ecx
    mov byte [input_buffer], 0
    mov dword [input_len], 0
    mov dword [input_pos], 0
    mov dword [input_view_start], 0
    mov eax, [cursor_x]
    mov [input_start_x], eax
    mov eax, [cursor_y]
    mov [input_start_y], eax
    mov dword [history_view], -1
    mov byte [history_draft_valid], 0

.next_key:
    call read_key
.handle_key:
    cmp al, 0x03
    je .cancel
    cmp al, 13
    je .enter
    cmp al, 8
    je .backspace
    cmp al, 0x01
    je .home
    cmp al, 0x02
    je .cursor_left
    cmp al, 0x04
    je .delete
    cmp al, 0x05
    je .end
    cmp al, 0x06
    je .cursor_right
    cmp al, 0x0B
    je .kill_after
    cmp al, 0x0C
    je .clear_redraw
    cmp al, 0x0E
    je .history_down
    cmp al, 0x10
    je .history_up
    cmp al, 0x15
    je .kill_before
    cmp al, 0x17
    je .kill_word_before
    cmp al, 0x80
    je .history_up
    cmp al, 0x81
    je .history_down
    cmp al, 0x82
    je .cursor_left
    cmp al, 0x83
    je .cursor_right
    cmp al, 0x84
    je .home
    cmp al, 0x85
    je .end
    cmp al, 0x86
    je .delete
    cmp al, 0x87
    je .word_left
    cmp al, 0x88
    je .word_right
    cmp al, 32
    jb .next_key
    cmp dword [input_len], 255
    jae .next_key

    call line_insert_char
    jmp .after_key

.backspace:
    cmp dword [input_pos], 0
    je .after_key
    call line_backspace
    jmp .after_key

.delete:
    mov eax, [input_pos]
    cmp eax, [input_len]
    jae .after_key
    call line_delete_char
    jmp .after_key

.cursor_left:
    cmp dword [input_pos], 0
    je .after_key
    dec dword [input_pos]
    call redraw_input_line
    jmp .after_key

.cursor_right:
    mov eax, [input_pos]
    cmp eax, [input_len]
    jae .after_key
    inc dword [input_pos]
    call redraw_input_line
    jmp .after_key

.word_left:
    call line_word_left
    jmp .after_key

.word_right:
    call line_word_right
    jmp .after_key

.home:
    mov dword [input_pos], 0
    call redraw_input_line
    jmp .after_key

.end:
    mov eax, [input_len]
    mov [input_pos], eax
    call redraw_input_line
    jmp .after_key

.kill_before:
    call line_kill_before_cursor
    jmp .after_key

.kill_after:
    call line_kill_after_cursor
    jmp .after_key

.kill_word_before:
    call line_kill_word_before_cursor
    jmp .after_key

.clear_redraw:
    call input_clear_screen_redraw
    jmp .after_key

.history_up:
    call history_previous
    jmp .reload

.history_down:
    call history_next

.reload:
    mov edi, input_buffer
    xor ecx, ecx
.count_reload:
    cmp byte [edi + ecx], 0
    je .redraw
    inc ecx
    cmp ecx, 255
    jb .count_reload
.redraw:
    mov [input_len], ecx
    mov [input_pos], ecx
    mov dword [input_view_start], 0
    call redraw_input_line
    add edi, ecx
    jmp .after_key

.after_key:
    call fb_cursor_show
    jmp .next_key

.enter:
    mov edi, input_buffer
    add edi, [input_len]
    mov byte [edi], 0
    cmp dword [input_len], 0
    je .empty_enter
    call console_newline
    call history_save
    pop ecx
    pop edi
    ret
.empty_enter:
    call console_newline
    pop ecx
    pop edi
    ret
.cancel:
    mov byte [input_buffer], 0
    mov dword [input_len], 0
    mov dword [input_pos], 0
    mov dword [input_view_start], 0
    mov esi, msg_command_cancelled
    call print_line
    mov byte [command_cancelled], 0
    pop ecx
    pop edi
    ret

read_password_prompt:
    push esi
    push edi
    push ecx
    call print_string
    mov edi, auth_buffer
    xor ecx, ecx
    mov byte [auth_buffer], 0
.next_key:
    call read_key
    cmp al, 0x03
    je .cancel
    cmp al, 13
    je .enter
    cmp al, 8
    je .backspace
    cmp al, 32
    jb .next_key
    cmp ecx, 63
    jae .next_key
    mov [edi], al
    inc edi
    inc ecx
    mov al, '*'
    call console_putc
    call fb_cursor_show
    jmp .next_key
.backspace:
    cmp ecx, 0
    je .next_key
    dec edi
    dec ecx
    mov byte [edi], 0
    call console_backspace
    call fb_cursor_show
    jmp .next_key
.enter:
    mov byte [edi], 0
    call console_newline
    pop ecx
    pop edi
    pop esi
    ret
.cancel:
    mov byte [auth_buffer], 0
    call console_newline
    pop ecx
    pop edi
    pop esi
    ret

read_key:
    push ebx
    cmp byte [fb_available], 1
    jne .wait
    mov dword [fb_cursor_ticks], 0
    call fb_cursor_show
.wait:
    call read_scancode
.read:
    cmp al, 0xE0
    je .extended
    cmp al, 0x01
    je .esc
    cmp al, 0x2A
    je .shift_down
    cmp al, 0x36
    je .shift_down
    cmp al, 0x1D
    je .ctrl_down
    cmp al, 0xAA
    je .shift_up
    cmp al, 0xB6
    je .shift_up
    cmp al, 0x9D
    je .ctrl_up
    test al, 0x80
    jnz .wait

    movzx ebx, al
    cmp ebx, 128
    jae .wait
    cmp byte [shift_state], 0
    jne .use_shift
    mov al, [scancode_lower + ebx]
    jmp .got

.use_shift:
    mov al, [scancode_shift + ebx]

.got:
    test al, al
    jz .wait
    cmp byte [ctrl_state], 0
    je .return
    cmp al, 'a'
    jb .check_upper_ctrl
    cmp al, 'z'
    ja .check_upper_ctrl
    sub al, 'a' - 1
    jmp .ctrl_return
.check_upper_ctrl:
    cmp al, 'A'
    jb .return
    cmp al, 'Z'
    ja .return
    sub al, 'A' - 1
.ctrl_return:
    cmp al, 0x03
    jne .ctrl_done
    mov byte [command_cancelled], 1
.ctrl_done:
    call fb_cursor_hide
    pop ebx
    ret
.return:
    call fb_cursor_hide
    pop ebx
    ret

.shift_down:
    mov byte [shift_state], 1
    jmp .wait

.shift_up:
    mov byte [shift_state], 0
    jmp .wait

.ctrl_down:
    mov byte [ctrl_state], 1
    jmp .wait

.ctrl_up:
    mov byte [ctrl_state], 0
    jmp .wait

.extended:
    call read_scancode
    cmp al, 0x1D
    je .ctrl_down
    cmp al, 0x9D
    je .ctrl_up
    test al, 0x80
    jnz .wait
    cmp al, 0x1C
    je .enter
    cmp al, 0x35
    je .slash
    cmp al, 0x48
    je .up
    cmp al, 0x50
    je .down
    cmp al, 0x4B
    je .left
    cmp al, 0x4D
    je .right
    cmp al, 0x47
    je .home
    cmp al, 0x4F
    je .end
    cmp al, 0x53
    je .delete
    jmp .wait
.up:
    mov al, 0x80
    call fb_cursor_hide
    pop ebx
    ret
.down:
    mov al, 0x81
    call fb_cursor_hide
    pop ebx
    ret
.left:
    cmp byte [ctrl_state], 1
    je .word_left
    mov al, 0x82
    call fb_cursor_hide
    pop ebx
    ret
.right:
    cmp byte [ctrl_state], 1
    je .word_right
    mov al, 0x83
    call fb_cursor_hide
    pop ebx
    ret
.word_left:
    mov al, 0x87
    call fb_cursor_hide
    pop ebx
    ret
.word_right:
    mov al, 0x88
    call fb_cursor_hide
    pop ebx
    ret
.home:
    mov al, 0x84
    call fb_cursor_hide
    pop ebx
    ret
.end:
    mov al, 0x85
    call fb_cursor_hide
    pop ebx
    ret
.delete:
    mov al, 0x86
    call fb_cursor_hide
    pop ebx
    ret
.enter:
    mov al, 13
    call fb_cursor_hide
    pop ebx
    ret
.slash:
    mov al, '/'
    call fb_cursor_hide
    pop ebx
    ret
.esc:
    mov al, 27
    call fb_cursor_hide
    pop ebx
    ret

read_key_idle_poll:
    push eax
    inc dword [kbd_idle_poll_ticks]
    mov eax, [kbd_idle_poll_ticks]
    and eax, 0x000003FF
    jnz .done
    call e1000_poll_rx
.done:
    pop eax
    ret

read_scancode:
.wait:
    call kbd_read_scancode_now
    test al, al
    jnz .done
    call fb_cursor_tick
    call read_key_idle_poll
    jmp .wait
.done:
    ret

kbd_read_scancode_now:
    cmp byte [kbd_irq_enabled], 1
    jne .port
    pushfd
    cli
    push ebx
    push edx
    mov edx, [kbd_ring_tail]
    cmp edx, [kbd_ring_head]
    je .empty_ring
    mov ebx, kbd_ring
    add ebx, edx
    mov al, [ebx]
    inc edx
    and edx, KBD_RING_MASK
    mov [kbd_ring_tail], edx
    pop edx
    pop ebx
    popfd
    ret
.empty_ring:
    in al, 0x64
    test al, 1
    jz .empty_none
    test al, 0x20
    jz .empty_keyboard_byte
    in al, 0x60
    call mouse_handle_byte
    pop edx
    pop ebx
    popfd
    xor al, al
    ret
.empty_keyboard_byte:
    in al, 0x60
    pop edx
    pop ebx
    popfd
    ret
.empty_none:
    pop edx
    pop ebx
    popfd
    xor al, al
    ret
.port:
    in al, 0x64
    test al, 1
    jz .none
    test al, 0x20
    jz .port_keyboard_byte
    in al, 0x60
    call mouse_handle_byte
    xor al, al
    ret
.port_keyboard_byte:
    in al, 0x60
    ret
.none:
    xor al, al
    ret

read_key_nonblocking:
    push ebx
.poll:
    call read_scancode_nonblocking
    test al, al
    jz .none
    cmp al, 0xE0
    je .extended
    cmp al, 0x01
    je .esc
    cmp al, 0x2A
    je .shift_down
    cmp al, 0x36
    je .shift_down
    cmp al, 0xAA
    je .shift_up
    cmp al, 0xB6
    je .shift_up
    cmp al, 0x1D
    je .ctrl_down
    cmp al, 0x9D
    je .ctrl_up
    test al, 0x80
    jnz .poll
    cmp al, 0x2E
    jne .normal
    cmp byte [ctrl_state], 1
    je .ctrl_c
.normal:
    movzx ebx, al
    cmp ebx, 128
    jae .poll
    cmp byte [shift_state], 0
    jne .use_shift
    mov al, [scancode_lower + ebx]
    jmp .mapped
.use_shift:
    mov al, [scancode_shift + ebx]
    jmp .mapped
.mapped:
    test al, al
    jz .poll
    cmp byte [ctrl_state], 0
    je .done
    cmp al, 'a'
    jb .check_upper_ctrl
    cmp al, 'z'
    ja .check_upper_ctrl
    sub al, 'a' - 1
    jmp .ctrl_done
.check_upper_ctrl:
    cmp al, 'A'
    jb .done
    cmp al, 'Z'
    ja .done
    sub al, 'A' - 1
.ctrl_done:
    cmp al, 0x03
    jne .done
    mov byte [command_cancelled], 1
    jmp .done
.esc:
    mov al, 27
    jmp .done
.ctrl_c:
    mov byte [command_cancelled], 1
    mov al, 0x03
    jmp .done
.shift_down:
    mov byte [shift_state], 1
    jmp .poll
.shift_up:
    mov byte [shift_state], 0
    jmp .poll
.ctrl_down:
    mov byte [ctrl_state], 1
    jmp .poll
.ctrl_up:
    mov byte [ctrl_state], 0
    jmp .poll
.none:
    xor al, al
    jmp .done
.extended:
    call read_scancode_nonblocking
    test al, al
    jz .none
    cmp al, 0x1D
    je .ctrl_down
    cmp al, 0x9D
    je .ctrl_up
    test al, 0x80
    jnz .poll
    cmp al, 0x1C
    je .enter
    cmp al, 0x35
    je .slash
    cmp al, 0x48
    je .up
    cmp al, 0x50
    je .down
    cmp al, 0x4B
    je .left
    cmp al, 0x4D
    je .right
    cmp al, 0x47
    je .home
    cmp al, 0x4F
    je .end
    cmp al, 0x53
    je .delete
    jmp .poll
.enter:
    mov al, 13
    jmp .done
.slash:
    mov al, '/'
    jmp .done
.up:
    mov al, 0x80
    jmp .done
.down:
    mov al, 0x81
    jmp .done
.left:
    cmp byte [ctrl_state], 1
    je .word_left
    mov al, 0x82
    jmp .done
.right:
    cmp byte [ctrl_state], 1
    je .word_right
    mov al, 0x83
    jmp .done
.word_left:
    mov al, 0x87
    jmp .done
.word_right:
    mov al, 0x88
    jmp .done
.home:
    mov al, 0x84
    jmp .done
.end:
    mov al, 0x85
    jmp .done
.delete:
    mov al, 0x86
    jmp .done
.done:
    pop ebx
    ret

read_scancode_nonblocking:
.wait:
    push ecx
    mov ecx, 1024
.poll:
    call kbd_read_scancode_now
    test al, al
    jnz .done
    loop .poll
    xor al, al
.done:
    pop ecx
    ret

poll_ctrl_c:
    push ebx
    call read_scancode_nonblocking
    test al, al
    jz .no
    cmp al, 0x1D
    je .ctrl_down
    cmp al, 0x9D
    je .ctrl_up
    test al, 0x80
    jnz .no
    cmp al, 0x2E
    jne .no
    cmp byte [ctrl_state], 1
    jne .no
    mov byte [command_cancelled], 1
    mov al, 1
    jmp .done
.ctrl_down:
    mov byte [ctrl_state], 1
    xor al, al
    jmp .done
.ctrl_up:
    mov byte [ctrl_state], 0
.no:
    xor al, al
.done:
    pop ebx
    ret

history_save:
    pushad
    cmp byte [input_buffer], 0
    je .done

    mov eax, [history_count]
    test eax, eax
    jz .capacity_check
    dec eax
    shl eax, 8
    mov esi, input_buffer
    mov edi, history_buffer
    add edi, eax
    call cstr_equals
    test eax, eax
    jnz .done

.capacity_check:
    mov eax, [history_count]
    cmp eax, 4
    jb .slot_ready

    mov esi, history_buffer + 256
    mov edi, history_buffer
    mov ecx, 256 * 3
    rep movsb
    mov eax, 3
    mov [history_count], eax

.slot_ready:
    mov eax, [history_count]
    shl eax, 8
    mov edi, history_buffer
    add edi, eax
    mov esi, input_buffer
    mov ecx, 256
    rep movsb
    inc dword [history_count]

.done:
    popad
    ret

history_previous:
    pushad
    cmp dword [history_count], 0
    je .done

    mov eax, [history_view]
    cmp eax, -1
    jne .has_view
    call history_save_draft
    mov eax, [history_count]
    dec eax
    jmp .copy

.has_view:
    cmp eax, 0
    je .copy
    dec eax

.copy:
    mov [history_view], eax
    call copy_history_to_input

.done:
    popad
    ret

history_next:
    pushad
    mov eax, [history_view]
    cmp eax, -1
    je .done
    inc eax
    cmp eax, [history_count]
    jae .clear

    mov [history_view], eax
    call copy_history_to_input
    jmp .done

.clear:
    mov dword [history_view], -1
    cmp byte [history_draft_valid], 1
    jne .clear_input
    mov esi, history_draft_buffer
    mov edi, input_buffer
    mov ecx, 256
    rep movsb
    mov byte [history_draft_valid], 0
    jmp .done
.clear_input:
    mov byte [input_buffer], 0
    mov byte [history_draft_valid], 0

.done:
    popad
    ret

history_save_draft:
    pushad
    cmp byte [history_draft_valid], 1
    je .done
    mov esi, input_buffer
    mov edi, history_draft_buffer
    mov ecx, 256
    rep movsb
    mov byte [history_draft_valid], 1
.done:
    popad
    ret

input_leave_history_view:
    cmp dword [history_view], -1
    je .done
    mov dword [history_view], -1
    mov byte [history_draft_valid], 0
.done:
    ret

copy_history_to_input:
    pushad
    mov eax, [history_view]
    shl eax, 8
    mov esi, history_buffer
    add esi, eax
    mov edi, input_buffer
    mov ecx, 256
    rep movsb
    popad
    ret

input_visible_cols:
    mov eax, [console_cols]
    sub eax, [input_start_x]
    cmp eax, 1
    jae .done
    mov eax, 1
.done:
    ret

input_normalize_view:
    push eax
    push ebx
    push edx
    call input_visible_cols
    mov ebx, eax
    mov eax, [input_pos]
    cmp eax, [input_view_start]
    jae .right_check
    mov [input_view_start], eax
    jmp .done
.right_check:
    sub eax, [input_view_start]
    cmp eax, ebx
    jb .done
    mov edx, 1
    cmp ebx, 16
    jb .set_right_view
    mov edx, 8
.set_right_view:
    mov eax, [input_pos]
    sub eax, ebx
    add eax, edx
    mov [input_view_start], eax
.done:
    pop edx
    pop ebx
    pop eax
    ret

redraw_input_line:
    pushad
    call fb_cursor_hide
    call input_normalize_view
    cmp byte [fb_available], 1
    jne .vga
    mov ebx, [input_start_y]
    mov eax, [input_start_x]
    call fb_clear_text_from
    jmp .redraw
.vga:
    call input_visible_cols
    mov ecx, eax
    mov eax, [input_start_y]
    mov ebx, 80
    mul ebx
    add eax, [input_start_x]
    shl eax, 1
    mov edi, 0xB8000
    add edi, eax
    mov ah, [text_attr]
    mov al, ' '
.clear:
    stosw
    loop .clear

.redraw:
    mov eax, [input_start_x]
    mov [cursor_x], eax
    mov eax, [input_start_y]
    mov [cursor_y], eax
    call update_cursor

    mov esi, input_buffer
    add esi, [input_view_start]
    call input_visible_cols
    mov ecx, eax
.print:
    cmp ecx, 0
    je .place_cursor
    lodsb
    test al, al
    jz .place_cursor
    call input_putc_no_wrap
    dec ecx
    jmp .print
.place_cursor:
    call position_cursor_for_input_pos
    popad
    ret

input_clear_screen_redraw:
    pushad
    call clear_screen
    call prepare_prompt_line
    call print_prompt
    mov eax, [cursor_x]
    mov [input_start_x], eax
    mov eax, [cursor_y]
    mov [input_start_y], eax
    call redraw_input_line
    popad
    ret

input_putc_no_wrap:
    pushad
    cmp byte [fb_available], 1
    jne .vga_char
    mov bl, al
    call fb_putc_raw
    jmp .advance
.vga_char:
    mov bl, al
    mov eax, [cursor_y]
    mov ecx, 80
    mul ecx
    add eax, [cursor_x]
    shl eax, 1
    mov edi, 0xB8000
    add edi, eax
    mov al, bl
    mov ah, [text_attr]
    mov [edi], ax
.advance:
    mov eax, [console_cols]
    dec eax
    cmp [cursor_x], eax
    jae .done
    inc dword [cursor_x]
.done:
    popad
    ret

line_insert_char:
    pushad
    call input_leave_history_view
    mov bl, al
    mov eax, [input_pos]
    cmp eax, [input_len]
    jne .insert_middle
    call input_visible_cols
    mov ecx, [input_pos]
    sub ecx, [input_view_start]
    inc ecx
    cmp ecx, eax
    jae .insert_middle
    mov edi, input_buffer
    add edi, [input_len]
    mov [edi], bl
    inc dword [input_len]
    inc dword [input_pos]
    inc edi
    mov byte [edi], 0
    mov al, bl
    call input_putc_no_wrap
    call update_cursor
    jmp .done

.insert_middle:
    mov ecx, [input_len]
    sub ecx, [input_pos]
    mov esi, input_buffer
    add esi, [input_len]
    mov edi, esi
    inc edi
.shift:
    cmp ecx, 0
    je .store
    mov al, [esi - 1]
    mov [edi - 1], al
    dec esi
    dec edi
    dec ecx
    jmp .shift
.store:
    mov edi, input_buffer
    add edi, [input_pos]
    mov [edi], bl
    inc dword [input_len]
    inc dword [input_pos]
    mov edi, input_buffer
    add edi, [input_len]
    mov byte [edi], 0
    call redraw_input_line
.done:
    popad
    ret

line_delete_char:
    pushad
    mov eax, [input_pos]
    cmp eax, [input_len]
    jae .done
    call input_leave_history_view
    mov ecx, [input_len]
    sub ecx, eax
    mov esi, input_buffer
    add esi, eax
    mov edi, esi
    inc esi
.shift:
    cmp ecx, 0
    je .shrink
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    dec ecx
    jmp .shift
.shrink:
    dec dword [input_len]
    mov edi, input_buffer
    add edi, [input_len]
    mov byte [edi], 0
    call redraw_input_line
.done:
    popad
    ret

line_backspace:
    pushad
    cmp dword [input_pos], 0
    je .done
    dec dword [input_pos]
    call line_delete_char
.done:
    popad
    ret

line_kill_before_cursor:
    pushad
    mov ecx, [input_pos]
    cmp ecx, 0
    je .done
    call input_leave_history_view
    mov esi, input_buffer
    add esi, ecx
    mov edi, input_buffer
    mov ecx, [input_len]
    sub ecx, [input_pos]
    inc ecx
    rep movsb
    mov eax, [input_len]
    sub eax, [input_pos]
    mov [input_len], eax
    mov dword [input_pos], 0
    mov dword [input_view_start], 0
    call redraw_input_line
.done:
    popad
    ret

line_kill_after_cursor:
    pushad
    mov eax, [input_pos]
    cmp eax, [input_len]
    jae .done
    call input_leave_history_view
    mov [input_len], eax
    mov edi, input_buffer
    add edi, eax
    mov byte [edi], 0
    call redraw_input_line
.done:
    popad
    ret

line_kill_word_before_cursor:
    pushad
    cmp dword [input_pos], 0
    je .done
    call input_leave_history_view
    mov edx, [input_pos]
    mov ebx, edx
.skip_space:
    cmp ebx, 0
    je .delete
    mov esi, input_buffer
    add esi, ebx
    mov al, [esi - 1]
    cmp al, ' '
    je .step_space
    cmp al, 9
    jne .skip_word
.step_space:
    dec ebx
    jmp .skip_space
.skip_word:
    cmp ebx, 0
    je .delete
    mov esi, input_buffer
    add esi, ebx
    mov al, [esi - 1]
    cmp al, ' '
    je .delete
    cmp al, 9
    je .delete
    dec ebx
    jmp .skip_word
.delete:
    cmp ebx, edx
    je .done
    mov ecx, [input_len]
    sub ecx, edx
    inc ecx
    mov esi, input_buffer
    add esi, edx
    mov edi, input_buffer
    add edi, ebx
    rep movsb
    mov eax, edx
    sub eax, ebx
    sub [input_len], eax
    mov [input_pos], ebx
    call redraw_input_line
.done:
    popad
    ret

line_word_left:
    pushad
    cmp dword [input_pos], 0
    je .done
.skip_space:
    cmp dword [input_pos], 0
    je .redraw
    mov esi, input_buffer
    add esi, [input_pos]
    mov al, [esi - 1]
    cmp al, ' '
    je .step_space
    cmp al, 9
    jne .skip_word
.step_space:
    dec dword [input_pos]
    jmp .skip_space
.skip_word:
    cmp dword [input_pos], 0
    je .redraw
    mov esi, input_buffer
    add esi, [input_pos]
    mov al, [esi - 1]
    cmp al, ' '
    je .redraw
    cmp al, 9
    je .redraw
    dec dword [input_pos]
    jmp .skip_word
.redraw:
    call redraw_input_line
.done:
    popad
    ret

line_word_right:
    pushad
    mov eax, [input_pos]
    cmp eax, [input_len]
    jae .done
.skip_space:
    mov eax, [input_pos]
    cmp eax, [input_len]
    jae .redraw
    mov esi, input_buffer
    add esi, eax
    mov al, [esi]
    cmp al, ' '
    je .step_space
    cmp al, 9
    jne .skip_word
.step_space:
    inc dword [input_pos]
    jmp .skip_space
.skip_word:
    mov eax, [input_pos]
    cmp eax, [input_len]
    jae .redraw
    mov esi, input_buffer
    add esi, eax
    mov al, [esi]
    cmp al, ' '
    je .redraw
    cmp al, 9
    je .redraw
    inc dword [input_pos]
    jmp .skip_word
.redraw:
    call redraw_input_line
.done:
    popad
    ret

position_cursor_for_input_pos:
    pushad
    call input_normalize_view
    call fb_cursor_hide
    mov eax, [input_start_x]
    mov ecx, [input_pos]
    sub ecx, [input_view_start]
    add eax, ecx
    mov ebx, [input_start_y]
    call set_cursor
    popad
    ret

execute_command:
    mov byte [command_cancelled], 0
    mov esi, input_buffer
    call skip_spaces
    cmp byte [esi], 0
    je .done

    mov edi, cmd_help
    call match_token
    test eax, eax
    jnz command_help

    mov edi, cmd_man
    call match_token
    test eax, eax
    jnz command_man

    mov edi, cmd_sky
    call match_token
    test eax, eax
    jnz command_sky

    mov edi, cmd_version
    call match_token
    test eax, eax
    jnz command_version

    mov edi, cmd_sysinfo
    call match_token
    test eax, eax
    jnz command_sysinfo

    mov edi, cmd_pwd
    call match_token
    test eax, eax
    jnz command_pwd

    mov edi, cmd_uname
    call match_token
    test eax, eax
    jnz command_uname

    mov edi, cmd_hostname
    call match_token
    test eax, eax
    jnz command_hostname

    mov edi, cmd_whoami
    call match_token
    test eax, eax
    jnz command_whoami

    mov edi, cmd_id
    call match_token
    test eax, eax
    jnz command_id

    mov edi, cmd_date
    call match_token
    test eax, eax
    jnz command_date

    mov edi, cmd_rand
    call match_token
    test eax, eax
    jnz command_rand

    mov edi, cmd_bigint
    call match_token
    test eax, eax
    jnz command_bigint

    mov edi, cmd_float
    call match_token
    test eax, eax
    jnz command_float

    mov edi, cmd_fault
    call match_token
    test eax, eax
    jnz command_fault

    mov edi, cmd_timezone
    call match_token
    test eax, eax
    jnz command_timezone

    mov edi, cmd_df
    call match_token
    test eax, eax
    jnz command_df

    mov edi, cmd_mount
    call match_token
    test eax, eax
    jnz command_mount

    mov edi, cmd_ps
    call match_token
    test eax, eax
    jnz command_ps

    mov edi, cmd_lspci
    call match_token
    test eax, eax
    jnz command_lspci

    mov edi, cmd_dmesg
    call match_token
    test eax, eax
    jnz command_dmesg

    mov edi, cmd_echo
    call match_token
    test eax, eax
    jnz command_echo

    mov edi, cmd_env
    call match_token
    test eax, eax
    jnz command_env

    mov edi, cmd_set
    call match_token
    test eax, eax
    jnz command_env

    mov edi, cmd_printenv
    call match_token
    test eax, eax
    jnz command_printenv

    mov edi, cmd_export
    call match_token
    test eax, eax
    jnz command_export

    mov edi, cmd_unset
    call match_token
    test eax, eax
    jnz command_unset

    mov edi, cmd_bootinfo
    call match_token
    test eax, eax
    jnz command_bootinfo

    mov edi, cmd_features
    call match_token
    test eax, eax
    jnz command_features

    mov edi, cmd_proc
    call match_token
    test eax, eax
    jnz command_proc

    mov edi, cmd_ipc
    call match_token
    test eax, eax
    jnz command_ipc

    mov edi, cmd_fsinfo
    call match_token
    test eax, eax
    jnz command_fsinfo

    mov edi, cmd_security
    call match_token
    test eax, eax
    jnz command_security

    mov edi, cmd_audit
    call match_token
    test eax, eax
    jnz command_audit

    mov edi, cmd_syscall
    call match_token
    test eax, eax
    jnz command_syscall

    mov edi, cmd_drivers
    call match_token
    test eax, eax
    jnz command_drivers

    mov edi, cmd_utils
    call match_token
    test eax, eax
    jnz command_utils

    mov edi, cmd_history
    call match_token
    test eax, eax
    jnz command_history

    mov edi, cmd_who
    call match_token
    test eax, eax
    jnz command_who

    mov edi, cmd_groups
    call match_token
    test eax, eax
    jnz command_groups

    mov edi, cmd_which
    call match_token
    test eax, eax
    jnz command_which

    mov edi, cmd_type
    call match_token
    test eax, eax
    jnz command_type

    mov edi, cmd_whereis
    call match_token
    test eax, eax
    jnz command_which

    mov edi, cmd_sudo
    call match_token
    test eax, eax
    jnz command_sudo

    mov edi, cmd_su
    call match_token
    test eax, eax
    jnz command_su

    mov edi, cmd_top
    call match_token
    test eax, eax
    jnz command_top

    mov edi, cmd_jobs
    call match_token
    test eax, eax
    jnz command_jobs

    mov edi, cmd_kill
    call match_token
    test eax, eax
    jnz command_kill

    mov edi, cmd_service
    call match_token
    test eax, eax
    jnz command_service

    mov edi, cmd_uptime
    call match_token
    test eax, eax
    jnz command_uptime

    mov edi, cmd_clear
    call match_token
    test eax, eax
    jnz command_clear

    mov edi, cmd_color
    call match_token
    test eax, eax
    jnz command_color

    mov edi, cmd_cursor
    call match_token
    test eax, eax
    jnz command_cursor

    mov edi, cmd_display
    call match_token
    test eax, eax
    jnz command_display

    mov edi, cmd_fbtest
    call match_token
    test eax, eax
    jnz command_fbtest

    mov edi, cmd_gui
    call match_token
    test eax, eax
    jnz command_gui

    mov edi, cmd_desktop
    call match_token
    test eax, eax
    jnz command_gui

    mov edi, cmd_startx
    call match_token
    test eax, eax
    jnz command_gui

    mov edi, cmd_reboot
    call match_token
    test eax, eax
    jnz command_reboot

    mov edi, cmd_reset
    call match_token
    test eax, eax
    jnz command_reboot

    mov edi, cmd_shutdown
    call match_token
    test eax, eax
    jnz command_shutdown

    mov edi, cmd_poweroff
    call match_token
    test eax, eax
    jnz command_shutdown

    mov edi, cmd_halt
    call match_token
    test eax, eax
    jnz command_shutdown

    mov edi, cmd_cd
    call match_token
    test eax, eax
    jnz command_cd

    mov edi, cmd_ls
    call match_token
    test eax, eax
    jnz command_ls

    mov edi, cmd_mem
    call match_token
    test eax, eax
    jnz command_mem

    mov edi, cmd_free
    call match_token
    test eax, eax
    jnz command_mem

    mov edi, cmd_peek
    call match_token
    test eax, eax
    jnz command_peek

    mov edi, cmd_poke
    call match_token
    test eax, eax
    jnz command_poke

    mov edi, cmd_cat
    call match_token
    test eax, eax
    jnz command_cat

    mov edi, cmd_write
    call match_token
    test eax, eax
    jnz command_write

    mov edi, cmd_cp
    call match_token
    test eax, eax
    jnz command_fsop

    mov edi, cmd_mv
    call match_token
    test eax, eax
    jnz command_fsop

    mov edi, cmd_rm
    call match_token
    test eax, eax
    jnz command_fsop

    mov edi, cmd_touch
    call match_token
    test eax, eax
    jnz command_fsop

    mov edi, cmd_mkdir
    call match_token
    test eax, eax
    jnz command_fsop

    mov edi, cmd_chmod
    call match_token
    test eax, eax
    jnz command_fsop

    mov edi, cmd_stat
    call match_token
    test eax, eax
    jnz command_stat

    mov edi, cmd_wc
    call match_token
    test eax, eax
    jnz command_wc

    mov edi, cmd_head
    call match_token
    test eax, eax
    jnz command_head

    mov edi, cmd_grep
    call match_token
    test eax, eax
    jnz command_grep

    mov edi, cmd_du
    call match_token
    test eax, eax
    jnz command_du

    mov edi, cmd_disk
    call match_token
    test eax, eax
    jnz command_disk

    mov edi, cmd_install
    call match_token
    test eax, eax
    jnz command_install

    mov edi, cmd_installer
    call match_token
    test eax, eax
    jnz command_installer

    mov edi, cmd_unskyos
    call match_token
    test eax, eax
    jnz command_unskyos

    mov edi, cmd_memedit
    call match_token
    test eax, eax
    jnz command_memedit

    mov edi, cmd_vi
    call match_token
    test eax, eax
    jnz command_vi

    mov edi, cmd_imgview
    call match_token
    test eax, eax
    jnz command_imgview

    mov edi, cmd_audio
    call match_token
    test eax, eax
    jnz command_audio

    mov edi, cmd_beep
    call match_token
    test eax, eax
    jnz command_beep

    mov edi, cmd_nano
    call match_token
    test eax, eax
    jnz command_nano

    mov edi, cmd_gcc
    call match_token
    test eax, eax
    jnz command_tool_pending

    mov edi, cmd_make
    call match_token
    test eax, eax
    jnz command_tool_pending

    mov edi, cmd_ip
    call match_token
    test eax, eax
    jnz command_ip

    mov edi, cmd_ifconfig
    call match_token
    test eax, eax
    jnz command_ifconfig

    mov edi, cmd_route
    call match_token
    test eax, eax
    jnz command_route

    mov edi, cmd_netstat
    call match_token
    test eax, eax
    jnz command_netstat

    mov edi, cmd_dhclient
    call match_token
    test eax, eax
    jnz command_dhclient

    mov edi, cmd_resolvectl
    call match_token
    test eax, eax
    jnz command_resolvectl

    mov edi, cmd_settings
    call match_token
    test eax, eax
    jnz command_settings

    mov edi, cmd_Settings
    call match_token
    test eax, eax
    jnz command_settings

    mov edi, cmd_ping
    call match_token
    test eax, eax
    jnz command_ping

    mov edi, cmd_wget
    call match_token
    test eax, eax
    jnz command_wget

    mov edi, cmd_curl
    call match_token
    test eax, eax
    jnz command_curl

    mov edi, cmd_ssh
    call match_token
    test eax, eax
    jnz command_ssh

    mov edi, cmd_sftp
    call match_token
    test eax, eax
    jnz command_sftp

    mov edi, cmd_sapp
    call match_token
    test eax, eax
    jnz command_sapp

    mov edi, cmd_netctl
    call match_token
    test eax, eax
    jnz command_netctl

    mov edi, cmd_ss
    call match_token
    test eax, eax
    jnz command_ss

    mov edi, cmd_systemd
    call match_token
    test eax, eax
    jnz command_systemd

    mov edi, cmd_systemctl
    call match_token
    test eax, eax
    jnz command_systemd

    mov edi, cmd_soj
    call match_token
    test eax, eax
    jnz command_soj

    mov edi, cmd_run
    call match_token
    test eax, eax
    jnz command_soj

    mov edi, cmd_bf
    call match_token
    test eax, eax
    jnz command_bf

    mov edi, cmd_login
    call match_token
    test eax, eax
    jnz command_login

    mov edi, cmd_passwd
    call match_token
    test eax, eax
    jnz command_passwd

    mov esi, input_buffer
    call skip_spaces
    call sapp_execute_installed_command
    test eax, eax
    jnz .done

    call print_unknown_command

.done:
    ret

command_help:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .index

    mov edi, help_topic_all
    call match_token
    test eax, eax
    jnz .all
    mov edi, help_topic_system
    call match_token
    test eax, eax
    jnz .system
    mov edi, help_topic_fs
    call match_token
    test eax, eax
    jnz .fs
    mov edi, help_topic_disk
    call match_token
    test eax, eax
    jnz .disk
    mov edi, help_topic_net
    call match_token
    test eax, eax
    jnz .net
    mov edi, help_topic_dev
    call match_token
    test eax, eax
    jnz .dev
    mov edi, help_topic_script
    call match_token
    test eax, eax
    jnz .script
    mov edi, help_topic_pkg
    call match_token
    test eax, eax
    jnz .script
    mov edi, help_topic_power
    call match_token
    test eax, eax
    jnz .power

.index:
    mov esi, help_title
    call print_line
    mov esi, help_head
    call print_line
    mov esi, help_sep
    call print_line
    mov esi, help_system_title
    call print_line
    mov esi, help_01
    call print_line
    mov esi, help_02
    call print_line
    mov esi, help_03
    call print_line
    mov esi, help_04
    call print_line
    mov esi, help_05
    call print_line
    mov esi, help_06
    call print_line
    mov esi, help_23
    call print_line
    mov esi, help_24
    call print_line
    mov esi, help_25
    call print_line
    mov esi, help_26
    call print_line
    mov esi, help_27
    call print_line
    mov esi, help_28
    call print_line
    mov esi, help_29
    call print_line
    mov esi, help_30
    call print_line
    mov esi, help_31
    call print_line
    mov esi, help_32
    call print_line
    mov esi, help_33
    call print_line
    mov esi, help_34
    call print_line
    mov esi, help_35
    call print_line
    mov esi, help_36
    call print_line
    mov esi, help_37
    call print_line
    mov esi, help_38
    call print_line
    mov esi, help_43
    call print_line
    mov esi, help_44
    call print_line
    mov esi, help_45
    call print_line
    ret
.all:
    call command_help_all
    ret
.system:
    call command_help_system
    ret
.fs:
    call command_help_fs
    ret
.disk:
    call command_help_disk
    ret
.net:
    call command_help_net
    ret
.dev:
    call command_help_dev
    ret
.script:
    call command_help_script
    ret
.power:
    call command_help_power
    ret

command_help_all:
    call command_help_system
    call command_help_fs
    call command_help_disk
    call command_help_net
    call command_help_dev
    call command_help_script
    call command_help_power
    ret

command_help_system:
    mov esi, help_system_title
    call print_line
    mov esi, help_01
    call print_line
    mov esi, help_02
    call print_line
    mov esi, help_03
    call print_line
    mov esi, help_04
    call print_line
    mov esi, help_05
    call print_line
    mov esi, help_06
    call print_line
    mov esi, help_23
    call print_line
    mov esi, help_24
    call print_line
    mov esi, help_25
    call print_line
    mov esi, help_26
    call print_line
    mov esi, help_27
    call print_line
    mov esi, help_28
    call print_line
    mov esi, help_29
    call print_line
    mov esi, help_30
    call print_line
    mov esi, help_31
    call print_line
    mov esi, help_32
    call print_line
    mov esi, help_33
    call print_line
    mov esi, help_34
    call print_line
    mov esi, help_35
    call print_line
    mov esi, help_36
    call print_line
    mov esi, help_37
    call print_line
    mov esi, help_38
    call print_line
    mov esi, help_44
    call print_line
    ret

command_help_fs:
    mov esi, help_fs_title
    call print_line
    mov esi, help_08
    call print_line
    mov esi, help_12
    call print_line
    mov esi, help_35
    call print_line
    mov esi, help_39
    call print_line
    mov esi, help_40
    call print_line
    mov esi, help_41
    call print_line
    mov esi, help_42
    call print_line
    ret

command_help_disk:
    mov esi, help_disk_title
    call print_line
    mov esi, help_11
    call print_line
    mov esi, msg_disk_help_1
    call print_line
    mov esi, msg_disk_help_2
    call print_line
    mov esi, msg_disk_help_3
    call print_line
    mov esi, msg_disk_help_4
    call print_line
    mov esi, msg_disk_help_5
    call print_line
    mov esi, msg_disk_help_6
    call print_line
    mov esi, msg_disk_help_7
    call print_line
    mov esi, msg_disk_help_8
    call print_line
    mov esi, msg_disk_help_9
    call print_line
    mov esi, msg_disk_help_10
    call print_line
    mov esi, msg_disk_help_11
    call print_line
    mov esi, msg_disk_help_12
    call print_line
    mov esi, msg_disk_help_13
    call print_line
    mov esi, msg_disk_help_14
    call print_line
    mov esi, msg_disk_help_15
    call print_line
    mov esi, msg_disk_help_16
    call print_line
    mov esi, msg_disk_help_17
    call print_line
    mov esi, msg_disk_help_18
    call print_line
    mov esi, msg_disk_help_19
    call print_line
    ret

command_help_net:
    mov esi, help_net_title
    call print_line
    mov esi, help_15
    call print_line
    mov esi, help_16
    call print_line
    mov esi, help_17
    call print_line
    mov esi, help_18
    call print_line
    mov esi, help_20
    call print_line
    mov esi, help_30
    call print_line
    ret

command_help_dev:
    mov esi, help_dev_title
    call print_line
    mov esi, help_09
    call print_line
    mov esi, help_10
    call print_line
    mov esi, help_13
    call print_line
    mov esi, help_14
    call print_line
    mov esi, help_46
    call print_line
    mov esi, help_43
    call print_line
    ret

command_help_script:
    mov esi, help_script_title
    call print_line
    mov esi, help_19
    call print_line
    mov esi, help_21
    call print_line
    mov esi, help_22
    call print_line
    mov esi, help_31
    call print_line
    ret

command_help_power:
    mov esi, help_power_title
    call print_line
    mov esi, help_07
    call print_line
    ret

command_sky:
    mov esi, input_buffer
    call first_arg
    mov edi, arg_help
    call match_token
    test eax, eax
    jz .unknown
    call command_help
    ret

.unknown:
    call print_unknown_command
    ret

command_version:
    mov esi, os_version
    call print_line
    mov esi, msg_internal_version
    call print_string
    mov esi, os_internal_version
    call print_line
    ret

command_clear:
    call clear_screen
    ret

command_color:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    call set_color
    mov esi, msg_done
    call print_line
    ret
.usage:
    mov esi, msg_usage_color
    call print_line
    ret

command_cursor:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov ebx, eax
    call parse_hex32
    xchg eax, ebx
    call set_cursor
    ret
.usage:
    mov esi, msg_usage_cursor
    call print_line
    ret

command_audio:
    mov esi, msg_audio_title
    call print_line
    mov esi, msg_audio_driver
    call print_line
    mov esi, msg_audio_last_freq
    call print_string
    mov eax, [audio_last_freq]
    call print_hex32
    call console_newline
    mov esi, msg_audio_last_ticks
    call print_string
    mov eax, [audio_last_ticks]
    call print_hex32
    call console_newline
    mov esi, msg_audio_qemu
    call print_line
    ret

command_beep:
    mov esi, input_buffer
    call first_arg
    mov eax, 0x03E8
    cmp byte [esi], 0
    je .have_freq
    call parse_hex32
.have_freq:
    cmp eax, 0
    je .usage
    mov ebx, eax
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .default_ticks
    call next_arg
    cmp byte [esi], 0
    je .default_ticks
    call parse_hex32
    cmp eax, 0
    je .usage
    mov ecx, eax
    jmp .play
.default_ticks:
    mov ecx, 0x00060000
.play:
    mov eax, ebx
    call pc_speaker_beep
    mov esi, msg_beep_done
    call print_line
    ret
.usage:
    mov esi, msg_usage_beep
    call print_line
    ret

pc_speaker_beep:
    pushad
    mov [audio_last_freq], eax
    mov [audio_last_ticks], ecx
    mov byte [audio_enabled], 1
    mov ebx, eax
    mov eax, PIT_BASE_HZ
    xor edx, edx
    div ebx
    mov ebx, eax
    mov al, 0xB6
    out 0x43, al
    mov ax, bx
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 0x03
    out 0x61, al
.delay:
    loop .delay
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    mov byte [audio_enabled], 0
    popad
    ret

command_sysinfo:
    call detect_cpu_vendor
    mov esi, os_version
    call print_line
    mov esi, msg_machine_id
    call print_line
    mov esi, msg_arch
    call print_line
    mov esi, msg_boot
    call print_line
    mov esi, msg_video
    call print_line
    call print_framebuffer_info
    mov esi, msg_cpu_vendor
    call print_string
    mov esi, cpu_vendor
    call print_line
    mov esi, msg_cpu_brand
    call print_string
    mov esi, cpu_brand
    call print_line
    mov esi, msg_cpu_sig
    call print_string
    mov eax, [cpu_sig]
    call print_hex32
    call console_newline
    mov esi, msg_cpu_features_ecx
    call print_string
    mov eax, [cpu_feat_ecx]
    call print_hex32
    call console_newline
    mov esi, msg_cpu_features_edx
    call print_string
    mov eax, [cpu_feat_edx]
    call print_hex32
    call console_newline
    mov esi, msg_mem_cap
    call print_string
    mov eax, 0x80000000
    call print_hex32
    call console_newline
    mov esi, msg_mem_freq
    call print_line
    call command_mem
    call print_available_storage
    call command_disk
    call command_ifconfig
    ret

command_pwd:
    call print_current_path
    call console_newline
    ret

command_uname:
    mov esi, msg_uname
    call print_line
    ret

command_hostname:
    mov esi, msg_hostname
    call print_line
    ret

command_whoami:
    call print_current_user
    call console_newline
    ret

command_id:
    cmp dword [current_uid], 0
    je .root
    mov esi, msg_id_user
    jmp print_line
.root:
    mov esi, msg_id_root
    call print_line
    ret

command_date:
    call cmos_read_datetime
    ret

random_mix_rdtsc_cmos:
    push ebx
    rdtsc
    xor eax, edx
    mov ebx, eax
    mov al, 0x00
    call cmos_read_reg
    movzx eax, al
    shl eax, 16
    xor ebx, eax
    mov al, 0x02
    call cmos_read_reg
    movzx eax, al
    shl eax, 8
    xor ebx, eax
    mov al, 0x04
    call cmos_read_reg
    movzx eax, al
    xor ebx, eax
    mov eax, [random_state]
    imul eax, eax, 1664525
    add eax, 1013904223
    xor eax, ebx
    mov [random_state], eax
    pop ebx
    ret

command_rand:
    mov esi, msg_rand_title
    call print_string
    call random_mix_rdtsc_cmos
    call print_hex32
    call console_newline
    ret

command_bigint:
    mov esi, msg_bigint_title
    call print_line
    ret

command_float:
    finit
    fld dword [float_22]
    fdiv dword [float_7]
    fstp dword [float_result]
    mov esi, msg_float_title
    call print_line
    ret

command_fault:
    mov esi, msg_fault_title
    call print_line
    ret

command_timezone:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .show
    mov edi, timezone_set_arg
    call match_token
    test eax, eax
    jnz .menu
    mov esi, msg_timezone_usage
    call print_line
    ret
.show:
    mov esi, msg_timezone_current
    call print_string
    call print_timezone_name
    call console_newline
    ret
.menu:
    mov esi, msg_timezone_menu
    call print_line
.draw:
    mov esi, msg_timezone_hint
    call print_string
    call print_timezone_name
    call console_newline
    call read_key
    cmp al, 13
    je .apply
    cmp al, 0x80
    je .up
    cmp al, 0x81
    je .down
    cmp al, 'q'
    je .cancel
    cmp al, 'Q'
    je .cancel
    jmp .draw
.up:
    cmp byte [timezone_index], 0
    jne .up_dec
    mov byte [timezone_index], 24
    jmp .draw
.up_dec:
    dec byte [timezone_index]
    jmp .draw
.down:
    inc byte [timezone_index]
    cmp byte [timezone_index], 25
    jb .draw
    mov byte [timezone_index], 0
    jmp .draw
.apply:
    mov esi, msg_timezone_selected
    call print_string
    call print_timezone_name
    call console_newline
.cancel:
    ret

command_display:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .show
    mov edi, arg_test
    call match_token
    test eax, eax
    jnz command_fbtest
.show:
    mov esi, msg_display_title
    call print_line
    call print_display_mode
    call print_framebuffer_info
    mov esi, msg_display_note
    call print_line
    ret

print_display_mode:
    mov esi, msg_display_mode
    call print_string
    mov al, [display_mode_index]
    cmp al, 1
    je .mode_1024
    cmp al, 2
    je .mode_1280
    mov esi, msg_display_auto
    jmp .print
.mode_1024:
    mov esi, msg_display_1024
    jmp .print
.mode_1280:
    mov esi, msg_display_1280
.print:
    call print_line
    ret

print_framebuffer_info:
    mov esi, msg_display_status
    call print_string
    cmp byte [fb_available], 1
    jne .fallback
    mov esi, msg_display_on
    call print_line
    mov esi, msg_display_addr
    call print_string
    mov eax, [fb_addr_low]
    call print_hex32
    call console_newline
    mov esi, msg_display_res
    call print_string
    mov eax, [fb_width]
    call print_dec32
    mov al, 'x'
    call console_putc
    mov eax, [fb_height]
    call print_dec32
    mov esi, msg_display_pitch
    call print_string
    mov eax, [fb_pitch]
    call print_dec32
    mov esi, msg_display_bpp
    call print_string
    movzx eax, byte [fb_bpp]
    call print_dec32
    mov esi, msg_display_type
    call print_string
    movzx eax, byte [fb_type]
    call print_dec32
    call console_newline
    jmp .vbe
.fallback:
    mov esi, msg_display_off
    call print_line
.vbe:
    mov esi, msg_display_vbe
    call print_string
    cmp byte [fb_vbe_available], 1
    jne .vbe_no
    mov esi, msg_display_on
    jmp .vbe_print
.vbe_no:
    mov esi, msg_display_off
.vbe_print:
    call print_line
    ret

command_fbtest:
    call fb_draw_test_pattern
    test eax, eax
    jz .none
    mov esi, msg_display_test_ok
    call print_line
    ret
.none:
    mov esi, msg_display_test_none
    call print_line
    ret

command_installer:
    mov esi, msg_installer_title
    call print_line
    mov esi, msg_installer_1
    call print_line
    mov esi, msg_installer_2
    call print_line
    mov esi, msg_installer_3
    call print_line
    mov esi, msg_installer_4
    call print_line
    call print_display_mode
    mov esi, msg_timezone_current
    call print_string
    call print_timezone_name
    call console_newline
    call disk_print_summary
    ret

command_df:
    mov esi, msg_df_head
    call print_line
    mov esi, msg_df_root
    call print_line
    mov esi, msg_df_disk
    call print_line
    ret

command_mount:
    mov esi, msg_mount_root
    call print_line
    cmp byte [disk_mount_valid], 1
    je .skyfs
    mov esi, msg_mount_disk
    call print_line
    ret
.skyfs:
    mov esi, msg_mount_skyfs
    call print_line
    ret

command_ps:
    mov esi, msg_ps_head
    call print_line
    mov esi, msg_ps_shell
    call print_line
    mov esi, msg_ps_net
    call print_line
    mov esi, msg_ps_sapp
    call print_line
    ret

command_lspci:
    mov esi, msg_lspci_none
    call print_line
    call detect_storage_pci
    cmp byte [sata_found], 0
    je .net
    call print_sata_pci_details
.net:
    call detect_network_pci
    cmp byte [net_found], 0
    je .done
    mov esi, msg_net_pci_addr
    call print_string
    movzx eax, byte [net_bus]
    call print_hex8
    mov al, ':'
    call console_putc
    movzx eax, byte [net_slot]
    call print_hex8
    mov al, '.'
    call console_putc
    movzx eax, byte [net_func]
    call print_hex8
    mov esi, msg_net_pci_vendor
    call print_string
    movzx eax, word [net_vendor]
    call print_hex32
    mov al, ':'
    call console_putc
    movzx eax, word [net_device]
    call print_hex32
    call console_newline
.done:
    ret

print_sata_pci_details:
    mov esi, msg_sata_pci_detected
    call print_line
    mov esi, msg_sata_pci_addr
    call print_string
    movzx eax, byte [sata_bus]
    call print_hex8
    mov al, ':'
    call console_putc
    movzx eax, byte [sata_slot]
    call print_hex8
    mov al, '.'
    call console_putc
    movzx eax, byte [sata_func]
    call print_hex8
    call console_newline
    mov esi, msg_sata_pci_vendor
    call print_string
    movzx eax, word [sata_vendor]
    call print_hex32
    mov al, ':'
    call console_putc
    movzx eax, word [sata_device]
    call print_hex32
    call console_newline
    mov esi, msg_sata_pci_class
    call print_string
    movzx eax, byte [sata_class]
    call print_hex8
    mov al, ':'
    call console_putc
    movzx eax, byte [sata_subclass]
    call print_hex8
    mov al, ':'
    call console_putc
    movzx eax, byte [sata_prog_if]
    call print_hex8
    call console_newline
    mov esi, msg_sata_pci_abar
    call print_string
    mov eax, [sata_abar]
    call print_hex32
    call console_newline
    mov esi, msg_sata_pci_pi
    call print_string
    mov eax, [sata_pi]
    call print_hex32
    call console_newline
    ret

command_dmesg:
    mov esi, msg_dmesg_1
    call print_line
    mov esi, msg_dmesg_2
    call print_line
    mov esi, msg_dmesg_3
    call print_line
    mov esi, msg_dmesg_4
    call print_line
    mov esi, msg_dmesg_5
    call print_line
    ret

command_echo:
    mov esi, input_buffer
    call first_arg
    call print_expanded_env_line
    ret

command_env:
    call print_all_env
    ret

command_printenv:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je command_env
    call print_env_value
    call console_newline
    ret

command_export:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov esi, msg_env_readonly
    call print_line
    ret
.usage:
    mov esi, msg_export_usage
    call print_line
    ret

command_unset:
    mov esi, msg_env_readonly
    call print_line
    ret

command_features:
    mov esi, msg_features_title
    call print_line
    mov esi, msg_feature_boot
    call print_line
    mov esi, msg_feature_init
    call print_line
    mov esi, msg_feature_proc
    call print_line
    mov esi, msg_feature_mem
    call print_line
    mov esi, msg_feature_fs
    call print_line
    mov esi, msg_feature_io
    call print_line
    mov esi, msg_feature_cli
    call print_line
    mov esi, msg_feature_sec
    call print_line
    mov esi, msg_feature_net
    call print_line
    mov esi, msg_feature_syscall
    call print_line
    ret

command_bootinfo:
    mov esi, msg_bootinfo_1
    call print_line
    mov esi, msg_bootinfo_2
    call print_line
    mov esi, msg_bootinfo_3
    call print_line
    mov esi, msg_bootinfo_4
    call print_line
    ret

command_proc:
    call command_ps
    mov esi, msg_proc_1
    call print_line
    mov esi, msg_proc_2
    call print_line
    mov esi, msg_proc_3
    call print_line
    ret

command_ipc:
    mov esi, msg_ipc_1
    call print_line
    mov esi, msg_ipc_2
    call print_line
    mov esi, msg_ipc_3
    call print_line
    ret

command_fsinfo:
    mov esi, msg_fsinfo_1
    call print_line
    mov esi, msg_fsinfo_2
    call print_line
    mov esi, msg_fsinfo_3
    call print_line
    mov esi, msg_fsinfo_4
    call print_line
    mov esi, msg_fsinfo_5
    call print_line
    mov esi, msg_fsinfo_6
    call print_line
    mov esi, msg_fsinfo_7
    call print_line
    ret

command_security:
    mov esi, msg_security_1
    call print_line
    mov esi, msg_security_2
    call print_line
    mov esi, msg_security_3
    call print_line
    mov esi, msg_security_4
    call print_line
    ret

command_audit:
    mov esi, msg_audit_1
    call print_line
    call command_dmesg
    ret

command_syscall:
    mov esi, msg_syscall_1
    call print_line
    mov esi, msg_syscall_2
    call print_line
    mov esi, msg_syscall_3
    call print_line
    mov esi, msg_syscall_4
    call print_line
    ret

command_drivers:
    mov esi, msg_drivers_1
    call print_line
    mov esi, msg_drivers_2
    call print_line
    mov esi, msg_drivers_3
    call print_line
    mov esi, msg_drivers_4
    call print_line
    mov esi, msg_drivers_5
    call print_line
    mov esi, msg_drivers_6
    call print_line
    call print_framebuffer_info
    call command_lspci
    ret

command_utils:
    mov esi, msg_utils_1
    call print_line
    mov esi, msg_utils_2
    call print_line
    ret

command_history:
    mov eax, [history_count]
    test eax, eax
    jz .empty
    mov esi, history_buffer
    mov ecx, eax
.loop:
    cmp byte [esi], 0
    je .next
    call print_line
.next:
    add esi, 256
    loop .loop
    ret
.empty:
    mov esi, msg_history_empty
    call print_line
    ret

command_who:
    cmp dword [current_uid], 0
    je .root
    mov esi, msg_who_user
    jmp print_line
.root:
    mov esi, msg_who_root
    call print_line
    ret

command_groups:
    cmp dword [current_uid], 0
    je .root
    mov esi, msg_groups_user
    jmp print_line
.root:
    mov esi, msg_groups_root
    call print_line
    ret

command_login:
    jmp command_su

command_passwd:
    mov esi, msg_passwd_note
    call print_line
    ret

print_all_env:
    mov esi, env_01
    call print_string
    call print_current_user
    call console_newline
    mov esi, env_02
    call print_line
    mov esi, env_03
    call print_line
    mov esi, env_04
    call print_line
    mov esi, env_05
    call print_line
    mov esi, env_06
    call print_line
    mov esi, env_07
    call print_line
    mov esi, env_08
    call print_line
    mov esi, env_09
    call print_line
    mov esi, env_10
    call print_string
    mov eax, [net_ip_addr]
    call print_ipv4_or_unconfigured
    call console_newline
    mov esi, env_11
    call print_string
    mov eax, [net_gateway_ip]
    call print_ipv4_or_unconfigured
    call console_newline
    mov esi, env_12
    call print_string
    mov eax, [net_dns_ip]
    call print_ipv4_or_unconfigured
    call console_newline
    call print_pwd_env
    ret

print_pwd_env:
    mov al, 'P'
    call console_putc
    mov al, 'W'
    call console_putc
    mov al, 'D'
    call console_putc
    mov al, '='
    call console_putc
    call print_current_path
    call console_newline
    ret

print_env_value:
    mov edi, env_name_user
    call match_token
    test eax, eax
    jnz .user
    mov edi, env_name_home
    call match_token
    test eax, eax
    jnz .home
    mov edi, env_name_shell
    call match_token
    test eax, eax
    jnz .shell
    mov edi, env_name_hostname
    call match_token
    test eax, eax
    jnz .hostname
    mov edi, env_name_path
    call match_token
    test eax, eax
    jnz .path
    mov edi, env_name_term
    call match_token
    test eax, eax
    jnz .term
    mov edi, env_name_arch
    call match_token
    test eax, eax
    jnz .arch
    mov edi, env_name_os
    call match_token
    test eax, eax
    jnz .os
    mov edi, env_name_netdev
    call match_token
    test eax, eax
    jnz .netdev
    mov edi, env_name_ip
    call match_token
    test eax, eax
    jnz .ip
    mov edi, env_name_gateway
    call match_token
    test eax, eax
    jnz .gateway
    mov edi, env_name_dns
    call match_token
    test eax, eax
    jnz .dns
    mov edi, env_name_pwd
    call match_token
    test eax, eax
    jnz .pwd
    ret
.user:
    jmp print_current_user
.home:
    mov esi, env_value_home
    jmp print_string
.shell:
    mov esi, env_value_shell
    jmp print_string
.hostname:
    mov esi, env_value_hostname
    jmp print_string
.path:
    mov esi, env_value_path
    jmp print_string
.term:
    mov esi, env_value_term
    jmp print_string
.arch:
    mov esi, env_value_arch
    jmp print_string
.os:
    mov esi, env_value_os
    jmp print_string
.netdev:
    mov esi, env_value_netdev
    jmp print_string
.ip:
    mov eax, [net_ip_addr]
    jmp print_ipv4_or_unconfigured
.gateway:
    mov eax, [net_gateway_ip]
    jmp print_ipv4_or_unconfigured
.dns:
    mov eax, [net_dns_ip]
    jmp print_ipv4_or_unconfigured
.pwd:
    call print_current_path
    ret

print_expanded_env_line:
    call skip_spaces
.loop:
    mov al, [esi]
    test al, al
    jz .done
    cmp al, '$'
    je .env
    call console_putc
    inc esi
    jmp .loop
.env:
    inc esi
    push esi
    call print_env_value
    pop esi
    call skip_env_name
    jmp .loop
.done:
    call console_newline
    ret

skip_env_name:
.loop:
    mov al, [esi]
    cmp al, 'A'
    jb .done
    cmp al, 'Z'
    ja .done
    inc esi
    jmp .loop
.done:
    ret

command_sudo:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, sudo_cmd_buffer
    mov ecx, 255
.copy:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .run
    inc esi
    inc edi
    loop .copy
    mov byte [edi], 0
.run:
    cmp dword [current_uid], 0
    je .run_as_root
    mov esi, msg_sudo_prompt
    call read_password_prompt
    mov esi, auth_buffer
    mov edi, root_password
    call cstr_equals
    test eax, eax
    jz .auth_fail
.run_as_root:
    push dword [current_uid]
    push dword [current_gid]
    mov dword [current_uid], 0
    mov dword [current_gid], 0
    mov esi, msg_sudo_running
    call print_line
    mov esi, sudo_cmd_buffer
    mov edi, input_buffer
    mov ecx, 255
.restore_cmd:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .exec
    inc esi
    inc edi
    loop .restore_cmd
    mov byte [edi], 0
.exec:
    call execute_command
    pop dword [current_gid]
    pop dword [current_uid]
.done:
    ret
.usage:
    mov esi, msg_sudo_usage
    call print_line
    ret
.auth_fail:
    mov esi, msg_auth_failure
    call print_line
    ret

command_su:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .to_root
    mov edi, user_root_name
    call match_token
    test eax, eax
    jnz .to_root
    mov edi, user_user_name
    call match_token
    test eax, eax
    jnz .to_user
    mov esi, msg_su_usage
    call print_line
    ret
.to_user:
    mov dword [current_uid], 1000
    mov dword [current_gid], 1000
    mov esi, msg_su_user
    call print_line
    ret
.to_root:
    cmp dword [current_uid], 0
    je .root_ok
    mov esi, msg_auth_password
    call read_password_prompt
    mov esi, auth_buffer
    mov edi, root_password
    call cstr_equals
    test eax, eax
    jz .auth_fail
.root_ok:
    mov dword [current_uid], 0
    mov dword [current_gid], 0
    mov esi, msg_su_root
    call print_line
    ret
.auth_fail:
    mov esi, msg_auth_failure
    call print_line
    ret

command_man:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, cmd_systemctl
    call match_token
    test eax, eax
    jnz .systemctl
    mov esi, msg_man_prefix
    call print_string
    mov esi, input_buffer
    call first_arg
    call print_first_token
    call console_newline
    call command_help_all
    ret
.systemctl:
    mov esi, msg_alias_systemctl
    call print_line
    mov esi, msg_systemd_usage
    call print_line
    ret
.usage:
    mov esi, msg_man_usage
    call print_line
    ret

command_which:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .not_found
    call shell_find_builtin_command
    test eax, eax
    jnz .builtin
    call sapp_find_installed_command
    test eax, eax
    jnz .package
    jmp .not_found
.builtin:
    mov edi, esi
    mov esi, msg_which_prefix
    call print_string
    mov esi, edi
    call print_first_token
    call console_newline
    ret
.package:
    mov ebx, [sapp_cmd_ptr]
    mov esi, [ebx + SAPP_CMD_FILE]
    call print_line
    ret
.not_found:
    mov esi, msg_which_not_found
    call print_line
    ret

command_type:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .not_found
    call shell_find_builtin_command
    test eax, eax
    jnz .builtin
    call sapp_find_installed_command
    test eax, eax
    jnz .package
    jmp .not_found
.builtin:
    mov edi, esi
    mov esi, edi
    call print_first_token
    mov esi, msg_type_prefix
    call print_line
    ret
.package:
    mov edi, esi
    mov esi, edi
    call print_first_token
    mov esi, msg_type_pkg_mid
    call print_string
    mov ebx, [sapp_cmd_ptr]
    mov esi, [ebx + SAPP_CMD_FILE]
    call print_string
    mov esi, msg_type_pkg_suffix
    call print_string
    mov ebx, [sapp_cmd_ptr]
    mov esi, [ebx + SAPP_CMD_PACKAGE]
    call print_line
    ret
.not_found:
    mov esi, msg_which_not_found
    call print_line
    ret

command_top:
    mov dword [monitor_frame], 0
.loop:
    call e1000_poll_rx
    call monitor_update
    call clear_screen
    call monitor_draw
    call monitor_delay
    call read_key_nonblocking
    cmp al, 'q'
    je .done
    cmp al, 'Q'
    je .done
    cmp al, 27
    je .done
    cmp al, 0x03
    je .done
    jmp .loop
.done:
    call clear_screen
    ret

monitor_update:
    pushad
    inc dword [monitor_frame]
    mov eax, [monitor_frame]
    and eax, 0x0F
    add eax, [net_rx_packets]
    add eax, [net_tx_packets]
    add eax, [net_tcp_packets]
    and eax, 0x63
    mov [monitor_load], eax
    popad
    ret

monitor_draw:
    pushad
    mov al, 0x0B
    call set_color
    mov esi, msg_top_title
    call print_line
    mov al, 0x0F
    call set_color
    mov esi, msg_top_hint
    call print_line
    call console_newline

    mov esi, msg_top_frame
    call print_string
    mov eax, [monitor_frame]
    call print_dec32
    mov esi, msg_top_load
    call print_string
    mov eax, [monitor_load]
    call print_dec32
    mov al, '%'
    call console_putc
    mov esi, msg_top_mem
    call print_string
    call monitor_print_mem_kb
    mov esi, msg_top_disk
    call print_string
    mov al, [disk_mount_valid]
    call print_service_state_inline
    mov esi, msg_top_net
    call print_string
    mov eax, [net_rx_packets]
    call print_dec32
    mov al, '/'
    call console_putc
    mov eax, [net_tx_packets]
    call print_dec32
    call console_newline

    mov esi, msg_top_services
    call print_string
    mov al, [svc_net]
    call print_service_state_inline
    mov al, '/'
    call console_putc
    mov al, [svc_tcp]
    call print_service_state_inline
    mov al, '/'
    call console_putc
    mov al, [svc_tls]
    call print_service_state_inline
    mov al, '/'
    call console_putc
    mov al, [svc_sapp]
    call print_service_state_inline
    mov al, '/'
    call console_putc
    mov al, [svc_ssh]
    call print_service_state_inline
    mov al, '/'
    call console_putc
    mov al, [svc_sftp]
    call print_service_state_inline
    call console_newline
    call console_newline

    mov esi, msg_top_proc_head
    call print_line
    mov esi, msg_top_shell
    call print_line
    mov esi, msg_top_net_proc
    call print_line
    mov esi, msg_top_sapp_proc
    call print_line
    mov esi, msg_top_disk_proc
    call print_line
    call console_newline

    mov esi, msg_top_perf_head
    call print_line
    call print_net_counters_compact
    popad
    ret

monitor_print_mem_kb:
    cmp dword [mb_magic], 0x2BADB002
    jne .fallback
    mov ebx, [mb_info_addr]
    test dword [ebx], 1
    jz .fallback
    mov eax, [ebx + 8]
    call print_dec32
    ret
.fallback:
    mov eax, 2097152
    call print_dec32
    ret

print_net_counters_compact:
    mov esi, msg_net_stats_ipv4
    call print_string
    mov eax, [net_ipv4_packets]
    call print_dec32
    mov al, ' '
    call console_putc
    mov esi, msg_net_stats_icmp
    call print_string
    mov eax, [net_icmp_packets]
    call print_dec32
    mov al, ' '
    call console_putc
    mov esi, msg_net_stats_udp
    call print_string
    mov eax, [net_udp_packets]
    call print_dec32
    mov al, ' '
    call console_putc
    mov esi, msg_net_stats_tcp
    call print_string
    mov eax, [net_tcp_packets]
    call print_dec32
    call console_newline
    ret

monitor_delay:
    push ecx
    mov ecx, 0x00180000
.spin:
    call net_poll_rx_burst
    loop .spin
    pop ecx
    ret

command_jobs:
    mov esi, msg_jobs_none
    call print_line
    ret

command_uptime:
    mov esi, msg_uptime
    call print_line
    ret

command_kill:
    call require_root
    test eax, eax
    jz .denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    cmp eax, 2
    je .kill_net
    cmp eax, 3
    je .kill_sapp
    jmp .bad
.kill_net:
    mov byte [svc_net], 0
    mov byte [svc_tcp], 0
    mov byte [svc_tls], 0
    mov esi, msg_kill_done
    call print_string
    mov eax, 2
    call print_hex32
    call console_newline
    ret
.kill_sapp:
    mov byte [svc_sapp], 0
    mov esi, msg_kill_done
    call print_string
    mov eax, 3
    call print_hex32
    call console_newline
    ret
.usage:
    mov esi, msg_kill_usage
    call print_line
    ret
.bad:
    mov esi, msg_kill_bad
    call print_line
    ret
.denied:
    ret

command_service:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    push esi
    call next_arg
    cmp byte [esi], 0
    je .usage_pop
    mov edi, systemd_status
    call match_token
    test eax, eax
    jnz .status
    mov edi, systemd_start
    call match_token
    test eax, eax
    jnz .start
    mov edi, systemd_stop
    call match_token
    test eax, eax
    jnz .stop
.usage_pop:
    pop esi
.usage:
    mov esi, msg_service_usage
    call print_line
    ret
.status:
    pop esi
    call print_unit_status
    ret
.start:
    pop esi
    call require_root
    test eax, eax
    jz .denied
    call set_unit_active
    ret
.stop:
    pop esi
    call require_root
    test eax, eax
    jz .denied
    call set_unit_inactive
    ret
.denied:
    ret

print_unknown_command:
    mov esi, msg_unknown_prefix
    call print_string
    mov esi, input_buffer
    call print_first_token
    call console_newline
    ret

print_first_token:
    pushad
    call skip_spaces
.loop:
    mov al, [esi]
    test al, al
    jz .done
    cmp al, ' '
    je .done
    cmp al, 9
    je .done
    call console_putc
    inc esi
    jmp .loop
.done:
    popad
    ret

shell_find_builtin_command:
    push ebx
    push esi
    push edi
    mov ebx, shell_builtin_cmd_table
.loop:
    mov edi, [ebx]
    cmp edi, 0
    je .no
    call soj_token_equals
    test eax, eax
    jnz .yes
    add ebx, 4
    jmp .loop
.yes:
    mov eax, 1
    jmp .done
.no:
    xor eax, eax
.done:
    pop edi
    pop esi
    pop ebx
    ret

command_reboot:
    mov esi, msg_reboot
    call print_line
.wait_input_clear:
    in al, 0x64
    test al, 0x02
    jnz .wait_input_clear
    mov al, 0xFE
    out 0x64, al
    jmp halt_forever

command_shutdown:
    call shutdown_animation
    call acpi_poweroff
    call legacy_poweroff
    mov esi, msg_shutdown_fail
    call print_line
    ret

legacy_poweroff:
    pushad
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax
    mov dx, 0xB004
    mov ax, 0x2000
    out dx, ax
    mov dx, 0x4004
    mov ax, 0x3400
    out dx, ax
    call poweroff_wait
    popad
    ret

acpi_poweroff:
    pushad
    call acpi_find_fadt
    test eax, eax
    jz .done
    call acpi_find_s5
    test eax, eax
    jz .done
    cmp byte [acpi_slp_typa], 0xFF
    je .done

    mov edx, [acpi_smi_cmd]
    test edx, edx
    jz .write_pm1
    mov al, [acpi_enable]
    test al, al
    jz .write_pm1
    out dx, al
    call poweroff_wait_short

.write_pm1:
    movzx eax, byte [acpi_slp_typa]
    shl ax, 10
    or ax, 0x2000
    mov edx, [acpi_pm1a_cnt]
    test edx, edx
    jz .write_pm1b
    out dx, ax

.write_pm1b:
    mov edx, [acpi_pm1b_cnt]
    test edx, edx
    jz .wait
    movzx eax, byte [acpi_slp_typb]
    cmp al, 0xFF
    jne .have_typb
    movzx eax, byte [acpi_slp_typa]
.have_typb:
    shl ax, 10
    or ax, 0x2000
    out dx, ax

.wait:
    call poweroff_wait
.done:
    popad
    ret

acpi_find_fadt:
    call acpi_clear_state
    call acpi_find_rsdp
    test eax, eax
    jz .fail
    mov [acpi_rsdp_addr], eax
    mov esi, eax
    mov eax, [esi + 16]
    test eax, eax
    jz .fail
    mov [acpi_rsdt_addr], eax
    mov esi, eax
    mov eax, [esi]
    cmp eax, 'RSDT'
    jne .fail
    cmp dword [esi + 4], 36
    jb .fail
    call acpi_checksum_sdt
    test eax, eax
    jz .fail

    mov esi, [acpi_rsdt_addr]
    mov ecx, [esi + 4]
    sub ecx, 36
    shr ecx, 2
    lea esi, [esi + 36]
.entry:
    test ecx, ecx
    jz .fail
    mov ebx, [esi]
    test ebx, ebx
    jz .next
    cmp dword [ebx], 'FACP'
    jne .next
    cmp dword [ebx + 4], 90
    jb .next
    push esi
    push ecx
    mov esi, ebx
    call acpi_checksum_sdt
    pop ecx
    pop esi
    test eax, eax
    jz .next
    mov [acpi_fadt_addr], ebx
    mov eax, [ebx + 40]
    mov [acpi_dsdt_addr], eax
    mov eax, [ebx + 48]
    mov [acpi_smi_cmd], eax
    mov al, [ebx + 52]
    mov [acpi_enable], al
    mov eax, [ebx + 64]
    mov [acpi_pm1a_cnt], eax
    mov eax, [ebx + 68]
    mov [acpi_pm1b_cnt], eax
    mov al, [ebx + 89]
    mov [acpi_pm1_cnt_len], al
    mov eax, 1
    ret
.next:
    add esi, 4
    dec ecx
    jmp .entry
.fail:
    xor eax, eax
    ret

acpi_clear_state:
    mov dword [acpi_rsdp_addr], 0
    mov dword [acpi_rsdt_addr], 0
    mov dword [acpi_fadt_addr], 0
    mov dword [acpi_dsdt_addr], 0
    mov dword [acpi_pm1a_cnt], 0
    mov dword [acpi_pm1b_cnt], 0
    mov dword [acpi_smi_cmd], 0
    mov byte [acpi_enable], 0
    mov byte [acpi_pm1_cnt_len], 0
    mov byte [acpi_slp_typa], 0xFF
    mov byte [acpi_slp_typb], 0xFF
    ret

acpi_find_rsdp:
    movzx eax, word [0x40E]
    shl eax, 4
    test eax, eax
    jz .bios_area
    mov esi, eax
    mov ecx, 1024
    call acpi_scan_rsdp
    test eax, eax
    jnz .done
.bios_area:
    mov esi, 0x000E0000
    mov ecx, 0x00020000
    call acpi_scan_rsdp
.done:
    ret

acpi_scan_rsdp:
.loop:
    cmp ecx, 20
    jb .fail
    cmp dword [esi], 'RSD '
    jne .next
    cmp dword [esi + 4], 'PTR '
    jne .next
    push esi
    call acpi_checksum_rsdp
    pop esi
    test eax, eax
    jz .next
    mov eax, esi
    ret
.next:
    add esi, 16
    sub ecx, 16
    jmp .loop
.fail:
    xor eax, eax
    ret

acpi_checksum_rsdp:
    mov ecx, 20
    jmp acpi_checksum_bytes

acpi_checksum_sdt:
    mov ecx, [esi + 4]

acpi_checksum_bytes:
    push esi
    xor eax, eax
.loop:
    add al, [esi]
    inc esi
    loop .loop
    test al, al
    sete al
    movzx eax, al
    pop esi
    ret

acpi_find_s5:
    mov esi, [acpi_dsdt_addr]
    test esi, esi
    jz .fail
    cmp dword [esi], 'DSDT'
    jne .fail
    cmp dword [esi + 4], 36
    jb .fail
    call acpi_checksum_sdt
    test eax, eax
    jz .fail
    mov ecx, [esi + 4]
    sub ecx, 36
    lea esi, [esi + 36]
.scan:
    cmp ecx, 4
    jb .fail
    cmp dword [esi], '_S5_'
    je .found
    inc esi
    dec ecx
    jmp .scan
.found:
    cmp byte [esi - 1], 0x08
    je .parse
    cmp byte [esi - 2], 0x08
    jne .fail
    cmp byte [esi - 1], 0x5C
    jne .fail
.parse:
    add esi, 4
    cmp byte [esi], 0x12
    jne .fail
    inc esi
    mov al, [esi]
    shr al, 6
    and eax, 3
    inc eax
    add esi, eax
    inc esi

    call acpi_read_sleep_value
    jc .fail
    mov [acpi_slp_typa], al
    call acpi_read_sleep_value
    jc .fail
    mov [acpi_slp_typb], al
    mov eax, 1
    ret
.fail:
    xor eax, eax
    ret

acpi_read_sleep_value:
    mov al, [esi]
    cmp al, 0x0A
    je .byte
    cmp al, 0x0B
    je .word
    cmp al, 0x0C
    je .dword
    cmp al, 0x0E
    je .qword
    cmp al, 0x00
    je .zero
    cmp al, 0x01
    je .one
    cmp al, 0x0F
    je .ones
    stc
    ret
.byte:
    mov al, [esi + 1]
    add esi, 2
    clc
    ret
.word:
    mov al, [esi + 1]
    add esi, 3
    clc
    ret
.dword:
    mov al, [esi + 1]
    add esi, 5
    clc
    ret
.qword:
    mov al, [esi + 1]
    add esi, 9
    clc
    ret
.zero:
    xor al, al
    inc esi
    clc
    ret
.one:
    mov al, 1
    inc esi
    clc
    ret
.ones:
    mov al, 0xFF
    inc esi
    clc
    ret

poweroff_wait_short:
    push ecx
    mov ecx, 0x00008000
.loop:
    loop .loop
    pop ecx
    ret

poweroff_wait:
    push ecx
    mov ecx, 0x00800000
.loop:
    loop .loop
    pop ecx
    ret

command_cd:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .home

    mov edi, name_root
    call match_token
    test eax, eax
    jnz .root

    mov edi, name_parent
    call match_token
    test eax, eax
    jnz .parent

    mov edi, name_current
    call match_token
    test eax, eax
    jnz .current

    mov edi, name_dash
    call match_token
    test eax, eax
    jnz .previous

    mov edi, name_tilde
    call match_token
    test eax, eax
    jnz .home

    mov edi, path_bin
    call match_token
    test eax, eax
    jnz .bin

    mov edi, path_etc
    call match_token
    test eax, eax
    jnz .etc

    mov edi, path_home
    call match_token
    test eax, eax
    jnz .home

    mov edi, path_dev
    call match_token
    test eax, eax
    jnz .dev

    cmp dword [current_dir], DIR_ROOT
    jne .not_found

    mov edi, name_bin
    call match_token
    test eax, eax
    jnz .bin

    mov edi, name_etc
    call match_token
    test eax, eax
    jnz .etc

    mov edi, name_home
    call match_token
    test eax, eax
    jnz .home

    mov edi, name_dev
    call match_token
    test eax, eax
    jnz .dev

.not_found:
    mov esi, msg_no_file
    call print_line
    ret

.root:
    mov eax, DIR_ROOT
    call set_current_dir
    ret
.parent:
    mov eax, DIR_ROOT
    call set_current_dir
    ret
.current:
    ret
.previous:
    mov eax, [previous_dir]
    call set_current_dir
    ret
.bin:
    mov eax, DIR_BIN
    call set_current_dir
    ret
.etc:
    mov eax, DIR_ETC
    call set_current_dir
    ret
.home:
    mov eax, DIR_HOME
    call set_current_dir
    ret
.dev:
    mov eax, DIR_DEV
    call set_current_dir
    ret

set_current_dir:
    mov ebx, [current_dir]
    mov [previous_dir], ebx
    mov [current_dir], eax
    ret

command_ls:
    mov eax, [current_dir]
    cmp eax, DIR_ROOT
    je .root
    cmp eax, DIR_BIN
    je .bin
    cmp eax, DIR_ETC
    je .etc
    cmp eax, DIR_HOME
    je .home
    cmp eax, DIR_DEV
    je .dev
    ret
.root:
    mov esi, root_listing
    jmp .print
.bin:
    mov esi, bin_listing
    jmp .print
.etc:
    mov esi, etc_listing
    call print_line
    mov esi, etc_sapp_listing
    jmp .print
.home:
    mov esi, home_listing
    jmp .print
.dev:
    mov esi, dev_listing
.print:
    call print_line
    ret

command_mem:
    cmp dword [mb_magic], 0x2BADB002
    jne .none
    mov ebx, [mb_info_addr]
    test dword [ebx], 1
    jz .none

    mov esi, msg_mem_lower
    call print_string
    mov eax, [ebx + 4]
    call print_hex32
    call console_newline

    mov esi, msg_mem_upper
    call print_string
    mov eax, [ebx + 8]
    call print_hex32
    call console_newline
    call print_available_memory
    ret

.none:
    mov esi, msg_mem_none
    call print_line
    ret

print_available_memory:
    cmp dword [mb_magic], 0x2BADB002
    jne .none
    mov ebx, [mb_info_addr]
    test dword [ebx], 1
    jz .none
    mov esi, msg_mem_available
    call print_string
    mov eax, [ebx + 8]
    sub eax, 4096
    call print_hex32
    call console_newline
    ret
.none:
    mov esi, msg_mem_available
    call print_string
    xor eax, eax
    call print_hex32
    call console_newline
    ret

print_available_storage:
    mov esi, msg_storage_available
    call print_string
    mov eax, 65535
    call print_hex32
    call console_newline
    ret

command_peek:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov ebx, eax
    mov esi, msg_peek_value
    call print_string
    movzx eax, byte [ebx]
    call print_hex32
    call console_newline
    ret
.usage:
    mov esi, msg_usage_peek
    call print_line
    ret

command_poke:
    call require_root
    test eax, eax
    jz .denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov ebx, eax
    call parse_hex32
    mov [ebx], al
    mov esi, msg_poke_done
    call print_line
    ret
.usage:
    mov esi, msg_usage_poke
    call print_line
    ret
.denied:
    ret

command_disk:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .summary

    mov edi, disk_arg_help
    call match_token
    test eax, eax
    jnz .help
    mov edi, disk_arg_map
    call match_token
    test eax, eax
    jnz .map
    mov edi, disk_arg_part
    call match_token
    test eax, eax
    jnz .part
    mov edi, disk_arg_verify
    call match_token
    test eax, eax
    jnz .verify
    mov edi, disk_arg_root
    call match_token
    test eax, eax
    jnz .root
    mov edi, disk_arg_select
    call match_token
    test eax, eax
    jnz .select
    mov edi, disk_arg_partition
    call match_token
    test eax, eax
    jnz .partition
    mov edi, disk_arg_format
    call match_token
    test eax, eax
    jnz .format
    mov edi, disk_arg_fs
    call match_token
    test eax, eax
    jnz .fs
    mov edi, disk_arg_mkfs
    call match_token
    test eax, eax
    jnz .mkfs
    mov edi, disk_arg_mount
    call match_token
    test eax, eax
    jnz .mount
    mov edi, disk_arg_install
    call match_token
    test eax, eax
    jnz .install
    mov edi, disk_arg_pread
    call match_token
    test eax, eax
    jnz .pread
    mov edi, disk_arg_pwrite
    call match_token
    test eax, eax
    jnz .pwrite
    mov edi, disk_arg_read
    call match_token
    test eax, eax
    jnz .read
    mov edi, disk_arg_hexdump
    call match_token
    test eax, eax
    jnz .hexdump
    mov edi, disk_arg_phex
    call match_token
    test eax, eax
    jnz .phex
    mov edi, disk_arg_write
    call match_token
    test eax, eax
    jnz .write
    mov edi, disk_arg_burn
    call match_token
    test eax, eax
    jnz .burn
    jmp .usage

.summary:
    call disk_print_summary
    ret
.help:
    call command_help_disk
    ret
.part:
    call disk_print_partitions
    ret
.map:
    mov esi, msg_disk_map_1
    call print_line
    mov esi, msg_disk_map_2
    call print_line
    call disk_print_summary
    ret
.verify:
    call disk_verify_layout
    ret
.root:
    call disk_print_root_entries
    ret
.select:
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    cmp eax, 0
    jne .select_unsupported
    mov [install_target_disk], al
    mov esi, msg_disk_select_ok
    call print_line
    ret
.select_unsupported:
    mov esi, msg_disk_select_unsupported
    call print_line
    ret
.partition:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    cmp byte [esi], 0
    je .partition_default
    call parse_hex32
    mov [disk_partition_preset], eax
.partition_default:
    call disk_partition_installer_layout
    ret
.format:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov [disk_part_index], eax
    mov esi, msg_disk_format_warn
    call print_line
    call disk_mkfs_skyfs
    ret
.fs:
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov [disk_part_index], eax
    mov dword [disk_rel_lba], 0
    call disk_partition_abs_lba
    test ecx, ecx
    jz .part_error
    call ata_read_lba
    call disk_probe_filesystem
    ret
.mkfs:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov [disk_part_index], eax
    call disk_mkfs_skyfs
    ret
.mount:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov [disk_part_index], eax
    call disk_mount_skyfs
    ret
.install:
    call command_install
    ret
.read:
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov ebx, eax
    call ata_read_lba
    mov esi, msg_disk_lba
    call print_string
    mov eax, ebx
    call print_hex32
    call console_newline
    mov esi, msg_disk_status
    call print_string
    movzx eax, al
    call print_hex32
    call console_newline
    mov esi, msg_disk_first16
    call print_string
    mov esi, disk_buffer
    mov ecx, 16
.print_bytes:
    mov al, [esi]
    call print_hex8
    mov al, ' '
    call console_putc
    inc esi
    loop .print_bytes
    call console_newline
    ret
.hexdump:
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov ebx, eax
    call ata_read_lba
    mov esi, msg_disk_lba
    call print_string
    mov eax, ebx
    call print_hex32
    call console_newline
    mov esi, msg_disk_first64
    call print_line
    mov esi, disk_buffer
    mov ecx, 64
    call disk_print_bytes
    ret
.pread:
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov [disk_part_index], eax
    call parse_hex32
    mov [disk_rel_lba], eax
    call disk_partition_abs_lba
    test ecx, ecx
    jz .part_error
    mov ebx, eax
    call ata_read_lba
    mov esi, msg_disk_lba
    call print_string
    mov eax, ebx
    call print_hex32
    call console_newline
    mov esi, msg_disk_first16
    call print_string
    mov esi, disk_buffer
    mov ecx, 16
.pread_bytes:
    mov al, [esi]
    call print_hex8
    mov al, ' '
    call console_putc
    inc esi
    loop .pread_bytes
    call console_newline
    ret
.phex:
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov [disk_part_index], eax
    call parse_hex32
    mov [disk_rel_lba], eax
    call disk_partition_abs_lba
    test ecx, ecx
    jz .part_error
    mov ebx, eax
    call ata_read_lba
    mov esi, msg_disk_lba
    call print_string
    mov eax, ebx
    call print_hex32
    call console_newline
    mov esi, msg_disk_first64
    call print_line
    mov esi, disk_buffer
    mov ecx, 64
    call disk_print_bytes
    ret
.pwrite:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov [disk_part_index], eax
    call parse_hex32
    mov [disk_rel_lba], eax
    call parse_hex32
    mov [disk_write_byte], al
    call disk_partition_abs_lba
    test ecx, ecx
    jz .part_error
    mov ebx, eax
    mov edi, disk_buffer
    mov ecx, 512
.pfill:
    mov al, [disk_write_byte]
    mov [edi], al
    inc edi
    loop .pfill
    mov esi, msg_disk_write_warn
    call print_line
    mov eax, ebx
    call ata_write_lba
    mov esi, msg_disk_write_done
    call print_string
    movzx eax, al
    call print_hex32
    call console_newline
    ret
.part_error:
    ret
.write:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov ebx, eax
    call parse_hex32
    mov [disk_write_byte], al
    mov edi, disk_buffer
    mov ecx, 512
.fill:
    mov al, [disk_write_byte]
    mov [edi], al
    inc edi
    loop .fill
    mov esi, msg_disk_write_warn
    call print_line
    mov eax, ebx
    call ata_write_lba
    mov esi, msg_disk_write_done
    call print_string
    movzx eax, al
    call print_hex32
    call console_newline
    ret
.burn:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    mov edi, disk_arg_mbr
    call match_token
    test eax, eax
    jz .usage
    call prepare_minimal_mbr
    mov esi, msg_disk_burn_warn
    call print_line
    xor eax, eax
    call ata_write_lba
    mov esi, msg_disk_burn_done
    call print_string
    movzx eax, al
    call print_hex32
    call console_newline
    ret
.usage:
    mov esi, msg_usage_disk
    call print_line
    ret
.denied:
    ret

ata_wait_ready:
    mov dx, 0x1F7
.wait:
    in al, dx
    test al, 0x80
    jnz .wait
    ret

ata_read_lba:
    push ebx
    push ecx
    mov ebx, eax
    call ata_wait_ready
    mov dx, 0x1F2
    mov al, 1
    out dx, al
    mov dx, 0x1F3
    mov al, bl
    out dx, al
    mov dx, 0x1F4
    mov al, bh
    out dx, al
    mov dx, 0x1F5
    mov ecx, ebx
    shr ecx, 16
    mov al, cl
    out dx, al
    mov dx, 0x1F6
    mov al, 0xE0
    mov ecx, ebx
    shr ecx, 24
    and cl, 0x0F
    or al, cl
    out dx, al
    mov dx, 0x1F7
    mov al, 0x20
    out dx, al
.poll:
    in al, dx
    mov ah, al
    test al, 0x08
    jnz .read
    test al, 0x01
    jnz .done
    jmp .poll
.read:
    mov dx, 0x1F0
    mov edi, disk_buffer
    mov ecx, 256
    rep insw
.done:
    mov al, ah
    pop ecx
    pop ebx
    ret

ata_write_lba:
    push ebx
    push ecx
    mov ebx, eax
    call ata_wait_ready
    mov dx, 0x1F2
    mov al, 1
    out dx, al
    mov dx, 0x1F3
    mov al, bl
    out dx, al
    mov dx, 0x1F4
    mov al, bh
    out dx, al
    mov dx, 0x1F5
    mov ecx, ebx
    shr ecx, 16
    mov al, cl
    out dx, al
    mov dx, 0x1F6
    mov al, 0xE0
    mov ecx, ebx
    shr ecx, 24
    and cl, 0x0F
    or al, cl
    out dx, al
    mov dx, 0x1F7
    mov al, 0x30
    out dx, al
.poll:
    in al, dx
    mov ah, al
    test al, 0x08
    jnz .write
    test al, 0x01
    jnz .done
    jmp .poll
.write:
    mov dx, 0x1F0
    mov esi, disk_buffer
    mov ecx, 256
    rep outsw
    mov dx, 0x1F7
    mov al, 0xE7
    out dx, al
    call ata_wait_ready
    in al, dx
    mov ah, al
.done:
    mov al, ah
    pop ecx
    pop ebx
    ret

prepare_minimal_mbr:
    pushad
    mov edi, disk_buffer
    xor eax, eax
    mov ecx, 512 / 4
    rep stosd
    mov byte [disk_buffer + 446], 0x00
    mov byte [disk_buffer + 446 + 4], 0x7F
    mov dword [disk_buffer + 446 + 8], 2048
    mov dword [disk_buffer + 446 + 12], 65536
    mov word [disk_buffer + 510], 0xAA55
    popad
    ret

prepare_hd_mbr:
    pushad
    mov esi, hd_mbr_template
    mov edi, disk_buffer
    mov ecx, 512
    rep movsb
    mov byte [disk_buffer + 446], 0x80
    mov byte [disk_buffer + 446 + 1], 0
    mov byte [disk_buffer + 446 + 2], 2
    mov byte [disk_buffer + 446 + 3], 0
    mov byte [disk_buffer + 446 + 4], 0x7F
    mov byte [disk_buffer + 446 + 5], 0xFE
    mov byte [disk_buffer + 446 + 6], 0xFF
    mov byte [disk_buffer + 446 + 7], 0xFF
    mov dword [disk_buffer + 446 + 8], 2048
    mov dword [disk_buffer + 446 + 12], 65536
    mov byte [disk_buffer + 446 + 16], 0x00
    mov byte [disk_buffer + 446 + 16 + 4], 0x7F
    mov dword [disk_buffer + 446 + 16 + 8], 67584
    mov dword [disk_buffer + 446 + 16 + 12], 2048
    mov byte [disk_buffer + 446 + 32], 0x00
    mov byte [disk_buffer + 446 + 32 + 4], 0x7F
    mov dword [disk_buffer + 446 + 32 + 8], 69632
    mov dword [disk_buffer + 446 + 32 + 12], 2048
    mov byte [disk_buffer + 446 + 48], 0x00
    mov byte [disk_buffer + 446 + 48 + 4], 0x7F
    mov dword [disk_buffer + 446 + 48 + 8], 71680
    mov dword [disk_buffer + 446 + 48 + 12], 2048
    mov word [disk_buffer + 510], 0xAA55
    popad
    ret

disk_partition_installer_layout:
    pushad
    mov esi, msg_disk_partitioning
    call print_line
    call prepare_hd_mbr
    mov byte [disk_buffer + 446 + 16], 0x00
    mov byte [disk_buffer + 446 + 16 + 4], 0x7F
    mov dword [disk_buffer + 446 + 16 + 8], 67584
    mov dword [disk_buffer + 446 + 16 + 12], 2048
    mov byte [disk_buffer + 446 + 32], 0x00
    mov byte [disk_buffer + 446 + 32 + 4], 0x7F
    mov dword [disk_buffer + 446 + 32 + 8], 69632
    mov dword [disk_buffer + 446 + 32 + 12], 2048
    mov byte [disk_buffer + 446 + 48], 0x00
    mov byte [disk_buffer + 446 + 48 + 4], 0x7F
    mov dword [disk_buffer + 446 + 48 + 8], 71680
    mov dword [disk_buffer + 446 + 48 + 12], 2048
    xor eax, eax
    call ata_write_lba
    mov esi, msg_disk_partition_done
    call print_line
    popad
    ret

disk_print_summary:
    pushad
    mov esi, msg_disk_title
    call print_line
    call detect_storage_pci
    cmp byte [sata_found], 0
    je .ide_bus
    mov esi, msg_disk_bus_sata
    call print_line
    jmp .read_mbr
.ide_bus:
    mov esi, msg_disk_bus_ide
    call print_line
.read_mbr:
    xor eax, eax
    call ata_read_lba
    mov esi, msg_disk_status
    call print_string
    movzx eax, al
    call print_hex32
    call console_newline

    cmp word [disk_buffer + 510], 0xAA55
    jne .bad_mbr
    mov esi, msg_disk_mbr_ok
    call print_line
    mov esi, msg_disk_part0
    call print_string
    mov al, [disk_buffer + 446 + 4]
    call print_hex8
    call console_newline
    mov esi, msg_disk_start
    call print_string
    mov eax, [disk_buffer + 446 + 8]
    call print_hex32
    call console_newline
    mov esi, msg_disk_size
    call print_string
    mov eax, [disk_buffer + 446 + 12]
    call print_hex32
    call console_newline
    mov esi, msg_disk_note
    call print_line
    jmp .done
.bad_mbr:
    mov esi, msg_disk_mbr_bad
    call print_line
    mov esi, msg_disk_note
    call print_line
.done:
    popad
    ret

disk_print_partitions:
    pushad
    xor eax, eax
    call ata_read_lba
    cmp word [disk_buffer + 510], 0xAA55
    jne .bad
    mov esi, msg_disk_part_head
    call print_line
    xor ebx, ebx
.loop:
    cmp ebx, 4
    jae .done
    call disk_print_partition_ebx
    inc ebx
    jmp .loop
.bad:
    mov esi, msg_disk_mbr_bad
    call print_line
.done:
    popad
    ret

disk_print_partition_ebx:
    pushad
    mov esi, msg_disk_part_idx
    call print_string
    mov eax, ebx
    call print_hex32
    mov al, ' '
    call console_putc
    mov eax, ebx
    imul eax, 16
    add eax, disk_buffer + 446
    mov edx, eax
    movzx eax, byte [edx]
    call print_hex8
    mov al, ' '
    call console_putc
    movzx eax, byte [edx + 4]
    call print_hex8
    mov al, ' '
    call console_putc
    mov eax, [edx + 8]
    call print_hex32
    mov al, ' '
    call console_putc
    mov eax, [edx + 12]
    call print_hex32
    call console_newline
    popad
    ret

disk_print_bytes:
    pushad
    xor ebx, ebx
.loop:
    cmp ecx, 0
    je .done
    mov al, [esi]
    call print_hex8
    mov al, ' '
    call console_putc
    inc esi
    inc ebx
    dec ecx
    mov eax, ebx
    and eax, 0x0F
    cmp eax, 0
    jne .loop
    call console_newline
    jmp .loop
.done:
    call console_newline
    popad
    ret

disk_verify_layout:
    pushad
    mov esi, msg_disk_verify_title
    call print_line
    xor eax, eax
    call ata_read_lba
    cmp word [disk_buffer + 510], 0xAA55
    jne .mbr_bad
    mov esi, msg_disk_verify_mbr_ok
    call print_line
    jmp .stage2
.mbr_bad:
    mov esi, msg_disk_verify_mbr_bad
    call print_line
.stage2:
    mov eax, 1
    call ata_read_lba
    mov esi, disk_buffer
    mov ecx, 512
    mov edi, msg_disk_verify_stage2_probe
    call disk_sector_contains
    test eax, eax
    jz .stage2_bad
.stage2_ok:
    mov esi, msg_disk_verify_stage2_ok
    call print_line
    jmp .kernel
.stage2_bad:
    mov esi, msg_disk_verify_stage2_bad
    call print_line
.kernel:
    mov eax, HD_KERNEL_LBA
    call ata_read_lba
    cmp dword [disk_buffer], 0x464C457F
    jne .kernel_bad
    mov esi, msg_disk_verify_kernel_ok
    call print_line
    jmp .skyfs
.kernel_bad:
    mov esi, msg_disk_verify_kernel_bad
    call print_line
.skyfs:
    mov eax, 2048
    call ata_read_lba
    cmp dword [disk_buffer], 0x46594B53
    jne .skyfs_bad
    mov esi, msg_disk_verify_skyfs_ok
    call print_line
    jmp .done
.skyfs_bad:
    mov esi, msg_disk_verify_skyfs_bad
    call print_line
.done:
    popad
    ret

disk_sector_contains:
    push esi
    push edi
    push ecx
.outer:
    cmp ecx, 4
    jb .no
    push esi
    push edi
    mov edx, 4
.cmp:
    mov al, [esi]
    cmp al, [edi]
    jne .mismatch
    inc esi
    inc edi
    dec edx
    jnz .cmp
    pop edi
    pop esi
    mov eax, 1
    jmp .done
.mismatch:
    pop edi
    pop esi
    inc esi
    dec ecx
    jmp .outer
.no:
    xor eax, eax
.done:
    pop ecx
    pop edi
    pop esi
    ret

disk_print_root_entries:
    pushad
    mov esi, msg_disk_root_title
    call print_line
    mov dword [disk_part_index], 0
    mov dword [disk_rel_lba], 2
    call disk_partition_abs_lba
    test ecx, ecx
    jz .done
    call ata_read_lba
    mov ebx, disk_buffer
    mov ecx, 8
.loop:
    cmp byte [ebx], 0
    je .next
    mov esi, ebx
    call print_string
    mov al, ' '
    call console_putc
    mov eax, [ebx + 48]
    call print_hex32
    mov al, ' '
    call console_putc
    mov eax, [ebx + 52]
    call print_dec32
    call console_newline
.next:
    add ebx, 64
    loop .loop
.done:
    popad
    ret

disk_probe_filesystem:
    pushad
    mov esi, msg_disk_fs_title
    call print_line
    mov esi, msg_disk_fs_mbr_type
    call print_string
    xor eax, eax
    call ata_read_lba
    mov ebx, [disk_part_index]
    cmp ebx, 4
    jae .unknown
    imul ebx, 16
    add ebx, disk_buffer + 446
    mov al, [ebx + 4]
    call print_hex8
    call console_newline
    mov eax, [ebx + 8]
    mov [disk_fs_lba], eax
    call ata_read_lba

    cmp dword [disk_buffer + 3], 0x5346544E
    jne .check_exfat
    cmp dword [disk_buffer + 7], 0x20202020
    jne .check_exfat
    mov esi, msg_disk_fs_ntfs
    call print_line
    jmp .done
.check_exfat:
    cmp dword [disk_buffer + 3], 0x41465845
    jne .check_fat32
    cmp dword [disk_buffer + 7], 0x20202054
    jne .check_fat32
    mov esi, msg_disk_fs_exfat
    call print_line
    jmp .done
.check_fat32:
    cmp dword [disk_buffer + 82], 0x33544146
    jne .check_fat16
    cmp byte [disk_buffer + 86], '2'
    jne .check_fat16
    mov esi, msg_disk_fs_fat32
    call print_line
    jmp .done
.check_fat16:
    cmp dword [disk_buffer + 54], 0x31544146
    jne .check_skyfs
    mov esi, msg_disk_fs_fat16
    call print_line
    jmp .done
.check_skyfs:
    cmp dword [disk_buffer], 0x46594B53
    jne .check_ext
    mov esi, msg_disk_fs_skyfs
    call print_line
    jmp .done
.check_ext:
    mov eax, [disk_fs_lba]
    add eax, 2
    call ata_read_lba
    cmp word [disk_buffer + 56], 0xEF53
    jne .unknown
    mov esi, msg_disk_fs_ext
    call print_line
    jmp .done
.unknown:
    mov esi, msg_disk_fs_unknown
    call print_line
.done:
    popad
    ret

disk_partition_abs_lba:
    push ebx
    push edx
    xor ecx, ecx
    xor eax, eax
    call ata_read_lba
    cmp word [disk_buffer + 510], 0xAA55
    jne .bad_mbr
    mov ebx, [disk_part_index]
    cmp ebx, 4
    jae .bounds
    imul ebx, 16
    add ebx, disk_buffer + 446
    mov eax, [ebx + 12]
    cmp eax, 0
    je .empty
    mov edx, [disk_rel_lba]
    cmp edx, eax
    jae .bounds
    mov eax, [ebx + 8]
    add eax, edx
    mov ecx, 1
    jmp .done
.bad_mbr:
    mov esi, msg_disk_mbr_bad
    call print_line
    jmp .done
.empty:
    mov esi, msg_disk_part_empty
    call print_line
    jmp .done
.bounds:
    mov esi, msg_disk_part_oob
    call print_line
.done:
    pop edx
    pop ebx
    ret

command_install:
    call require_root
    test eax, eax
    jz .denied
    mov esi, msg_disk_install_start
    call print_line
    call disk_partition_installer_layout
    call install_boot_chain
    test eax, eax
    jz .no_kernel
    mov esi, msg_disk_install_mbr
    call print_line
    mov esi, msg_disk_install_stage2
    call print_line
    mov esi, msg_disk_install_kernel
    call print_line
    mov dword [disk_part_index], 0
    call disk_mkfs_skyfs
    mov esi, msg_disk_root_marker
    call print_line
    mov esi, msg_disk_install_done
    call print_line
    mov esi, msg_disk_install_note
    call print_line
    ret
.no_kernel:
    mov esi, msg_disk_install_no_kernel
    call print_line
    ret
.denied:
    ret

command_unskyos:
    call require_root
    test eax, eax
    jz .denied
    mov esi, msg_unskyos_warning
    call print_line
    mov esi, msg_unskyos_prompt
    call print_string
    call read_line
    mov esi, input_buffer
    mov edi, msg_unskyos_confirm
    call cstr_equals
    test eax, eax
    jz .abort
    mov esi, msg_unskyos_wiping
    call print_line
    call unskyos_wipe_disk
    mov byte [disk_mount_valid], 0
    mov esi, msg_unskyos_done
    call print_line
    ret
.abort:
    mov esi, msg_unskyos_abort
    call print_line
    ret
.denied:
    ret

unskyos_wipe_disk:
    pushad
    xor eax, eax
    call ata_read_lba
    mov esi, disk_buffer + 446
    mov ecx, 4
.part_loop:
    cmp byte [esi + 4], 0x7F
    jne .next_part
    push ecx
    push esi
    mov eax, [esi + 8]
    mov [disk_wipe_lba], eax
    mov eax, [esi + 12]
    mov [disk_wipe_sectors], eax
    mov ebx, [disk_wipe_lba]
    mov ecx, [disk_wipe_sectors]
    call disk_zero_lba_range
    pop esi
    pop ecx
.next_part:
    add esi, 16
    loop .part_loop
    mov ebx, 0
    mov ecx, 2048
    call disk_zero_lba_range
    popad
    ret

disk_zero_lba_range:
    pushad
    push ebx
    push ecx
    mov edi, disk_buffer
    xor eax, eax
    mov ecx, 512 / 4
    rep stosd
    pop ecx
    pop ebx
.loop:
    test ecx, ecx
    jz .done
    mov eax, ebx
    call ata_write_lba
    inc ebx
    dec ecx
    jmp .loop
.done:
    popad
    ret

install_boot_chain:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    cmp dword [boot_kernel_cd_sectors], 0
    jne .have_kernel
    cmp byte [boot_mode_install], 1
    jne .fail
.have_kernel:
    call prepare_hd_mbr
    xor eax, eax
    call ata_write_lba

    mov esi, hd_stage2_blob
    mov ebx, HD_STAGE2_LBA
    mov ecx, HD_STAGE2_SECTORS * 512
    call write_blob_sectors

    mov eax, [boot_kernel_cd_sectors]
    test eax, eax
    jz .fail
    shl eax, 11
    mov ecx, eax
    mov esi, CD_KERNEL_LOAD_PHYS
    mov ebx, HD_KERNEL_LBA
    call write_blob_sectors
    mov eax, 1
    jmp .done
.fail:
    xor eax, eax
.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

write_blob_sectors:
    pushad
.sector:
    test ecx, ecx
    jz .done
    push esi
    push ecx
    push ebx
    mov edi, disk_buffer
    mov ecx, 512 / 4
    xor eax, eax
    rep stosd
    pop ebx
    pop ecx
    pop esi
    push esi
    push ecx
    push ebx
    mov edi, disk_buffer
    mov edx, ecx
    cmp edx, 512
    jbe .copy_count_ok
    mov edx, 512
.copy_count_ok:
    mov ecx, edx
    rep movsb
    pop ebx
    mov eax, ebx
    call ata_write_lba
    inc ebx
    pop ecx
    pop esi
    add esi, 512
    cmp ecx, 512
    jbe .done
    sub ecx, 512
    jmp .sector
.done:
    popad
    ret

disk_mkfs_skyfs:
    mov dword [disk_rel_lba], 0
    call disk_partition_abs_lba
    test ecx, ecx
    jz .done
    mov [disk_mount_lba], eax
    mov ebx, [disk_part_index]
    imul ebx, 16
    add ebx, disk_buffer + 446
    mov eax, [ebx + 12]
    mov [disk_mount_sectors], eax
    mov esi, msg_disk_skyfs_format
    call print_line
    call prepare_skyfs_superblock
    mov eax, [disk_mount_lba]
    call ata_write_lba
    mov esi, msg_disk_write_done
    call print_string
    movzx eax, al
    call print_hex32
    call console_newline
    call prepare_skyfs_manifest
    mov eax, [disk_mount_lba]
    inc eax
    call ata_write_lba
    mov esi, msg_disk_write_done
    call print_string
    movzx eax, al
    call print_hex32
    call console_newline
    call prepare_skyfs_directory
    mov eax, [disk_mount_lba]
    add eax, 2
    call ata_write_lba
    call skyfs_write_installed_files
    mov byte [disk_mount_valid], 1
    mov eax, [disk_part_index]
    mov [disk_mount_part], eax
    mov esi, msg_disk_skyfs_mount
    call print_line
.done:
    ret

disk_mount_skyfs:
    mov dword [disk_rel_lba], 0
    call disk_partition_abs_lba
    test ecx, ecx
    jz .done
    mov [disk_mount_lba], eax
    mov ebx, [disk_part_index]
    imul ebx, 16
    add ebx, disk_buffer + 446
    mov eax, [ebx + 12]
    mov [disk_mount_sectors], eax
    mov eax, [disk_mount_lba]
    call ata_read_lba
    cmp dword [disk_buffer], 0x46594B53
    jne .bad
    mov byte [disk_mount_valid], 1
    mov eax, [disk_part_index]
    mov [disk_mount_part], eax
    mov esi, msg_disk_skyfs_mount
    call print_line
    ret
.bad:
    mov byte [disk_mount_valid], 0
    mov esi, msg_disk_skyfs_bad
    call print_line
.done:
    ret

init_skyfs_root:
    mov dword [disk_part_index], 0
    call disk_mount_skyfs_quiet
    cmp byte [disk_mount_valid], 1
    jne .done
    mov esi, msg_skyfs_root_found
    call print_line
    mov esi, path_skyfs_init
    call skyfs_find_file
    test eax, eax
    jz .done
    mov esi, msg_skyfs_init_found
    call print_line
.done:
    ret

run_skyfs_init:
    cmp byte [skyfs_init_ran], 1
    je .done
    cmp byte [disk_mount_valid], 1
    je .mounted
    mov dword [disk_part_index], 0
    call disk_mount_skyfs_quiet
    cmp byte [disk_mount_valid], 1
    jne .done
.mounted:
    mov esi, path_skyfs_init
    call skyfs_find_file
    test eax, eax
    jnz .load
    mov esi, msg_skyfs_init_missing
    call print_line
    jmp .done
.load:
    mov esi, msg_skyfs_init_run
    call print_line
    mov eax, [disk_mount_lba]
    add eax, [skyfs_file_lba]
    call ata_read_lba
    mov esi, disk_buffer
    mov edi, skyfs_init_buffer
    mov ecx, [skyfs_file_size]
    cmp ecx, 511
    jbe .size_ok
    mov ecx, 511
.size_ok:
    push ecx
    rep movsb
    pop ecx
    mov byte [skyfs_init_buffer + ecx], 0
    mov byte [skyfs_init_ran], 1
    mov esi, skyfs_init_buffer
    call run_soj_script
.done:
    ret

disk_mount_skyfs_quiet:
    mov dword [disk_rel_lba], 0
    call disk_partition_abs_lba
    test ecx, ecx
    jz .done
    mov [disk_mount_lba], eax
    mov ebx, [disk_part_index]
    imul ebx, 16
    add ebx, disk_buffer + 446
    mov eax, [ebx + 12]
    mov [disk_mount_sectors], eax
    mov eax, [disk_mount_lba]
    call ata_read_lba
    cmp dword [disk_buffer], 0x46594B53
    jne .bad
    mov byte [disk_mount_valid], 1
    mov eax, [disk_part_index]
    mov [disk_mount_part], eax
    ret
.bad:
    mov byte [disk_mount_valid], 0
.done:
    ret

skyfs_cat_path:
    cmp byte [disk_mount_valid], 1
    jne .missing
    cmp byte [esi], '/'
    je .absolute
    dec esi
.absolute:
    call skyfs_find_file
    test eax, eax
    jz .missing
    mov eax, [disk_mount_lba]
    add eax, [skyfs_file_lba]
    call ata_read_lba
    mov esi, disk_buffer
    mov ecx, [skyfs_file_size]
    cmp ecx, 512
    jbe .print
    mov ecx, 512
.print:
    cmp ecx, 0
    je .newline
    mov al, [esi]
    test al, al
    jz .newline
    call console_putc
    inc esi
    dec ecx
    jmp .print
.newline:
    call console_newline
    ret
.missing:
    mov esi, msg_skyfs_no_file
    call print_line
    ret

skyfs_find_file:
    push esi
    mov dword [skyfs_file_lba], 0
    mov dword [skyfs_file_size], 0
    mov eax, [disk_mount_lba]
    add eax, 2
    call ata_read_lba
    mov ebx, disk_buffer
    mov ecx, 8
.loop:
    cmp byte [ebx], 0
    je .next
    mov edi, ebx
    mov esi, [esp]
    call cstr_equals
    test eax, eax
    jnz .found
.next:
    add ebx, 64
    loop .loop
    xor eax, eax
    jmp .done
.found:
    mov eax, [ebx + 48]
    mov [skyfs_file_lba], eax
    mov eax, [ebx + 52]
    mov [skyfs_file_size], eax
    mov eax, [ebx + 56]
    mov [skyfs_file_sectors], eax
    mov eax, 1
.done:
    pop esi
    ret

prepare_skyfs_superblock:
    pushad
    mov edi, disk_buffer
    xor eax, eax
    mov ecx, 512 / 4
    rep stosd
    mov dword [disk_buffer], 0x46594B53
    mov dword [disk_buffer + 4], 1
    mov dword [disk_buffer + 8], 512
    mov eax, [disk_mount_sectors]
    mov [disk_buffer + 12], eax
    mov dword [disk_buffer + 16], 1
    mov dword [disk_buffer + 20], 2
    mov edi, disk_buffer + 64
    mov esi, skyfs_label
    mov ecx, 63
    call copy_cstr_limited
    mov edi, disk_buffer + 128
    mov esi, skyfs_super_note
    mov ecx, 127
    call copy_cstr_limited
    popad
    ret

prepare_skyfs_manifest:
    pushad
    mov edi, disk_buffer
    xor eax, eax
    mov ecx, 512 / 4
    rep stosd
    mov edi, disk_buffer
    mov esi, skyfs_install_manifest
    mov ecx, 255
    call copy_cstr_limited
    popad
    ret

prepare_skyfs_directory:
    pushad
    mov edi, disk_buffer
    xor eax, eax
    mov ecx, 512 / 4
    rep stosd
    mov ebx, disk_buffer
    mov esi, path_skyfs_os_release
    mov edx, skyfs_file_os_release
    mov eax, 16
    call skyfs_add_dir_entry
    add ebx, 64
    mov esi, path_skyfs_init
    mov edx, skyfs_file_init
    mov eax, 17
    call skyfs_add_dir_entry
    add ebx, 64
    mov esi, path_skyfs_skysh
    mov edx, skyfs_file_skysh
    mov eax, 18
    call skyfs_add_dir_entry
    add ebx, 64
    mov esi, path_skyfs_passwd
    mov edx, skyfs_file_passwd
    mov eax, 19
    call skyfs_add_dir_entry
    add ebx, 64
    mov esi, path_skyfs_shadow
    mov edx, skyfs_file_shadow
    mov eax, 20
    call skyfs_add_dir_entry
    add ebx, 64
    mov esi, path_skyfs_sudoers
    mov edx, skyfs_file_sudoers
    mov eax, 21
    call skyfs_add_dir_entry
    add ebx, 64
    mov esi, path_skyfs_loader
    mov edx, skyfs_file_loader
    mov eax, 22
    call skyfs_add_dir_entry
    add ebx, 64
    mov esi, path_skyfs_sources
    mov edx, skyfs_file_sources
    mov eax, 23
    call skyfs_add_dir_entry
    popad
    ret

skyfs_add_dir_entry:
    pushad
    mov edi, ebx
    mov ecx, 47
    call copy_cstr_limited
    mov [ebx + 48], eax
    mov esi, edx
    call cstr_len
    mov [ebx + 52], eax
    mov dword [ebx + 56], 1
    popad
    ret

skyfs_write_installed_files:
    pushad
    mov esi, skyfs_file_os_release
    mov eax, 16
    call skyfs_write_file_sector
    mov esi, skyfs_file_init
    mov eax, 17
    call skyfs_write_file_sector
    mov esi, skyfs_file_skysh
    mov eax, 18
    call skyfs_write_file_sector
    mov esi, skyfs_file_passwd
    mov eax, 19
    call skyfs_write_file_sector
    mov esi, skyfs_file_shadow
    mov eax, 20
    call skyfs_write_file_sector
    mov esi, skyfs_file_sudoers
    mov eax, 21
    call skyfs_write_file_sector
    mov esi, skyfs_file_loader
    mov eax, 22
    call skyfs_write_file_sector
    mov esi, skyfs_file_sources
    mov eax, 23
    call skyfs_write_file_sector
    popad
    ret

skyfs_write_file_sector:
    pushad
    push eax
    push esi
    mov edi, disk_buffer
    xor eax, eax
    mov ecx, 512 / 4
    rep stosd
    pop esi
    mov edi, disk_buffer
    mov ecx, 511
    call copy_cstr_limited
    pop eax
    add eax, [disk_mount_lba]
    call ata_write_lba
    popad
    ret

copy_cstr_limited:
    cmp ecx, 0
    je .done
.loop:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .done
    inc esi
    inc edi
    dec ecx
    jnz .loop
    mov byte [edi], 0
.done:
    ret

cstr_len:
    push esi
    xor eax, eax
.loop:
    cmp byte [esi], 0
    je .done
    inc esi
    inc eax
    jmp .loop
.done:
    pop esi
    ret

command_cat:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, path_mnt_disk0_prefix
    call starts_with
    test eax, eax
    jnz .skyfs_cat
    call ramfs_check_read
    cmp eax, 2
    je .done_denied
    test eax, eax
    jz .not_found

    mov edi, path_home_note
    call match_token
    test eax, eax
    jnz .note
    mov edi, path_demo_soj
    call match_token
    test eax, eax
    jnz .demo_soj
    mov edi, path_dot_demo_soj
    call match_token
    test eax, eax
    jnz .demo_soj
    mov edi, path_script_soj
    call match_token
    test eax, eax
    jnz .script_soj
    mov edi, path_logo_png
    call match_token
    test eax, eax
    jnz .logo_png
    mov edi, path_photo_jpg
    call match_token
    test eax, eax
    jnz .photo_jpg
    mov edi, path_dot_script_soj
    call match_token
    test eax, eax
    jnz .script_soj
    mov edi, path_dot_logo_png
    call match_token
    test eax, eax
    jnz .logo_png
    mov edi, path_dot_photo_jpg
    call match_token
    test eax, eax
    jnz .photo_jpg
    mov edi, path_home_sky
    call match_token
    test eax, eax
    jnz .sky
    mov edi, path_etc_conf
    call match_token
    test eax, eax
    jnz .conf
    mov edi, path_sapp_sources
    call match_token
    test eax, eax
    jnz .sources

    cmp dword [current_dir], DIR_ROOT
    jne .check_etc
    mov edi, name_sky
    call match_token
    test eax, eax
    jnz .sky

.check_etc:
    cmp dword [current_dir], DIR_ETC
    jne .check_home
    mov edi, name_conf
    call match_token
    test eax, eax
    jnz .conf
    mov edi, name_sources
    call match_token
    test eax, eax
    jnz .sources

.check_home:
    cmp dword [current_dir], DIR_HOME
    jne .not_found
    mov edi, name_note
    call match_token
    test eax, eax
    jnz .note
    mov edi, name_demo_soj
    call match_token
    test eax, eax
    jnz .demo_soj
    mov edi, name_script_soj
    call match_token
    test eax, eax
    jnz .script_soj
    mov edi, name_logo_png
    call match_token
    test eax, eax
    jnz .logo_png
    mov edi, name_photo_jpg
    call match_token
    test eax, eax
    jnz .photo_jpg

.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_usage_cat
    call print_line
    ret
.skyfs_cat:
    add esi, 10
    call skyfs_cat_path
    ret
.sky:
    mov esi, file_sky
    call print_line
    ret
.conf:
    mov esi, file_conf
    call print_line
    ret
.sources:
    mov esi, file_sapp_sources
    call print_line
    ret
.note:
    mov esi, home_note
    call print_line
    ret
.demo_soj:
    mov esi, file_demo_soj
    call print_line
    ret
.script_soj:
    mov esi, home_script_soj
    call print_line
    ret
.logo_png:
    mov esi, file_logo_png
    call print_line
    ret
.photo_jpg:
    mov esi, file_photo_jpg
    call print_line
    ret
.done_denied:
    ret

command_write:
    call require_root
    test eax, eax
    jz .root_denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_check_write
    cmp eax, 2
    je .done_denied
    test eax, eax
    jz .not_found
    mov edi, path_home_note
    call match_token
    test eax, eax
    jnz .write_note
    mov edi, path_script_soj
    call match_token
    test eax, eax
    jnz .write_script
    cmp dword [current_dir], DIR_HOME
    jne .not_found
    mov edi, name_note
    call match_token
    test eax, eax
    jnz .write_note
    mov edi, name_script_soj
    call match_token
    test eax, eax
    jnz .write_script
    jmp .not_found

.write_note:
    call next_arg
    mov edi, home_note
    jmp .copy_text
.write_script:
    call next_arg
    mov edi, home_script_soj
.copy_text:
    mov ecx, 255
.copy:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .done
    inc esi
    inc edi
    loop .copy
    mov byte [edi], 0
.done:
    mov esi, msg_write_done
    call print_line
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_usage_write
    call print_line
    ret
.done_denied:
    ret
.root_denied:
    ret

command_fsop:
    mov esi, input_buffer
    call skip_spaces
    mov edi, cmd_cp
    call match_token
    test eax, eax
    jnz command_cp
    mov edi, cmd_mv
    call match_token
    test eax, eax
    jnz command_mv
    mov edi, cmd_rm
    call match_token
    test eax, eax
    jnz command_rm
    mov edi, cmd_touch
    call match_token
    test eax, eax
    jnz command_touch
    mov edi, cmd_mkdir
    call match_token
    test eax, eax
    jnz command_mkdir
    mov edi, cmd_chmod
    call match_token
    test eax, eax
    jnz command_chmod
    mov esi, msg_fsop_usage
    call print_line
    mov esi, msg_fsop_status
    call print_line
    ret

command_cp:
    call require_root
    test eax, eax
    jz .done
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_check_read
    cmp eax, 2
    je .done
    test eax, eax
    jz .not_found
    call ramfs_file_ptr_from_esi
    test eax, eax
    jz .not_found
    mov [fs_src_ptr], eax
    mov esi, input_buffer
    call first_arg
    call next_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_writable_file_ptr_from_esi
    cmp eax, 2
    je .readonly
    test eax, eax
    jz .not_found
    mov [fs_dst_ptr], eax
    call copy_fs_file
    mov esi, msg_fsop_done
    call print_line
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.readonly:
    mov esi, msg_fsop_readonly
    call print_line
    ret
.usage:
    mov esi, msg_cp_usage
    call print_line
.done:
    ret

command_mv:
    call require_root
    test eax, eax
    jz .denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_writable_file_ptr_from_esi
    cmp eax, 2
    je .readonly
    test eax, eax
    jz .not_found
    mov [fs_src_ptr], eax
    mov esi, input_buffer
    call first_arg
    call next_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_writable_file_ptr_from_esi
    cmp eax, 2
    je .readonly
    test eax, eax
    jz .not_found
    mov [fs_dst_ptr], eax
    call copy_fs_file
    mov edi, [fs_src_ptr]
    mov byte [edi], 0
    mov esi, msg_fsop_done
    call print_line
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.readonly:
    mov esi, msg_fsop_readonly
    call print_line
    ret
.usage:
    mov esi, msg_mv_usage
    call print_line
    ret
.denied:
    ret

command_rm:
    call require_root
    test eax, eax
    jz .denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_writable_file_ptr_from_esi
    cmp eax, 2
    je .readonly
    test eax, eax
    jz .not_found
    mov edi, eax
    mov byte [edi], 0
    mov esi, msg_fsop_done
    call print_line
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.readonly:
    mov esi, msg_fsop_readonly
    call print_line
    ret
.usage:
    mov esi, msg_rm_usage
    call print_line
    ret
.denied:
    ret

command_touch:
    call require_root
    test eax, eax
    jz .denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_writable_file_ptr_from_esi
    cmp eax, 2
    je .readonly
    test eax, eax
    jz .not_found
    mov esi, msg_fsop_done
    call print_line
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.readonly:
    mov esi, msg_fsop_readonly
    call print_line
    ret
.usage:
    mov esi, msg_touch_usage
    call print_line
    ret
.denied:
    ret

command_mkdir:
    call require_root
    test eax, eax
    jz .denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov esi, msg_mkdir_fixed
    call print_line
    ret
.usage:
    mov esi, msg_mkdir_usage
    call print_line
    ret
.denied:
    ret

command_chmod:
    call require_root
    test eax, eax
    jz .denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call parse_perm_octal
    mov [chmod_perm], al
    call next_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_perm_ptr_from_esi
    test eax, eax
    jz .not_found
    mov bl, [chmod_perm]
    mov [eax], bl
    mov esi, msg_chmod_done
    call print_line
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_chmod_usage
    call print_line
    ret
.denied:
    ret

command_stat:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_file_ptr_from_esi
    test eax, eax
    jz .not_found
    mov [fs_src_ptr], eax
    call ramfs_perm_ptr_from_esi
    test eax, eax
    jz .not_found
    mov [fs_perm_ptr], eax
    mov esi, msg_stat_file
    call print_string
    mov esi, input_buffer
    call first_arg
    call print_first_token
    call console_newline
    mov esi, msg_stat_size
    call print_string
    mov esi, [fs_src_ptr]
    call string_length_eax
    call print_hex32
    call console_newline
    mov esi, msg_stat_mode
    call print_string
    mov eax, [fs_perm_ptr]
    mov al, [eax]
    call print_hex8
    call console_newline
    mov esi, msg_stat_type
    call print_line
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_stat_usage
    call print_line
    ret

command_wc:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_check_read
    cmp eax, 2
    je .done
    test eax, eax
    jz .not_found
    call ramfs_file_ptr_from_esi
    test eax, eax
    jz .not_found
    mov esi, msg_wc_prefix
    call print_string
    mov esi, eax
    call string_length_eax
    call print_hex32
    call console_newline
.done:
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_wc_usage
    call print_line
    ret

command_head:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_check_read
    cmp eax, 2
    je .done
    test eax, eax
    jz .not_found
    call ramfs_file_ptr_from_esi
    test eax, eax
    jz .not_found
    mov esi, eax
    call print_line
.done:
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_head_usage
    call print_line
    ret

parse_perm_octal:
    call skip_spaces
    xor eax, eax
.loop:
    mov bl, [esi]
    cmp bl, '0'
    jb .done
    cmp bl, '7'
    ja .done
    shl eax, 3
    sub bl, '0'
    movzx edx, bl
    or eax, edx
    inc esi
    jmp .loop
.done:
    and eax, 7
    ret

copy_fs_file:
    pushad
    mov esi, [fs_src_ptr]
    mov edi, [fs_dst_ptr]
    mov ecx, 255
.copy:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .done
    inc esi
    inc edi
    loop .copy
    mov byte [edi], 0
.done:
    popad
    ret

string_length_eax:
    push esi
    xor eax, eax
.loop:
    cmp byte [esi + eax], 0
    je .done
    inc eax
    jmp .loop
.done:
    pop esi
    ret

ramfs_writable_file_ptr_from_esi:
    push esi
    call ramfs_perm_ptr_from_esi
    test eax, eax
    jz .missing
    test byte [eax], 2
    jz .denied
    pop esi
    call ramfs_file_ptr_from_esi
    ret
.missing:
    pop esi
    xor eax, eax
    ret
.denied:
    pop esi
    mov eax, 2
    ret

ramfs_file_ptr_from_esi:
    push esi
    mov edi, path_home_note
    call match_token
    test eax, eax
    jnz .note
    mov edi, name_note
    call match_token
    test eax, eax
    jnz .note_home
    mov edi, path_script_soj
    call match_token
    test eax, eax
    jnz .script
    mov edi, path_dot_script_soj
    call match_token
    test eax, eax
    jnz .script_home
    mov edi, name_script_soj
    call match_token
    test eax, eax
    jnz .script_home
    mov edi, path_demo_soj
    call match_token
    test eax, eax
    jnz .demo
    mov edi, path_dot_demo_soj
    call match_token
    test eax, eax
    jnz .demo_home
    mov edi, name_demo_soj
    call match_token
    test eax, eax
    jnz .demo_home
    mov edi, path_home_sky
    call match_token
    test eax, eax
    jnz .sky
    mov edi, name_sky
    call match_token
    test eax, eax
    jnz .sky_root
    mov edi, path_etc_conf
    call match_token
    test eax, eax
    jnz .conf
    mov edi, name_conf
    call match_token
    test eax, eax
    jnz .conf_etc
    mov edi, path_sapp_sources
    call match_token
    test eax, eax
    jnz .sources
    mov edi, name_sources
    call match_token
    test eax, eax
    jnz .sources_etc
    mov edi, path_logo_png
    call match_token
    test eax, eax
    jnz .logo
    mov edi, path_dot_logo_png
    call match_token
    test eax, eax
    jnz .logo_home
    mov edi, name_logo_png
    call match_token
    test eax, eax
    jnz .logo_home
    mov edi, path_photo_jpg
    call match_token
    test eax, eax
    jnz .photo
    mov edi, path_dot_photo_jpg
    call match_token
    test eax, eax
    jnz .photo_home
    mov edi, name_photo_jpg
    call match_token
    test eax, eax
    jnz .photo_home
    xor eax, eax
    jmp .done
.note_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.note:
    mov eax, home_note
    jmp .done
.script_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.script:
    mov eax, home_script_soj
    jmp .done
.demo_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.demo:
    mov eax, file_demo_soj
    jmp .done
.sky_root:
    cmp dword [current_dir], DIR_ROOT
    jne .no
.sky:
    mov eax, file_sky
    jmp .done
.conf_etc:
    cmp dword [current_dir], DIR_ETC
    jne .no
.conf:
    mov eax, file_conf
    jmp .done
.sources_etc:
    cmp dword [current_dir], DIR_ETC
    jne .no
.sources:
    mov eax, file_sapp_sources
    jmp .done
.logo_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.logo:
    mov eax, file_logo_png
    jmp .done
.photo_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.photo:
    mov eax, file_photo_jpg
    jmp .done
.no:
    xor eax, eax
.done:
    pop esi
    ret

ramfs_perm_ptr_from_esi:
    push esi
    mov edi, path_home_note
    call match_token
    test eax, eax
    jnz .note
    mov edi, name_note
    call match_token
    test eax, eax
    jnz .note_home
    mov edi, path_script_soj
    call match_token
    test eax, eax
    jnz .script
    mov edi, path_dot_script_soj
    call match_token
    test eax, eax
    jnz .script_home
    mov edi, name_script_soj
    call match_token
    test eax, eax
    jnz .script_home
    mov edi, path_demo_soj
    call match_token
    test eax, eax
    jnz .demo
    mov edi, path_dot_demo_soj
    call match_token
    test eax, eax
    jnz .demo_home
    mov edi, name_demo_soj
    call match_token
    test eax, eax
    jnz .demo_home
    mov edi, path_home_sky
    call match_token
    test eax, eax
    jnz .sky
    mov edi, name_sky
    call match_token
    test eax, eax
    jnz .sky_root
    mov edi, path_etc_conf
    call match_token
    test eax, eax
    jnz .conf
    mov edi, name_conf
    call match_token
    test eax, eax
    jnz .conf_etc
    mov edi, path_sapp_sources
    call match_token
    test eax, eax
    jnz .sources
    mov edi, name_sources
    call match_token
    test eax, eax
    jnz .sources_etc
    mov edi, path_logo_png
    call match_token
    test eax, eax
    jnz .logo
    mov edi, path_dot_logo_png
    call match_token
    test eax, eax
    jnz .logo_home
    mov edi, name_logo_png
    call match_token
    test eax, eax
    jnz .logo_home
    mov edi, path_photo_jpg
    call match_token
    test eax, eax
    jnz .photo
    mov edi, path_dot_photo_jpg
    call match_token
    test eax, eax
    jnz .photo_home
    mov edi, name_photo_jpg
    call match_token
    test eax, eax
    jnz .photo_home
    xor eax, eax
    jmp .done
.note_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.note:
    mov eax, perm_note
    jmp .done
.script_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.script:
    mov eax, perm_script
    jmp .done
.demo_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.demo:
    mov eax, perm_demo
    jmp .done
.sky_root:
    cmp dword [current_dir], DIR_ROOT
    jne .no
.sky:
    mov eax, perm_sky
    jmp .done
.conf_etc:
    cmp dword [current_dir], DIR_ETC
    jne .no
.conf:
    mov eax, perm_conf
    jmp .done
.sources_etc:
    cmp dword [current_dir], DIR_ETC
    jne .no
.sources:
    mov eax, perm_sources
    jmp .done
.logo_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.logo:
    mov eax, perm_logo
    jmp .done
.photo_home:
    cmp dword [current_dir], DIR_HOME
    jne .no
.photo:
    mov eax, perm_photo
    jmp .done
.no:
    xor eax, eax
.done:
    pop esi
    ret

ramfs_check_read:
    call ramfs_perm_ptr_from_esi
    test eax, eax
    jz .missing
    test byte [eax], 4
    jz .denied
    mov eax, 1
    ret
.missing:
    xor eax, eax
    ret
.denied:
    mov esi, msg_permission_denied
    call print_line
    mov eax, 2
    ret

ramfs_check_write:
    call ramfs_perm_ptr_from_esi
    test eax, eax
    jz .missing
    test byte [eax], 2
    jz .denied
    mov eax, 1
    ret
.missing:
    xor eax, eax
    ret
.denied:
    mov esi, msg_permission_denied
    call print_line
    mov eax, 2
    ret

command_grep:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov [grep_needle], esi
    call next_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_check_read
    cmp eax, 2
    je .done
    test eax, eax
    jz .not_found
    mov edi, path_home_note
    call match_token
    test eax, eax
    jnz .note
    mov edi, path_script_soj
    call match_token
    test eax, eax
    jnz .script
    mov edi, path_demo_soj
    call match_token
    test eax, eax
    jnz .demo
    cmp dword [current_dir], DIR_HOME
    jne .not_found
    mov edi, name_note
    call match_token
    test eax, eax
    jnz .note
    mov edi, name_script_soj
    call match_token
    test eax, eax
    jnz .script
    mov edi, name_demo_soj
    call match_token
    test eax, eax
    jnz .demo
    jmp .not_found
.note:
    mov esi, home_note
    jmp .match_file
.script:
    mov esi, home_script_soj
    jmp .match_file
.demo:
    mov esi, file_demo_soj
    jmp .match_file
.match_file:
    mov edi, [grep_needle]
    call string_contains_token
    test eax, eax
    jz .done
    call print_line
.done:
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_grep_usage
    call print_line
    ret

string_contains_token:
    push esi
    push edi
    push ebx
.outer:
    mov al, [esi]
    test al, al
    jz .no
    mov ebx, esi
    push edi
.inner:
    mov al, [edi]
    cmp al, 0
    je .yes_pop
    cmp al, ' '
    je .yes_pop
    cmp al, 9
    je .yes_pop
    mov ah, [ebx]
    cmp ah, 0
    je .no_pop
    cmp ah, al
    jne .no_pop
    inc ebx
    inc edi
    jmp .inner
.no_pop:
    pop edi
    inc esi
    jmp .outer
.yes_pop:
    pop edi
    mov eax, 1
    jmp .done
.no:
    xor eax, eax
.done:
    pop ebx
    pop edi
    pop esi
    ret

command_du:
    mov esi, msg_du_head
    call print_line
    ret

command_tool_pending:
    mov esi, msg_tool_pending
    call print_line
    ret

command_memedit:
    call require_root
    test eax, eax
    jz .denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call parse_hex32
    mov ebx, eax
    mov esi, msg_memedit_intro
    call print_line
.loop:
    mov esi, msg_memedit_addr
    call print_string
    mov eax, ebx
    call print_hex32
    mov esi, msg_memedit_value
    call print_string
    mov al, [ebx]
    call print_hex8
    call console_newline
    mov esi, msg_memedit_prompt
    call print_string
    call read_line
    cmp byte [command_cancelled], 1
    je .done
    cmp byte [input_buffer], 'q'
    je .done
    cmp byte [input_buffer], 0
    je .next
    mov esi, input_buffer
    call parse_hex32
    mov [ebx], al
.next:
    inc ebx
    jmp .loop
.done:
    ret
.usage:
    mov esi, msg_usage_memedit
    call print_line
    ret
.denied:
    ret

command_vi:
    call require_root
    test eax, eax
    jz .root_denied
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage

    mov byte [vi_readonly], 0
    call ramfs_check_read
    cmp eax, 2
    je .done_denied
    test eax, eax
    jz .not_found
    mov [vi_perm_ptr], eax
    mov dword [vi_status_ptr], msg_vi_status
    mov dword [vi_file_name_ptr], esi
    mov edi, path_home_note
    call match_token
    test eax, eax
    jnz .open_note
    mov edi, path_script_soj
    call match_token
    test eax, eax
    jnz .open_script
    mov edi, path_demo_soj
    call match_token
    test eax, eax
    jnz .open_demo
    mov edi, path_home_sky
    call match_token
    test eax, eax
    jnz .open_sky

    cmp dword [current_dir], DIR_ROOT
    jne .check_home
    mov edi, name_sky
    call match_token
    test eax, eax
    jnz .open_sky

.check_home:
    cmp dword [current_dir], DIR_HOME
    jne .not_found
    mov edi, name_note
    call match_token
    test eax, eax
    jnz .open_note
    mov edi, name_script_soj
    call match_token
    test eax, eax
    jnz .open_script
    mov edi, path_dot_script_soj
    call match_token
    test eax, eax
    jnz .open_script
    mov edi, name_demo_soj
    call match_token
    test eax, eax
    jnz .open_demo
    mov edi, path_dot_demo_soj
    call match_token
    test eax, eax
    jnz .open_demo
    jmp .not_found

.open_note:
    mov dword [vi_file_ptr], home_note
    mov dword [vi_file_name_ptr], path_home_note
    mov byte [vi_readonly], 0
    jmp .open
.open_script:
    mov dword [vi_file_ptr], home_script_soj
    mov dword [vi_file_name_ptr], path_script_soj
    mov byte [vi_readonly], 0
    jmp .open
.open_demo:
    mov dword [vi_file_ptr], file_demo_soj
    mov dword [vi_file_name_ptr], path_demo_soj
    mov byte [vi_readonly], 1
    jmp .open
.open_sky:
    mov dword [vi_file_ptr], file_sky
    mov dword [vi_file_name_ptr], path_home_sky
    mov byte [vi_readonly], 0
    jmp .open
.open:
    mov eax, [vi_perm_ptr]
    test byte [eax], 2
    jnz .writable
    cmp dword [current_uid], 0
    jne .readonly_perm
    cmp byte [vi_readonly], 1
    je .readonly_perm
    jmp .writable
.readonly_perm:
    mov byte [vi_readonly], 1
.writable:
    call vi_copy_file_to_clipboard
    call vi_redraw_screen
.loop:
    call read_key
    cmp al, 0x03
    je .quit
    cmp al, 27
    je .quit
    cmp al, 0x13
    je .save
    cmp al, 0x16
    je .paste
    cmp al, 8
    je .backspace
    cmp al, 13
    je .newline
    cmp al, 32
    jb .loop
    call vi_insert_char
    mov dword [vi_status_ptr], msg_vi_editing
    call vi_redraw_screen
    jmp .loop
.newline:
    mov al, 10
    call vi_insert_char
    mov dword [vi_status_ptr], msg_vi_editing
    call vi_redraw_screen
    jmp .loop
.backspace:
    cmp byte [vi_readonly], 0
    jne .readonly
    call vi_backspace_file
    mov dword [vi_status_ptr], msg_vi_editing
    call vi_redraw_screen
    jmp .loop
.save:
    call vi_copy_file_to_clipboard
    mov dword [vi_status_ptr], msg_vi_saved
    call vi_redraw_screen
    jmp .loop
.paste:
    cmp byte [vi_readonly], 0
    jne .readonly
    call vi_paste_clipboard
    mov dword [vi_status_ptr], msg_vi_pasted
    call vi_redraw_screen
    jmp .loop
.readonly:
    mov dword [vi_status_ptr], msg_vi_readonly
    call vi_redraw_status
    call vi_place_body_cursor
    jmp .loop
.quit:
    mov al, 0x0F
    call set_color
    call clear_screen
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_usage_vi
    call print_line
    ret
.done_denied:
    ret
.root_denied:
    ret

vi_print_content:
    mov esi, [vi_file_ptr]
    call print_line
    ret

vi_redraw_screen:
    pushad
    call clear_screen
    call vi_draw_header
    call vi_draw_body
    call vi_redraw_status
    call vi_place_body_cursor
    popad
    ret

vi_draw_header:
    pushad
    mov ebx, 0
    mov al, 0x70
    call vi_clear_row
    mov eax, 0
    mov ebx, 0
    call set_cursor
    mov al, 0x70
    call set_color
    mov esi, msg_vi_file
    call print_string
    mov esi, [vi_file_name_ptr]
    call print_string
    mov al, 0x0F
    call set_color
    popad
    ret

vi_draw_body:
    pushad
    mov dword [vi_body_cursor_x], 0
    mov dword [vi_body_cursor_y], 1
    mov eax, 0
    mov ebx, 1
    call set_cursor
    mov al, 0x0F
    call set_color
    mov esi, [vi_file_ptr]
    cmp byte [esi], 0
    jne .content
    mov esi, msg_vi_empty
    call print_string
    jmp .done
.content:
    mov ebx, 1
    xor ecx, ecx
.next_char:
    call vi_status_row
    cmp ebx, eax
    jae .done
    lodsb
    test al, al
    jz .done
    cmp al, 13
    je .newline
    cmp al, 10
    je .newline
    cmp ecx, [console_cols]
    jae .wrap
    call console_putc
    inc ecx
    mov [vi_body_cursor_x], ecx
    mov [vi_body_cursor_y], ebx
    jmp .next_char
.wrap:
    push eax
    xor ecx, ecx
    inc ebx
    call vi_status_row
    cmp ebx, eax
    jae .wrap_done
    mov eax, 0
    call set_cursor
    pop eax
    call console_putc
    inc ecx
    mov [vi_body_cursor_x], ecx
    mov [vi_body_cursor_y], ebx
    jmp .next_char
.wrap_done:
    pop eax
    jmp .done
.newline:
    xor ecx, ecx
    inc ebx
    call vi_status_row
    cmp ebx, eax
    jae .done
    mov eax, 0
    call set_cursor
    mov [vi_body_cursor_x], ecx
    mov [vi_body_cursor_y], ebx
    jmp .next_char
.done:
    popad
    ret

vi_redraw_status:
    pushad
    call vi_status_row
    mov ebx, eax
    mov al, 0x70
    call vi_clear_row
    call vi_status_row
    mov ebx, eax
    mov eax, 0
    call set_cursor
    mov al, 0x70
    call set_color
    mov esi, [vi_status_ptr]
    call print_string
    mov al, 0x0F
    call set_color
    popad
    ret

vi_insert_char:
    pushad
    cmp byte [vi_readonly], 0
    jne .done
    mov bl, al
    mov edi, [vi_file_ptr]
    xor ecx, ecx
.find_end:
    cmp byte [edi + ecx], 0
    je .at_end
    inc ecx
    cmp ecx, 254
    jb .find_end
    jmp .done
.at_end:
    cmp ecx, 254
    jae .done
    mov [edi + ecx], bl
    inc ecx
    mov byte [edi + ecx], 0
.done:
    popad
    ret

vi_backspace_file:
    pushad
    mov edi, [vi_file_ptr]
    xor ecx, ecx
.find_end:
    cmp byte [edi + ecx], 0
    je .at_end
    inc ecx
    cmp ecx, 255
    jb .find_end
    jmp .done
.at_end:
    cmp ecx, 0
    je .done
    dec ecx
    mov byte [edi + ecx], 0
.done:
    popad
    ret

vi_copy_file_to_clipboard:
    pushad
    mov esi, [vi_file_ptr]
    mov edi, vi_clipboard
    mov ecx, 255
    xor edx, edx
.copy:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .done
    inc esi
    inc edi
    inc edx
    loop .copy
    mov byte [edi], 0
.done:
    mov [vi_clipboard_len], edx
    mov dword [vi_clipboard_ptr], vi_clipboard
    popad
    ret

vi_paste_clipboard:
    pushad
    mov esi, vi_clipboard
.loop:
    lodsb
    test al, al
    jz .done
    call vi_insert_char
    jmp .loop
.done:
    popad
    ret

vi_read_edit_line:
    pushad
    mov dword [vi_status_ptr], msg_vi_editing
    call vi_redraw_status
    mov edi, input_buffer
    mov byte [edi], 0
    mov dword [input_len], 0
    mov ebx, 23
    mov al, 0x0F
    call vi_clear_row
    mov eax, 0
    mov ebx, 23
    call set_cursor
    mov al, 0x0F
    call set_color
    mov esi, msg_vi_edit_prompt
    call print_string
.loop:
    call read_key
    cmp al, 0x03
    je .cancel
    cmp al, 13
    je .done
    cmp al, 8
    je .backspace
    cmp al, 32
    jb .loop
    cmp dword [input_len], 72
    jae .loop
    mov edi, input_buffer
    add edi, [input_len]
    mov [edi], al
    inc dword [input_len]
    inc edi
    mov byte [edi], 0
    call console_putc
    jmp .loop
.backspace:
    cmp dword [input_len], 0
    je .loop
    dec dword [input_len]
    mov edi, input_buffer
    add edi, [input_len]
    mov byte [edi], 0
    call console_backspace
    jmp .loop
.done:
    popad
    ret
.cancel:
    mov byte [command_cancelled], 1
    mov byte [input_buffer], 0
    popad
    ret

vi_place_body_cursor:
    pushad
    mov ecx, [vi_body_cursor_x]
    mov ebx, [vi_body_cursor_y]
    call vi_status_row
    dec eax
    cmp ebx, eax
    jbe .ok
    mov ebx, eax
.ok:
    mov eax, ecx
    call set_cursor
    popad
    ret

vi_status_row:
    mov eax, [console_rows]
    cmp eax, 2
    ja .ok
    mov eax, 25
.ok:
    dec eax
    ret

vi_clear_row:
    pushad
    cmp byte [fb_available], 1
    jne .vga
    call fb_clear_text_row
    popad
    ret
.vga:
    movzx edx, al
    mov eax, ebx
    mov ecx, 80
    mul ecx
    shl eax, 1
    mov edi, 0xB8000
    add edi, eax
    mov ah, dl
    mov al, ' '
    mov ecx, 80
    rep stosw
    popad
    ret

command_imgview:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, path_logo_png
    call match_token
    test eax, eax
    jnz .png
    mov edi, path_photo_jpg
    call match_token
    test eax, eax
    jnz .jpg
    cmp dword [current_dir], DIR_HOME
    jne .not_found
    mov edi, name_logo_png
    call match_token
    test eax, eax
    jnz .png
    mov edi, path_dot_logo_png
    call match_token
    test eax, eax
    jnz .png
    mov edi, name_photo_jpg
    call match_token
    test eax, eax
    jnz .jpg
    mov edi, path_dot_photo_jpg
    call match_token
    test eax, eax
    jnz .jpg
    jmp .not_found
.png:
    mov esi, msg_img_title
    call print_line
    mov esi, msg_img_format_png
    call print_line
    mov esi, msg_img_size_png
    call print_line
    call png_decode_logo
    ret
.jpg:
    mov esi, msg_img_title
    call print_line
    mov esi, msg_img_format_jpg
    call print_line
    mov esi, msg_img_size_jpg
    call print_line
    call print_image_preview
    ret
.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_usage_imgview
    call print_line
    ret

print_image_preview:
    mov esi, msg_img_decode_note
    call print_line
    mov esi, msg_img_preview_1
    call print_line
    mov esi, msg_img_preview_2
    call print_line
    mov esi, msg_img_preview_3
    call print_line
    mov esi, msg_img_preview_4
    call print_line
    mov esi, msg_img_preview_5
    call print_line
    ret

png_decode_logo:
    pushad
    mov esi, logo_png_data
    cmp dword [esi], 0x474E5089
    jne .bad
    cmp dword [esi + 4], 0x0A1A0A0D
    jne .bad
    cmp dword [esi + 12], 0x52444849
    jne .bad
    cmp byte [esi + 24], 8
    jne .bad
    cmp byte [esi + 25], 3
    jne .bad
    mov esi, msg_img_decode_note
    call print_line
    mov esi, msg_img_png_wh
    call print_string
    mov eax, 32
    call print_hex32
    mov al, 'x'
    call console_putc
    mov eax, 12
    call print_hex32
    call console_newline
    mov esi, msg_img_png_palette
    call print_string
    mov eax, 8
    call print_hex32
    call console_newline
    mov esi, logo_png_data + 86
    call png_render_indexed_stored
    jmp .done
.bad:
    mov esi, msg_img_png_bad
    call print_line
.done:
    popad
    ret

png_render_indexed_stored:
    pushad
    call console_newline
    mov ebx, 0
.row:
    cmp ebx, 12
    jae .done
    lodsb
    cmp al, 0
    jne .done
    mov edx, 32
.col:
    lodsb
    push eax
    push edx
    call png_palette_to_vga_attr
    call set_color
    mov al, ' '
    call console_putc
    pop edx
    pop eax
    dec edx
    jnz .col
    mov al, 0x0F
    call set_color
    call console_newline
    inc ebx
    jmp .row
.done:
    mov al, 0x0F
    call set_color
    popad
    ret

png_palette_to_vga_attr:
    and eax, 0xFF
    cmp al, 1
    je .dark_blue
    cmp al, 2
    je .blue
    cmp al, 3
    je .cyan
    cmp al, 4
    je .light_cyan
    cmp al, 5
    je .white
    cmp al, 6
    je .gray
    cmp al, 7
    je .bright_blue
    mov al, 0x00
    ret
.dark_blue:
    mov al, 0x10
    ret
.blue:
    mov al, 0x10
    ret
.cyan:
    mov al, 0x30
    ret
.light_cyan:
    mov al, 0xB0
    ret
.white:
    mov al, 0xF0
    ret
.gray:
    mov al, 0x80
    ret
.bright_blue:
    mov al, 0x90
    ret

command_nano:
    mov esi, msg_nano_title
    call print_line
    mov esi, msg_nano_note
    call print_line
    ret

command_ip:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je command_ifconfig
    mov edi, cmd_a
    call match_token
    test eax, eax
    jnz command_ifconfig
    mov edi, cmd_addr
    call match_token
    test eax, eax
    jnz command_ifconfig
    mov edi, cmd_route
    call match_token
    test eax, eax
    jnz command_route
    mov edi, cmd_link
    call match_token
    test eax, eax
    jnz command_ifconfig
    call print_unknown_command
    ret

command_ifconfig:
    call detect_network_pci
    call init_network_services
    mov esi, msg_net_iface
    call print_line
    call print_net_dynamic_info
    mov esi, msg_net_mode
    call print_line
    mov esi, msg_net_mode_2
    call print_line
    mov esi, msg_net_driver
    call print_line
    cmp byte [net_found], 0
    jne .supported
    cmp byte [net_any_found], 0
    je .none
    mov esi, msg_net_any_detected
    call print_line
    call print_any_net_pci_details
    ret
.supported:
    cmp byte [e1000_inited], 1
    jne .driver_fail
    mov esi, msg_e1000_init_ok
    call print_line
    jmp .driver_done
.driver_fail:
    mov esi, msg_e1000_init_fail
    call print_line
.driver_done:
    mov esi, msg_net_pci_detected
    call print_line
    call print_net_pci_details
    mov esi, msg_net_stack_pending
    call print_line
    mov esi, msg_net_stack_pending_2
    call print_line
    ret
.none:
    mov esi, msg_net_pci_none
    call print_line
    ret

print_net_dynamic_info:
    mov esi, msg_net_mac
    call print_string
    call print_mac_addr
    call console_newline
    mov esi, msg_net_ip
    call print_string
    cmp dword [net_ip_addr], 0
    je .ip_unconfigured
    mov eax, [net_ip_addr]
    call print_ipv4
    call print_net_prefix
    mov esi, msg_net_scope
    call print_line
    jmp .gateway
.ip_unconfigured:
    mov esi, msg_net_unconfigured
    call print_line
.gateway:
    mov esi, msg_net_gateway
    call print_string
    cmp dword [net_gateway_ip], 0
    je .gateway_unconfigured
    mov eax, [net_gateway_ip]
    call print_ipv4
    mov esi, msg_net_gateway_suffix
    call print_line
    jmp .dns
.gateway_unconfigured:
    mov esi, msg_net_unconfigured
    call print_line
.dns:
    mov esi, msg_net_dns
    call print_string
    cmp dword [net_dns_ip], 0
    je .dns_unconfigured
    mov eax, [net_dns_ip]
    call print_ipv4
    call console_newline
    ret
.dns_unconfigured:
    mov esi, msg_net_unconfigured
    call print_line
    ret

print_net_summary:
    call detect_network_pci
    cmp byte [net_found], 0
    jne .supported
    cmp byte [net_any_found], 0
    je .none
    mov esi, msg_net_any_detected
    call print_line
    ret
.supported:
    mov esi, msg_net_iface
    call print_line
    mov esi, msg_net_pci_detected
    call print_line
    ret
.none:
    mov esi, msg_net_pci_none
    call print_line
    ret

print_net_pci_details:
    mov esi, msg_net_pci_addr
    call print_string
    movzx eax, byte [net_bus]
    call print_hex8
    mov al, ':'
    call console_putc
    movzx eax, byte [net_slot]
    call print_hex8
    mov al, '.'
    call console_putc
    movzx eax, byte [net_func]
    call print_hex8
    call console_newline

    mov esi, msg_net_pci_vendor
    call print_string
    movzx eax, word [net_vendor]
    call print_hex32
    mov al, ':'
    call console_putc
    movzx eax, word [net_device]
    call print_hex32
    call console_newline

    mov esi, msg_net_pci_class
    call print_string
    movzx eax, byte [net_class]
    call print_hex8
    mov al, ':'
    call console_putc
    movzx eax, byte [net_subclass]
    call print_hex8
    call console_newline

    mov esi, msg_net_pci_bar0
    call print_string
    mov eax, [net_bar0]
    call print_hex32
    call console_newline
    ret

print_any_net_pci_details:
    mov esi, msg_net_pci_addr
    call print_string
    movzx eax, byte [net_any_bus]
    call print_hex8
    mov al, ':'
    call console_putc
    movzx eax, byte [net_any_slot]
    call print_hex8
    mov al, '.'
    call console_putc
    movzx eax, byte [net_any_func]
    call print_hex8
    call console_newline

    mov esi, msg_net_pci_vendor
    call print_string
    movzx eax, word [net_any_vendor]
    call print_hex32
    mov al, ':'
    call console_putc
    movzx eax, word [net_any_device]
    call print_hex32
    call console_newline

    mov esi, msg_net_pci_class
    call print_string
    movzx eax, byte [net_any_class]
    call print_hex8
    mov al, ':'
    call console_putc
    movzx eax, byte [net_any_subclass]
    call print_hex8
    call console_newline

    mov esi, msg_net_pci_bar0
    call print_string
    mov eax, [net_any_bar0]
    call print_hex32
    call console_newline
    ret

command_route:
    call detect_network_pci
    call init_network_services
    mov esi, msg_route_head
    call print_line
    cmp byte [dhcp_lease_valid], 1
    jne .unconfigured
    mov esi, msg_route_default
    call print_string
    cmp dword [net_gateway_ip], 0
    je .unconfigured
    mov eax, [net_gateway_ip]
    call print_ipv4
    mov esi, msg_route_suffix
    call print_line
    cmp dword [net_subnet_mask], 0
    je .skip_connected
    mov esi, msg_route_lan
    call print_string
    mov eax, [net_ip_addr]
    and eax, [net_subnet_mask]
    call print_ipv4
    mov al, ' '
    call console_putc
    mov eax, [net_subnet_mask]
    call print_ipv4
    mov esi, msg_route_suffix
    call print_line
.skip_connected:
    ret
.unconfigured:
    mov esi, msg_net_unconfigured
    call print_line
    ret

command_netstat:
    mov esi, msg_netstat_head
    call print_line
    mov esi, msg_netstat_tcp
    call print_line
    call command_ss
    ret

command_dhclient:
    call require_root
    test eax, eax
    jz .denied
    call detect_network_pci
    call init_network_services
    mov byte [dhcp_lease_valid], 0
    mov dword [net_ip_addr], 0
    mov dword [net_subnet_mask], 0
    mov dword [net_gateway_ip], 0
    mov dword [net_dns_ip], 0x72727272
    mov dword [net_dhcp_dns_ip], 0
    mov byte [net_gateway_mac_valid], 0
    call net_send_dhcp_discover
    call net_poll_dhcp_lease
    cmp dword [net_ip_addr], 0
    jne .lease_ready
    call apply_qemu_dhcp_fallback
.lease_ready:
    cmp byte [command_cancelled], 1
    je .cancelled
    mov esi, msg_net_dhcp
    call print_line
    mov esi, msg_net_mode
    call print_line
    ret
.cancelled:
    mov esi, msg_command_cancelled
    call print_line
    ret
.denied:
    ret

command_resolvectl:
    call detect_network_pci
    call init_network_services
    mov esi, msg_resolv_head
    call print_line
    mov esi, msg_resolv_domain
    call print_line
    mov esi, msg_net_dns
    call print_string
    cmp dword [net_dns_ip], 0
    je .unconfigured
    mov eax, [net_dns_ip]
    call print_ipv4
    call console_newline
    call print_settings_network
    ret
.unconfigured:
    mov esi, msg_net_unconfigured
    call print_line
    call print_settings_network
    ret

command_settings:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .show
    mov edi, arg_dns
    call match_token
    test eax, eax
    jnz .set_dns
    mov edi, arg_qemu
    call match_token
    test eax, eax
    jnz .set_qemu
    mov edi, arg_net
    call match_token
    test eax, eax
    jnz .net_cmd
    mov edi, arg_display
    call match_token
    test eax, eax
    jnz .display_cmd
    mov esi, msg_settings_usage
    call print_line
    ret
.show:
    mov esi, msg_settings_title
    call print_line
    call print_settings_network
    call command_ifconfig
    ret
.set_dns:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    cmp byte [esi], 0
    je .usage
    call validate_ipv4_token
    test eax, eax
    jz .invalid
    call parse_ipv4_token
    mov [net_dns_ip], eax
    mov [net_dhcp_dns_ip], eax
    mov byte [net_dns_rx_valid], 0
    mov dword [net_dns_resolved_ip], 0
    mov esi, msg_settings_updated
    call print_line
    call print_settings_network
    ret
.set_qemu:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    mov edi, arg_on
    call match_token
    test eax, eax
    jnz .qemu_on
    mov edi, arg_off
    call match_token
    test eax, eax
    jnz .qemu_off
    jmp .invalid
.qemu_on:
    mov byte [net_qemu_fallback_enabled], 1
    cmp dword [net_ip_addr], 0
    jne .qemu_done
    call apply_qemu_dhcp_fallback
.qemu_done:
    mov esi, msg_settings_updated
    call print_line
    call print_settings_network
    ret
.qemu_off:
    mov byte [net_qemu_fallback_enabled], 0
    mov esi, msg_settings_updated
    call print_line
    call print_settings_network
    ret
.net_cmd:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    mov edi, cmd_reset
    call match_token
    test eax, eax
    jz .usage
    mov byte [dhcp_lease_valid], 0
    mov dword [net_ip_addr], 0
    mov dword [net_subnet_mask], 0
    mov dword [net_gateway_ip], 0
    mov dword [net_dns_ip], 0x72727272
    mov dword [net_dhcp_dns_ip], 0
    mov dword [net_dns_saved_ip], 0
    mov byte [net_dns_rx_valid], 0
    mov dword [net_dns_resolved_ip], 0
    mov byte [net_gateway_mac_valid], 0
    mov esi, msg_settings_reset
    call print_line
    call detect_network_pci
    call init_network_services
    call print_settings_network
    ret
.display_cmd:
    call require_root
    test eax, eax
    jz .denied
    call next_arg
    mov edi, arg_auto
    call match_token
    test eax, eax
    jnz .display_auto
    mov edi, arg_1024x768
    call match_token
    test eax, eax
    jnz .display_1024
    mov edi, arg_1280x720
    call match_token
    test eax, eax
    jnz .display_1280
    jmp .invalid
.display_auto:
    mov byte [display_mode_index], 0
    jmp .display_done
.display_1024:
    mov byte [display_mode_index], 1
    jmp .display_done
.display_1280:
    mov byte [display_mode_index], 2
.display_done:
    mov esi, msg_settings_updated
    call print_line
    call print_display_mode
    ret
.usage:
    mov esi, msg_settings_usage
    call print_line
    ret
.invalid:
    mov esi, msg_settings_invalid
    call print_line
    mov esi, msg_settings_usage
    call print_line
    ret
.denied:
    ret

print_settings_network:
    mov esi, msg_settings_dns
    call print_string
    mov eax, [net_dns_ip]
    call print_ipv4_or_unconfigured
    call console_newline
    mov esi, msg_settings_dns_fallback
    call print_string
    mov eax, [net_dns_fallback_ip]
    call print_ipv4_or_unconfigured
    call console_newline
    mov esi, msg_settings_qemu
    call print_string
    mov al, [net_qemu_fallback_enabled]
    call print_bool_on_off
    call console_newline
    call print_display_mode
    ret

print_bool_on_off:
    cmp al, 0
    je .off
    mov esi, arg_on
    call print_string
    ret
.off:
    mov esi, arg_off
    call print_string
    ret

restore_saved_dns:
    cmp dword [net_dns_saved_ip], 0
    je .done
    mov eax, [net_dns_saved_ip]
    mov [net_dns_ip], eax
    mov dword [net_dns_saved_ip], 0
.done:
    ret

command_ping:
    call detect_network_pci
    call init_network_services
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov [sapp_arg_ptr], esi
    call validate_ipv4_token
    test eax, eax
    jz .dns_pending
    call parse_ipv4_token
    mov [net_ping_target_ip], eax
    cmp eax, 0x0100007F
    je .loopback_ip
    mov esi, [sapp_arg_ptr]
    call print_ping_intro_token
    cmp dword [net_ip_addr], 0
    je .no_address
    cmp byte [svc_tcp], 0
    je .pending
    mov esi, [sapp_arg_ptr]
    call ping_run_ipv4
    ret
.no_address:
    mov esi, msg_ping_no_address
    call print_line
    ret
.pending:
    mov esi, msg_ping_tx_fail
    call print_line
    ret
.usage:
    mov esi, msg_usage_ping
    call print_line
    mov esi, msg_usage_ping_1
    call print_line
    mov esi, msg_usage_ping_2
    call print_line
    mov esi, msg_usage_ping_3
    call print_line
    mov esi, msg_usage_ping_4
    call print_line
    mov esi, msg_usage_ping_5
    call print_line
    mov esi, msg_usage_ping_6
    call print_line
    mov esi, msg_usage_ping_7
    call print_line
    ret
.loopback_ip:
    mov esi, [sapp_arg_ptr]
    call print_ping_intro_token
    mov esi, [sapp_arg_ptr]
    call ping_run_loopback
    mov esi, [sapp_arg_ptr]
    call print_ping_stats_current
    ret
.dns_pending:
    mov [sapp_arg_ptr], esi
    mov edi, domain_localhost
    call match_token
    test eax, eax
    jnz .builtin_localhost
    cmp dword [net_ip_addr], 0
    je .dns_no_address
    cmp byte [svc_tcp], 0
    je .pending
    mov byte [net_dns_rx_valid], 0
    mov dword [net_dns_resolved_ip], 0
    mov dword [net_dns_saved_ip], 0
    call dns_build_query_from_token
    test eax, eax
    jz .dns_bad
    call ping_timer_init
    mov eax, [net_udp_packets]
    mov [ping_rx_before], eax
    call net_send_dns_query
    mov dword [ping_wait_counter], DNS_WAIT_POLLS
.wait_dns:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .dns_cancelled
    call net_poll_rx_burst
    cmp byte [net_dns_rx_valid], 1
    je .dns_reply
    cmp byte [net_dns_rx_valid], 2
    je .dns_retry_or_fail
    mov eax, [ping_wait_counter]
    and eax, DNS_RETRY_POLLS - 1
    cmp eax, 0
    jne .dns_delay
    call net_send_dns_query
.dns_delay:
    call ping_wait_1ms
    dec dword [ping_wait_counter]
    jnz .wait_dns
.dns_retry_or_fail:
    mov eax, [net_dns_ip]
    cmp eax, [net_dns_fallback_ip]
    je .dns_timeout
    mov [net_dns_saved_ip], eax
    mov eax, [net_dns_fallback_ip]
    mov [net_dns_ip], eax
    mov esi, msg_ping_dns_retry
    call print_string
    mov eax, [net_dns_ip]
    call print_ipv4
    call console_newline
    mov byte [net_dns_rx_valid], 0
    mov dword [net_dns_resolved_ip], 0
    call net_send_dns_query
    mov dword [ping_wait_counter], DNS_WAIT_POLLS
    jmp .wait_dns
.dns_timeout:
    call restore_saved_dns
    mov esi, [sapp_arg_ptr]
    call print_ping_host_not_found
    ret
.dns_cancelled:
    call restore_saved_dns
    mov esi, msg_command_cancelled
    call print_line
    ret
.dns_bad:
    mov esi, [sapp_arg_ptr]
    call print_ping_host_not_found
    ret
.dns_no_address:
    mov esi, msg_ping_no_address
    call print_line
    ret
.dns_reply:
    call restore_saved_dns
    mov eax, [net_dns_resolved_ip]
    mov [net_ping_target_ip], eax
    jmp .send_host_icmp
.builtin_localhost:
    mov esi, msg_ping_localhost_dns
    call print_line
    mov esi, domain_localhost
    call print_ping_intro_token
    mov esi, domain_localhost
    call ping_run_loopback
    mov esi, domain_localhost
    call print_ping_stats_current
    ret
.send_host_icmp:
    mov esi, [sapp_arg_ptr]
    call print_ping_intro_host_ip
    mov esi, [sapp_arg_ptr]
    call ping_run_ipv4
    ret

print_ping_intro_token:
    push esi
    mov esi, msg_ping_intro
    call print_string
    pop esi
    call print_first_token
    mov esi, msg_ping_intro_mid
    call print_line
    ret

print_ping_intro_host_ip:
    push esi
    mov esi, msg_ping_intro
    call print_string
    pop esi
    call print_first_token
    mov esi, msg_ping_intro_addr_open
    call print_string
    mov eax, [net_ping_target_ip]
    call print_ipv4
    mov esi, msg_ping_intro_addr_close_mid
    call print_line
    ret

print_ping_reply_ipv4:
    push eax
    mov esi, msg_ping_reply_from
    call print_string
    pop eax
    call print_ipv4
    mov esi, msg_ping_reply_bytes
    call print_string
    mov eax, [ping_rtt_current]
    cmp eax, 0
    jne .print_ms
    mov esi, msg_ping_reply_time_lt
    call print_string
    jmp .ttl
.print_ms:
    call print_dec32
.ttl:
    mov esi, msg_ping_reply_ms_ttl
    call print_string
    movzx eax, byte [ping_reply_ttl]
    call print_dec8
    call console_newline
    ret

print_ping_loopback_reply_token:
    push esi
    mov esi, msg_ping_reply_from
    call print_string
    pop esi
    call print_first_token
    mov esi, msg_ping_loopback_tail
    call print_line
    ret

print_ping_timeout:
    mov esi, msg_ping_timeout_line
    call print_line
    ret

print_ping_host_not_found:
    push esi
    mov esi, msg_ping_host_not_found_1
    call print_string
    pop esi
    call print_first_token
    mov esi, msg_ping_host_not_found_2
    call print_line
    ret

ping_reset_stats:
    mov dword [ping_sent_count], 0
    mov dword [ping_recv_count], 0
    mov dword [ping_rtt_current], 0
    mov dword [ping_rtt_min], 0xFFFFFFFF
    mov dword [ping_rtt_max], 0
    mov dword [ping_rtt_sum], 0
    mov byte [ping_reply_ttl], 0
    ret

ping_run_loopback:
    push esi
    call ping_reset_stats
    mov dword [ping_loop_remaining], 4
.loop:
    inc dword [ping_sent_count]
    inc dword [ping_recv_count]
    mov dword [ping_rtt_current], 0
    mov dword [ping_rtt_min], 0
    mov dword [ping_rtt_max], 0
    pop esi
    push esi
    call print_ping_loopback_reply_token
    call ping_wait_1ms
    dec dword [ping_loop_remaining]
    jnz .loop
    pop esi
    ret

ping_run_ipv4:
    push esi
    call ping_reset_stats
    call ping_timer_init
    call net_select_next_hop
    mov dword [ping_loop_remaining], 4
.request_loop:
    inc dword [ping_sent_count]
    inc word [ping_seq]
    mov byte [net_ping_reply_received], 0
    mov byte [ping_reply_ttl], 0
    mov dword [ping_rtt_current], 0
    call net_send_icmp_echo
    cmp byte [net_gateway_mac_valid], 1
    jne .arp_timeout
    mov dword [ping_wait_counter], ICMP_WAIT_POLLS
    call ping_timer_mark
.wait_icmp:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .cancelled
    call net_poll_rx_burst
    cmp byte [net_ping_reply_received], 1
    je .icmp_reply
    call ping_wait_1ms
    dec dword [ping_wait_counter]
    jnz .wait_icmp
    call print_ping_timeout
    jmp .next_request
.icmp_reply:
    inc dword [ping_recv_count]
    call ping_update_rtt_stats
    mov eax, [net_ping_target_ip]
    call print_ping_reply_ipv4
    jmp .next_request
.arp_timeout:
    mov esi, msg_ping_arp_timeout
    call print_line
    mov dword [ping_wait_counter], 0
.next_request:
    call ping_wait_1ms
    dec dword [ping_loop_remaining]
    jnz .request_loop
    pop esi
    call print_ping_stats_current
    ret
.cancelled:
    pop esi
    mov esi, msg_command_cancelled
    call print_line
    ret

net_poll_rx_burst:
    push ecx
    mov ecx, E1000_RX_COUNT
.loop:
    call e1000_poll_rx
    loop .loop
.done:
    pop ecx
    ret

ping_update_rtt_stats:
    mov eax, [ping_rtt_current]
    cmp eax, [ping_rtt_min]
    jae .check_max
    mov [ping_rtt_min], eax
.check_max:
    cmp eax, [ping_rtt_max]
    jbe .sum
    mov [ping_rtt_max], eax
.sum:
    add [ping_rtt_sum], eax
    ret

print_ping_stats_current:
    push esi
    call console_newline
    mov esi, msg_ping_stats_1
    call print_string
    pop esi
    call print_first_token
    mov esi, msg_ping_stats_packets
    call print_string
    mov eax, [ping_sent_count]
    call print_dec8
    mov esi, msg_ping_stats_received
    call print_string
    mov eax, [ping_recv_count]
    call print_dec8
    mov esi, msg_ping_stats_lost
    call print_string
    mov eax, [ping_sent_count]
    sub eax, [ping_recv_count]
    call print_dec8
    mov esi, msg_ping_stats_loss_open
    call print_string
    call print_ping_loss_percent
    mov esi, msg_ping_stats_loss_close
    call print_string
    call console_newline
    cmp dword [ping_recv_count], 0
    je .done
    mov esi, msg_ping_approx
    call print_line
    mov esi, msg_ping_times_min
    call print_string
    mov eax, [ping_rtt_min]
    call print_dec32
    mov esi, msg_ping_times_max
    call print_string
    mov eax, [ping_rtt_max]
    call print_dec32
    mov esi, msg_ping_times_avg
    call print_string
    mov eax, [ping_rtt_sum]
    xor edx, edx
    mov ebx, [ping_recv_count]
    div ebx
    call print_dec32
    mov esi, msg_ping_times_end
    call print_string
    call console_newline
.done:
    ret

print_ping_loss_percent:
    mov eax, [ping_sent_count]
    cmp eax, 0
    je .hundred
    mov eax, [ping_sent_count]
    sub eax, [ping_recv_count]
    mov ebx, 100
    mul ebx
    mov ebx, [ping_sent_count]
    div ebx
    cmp eax, 255
    jbe .print
    mov eax, 255
    jmp .print
.hundred:
    mov eax, 100
.print:
    call print_dec8
    ret

ping_timer_init:
    push eax
    mov al, 0xB0
    out 0x43, al
    mov ax, [ping_pit_divisor]
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 0x01
    and al, 0xFD
    out 0x61, al
    pop eax
    ret

ping_timer_mark:
    push eax
    in al, 0x61
    mov [ping_pit_last], al
    pop eax
    ret

ping_timer_poll:
    ret

ping_wait_1ms:
    push eax
    push ebx
    push ecx
    mov al, 0xB0
    out 0x43, al
    mov ax, [ping_pit_divisor]
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    or al, 0x01
    out 0x61, al
    mov ecx, 0x40000
.loop:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .done
    in al, 0x61
    test al, 0x20
    jnz .tick
    loop .loop
    jmp .done
.tick:
    inc dword [ping_rtt_current]
.done:
    pop ecx
    pop ebx
    pop eax
    ret

ping_wait_delay:
    push ecx
    mov ecx, PING_WAIT_DELAY
.loop:
    test ecx, 0x03FF
    jnz .spin
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .done
.spin:
    loop .loop
.done:
    pop ecx
    ret

command_wget:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov [sapp_arg_ptr], esi
    mov esi, msg_wget_start
    call print_string
    mov esi, [sapp_arg_ptr]
    call print_line
    call detect_network_pci
    call init_network_services
    cmp byte [svc_net], 0
    je .network_down
    mov esi, [sapp_arg_ptr]
    mov edi, url_https_prefix
    call starts_with
    test eax, eax
    jnz .https
    mov esi, [sapp_arg_ptr]
    mov edi, url_http_prefix
    call starts_with
    test eax, eax
    jnz .http
    mov esi, msg_wget_default_scheme
    call print_line
    jmp .http
.https:
    cmp byte [svc_tls], 0
    je .https_pending
    mov esi, msg_wget_https_ready
    call print_line
    ret
.https_pending:
    mov esi, msg_wget_https_pending
    call print_line
    ret
.http:
    call wget_resolve_target
    test eax, eax
    jz .dns_failed
    mov esi, msg_wget_resolved
    call print_string
    mov eax, [net_ping_target_ip]
    call print_ipv4
    call console_newline
    mov esi, msg_wget_connect
    call print_string
    mov eax, [net_ping_target_ip]
    call print_ipv4
    mov esi, msg_wget_port80
    call print_line
    cmp dword [net_ip_addr], 0
    je .no_address
    cmp byte [svc_tcp], 0
    je .tcp_pending
    mov byte [http_tcp_state], 0
    inc dword [http_client_seq]
    call net_send_http_syn
    cmp byte [net_gateway_mac_valid], 1
    jne .arp_timeout
    mov esi, msg_wget_syn_sent
    call print_line
    mov dword [ping_wait_counter], ICMP_WAIT_POLLS
.wait_tcp:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .cancelled
    call net_poll_rx_burst
    cmp byte [http_tcp_state], 2
    je .tcp_open
    cmp byte [http_tcp_state], 3
    je .tcp_reset
    call ping_wait_1ms
    dec dword [ping_wait_counter]
    jnz .wait_tcp
    mov esi, msg_wget_tcp_timeout
    call print_line
    ret
.tcp_open:
    mov esi, msg_wget_tcp_open
    call print_line
    ret
.tcp_reset:
    mov esi, msg_wget_tcp_reset
    call print_line
    ret
.tcp_pending:
    mov esi, msg_wget_http_pending
    call print_line
    ret
.arp_timeout:
    mov esi, msg_wget_arp_timeout
    call print_line
    ret
.no_address:
    mov esi, msg_ping_no_address
    call print_line
    ret
.dns_failed:
    mov esi, msg_wget_dns_timeout
    call print_line
    ret
.cancelled:
    mov esi, msg_command_cancelled
    call print_line
    ret
.network_down:
    mov esi, msg_wget_network_down
    call print_line
    ret
.usage:
    mov esi, msg_usage_wget
    call print_line
    ret

wget_resolve_target:
    mov esi, [sapp_arg_ptr]
    mov edi, url_http_prefix
    call starts_with
    test eax, eax
    jz .maybe_https
    mov esi, [sapp_arg_ptr]
    add esi, 7
    jmp .resolve
.maybe_https:
    mov esi, [sapp_arg_ptr]
    mov edi, url_https_prefix
    call starts_with
    test eax, eax
    jz .plain
    mov esi, [sapp_arg_ptr]
    add esi, 8
    jmp .resolve
.plain:
    mov esi, [sapp_arg_ptr]
.resolve:
    call copy_url_host_to_buffer
    mov esi, url_host_buf
    cmp byte [esi], 0
    je .bad
    call validate_ipv4_token
    test eax, eax
    jz .dns
    call parse_ipv4_token
    mov [net_ping_target_ip], eax
    mov eax, 1
    ret
.dns:
    mov byte [net_dns_rx_valid], 0
    mov dword [net_dns_resolved_ip], 0
    mov dword [net_dns_saved_ip], 0
    call dns_build_query_from_token
    test eax, eax
    jz .bad
    call ping_timer_init
    call net_send_dns_query
    mov dword [ping_wait_counter], DNS_WAIT_POLLS
.wait_dns:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .bad
    call net_poll_rx_burst
    cmp byte [net_dns_rx_valid], 1
    je .dns_ok
    cmp byte [net_dns_rx_valid], 2
    je .dns_retry_or_fail
    mov eax, [ping_wait_counter]
    and eax, DNS_RETRY_POLLS - 1
    cmp eax, 0
    jne .dns_delay
    call net_send_dns_query
.dns_delay:
    call ping_wait_1ms
    dec dword [ping_wait_counter]
    jnz .wait_dns
.dns_retry_or_fail:
    mov eax, [net_dns_ip]
    cmp eax, [net_dns_fallback_ip]
    je .bad_restore
    mov [net_dns_saved_ip], eax
    mov eax, [net_dns_fallback_ip]
    mov [net_dns_ip], eax
    mov byte [net_dns_rx_valid], 0
    mov dword [net_dns_resolved_ip], 0
    call net_send_dns_query
    mov dword [ping_wait_counter], DNS_WAIT_POLLS
    jmp .wait_dns
.dns_ok:
    call restore_saved_dns
    mov eax, [net_dns_resolved_ip]
    mov [net_ping_target_ip], eax
    mov eax, 1
    ret
.bad_restore:
    call restore_saved_dns
.bad:
    call wget_resolve_skyapps_fallback
    test eax, eax
    jnz .fallback_ok
    xor eax, eax
    ret
.fallback_ok:
    mov eax, 1
    ret

wget_resolve_skyapps_fallback:
    push esi
    push edi
    mov esi, url_host_buf
    mov edi, domain_skyapps
    call cstr_equals
    test eax, eax
    jz .no
    mov dword [net_ping_target_ip], 0xCBDA43AC
    mov eax, 1
    jmp .done
.no:
    xor eax, eax
.done:
    pop edi
    pop esi
    ret

copy_url_host_to_buffer:
    push esi
    push edi
    push ecx
    mov edi, url_host_buf
    mov ecx, 127
.loop:
    cmp ecx, 0
    je .done
    mov al, [esi]
    cmp al, 0
    je .done
    cmp al, ' '
    je .done
    cmp al, 9
    je .done
    cmp al, '/'
    je .done
    cmp al, ':'
    je .done
    stosb
    inc esi
    dec ecx
    jmp .loop
.done:
    mov byte [edi], 0
    pop ecx
    pop edi
    pop esi
    ret

command_curl:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, esi
    mov esi, msg_curl_start
    call print_string
    mov esi, edi
    call print_line
    call detect_network_pci
    call init_network_services
    cmp byte [svc_net], 0
    je .network_down
    cmp byte [svc_tcp], 0
    je .tcp_pending
    cmp byte [svc_tls], 0
    je .tls_pending
    mov esi, msg_curl_ready
    call print_line
    ret
.network_down:
    mov esi, msg_curl_network_down
    call print_line
    ret
.tcp_pending:
    mov esi, msg_curl_tcp_pending
    call print_line
    ret
.tls_pending:
    mov esi, msg_curl_tls_pending
    call print_line
    ret
.usage:
    mov esi, msg_usage_curl
    call print_line
    ret

command_ssh:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, esi
    mov esi, msg_ssh_start
    call print_string
    mov esi, edi
    call print_line
    call detect_network_pci
    call init_network_services
    cmp byte [svc_net], 0
    je .net_down
    mov esi, msg_ssh_pending
    call print_line
    ret
.net_down:
    mov esi, msg_ssh_net_down
    call print_line
    ret
.usage:
    mov esi, msg_usage_ssh
    call print_line
    ret

command_sftp:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, esi
    mov esi, msg_sftp_start
    call print_string
    mov esi, edi
    call print_line
    call detect_network_pci
    call init_network_services
    cmp byte [svc_net], 0
    je .net_down
    mov esi, msg_sftp_pending
    call print_line
    ret
.net_down:
    mov esi, msg_ssh_net_down
    call print_line
    ret
.usage:
    mov esi, msg_usage_sftp
    call print_line
    ret

command_sapp:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage

    mov edi, sapp_update
    call match_token
    test eax, eax
    jnz .update

    mov edi, sapp_list
    call match_token
    test eax, eax
    jnz .list

    mov edi, sapp_search
    call match_token
    test eax, eax
    jnz .search

    mov edi, sapp_install
    call match_token
    test eax, eax
    jnz .install

    mov edi, sapp_remove
    call match_token
    test eax, eax
    jnz .remove

    mov edi, sapp_files
    call match_token
    test eax, eax
    jnz .files

    mov edi, sapp_info
    call match_token
    test eax, eax
    jnz .info

    mov edi, sapp_run
    call match_token
    test eax, eax
    jnz .run

    mov edi, sapp_source
    call match_token
    test eax, eax
    jnz .source

.usage:
    mov esi, msg_sapp_usage
    call print_line
    ret

.update:
    mov esi, msg_sapp_source_path
    call print_line
    mov esi, msg_sapp_update_1
    call print_line
    mov esi, msg_sapp_fetch_index
    call print_line
    call sapp_fetch_remote_index
    test eax, eax
    jz .update_failed
    mov esi, msg_sapp_index_downloaded
    call print_line
    call print_sapp_cache_count
    jmp .update_done
.update_failed:
    mov esi, msg_sapp_index_failed
    call print_line
    call print_sapp_cache_count
.update_done:
    mov esi, msg_sapp_update_2
    call print_line
    mov esi, msg_sapp_update_3
    call print_line
    ret

.list:
    mov esi, msg_sapp_list_title
    call print_line
    cmp byte [sapp_remote_index_ready], 1
    jne .list_builtin
    call sapp_remote_print_packages
    ret
.list_builtin:
    call print_sapp_packages
    ret

.search:
    call next_arg
    cmp byte [esi], 0
    je .usage
    mov [sapp_arg_ptr], esi
    mov esi, msg_sapp_search_title
    call print_line
    cmp byte [sapp_remote_index_ready], 1
    jne .search_builtin
    call sapp_remote_print_search_results
    ret
.search_builtin:
    call print_sapp_search_results
    ret

.install:
    call next_arg
    cmp byte [esi], 0
    je .usage
    mov [sapp_arg_ptr], esi
    cmp byte [sapp_remote_index_ready], 1
    jne .install_builtin
    call sapp_remote_package_exists
    test eax, eax
    jz .unknown_pkg
    mov esi, [sapp_arg_ptr]
    mov edi, esi
    mov esi, msg_sapp_install_prefix
    call print_string
    mov esi, edi
    call print_line
    call sapp_remote_print_dependencies
    call sapp_remote_print_binary_fetch
    mov esi, msg_sapp_transport_ready
    call print_line
    mov esi, msg_sapp_installed
    call print_line
    call sapp_mark_installed_by_arg
    mov esi, msg_sapp_spk_magic
    call print_line
    mov esi, msg_sapp_unpack
    call print_line
    mov esi, msg_sapp_done
    call print_line
    ret
.install_builtin:
    call sapp_package_exists
    test eax, eax
    jz .unknown_pkg
    mov esi, [sapp_arg_ptr]
    mov edi, esi
    mov esi, msg_sapp_install_prefix
    call print_string
    mov esi, edi
    call print_line
    call sapp_print_dependencies
    call sapp_print_binary_fetch
    cmp byte [svc_tcp], 0
    je .install_pending
    mov esi, msg_sapp_transport_ready
    jmp .install_print
.install_pending:
    mov esi, msg_sapp_transport
.install_print:
    call print_line
    mov esi, msg_sapp_installed
    call print_line
    call sapp_mark_installed
    mov esi, msg_sapp_spk_magic
    call print_line
    mov esi, msg_sapp_unpack
    call print_line
    mov esi, msg_sapp_done
    call print_line
    ret

.remove:
    call next_arg
    cmp byte [esi], 0
    je .usage
    mov [sapp_arg_ptr], esi
    cmp byte [sapp_remote_index_ready], 1
    jne .remove_builtin
    call sapp_remote_package_exists
    test eax, eax
    jz .unknown_pkg
    mov esi, [sapp_arg_ptr]
    mov edi, esi
    mov esi, msg_sapp_remove_prefix
    call print_string
    mov esi, edi
    call print_line
    mov esi, msg_sapp_removed
    call print_line
    call sapp_mark_removed_by_arg
    mov esi, msg_sapp_done
    call print_line
    ret
.remove_builtin:
    call sapp_package_exists
    test eax, eax
    jz .unknown_pkg
    mov esi, [sapp_arg_ptr]
    mov edi, esi
    mov esi, msg_sapp_remove_prefix
    call print_string
    mov esi, edi
    call print_line
    call sapp_mark_removed
    mov esi, msg_sapp_removed
    call print_line
    mov esi, msg_sapp_done
    call print_line
    ret

.files:
    call next_arg
    cmp byte [esi], 0
    je .usage
    mov [sapp_arg_ptr], esi
    call sapp_package_exists
    test eax, eax
    jz .unknown_pkg
    call sapp_print_package_files
    ret

.info:
    call next_arg
    cmp byte [esi], 0
    je .usage
    mov [sapp_arg_ptr], esi
    call sapp_package_exists
    test eax, eax
    jz .unknown_pkg
    mov ebx, [sapp_pkg_ptr]
    call sapp_print_package_record
    call sapp_print_builtin_extended_fields
    ret

.run:
    call next_arg
    cmp byte [esi], 0
    je .usage
    mov [sapp_arg_ptr], esi
    call sapp_package_exists
    test eax, eax
    jz .unknown_pkg
    call sapp_run_package_entry
    ret

.unknown_pkg:
    mov esi, msg_sapp_unknown_pkg
    call print_string
    mov esi, [sapp_arg_ptr]
    call print_line
    ret

.source:
    mov esi, msg_sapp_source_title
    call print_line
    mov esi, path_sapp_sources
    call print_line
    mov esi, file_sapp_sources
    call print_line
    ret

print_sapp_cache_count:
    push eax
    mov esi, msg_sapp_cache_count_prefix
    call print_string
    cmp byte [sapp_remote_index_ready], 1
    jne .builtin
    mov eax, [sapp_index_count]
    jmp .print
.builtin:
    call sapp_builtin_count_packages
.print:
    call print_dec32
    mov esi, msg_sapp_cache_suffix
    call print_line
    pop eax
    ret

sapp_builtin_count_packages:
    push ebx
    xor eax, eax
    mov ebx, sapp_pkg_table
.loop:
    cmp dword [ebx + SAPP_PKG_NAME], 0
    je .done
    inc eax
    add ebx, SAPP_PKG_STRIDE
    jmp .loop
.done:
    pop ebx
    ret

sapp_fetch_remote_index:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov byte [sapp_remote_index_ready], 0
    mov byte [http_response_done], 0
    mov byte [http_response_overflow], 0
    mov dword [http_response_len], 0
    mov byte [http_response_buf], 0
    call detect_network_pci
    call init_network_services
    cmp byte [svc_net], 1
    jne .fail
    cmp dword [net_ip_addr], 0
    jne .have_ip
    call apply_qemu_dhcp_fallback
.have_ip:
    cmp dword [net_ip_addr], 0
    je .fail
    cmp byte [svc_tcp], 1
    jne .fail
    mov dword [sapp_arg_ptr], sapp_packages_url
    call wget_resolve_target
    test eax, eax
    jz .fail
    mov byte [http_tcp_state], 0
    inc dword [http_client_seq]
    call net_send_http_syn
    cmp byte [net_gateway_mac_valid], 1
    jne .fail
    mov dword [ping_wait_counter], ICMP_WAIT_POLLS
.wait_open:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .fail
    call net_poll_rx_burst
    cmp byte [http_tcp_state], 2
    je .send_get
    cmp byte [http_tcp_state], 3
    je .fail
    call ping_wait_1ms
    dec dword [ping_wait_counter]
    jnz .wait_open
    jmp .fail
.send_get:
    call net_send_http_get_sapp_index
    mov dword [ping_wait_counter], ICMP_WAIT_POLLS
.wait_body:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .fail
    call net_poll_rx_burst
    cmp byte [http_response_done], 1
    je .cache
    cmp byte [http_response_overflow], 1
    je .cache
    call ping_wait_1ms
    dec dword [ping_wait_counter]
    jnz .wait_body
    cmp dword [http_response_len], 0
    je .fail
.cache:
    call sapp_cache_http_response
    test eax, eax
    jz .fail
    mov eax, 1
    jmp .done
.fail:
    xor eax, eax
.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

sapp_cache_http_response:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov esi, http_response_buf
    mov edi, http_status_prefix
    call starts_with
    test eax, eax
    jz .fail
    cmp byte [http_response_buf + 8], ' '
    jne .fail
    cmp byte [http_response_buf + 9], '2'
    jne .fail
    cmp byte [http_response_buf + 10], '0'
    jne .fail
    cmp byte [http_response_buf + 11], '0'
    jne .fail
    mov esi, http_response_buf
    mov ecx, [http_response_len]
    cmp ecx, 4
    jb .fail
.find_body:
    cmp ecx, 4
    jb .fail
    cmp byte [esi], 13
    jne .next
    cmp byte [esi + 1], 10
    jne .next
    cmp byte [esi + 2], 13
    jne .next
    cmp byte [esi + 3], 10
    je .body
.next:
    inc esi
    dec ecx
    jmp .find_body
.body:
    add esi, 4
    sub ecx, 4
    cmp ecx, 4095
    jbe .len_ok
    mov ecx, 4095
.len_ok:
    mov edi, sapp_index_buf
    mov [sapp_index_len], ecx
    rep movsb
    mov byte [edi], 0
    call sapp_count_remote_packages
    cmp eax, 0
    je .fail
    mov [sapp_index_count], eax
    mov byte [sapp_remote_index_ready], 1
    mov eax, 1
    jmp .done
.fail:
    mov byte [sapp_remote_index_ready], 0
    xor eax, eax
.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

sapp_count_remote_packages:
    push esi
    push edi
    xor edx, edx
    mov esi, sapp_index_buf
.loop:
    call sapp_find_next_package
    test eax, eax
    jz .done
    inc edx
    call sapp_next_record
    jmp .loop
.done:
    mov eax, edx
    pop edi
    pop esi
    ret

print_sapp_packages:
    push ebx
    mov ebx, sapp_pkg_table
.loop:
    cmp dword [ebx + SAPP_PKG_NAME], 0
    je .done
    call sapp_print_package_record
    add ebx, SAPP_PKG_STRIDE
    jmp .loop
.done:
    pop ebx
    ret

print_sapp_search_results:
    push ebx
    xor edx, edx
    mov ebx, sapp_pkg_table
.loop:
    cmp dword [ebx + SAPP_PKG_NAME], 0
    je .finish
    mov esi, [ebx + SAPP_PKG_NAME]
    call print_sapp_match_candidate
    add ebx, SAPP_PKG_STRIDE
    jmp .loop
.finish:
    test edx, edx
    jnz .done
    mov esi, msg_sapp_no_match
    call print_line
.done:
    pop ebx
    ret

print_sapp_match_candidate:
    push edi
    mov edi, [sapp_arg_ptr]
    call string_contains_token
    test eax, eax
    jz .done
    call sapp_print_package_record
    mov edx, 1
.done:
    pop edi
    ret

sapp_print_package_record:
    pushad
    mov esi, [ebx + SAPP_PKG_NAME]
    call print_string
    mov esi, msg_sapp_version_sep
    call print_string
    mov esi, [ebx + SAPP_PKG_VERSION]
    call print_string
    mov esi, msg_sapp_arch_tail
    call print_string
    mov esi, [ebx + SAPP_PKG_FORMAT]
    call print_line
    mov esi, msg_sapp_internal_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_INTERNAL]
    call print_line
    mov esi, [ebx + SAPP_PKG_DEPENDS]
    cmp byte [esi], 0
    je .file
    mov esi, msg_sapp_depends_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_DEPENDS]
    call print_line
.file:
    mov esi, msg_sapp_file_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_FILE]
    call print_line
    mov esi, msg_sapp_size_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_SIZE]
    call print_string
    mov esi, msg_sapp_bytes_tail
    call print_line
    mov esi, msg_sapp_desc_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_DESC]
    call print_line
    mov esi, msg_sapp_status_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_STATE]
    cmp byte [esi], 1
    je .installed
    mov esi, msg_sapp_state_available
    call print_line
    jmp .done
.installed:
    mov esi, msg_sapp_state_installed
    call print_line
.done:
    popad
    ret

sapp_print_builtin_extended_fields:
    pushad
    mov ebx, [sapp_pkg_ptr]
    cmp ebx, 0
    je .done
    mov esi, [ebx + SAPP_PKG_NAME]
    mov edi, msg_sapp_name_5
    call cstr_equals
    test eax, eax
    jnz .calc
    mov esi, [ebx + SAPP_PKG_NAME]
    mov edi, msg_sapp_name_6
    call cstr_equals
    test eax, eax
    jnz .skycrt
    mov esi, [ebx + SAPP_PKG_NAME]
    mov edi, msg_sapp_name_7
    call cstr_equals
    test eax, eax
    jnz .skyui
    jmp .done
.calc:
    mov esi, msg_sapp_calc_runtime
    call print_line
    mov esi, msg_sapp_calc_entry
    call print_line
    mov esi, msg_sapp_calc_sxr
    call print_line
    mov esi, msg_sapp_calc_type
    call print_line
    mov esi, msg_sapp_calc_permissions
    call print_line
    mov esi, msg_sapp_tc
    call print_line
    jmp .done
.skycrt:
    mov esi, msg_sapp_skycrt_runtime
    call print_line
    mov esi, msg_sapp_sxr_type
    call print_line
    jmp .done
.skyui:
    mov esi, msg_sapp_skyui_runtime
    call print_line
    mov esi, msg_sapp_sxr_type
    call print_line
.done:
    popad
    ret

sapp_run_package_entry:
    pushad
    mov ebx, [sapp_pkg_ptr]
    cmp ebx, 0
    je .done
    mov esi, [ebx + SAPP_PKG_STATE]
    cmp byte [esi], 1
    je .installed
    mov esi, msg_sapp_not_installed
    call print_string
    mov esi, [ebx + SAPP_PKG_NAME]
    call print_line
    jmp .done
.installed:
    mov esi, [ebx + SAPP_PKG_NAME]
    mov edi, msg_sapp_name_5
    call cstr_equals
    test eax, eax
    jz .no_entry
    mov esi, msg_sapp_run_prefix
    call print_string
    mov esi, path_usr_bin_calc
    call print_line
    call command_pkg_calc_intro
    jmp .done
.no_entry:
    mov esi, msg_sapp_run_no_entry
    call print_line
.done:
    popad
    ret

sapp_print_binary_fetch:
    pushad
    mov ebx, [sapp_pkg_ptr]
    cmp ebx, 0
    je .done
    mov esi, msg_sapp_fetch_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_FILE]
    call print_line
    mov esi, msg_sapp_http_get_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_FILE]
    call print_line
    mov esi, msg_sapp_cache_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_FILE]
    call print_line
.done:
    popad
    ret

sapp_mark_installed:
    pushad
    mov ebx, [sapp_pkg_ptr]
    cmp ebx, 0
    je .done
    mov esi, [ebx + SAPP_PKG_STATE]
    mov byte [esi], 1
    call sapp_print_registered_commands
.done:
    popad
    ret

sapp_mark_removed:
    pushad
    mov ebx, [sapp_pkg_ptr]
    cmp ebx, 0
    je .done
    mov esi, [ebx + SAPP_PKG_STATE]
    mov byte [esi], 0
    call sapp_print_unregistered_commands
.done:
    popad
    ret

sapp_mark_installed_by_arg:
    pushad
    call sapp_package_exists
    test eax, eax
    jz .done
    call sapp_mark_installed
.done:
    popad
    ret

sapp_mark_removed_by_arg:
    pushad
    call sapp_package_exists
    test eax, eax
    jz .done
    call sapp_mark_removed
.done:
    popad
    ret

sapp_print_registered_commands:
    pushad
    mov ebx, [sapp_pkg_ptr]
    cmp ebx, 0
    je .done
    mov edx, sapp_cmd_table
.loop:
    cmp dword [edx + SAPP_CMD_NAME], 0
    je .done
    mov esi, [edx + SAPP_CMD_PACKAGE]
    mov edi, [ebx + SAPP_PKG_NAME]
    call cstr_equals
    test eax, eax
    jz .next
    mov esi, msg_sapp_registered_prefix
    call print_string
    mov esi, [edx + SAPP_CMD_FILE]
    call print_line
.next:
    add edx, SAPP_CMD_STRIDE
    jmp .loop
.done:
    popad
    ret

sapp_print_unregistered_commands:
    pushad
    mov ebx, [sapp_pkg_ptr]
    cmp ebx, 0
    je .done
    mov edx, sapp_cmd_table
.loop:
    cmp dword [edx + SAPP_CMD_NAME], 0
    je .done
    mov esi, [edx + SAPP_CMD_PACKAGE]
    mov edi, [ebx + SAPP_PKG_NAME]
    call cstr_equals
    test eax, eax
    jz .next
    mov esi, msg_sapp_unregistered_prefix
    call print_string
    mov esi, [edx + SAPP_CMD_FILE]
    call print_line
.next:
    add edx, SAPP_CMD_STRIDE
    jmp .loop
.done:
    popad
    ret

sapp_print_package_files:
    pushad
    mov ebx, [sapp_pkg_ptr]
    cmp ebx, 0
    je .done
    mov esi, [ebx + SAPP_PKG_STATE]
    cmp byte [esi], 1
    je .installed
    mov esi, msg_sapp_not_installed
    call print_string
    mov esi, [ebx + SAPP_PKG_NAME]
    call print_line
    jmp .done
.installed:
    mov esi, msg_sapp_files_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_NAME]
    call print_line
    xor ecx, ecx
    mov edx, sapp_cmd_table
.loop:
    cmp dword [edx + SAPP_CMD_NAME], 0
    je .finish
    mov esi, [edx + SAPP_CMD_PACKAGE]
    mov edi, [ebx + SAPP_PKG_NAME]
    call cstr_equals
    test eax, eax
    jz .next
    mov esi, [edx + SAPP_CMD_FILE]
    call print_line
    inc ecx
.next:
    add edx, SAPP_CMD_STRIDE
    jmp .loop
.finish:
    test ecx, ecx
    jnz .done
    mov esi, msg_sapp_files_none
    call print_line
.done:
    popad
    ret

sapp_find_installed_command:
    push ebx
    push esi
    push edi
    mov dword [sapp_cmd_ptr], 0
    mov ebx, sapp_cmd_table
.loop:
    cmp dword [ebx + SAPP_CMD_NAME], 0
    je .no
    mov edi, [ebx + SAPP_CMD_NAME]
    call soj_token_equals
    test eax, eax
    jnz .match
    mov edi, [ebx + SAPP_CMD_FILE]
    call soj_token_equals
    test eax, eax
    jnz .match
.next:
    add ebx, SAPP_CMD_STRIDE
    jmp .loop
.match:
    mov edi, [ebx + SAPP_CMD_STATE]
    cmp byte [edi], 1
    jne .next
    mov [sapp_cmd_ptr], ebx
    mov eax, 1
    jmp .done
.no:
    xor eax, eax
.done:
    pop edi
    pop esi
    pop ebx
    ret

sapp_execute_installed_command:
    push ebx
    call sapp_find_installed_command
    test eax, eax
    jz .no
    mov ebx, [sapp_cmd_ptr]
    mov eax, [ebx + SAPP_CMD_HANDLER]
    call eax
    mov eax, 1
    pop ebx
    ret
.no:
    xor eax, eax
    pop ebx
    ret

command_pkg_calc:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .intro
    call skip_spaces
    mov al, [esi]
    cmp al, '0'
    jb .usage
    cmp al, '9'
    ja .usage
    call parse_dec32
    mov [calc_lhs], eax
    call skip_spaces
    mov al, [esi]
    cmp al, '+'
    je .op_ok
    cmp al, '-'
    je .op_ok
    cmp al, '*'
    je .op_ok
    cmp al, '/'
    jne .usage
.op_ok:
    mov [calc_op], al
    inc esi
    call skip_spaces
    mov al, [esi]
    cmp al, '0'
    jb .usage
    cmp al, '9'
    ja .usage
    call parse_dec32
    mov [calc_rhs], eax
    mov byte [calc_negative], 0
    mov al, [calc_op]
    cmp al, '+'
    je .add
    cmp al, '-'
    je .sub
    cmp al, '*'
    je .mul
    cmp al, '/'
    je .div
    jmp .usage
.add:
    mov eax, [calc_lhs]
    add eax, [calc_rhs]
    mov [calc_result], eax
    jmp .print
.sub:
    mov eax, [calc_lhs]
    cmp eax, [calc_rhs]
    jae .sub_positive
    mov eax, [calc_rhs]
    sub eax, [calc_lhs]
    mov [calc_result], eax
    mov byte [calc_negative], 1
    jmp .print
.sub_positive:
    sub eax, [calc_rhs]
    mov [calc_result], eax
    jmp .print
.mul:
    mov eax, [calc_lhs]
    mov ebx, [calc_rhs]
    mul ebx
    mov [calc_result], eax
    jmp .print
.div:
    mov ebx, [calc_rhs]
    cmp ebx, 0
    je .div_zero
    mov eax, [calc_lhs]
    xor edx, edx
    div ebx
    mov [calc_result], eax
    jmp .print
.print:
    mov eax, [calc_lhs]
    call print_dec32
    mov al, ' '
    call console_putc
    mov al, [calc_op]
    call console_putc
    mov al, ' '
    call console_putc
    mov eax, [calc_rhs]
    call print_dec32
    mov al, ' '
    call console_putc
    mov al, '='
    call console_putc
    mov al, ' '
    call console_putc
    cmp byte [calc_negative], 1
    jne .print_value
    mov al, '-'
    call console_putc
.print_value:
    mov eax, [calc_result]
    call print_dec32
    call console_newline
    ret
.intro:
    call command_pkg_calc_intro
    ret
.usage:
    mov esi, msg_pkg_calc_usage
    call print_line
    ret
.div_zero:
    mov esi, msg_pkg_calc_div_zero
    call print_line
    ret

command_pkg_calc_intro:
    mov esi, msg_pkg_calc_title
    call print_line
    mov esi, msg_pkg_calc_usage
    call print_line
    ret

sapp_print_dependencies:
    pushad
    mov ebx, [sapp_pkg_ptr]
    cmp ebx, 0
    je .done
    mov esi, [ebx + SAPP_PKG_DEPENDS]
    cmp byte [esi], 0
    je .done
    mov esi, msg_sapp_dep_prefix
    call print_string
    mov esi, [ebx + SAPP_PKG_DEPENDS]
    call print_line
.done:
    popad
    ret

sapp_package_exists:
    push ebx
    mov dword [sapp_pkg_ptr], 0
    mov ebx, sapp_pkg_table
.loop:
    cmp dword [ebx + SAPP_PKG_NAME], 0
    je .no
    mov edi, [sapp_arg_ptr]
    mov esi, [ebx + SAPP_PKG_NAME]
    call soj_token_equals
    test eax, eax
    jnz .yes
    add ebx, SAPP_PKG_STRIDE
    jmp .loop
.no:
    xor eax, eax
    pop ebx
    ret
.yes:
    mov [sapp_pkg_ptr], ebx
    mov eax, 1
    pop ebx
    ret

sapp_find_next_package:
.scan:
    cmp byte [esi], 0
    je .no
    mov edi, sapp_field_package
    call starts_with
    test eax, eax
    jnz .yes
    inc esi
    jmp .scan
.yes:
    mov eax, 1
    ret
.no:
    xor eax, eax
    ret

sapp_next_record:
.line:
    cmp byte [esi], 0
    je .done
    cmp byte [esi], 13
    je .maybe_cr_blank
    cmp byte [esi], 10
    je .maybe_lf_blank
    inc esi
    jmp .line
.maybe_cr_blank:
    cmp byte [esi + 1], 10
    jne .skip_cr
    cmp byte [esi + 2], 13
    jne .skip_crlf
    cmp byte [esi + 3], 10
    je .after_crlf_blank
.skip_crlf:
    add esi, 2
    jmp .line
.skip_cr:
    inc esi
    jmp .line
.maybe_lf_blank:
    cmp byte [esi + 1], 10
    je .after_lf_blank
    inc esi
    jmp .line
.after_crlf_blank:
    add esi, 4
    ret
.after_lf_blank:
    add esi, 2
.done:
    ret

sapp_copy_field_from_block:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov ebx, esi
.line_loop:
    cmp byte [ebx], 0
    je .no
    cmp byte [ebx], 13
    je .blank_or_next
    cmp byte [ebx], 10
    je .no
    mov esi, ebx
    call starts_with
    test eax, eax
    jnz .copy_value
.next_line:
    cmp byte [ebx], 0
    je .no
    cmp byte [ebx], 10
    je .advance_line
    inc ebx
    jmp .next_line
.advance_line:
    inc ebx
    jmp .line_loop
.blank_or_next:
    cmp byte [ebx + 1], 10
    jne .next_line
    cmp byte [ebx + 2], 13
    je .no
    cmp byte [ebx + 2], 10
    je .no
    add ebx, 2
    jmp .line_loop
.copy_value:
    mov esi, ebx
    mov edx, edi
.skip_prefix:
    cmp byte [edx], 0
    je .prefix_done
    inc esi
    inc edx
    jmp .skip_prefix
.prefix_done:
    mov edi, sapp_field_buf
    mov ecx, 255
.copy_loop:
    cmp ecx, 0
    je .terminate
    mov al, [esi]
    cmp al, 0
    je .terminate
    cmp al, 13
    je .terminate
    cmp al, 10
    je .terminate
    mov [edi], al
    inc edi
    inc esi
    dec ecx
    jmp .copy_loop
.terminate:
    mov byte [edi], 0
    mov eax, 1
    jmp .done
.no:
    xor eax, eax
.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

sapp_remote_print_packages:
    push esi
    mov esi, sapp_index_buf
.loop:
    call sapp_find_next_package
    test eax, eax
    jz .done
    push esi
    call sapp_remote_print_record
    pop esi
    call sapp_next_record
    jmp .loop
.done:
    pop esi
    ret

sapp_remote_print_search_results:
    push esi
    xor edx, edx
    mov esi, sapp_index_buf
.loop:
    call sapp_find_next_package
    test eax, eax
    jz .finish
    push esi
    mov edi, sapp_field_package
    call sapp_copy_field_from_block
    test eax, eax
    jz .skip
    mov esi, sapp_field_buf
    mov edi, [sapp_arg_ptr]
    call string_contains_token
    test eax, eax
    jz .skip
    pop esi
    push esi
    call sapp_remote_print_record
    mov edx, 1
.skip:
    pop esi
    call sapp_next_record
    jmp .loop
.finish:
    test edx, edx
    jnz .done
    mov esi, msg_sapp_no_match
    call print_line
.done:
    pop esi
    ret

sapp_remote_package_exists:
    push esi
    mov byte [sapp_remote_pkg_found], 0
    mov dword [sapp_remote_pkg_ptr], 0
    mov esi, sapp_index_buf
.loop:
    call sapp_find_next_package
    test eax, eax
    jz .no
    push esi
    mov edi, sapp_field_package
    call sapp_copy_field_from_block
    test eax, eax
    jz .next
    mov esi, sapp_field_buf
    mov edi, [sapp_arg_ptr]
    call soj_token_equals
    test eax, eax
    jnz .yes
.next:
    pop esi
    call sapp_next_record
    jmp .loop
.yes:
    pop esi
    mov [sapp_remote_pkg_ptr], esi
    mov byte [sapp_remote_pkg_found], 1
    mov eax, 1
    pop esi
    ret
.no:
    xor eax, eax
    pop esi
    ret

sapp_remote_print_record:
    pushad
    mov edi, sapp_field_package
    call sapp_copy_field_from_block
    test eax, eax
    jz .done
    mov esi, sapp_field_buf
    call print_string
    mov esi, msg_sapp_version_sep
    call print_string
    mov esi, [esp + 4]
    mov edi, sapp_field_version
    call sapp_copy_field_from_block
    test eax, eax
    jz .format
    mov esi, sapp_field_buf
    call print_string
.format:
    mov esi, msg_sapp_arch_tail
    call print_string
    mov esi, [esp + 4]
    mov edi, sapp_field_format
    call sapp_copy_field_from_block
    test eax, eax
    jz .default_format
    mov esi, sapp_field_buf
    call print_line
    jmp .internal
.default_format:
    mov esi, msg_sapp_format_binary
    call print_line
.internal:
    mov esi, msg_sapp_internal_prefix
    call print_string
    mov esi, [esp + 4]
    mov edi, sapp_field_internal
    call sapp_copy_field_from_block
    test eax, eax
    jz .depends
    mov esi, sapp_field_buf
    call print_line
.depends:
    mov esi, [esp + 4]
    mov edi, sapp_field_depends
    call sapp_copy_field_from_block
    test eax, eax
    jz .sxr
    mov esi, msg_sapp_depends_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.sxr:
    mov esi, [esp + 4]
    mov edi, sapp_field_sxr_depends
    call sapp_copy_field_from_block
    test eax, eax
    jz .runtime
    mov esi, msg_sapp_sxr_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.runtime:
    mov esi, [esp + 4]
    mov edi, sapp_field_runtime
    call sapp_copy_field_from_block
    test eax, eax
    jz .entry
    mov esi, msg_sapp_runtime_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.entry:
    mov esi, [esp + 4]
    mov edi, sapp_field_entry
    call sapp_copy_field_from_block
    test eax, eax
    jz .commands
    mov esi, msg_sapp_entry_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.commands:
    mov esi, [esp + 4]
    mov edi, sapp_field_commands
    call sapp_copy_field_from_block
    test eax, eax
    jz .pkgtype
    mov esi, msg_sapp_commands_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.pkgtype:
    mov esi, [esp + 4]
    mov edi, sapp_field_package_type
    call sapp_copy_field_from_block
    test eax, eax
    jz .permissions
    mov esi, msg_sapp_pkg_type_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.permissions:
    mov esi, [esp + 4]
    mov edi, sapp_field_permissions
    call sapp_copy_field_from_block
    test eax, eax
    jz .turing
    mov esi, msg_sapp_permissions_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.turing:
    mov esi, [esp + 4]
    mov edi, sapp_field_turing
    call sapp_copy_field_from_block
    test eax, eax
    jz .file
    mov esi, msg_sapp_tc
    call print_line
.file:
    mov esi, msg_sapp_file_prefix
    call print_string
    mov esi, [esp + 4]
    mov edi, sapp_field_filename
    call sapp_copy_field_from_block
    test eax, eax
    jz .size
    mov esi, sapp_field_buf
    call print_line
.size:
    mov esi, msg_sapp_size_prefix
    call print_string
    mov esi, [esp + 4]
    mov edi, sapp_field_size
    call sapp_copy_field_from_block
    test eax, eax
    jz .desc
    mov esi, sapp_field_buf
    call print_string
    mov esi, msg_sapp_bytes_tail
    call print_line
.desc:
    mov esi, msg_sapp_desc_prefix
    call print_string
    mov esi, [esp + 4]
    mov edi, sapp_field_description
    call sapp_copy_field_from_block
    test eax, eax
    jz .status
    mov esi, sapp_field_buf
    call print_line
.status:
    mov esi, msg_sapp_status_prefix
    call print_string
    mov esi, msg_sapp_state_available
    call print_line
.done:
    popad
    ret

sapp_remote_print_dependencies:
    pushad
    mov esi, [sapp_remote_pkg_ptr]
    cmp esi, 0
    je .done
    mov edi, sapp_field_depends
    call sapp_copy_field_from_block
    test eax, eax
    jz .sxr
    cmp byte [sapp_field_buf], 0
    je .sxr
    mov esi, msg_sapp_dep_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.sxr:
    mov esi, [sapp_remote_pkg_ptr]
    mov edi, sapp_field_sxr_depends
    call sapp_copy_field_from_block
    test eax, eax
    jz .done
    cmp byte [sapp_field_buf], 0
    je .done
    mov esi, msg_sapp_sxr_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.done:
    popad
    ret

sapp_remote_print_binary_fetch:
    pushad
    mov esi, [sapp_remote_pkg_ptr]
    cmp esi, 0
    je .done
    mov edi, sapp_field_filename
    call sapp_copy_field_from_block
    test eax, eax
    jz .done
    mov esi, msg_sapp_fetch_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
    mov esi, msg_sapp_http_get_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
    mov esi, msg_sapp_cache_prefix
    call print_string
    mov esi, sapp_field_buf
    call print_line
.done:
    popad
    ret

command_netctl:
    call detect_network_pci
    call init_network_services
    call e1000_poll_rx
    mov esi, msg_netctl_title
    call print_line
    mov esi, msg_netctl_e1000
    call print_string
    mov al, [e1000_inited]
    call print_service_state
    mov esi, msg_netctl_link
    call print_string
    mov al, [svc_net]
    call print_service_state
    mov esi, msg_netctl_tcp
    call print_string
    mov al, [svc_tcp]
    call print_service_state
    mov esi, msg_netctl_tls
    call print_string
    mov al, [svc_tls]
    call print_service_state
    mov esi, msg_net_lease
    call print_string
    mov al, [dhcp_lease_valid]
    call print_service_state
    mov esi, msg_net_gwmac
    call print_string
    mov al, [net_gateway_mac_valid]
    call print_service_state
    mov esi, msg_unit_ssh
    call print_string
    mov al, [svc_ssh]
    call print_service_state_inline
    mov esi, msg_unit_ssh_desc
    call print_line
    mov esi, ssh_server_note
    call print_line
    mov esi, msg_unit_sftp
    call print_string
    mov al, [svc_sftp]
    call print_service_state_inline
    mov esi, msg_unit_sftp_desc
    call print_line
    mov esi, msg_netctl_arp
    call print_line
    mov esi, msg_netctl_ipv4
    call print_line
    mov esi, msg_netctl_icmp
    call print_line
    mov esi, msg_netctl_udp
    call print_line
    mov esi, msg_netctl_tcp_note
    call print_line
    call print_net_counters
    call command_ifconfig
    ret

print_net_counters:
    mov esi, msg_net_last_proto
    call print_string
    call print_net_last_proto
    mov esi, msg_net_stats_rx
    call print_string
    mov eax, [net_rx_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_tx
    call print_string
    mov eax, [net_tx_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_arp
    call print_string
    mov eax, [net_arp_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_ipv4
    call print_string
    mov eax, [net_ipv4_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_icmp
    call print_string
    mov eax, [net_icmp_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_udp
    call print_string
    mov eax, [net_udp_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_tcp
    call print_string
    mov eax, [net_tcp_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_dhcp
    call print_string
    mov eax, [net_dhcp_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_dns
    call print_string
    mov eax, [net_dns_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_icmp_req
    call print_string
    mov eax, [net_icmp_echo_requests]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_icmp_reply
    call print_string
    mov eax, [net_icmp_echo_replies]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_tcp_syn
    call print_string
    mov eax, [net_tcp_syn_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_tcp_ack
    call print_string
    mov eax, [net_tcp_ack_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_tcp_psh
    call print_string
    mov eax, [net_tcp_psh_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_tcp_rst
    call print_string
    mov eax, [net_tcp_rst_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_ssh_syn
    call print_string
    mov eax, [ssh_rx_syn_packets]
    call print_hex32
    call console_newline
    mov esi, msg_net_stats_ssh_banner
    call print_string
    mov eax, [ssh_tx_banner_packets]
    call print_hex32
    call console_newline
    ret

print_net_last_proto:
    mov al, [net_last_proto]
    cmp al, 1
    je .arp
    cmp al, IP_PROTO_ICMP
    je .icmp
    cmp al, IP_PROTO_UDP
    je .udp
    cmp al, IP_PROTO_TCP
    je .tcp
    mov esi, msg_net_proto_none
    call print_line
    ret
.arp:
    mov esi, msg_net_proto_arp
    call print_line
    ret
.icmp:
    mov esi, msg_net_proto_icmp
    call print_line
    ret
.udp:
    mov esi, msg_net_proto_udp
    call print_line
    ret
.tcp:
    mov esi, msg_net_proto_tcp
    call print_line
    ret

command_ss:
    mov esi, msg_ss_head
    call print_line
    mov esi, msg_ss_ssh
    call print_line
    ret

print_service_state:
    cmp al, 0
    je .inactive
    mov esi, msg_svc_active
    call print_line
    ret
.inactive:
    mov esi, msg_svc_inactive
    call print_line
    ret

command_systemd:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, systemd_list
    call match_token
    test eax, eax
    jnz .list
    mov edi, systemd_status
    call match_token
    test eax, eax
    jnz .status
    mov edi, systemd_start
    call match_token
    test eax, eax
    jnz .start
    mov edi, systemd_stop
    call match_token
    test eax, eax
    jnz .stop
.usage:
    mov esi, msg_systemd_usage
    call print_line
    ret
.list:
    call print_systemd_units
    ret
.status:
    call next_arg
    cmp byte [esi], 0
    je .list
    call print_unit_status
    ret
.start:
    call next_arg
    call require_root
    test eax, eax
    jz .denied
    call set_unit_active
    ret
.stop:
    call next_arg
    call require_root
    test eax, eax
    jz .denied
    call set_unit_inactive
    ret
.denied:
    ret

print_systemd_units:
    mov esi, msg_systemd_units
    call print_line
    mov esi, msg_unit_net
    call print_string
    mov al, [svc_net]
    call print_service_state_inline
    mov esi, msg_unit_net_desc
    call print_line
    mov esi, msg_unit_tcp
    call print_string
    mov al, [svc_tcp]
    call print_service_state_inline
    mov esi, msg_unit_tcp_desc
    call print_line
    mov esi, msg_unit_tls
    call print_string
    mov al, [svc_tls]
    call print_service_state_inline
    mov esi, msg_unit_tls_desc
    call print_line
    mov esi, msg_unit_sapp
    call print_string
    mov al, [svc_sapp]
    call print_service_state_inline
    mov esi, msg_unit_sapp_desc
    call print_line
    mov esi, msg_unit_ssh
    call print_string
    mov al, [svc_ssh]
    call print_service_state_inline
    mov esi, msg_unit_ssh_desc
    call print_line
    mov esi, msg_unit_sftp
    call print_string
    mov al, [svc_sftp]
    call print_service_state_inline
    mov esi, msg_unit_sftp_desc
    call print_line
    ret

print_service_state_inline:
    cmp al, 0
    je .inactive
    mov esi, msg_svc_active
    call print_string
    ret
.inactive:
    mov esi, msg_svc_inactive
    call print_string
    ret

print_unit_status:
    mov edi, unit_network
    call match_token
    test eax, eax
    jnz .net
    mov edi, unit_tcpip
    call match_token
    test eax, eax
    jnz .tcp
    mov edi, unit_https
    call match_token
    test eax, eax
    jnz .tls
    mov edi, unit_sapp
    call match_token
    test eax, eax
    jnz .sapp
    mov edi, unit_ssh
    call match_token
    test eax, eax
    jnz .ssh
    mov edi, unit_sftp
    call match_token
    test eax, eax
    jnz .sftp
    mov edi, unit_ssh
    call match_token
    test eax, eax
    jnz .ssh
    mov edi, unit_sftp
    call match_token
    test eax, eax
    jnz .sftp
    mov esi, msg_systemd_unknown
    call print_line
    ret
.net:
    mov esi, msg_unit_net
    call print_string
    mov al, [svc_net]
    call print_service_state_inline
    mov esi, msg_unit_net_desc
    call print_line
    ret
.tcp:
    mov esi, msg_unit_tcp
    call print_string
    mov al, [svc_tcp]
    call print_service_state_inline
    mov esi, msg_unit_tcp_desc
    call print_line
    ret
.tls:
    mov esi, msg_unit_tls
    call print_string
    mov al, [svc_tls]
    call print_service_state_inline
    mov esi, msg_unit_tls_desc
    call print_line
    ret
.sapp:
    mov esi, msg_unit_sapp
    call print_string
    mov al, [svc_sapp]
    call print_service_state_inline
    mov esi, msg_unit_sapp_desc
    call print_line
    ret
.ssh:
    mov esi, msg_unit_ssh
    call print_string
    mov al, [svc_ssh]
    call print_service_state_inline
    mov esi, msg_unit_ssh_desc
    call print_line
    mov esi, ssh_server_note
    call print_line
    ret
.sftp:
    mov esi, msg_unit_sftp
    call print_string
    mov al, [svc_sftp]
    call print_service_state_inline
    mov esi, msg_unit_sftp_desc
    call print_line
    ret

set_unit_active:
    mov edi, unit_network
    call match_token
    test eax, eax
    jnz .net
    mov edi, unit_tcpip
    call match_token
    test eax, eax
    jnz .tcp
    mov edi, unit_https
    call match_token
    test eax, eax
    jnz .tls
    mov edi, unit_sapp
    call match_token
    test eax, eax
    jnz .sapp
    mov edi, unit_ssh
    call match_token
    test eax, eax
    jnz .ssh
    mov edi, unit_sftp
    call match_token
    test eax, eax
    jnz .sftp
    mov esi, msg_systemd_unknown
    call print_line
    ret
.net:
    mov byte [svc_net], 1
    jmp .done
.tcp:
    mov byte [svc_tcp], 1
    jmp .done
.tls:
    mov byte [svc_tls], 1
    jmp .done
.sapp:
    mov byte [svc_sapp], 1
    jmp .done
.ssh:
    mov byte [svc_ssh], 1
    jmp .done
.sftp:
    mov byte [svc_sftp], 1
.done:
    mov esi, msg_systemd_started
    call print_string
    mov esi, input_buffer
    call first_arg
    call next_arg
    call print_line
    ret

set_unit_inactive:
    mov edi, unit_network
    call match_token
    test eax, eax
    jnz .net
    mov edi, unit_tcpip
    call match_token
    test eax, eax
    jnz .tcp
    mov edi, unit_https
    call match_token
    test eax, eax
    jnz .tls
    mov edi, unit_sapp
    call match_token
    test eax, eax
    jnz .sapp
    mov edi, unit_ssh
    call match_token
    test eax, eax
    jnz .ssh
    mov edi, unit_sftp
    call match_token
    test eax, eax
    jnz .sftp
    mov esi, msg_systemd_unknown
    call print_line
    ret
.net:
    mov byte [svc_net], 0
    jmp .done
.tcp:
    mov byte [svc_tcp], 0
    jmp .done
.tls:
    mov byte [svc_tls], 0
    jmp .done
.sapp:
    mov byte [svc_sapp], 0
    jmp .done
.ssh:
    mov byte [svc_ssh], 0
    jmp .done
.sftp:
    mov byte [svc_sftp], 0
.done:
    mov esi, msg_systemd_stopped
    call print_string
    mov esi, input_buffer
    call first_arg
    call next_arg
    call print_line
    ret

command_soj:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call ramfs_check_read
    cmp eax, 2
    je .done_denied
    test eax, eax
    jz .not_found

    mov edi, path_demo_soj
    call match_token
    test eax, eax
    jnz .demo
    mov edi, path_script_soj
    call match_token
    test eax, eax
    jnz .script

    cmp dword [current_dir], DIR_HOME
    jne .not_found
    mov edi, name_demo_soj
    call match_token
    test eax, eax
    jnz .demo
    mov edi, path_dot_demo_soj
    call match_token
    test eax, eax
    jnz .demo
    mov edi, name_script_soj
    call match_token
    test eax, eax
    jnz .script
    mov edi, path_dot_script_soj
    call match_token
    test eax, eax
    jnz .script

.not_found:
    mov esi, msg_no_file
    call print_line
    ret
.usage:
    mov esi, msg_usage_soj
    call print_line
    ret
.demo:
    mov esi, msg_soj_start
    call print_string
    mov esi, name_demo_soj
    call print_line
    mov esi, file_demo_soj
    call run_soj_script
    ret
.script:
    mov esi, msg_soj_start
    call print_string
    mov esi, name_script_soj
    call print_line
    mov esi, home_script_soj
    call run_soj_script
    ret
.done_denied:
    ret

run_soj_script:
    pushad
    mov [soj_ptr], esi
    mov [soj_base_ptr], esi
    mov byte [soj_stop], 0
.line_loop:
    call poll_ctrl_c
    cmp byte [command_cancelled], 1
    je .cancelled
    cmp byte [soj_stop], 0
    jne .done
    mov esi, [soj_ptr]
    cmp byte [esi], 0
    je .done
    mov edi, soj_line_buffer
    mov ecx, 255
.copy:
    mov al, [esi]
    cmp al, 0
    je .finish_line
    cmp al, ';'
    je .finish_sep
    cmp al, 10
    je .finish_sep
    cmp al, 13
    je .finish_sep
    mov [edi], al
    inc esi
    inc edi
    loop .copy
    jmp .finish_line
.finish_sep:
    inc esi
.finish_line:
    mov byte [edi], 0
    mov [soj_ptr], esi
    mov esi, soj_line_buffer
    call soj_execute_line
    jmp .line_loop
.done:
    mov esi, msg_soj_done
    call print_line
    popad
    ret
.cancelled:
    mov esi, msg_command_cancelled
    call print_line
    popad
    ret

soj_execute_line:
    call skip_spaces
    cmp byte [esi], 0
    je .done
    cmp byte [esi], '#'
    je .done

    mov edi, soj_kw_echo
    call match_token
    test eax, eax
    jnz .echo

    mov edi, soj_kw_print
    call match_token
    test eax, eax
    jnz .print

    mov edi, soj_kw_set
    call match_token
    test eax, eax
    jnz .set

    mov edi, soj_kw_if
    call match_token
    test eax, eax
    jnz .if

    mov edi, soj_kw_exec
    call match_token
    test eax, eax
    jnz .exec

    mov edi, soj_kw_exit
    call match_token
    test eax, eax
    jnz .exit

    mov edi, soj_kw_label
    call match_token
    test eax, eax
    jnz .done

    mov edi, soj_kw_goto
    call match_token
    test eax, eax
    jnz .goto

    mov edi, soj_kw_inc
    call match_token
    test eax, eax
    jnz .inc

    mov edi, soj_kw_dec
    call match_token
    test eax, eax
    jnz .dec

    mov edi, soj_kw_input
    call match_token
    test eax, eax
    jnz .input

    mov edi, cmd_clear
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_ls
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_cd
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_version
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_sysinfo
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_pwd
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_uname
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_hostname
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_whoami
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_id
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_date
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_timezone
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_man
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_which
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_type
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_whereis
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_sudo
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_df
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_mount
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_ps
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_lspci
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_dmesg
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_features
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_top
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_jobs
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_kill
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_service
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_uptime
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_mem
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_free
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_disk
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_install
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_ifconfig
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_netstat
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_dhclient
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_resolvectl
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_netctl
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_sapp
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_systemd
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_systemctl
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_bf
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_ping
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_wget
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_curl
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_ssh
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_sftp
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_cat
    call match_token
    test eax, eax
    jnz .exec_current

    mov edi, cmd_imgview
    call match_token
    test eax, eax
    jnz .exec_current

    call sapp_find_installed_command
    test eax, eax
    jnz .exec_current

    mov esi, msg_soj_unknown
    call print_string
    mov esi, soj_line_buffer
    call print_line
    ret
.echo:
    call first_arg
    call soj_print_expanded_line
    ret
.print:
    call first_arg
    call soj_print_expr
    ret
.set:
    call soj_set_statement
    ret
.if:
    call soj_if_statement
    ret
.exec:
    call first_arg
    cmp byte [esi], 0
    je .done
    call soj_exec_from_esi
    ret
.exec_current:
    call soj_exec_from_esi
    ret
.exit:
    mov byte [soj_stop], 1
    ret
.goto:
    call soj_goto_statement
    ret
.inc:
    call soj_inc_statement
    ret
.dec:
    call soj_dec_statement
    ret
.input:
    call soj_input_statement
.done:
    ret

soj_set_statement:
    mov esi, soj_line_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, soj_var_name
    mov ecx, 31
.copy_name:
    mov al, [esi]
    cmp al, 0
    je .name_done
    cmp al, ' '
    je .name_done
    cmp al, 9
    je .name_done
    mov [edi], al
    inc esi
    inc edi
    loop .copy_name
.name_done:
    mov byte [edi], 0
    call skip_spaces
    cmp byte [esi], 0
    je .usage
    mov edi, soj_var_value
    mov ecx, 95
.copy_value:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .done
    inc esi
    inc edi
    loop .copy_value
    mov byte [edi], 0
.done:
    ret
.usage:
    mov esi, msg_usage_soj_set
    call print_line
    ret

soj_if_statement:
    mov esi, soj_line_buffer
    mov byte [soj_if_not], 0
    call first_arg
    cmp byte [esi], '$'
    jne .usage
    inc esi
    call soj_compare_var_name
    test eax, eax
    jz .var_missing
    call next_arg
    mov edi, soj_op_eq
    call match_token
    test eax, eax
    jnz .operator_ok
    mov edi, soj_op_ne
    call match_token
    test eax, eax
    jz .usage
    mov byte [soj_if_not], 1
.operator_ok:
    call next_arg
    call soj_compare_value_token
    cmp byte [soj_if_not], 0
    je .check_condition
    xor eax, 1
.check_condition:
    test eax, eax
    jz .done
    call next_arg
    mov edi, soj_kw_then
    call match_token
    test eax, eax
    jz .usage
    call next_arg
    cmp byte [esi], 0
    je .usage
    mov edi, soj_kw_goto
    call match_token
    test eax, eax
    jnz .goto
    call soj_execute_inline
    ret
.goto:
    call soj_goto_statement_from_esi
    ret
.var_missing:
    mov esi, msg_soj_var_missing
    call print_line
    ret
.usage:
    mov esi, msg_soj_if_usage
    call print_line
.done:
    ret

soj_goto_statement:
    mov esi, soj_line_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call soj_find_label
    test eax, eax
    jz .missing
    mov [soj_ptr], eax
    ret
.usage:
    mov esi, msg_usage_soj_goto
    call print_line
    ret
.missing:
    mov esi, msg_soj_label_missing
    call print_string
    mov esi, soj_line_buffer
    call first_arg
    call print_line
    ret

soj_goto_statement_from_esi:
    call skip_spaces
    cmp byte [esi], 0
    je .usage
    call soj_find_label
    test eax, eax
    jz .missing
    mov [soj_ptr], eax
    ret
.usage:
    mov esi, msg_usage_soj_goto
    call print_line
    ret
.missing:
    mov esi, msg_soj_label_missing
    call print_string
    call print_line
    ret

soj_find_label:
    push ebx
    push ecx
    push edx
    mov edx, esi
    mov ebx, [soj_base_ptr]
.line:
    cmp byte [ebx], 0
    je .not_found
    mov esi, ebx
    call skip_spaces
    mov edi, soj_kw_label
    call match_token
    test eax, eax
    jz .advance
    call first_arg
    push esi
    mov esi, edx
    mov edi, [esp]
    call soj_token_equals
    add esp, 4
    test eax, eax
    jnz .found
.advance:
    mov al, [ebx]
    cmp al, 0
    je .not_found
    inc ebx
    cmp al, ';'
    je .line
    cmp al, 10
    je .line
    cmp al, 13
    je .line
    jmp .advance
.found:
    mov eax, ebx
    call soj_advance_line_ptr
    jmp .done
.not_found:
    xor eax, eax
.done:
    pop edx
    pop ecx
    pop ebx
    ret

soj_advance_line_ptr:
    cmp byte [eax], 0
    je .done
    cmp byte [eax], ';'
    je .step
    cmp byte [eax], 10
    je .step
    cmp byte [eax], 13
    je .step
    inc eax
    jmp soj_advance_line_ptr
.step:
    inc eax
.done:
    ret

soj_token_equals:
    push ebx
    push esi
    push edi
.loop:
    mov al, [esi]
    cmp al, 0
    je .left_end
    cmp al, ' '
    je .left_end
    cmp al, 9
    je .left_end
    mov bl, [edi]
    cmp bl, 0
    je .no
    cmp bl, ' '
    je .no
    cmp bl, 9
    je .no
    cmp al, bl
    jne .no
    inc esi
    inc edi
    jmp .loop
.left_end:
    mov bl, [edi]
    cmp bl, 0
    je .yes
    cmp bl, ' '
    je .yes
    cmp bl, 9
    je .yes
.no:
    xor eax, eax
    jmp .done
.yes:
    mov eax, 1
.done:
    pop edi
    pop esi
    pop ebx
    ret

soj_inc_statement:
    mov esi, soj_line_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call soj_compare_var_name
    test eax, eax
    jz .missing
    mov esi, soj_var_value
    call parse_dec32
    inc eax
    call soj_store_eax_decimal
    ret
.usage:
    mov esi, msg_usage_soj_math
    call print_line
    ret
.missing:
    mov esi, msg_soj_var_missing
    call print_line
    ret

soj_dec_statement:
    mov esi, soj_line_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    call soj_compare_var_name
    test eax, eax
    jz .missing
    mov esi, soj_var_value
    call parse_dec32
    cmp eax, 0
    je .store
    dec eax
.store:
    call soj_store_eax_decimal
    ret
.usage:
    mov esi, msg_usage_soj_math
    call print_line
    ret
.missing:
    mov esi, msg_soj_var_missing
    call print_line
    ret

soj_input_statement:
    mov esi, soj_line_buffer
    call first_arg
    cmp byte [esi], 0
    je .usage
    mov edi, soj_var_name
    mov ecx, 31
.copy_name:
    mov al, [esi]
    cmp al, 0
    je .name_done
    cmp al, ' '
    je .name_done
    cmp al, 9
    je .name_done
    mov [edi], al
    inc esi
    inc edi
    loop .copy_name
.name_done:
    mov byte [edi], 0
    mov esi, msg_soj_input_prompt
    call print_string
    call read_line
    mov esi, input_buffer
    mov edi, soj_var_value
    mov ecx, 95
.copy_value:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .done
    inc esi
    inc edi
    loop .copy_value
    mov byte [edi], 0
.done:
    ret
.usage:
    mov esi, msg_usage_soj_input
    call print_line
    ret

parse_dec32:
    call skip_spaces
    xor eax, eax
.loop:
    mov bl, [esi]
    cmp bl, '0'
    jb .done
    cmp bl, '9'
    ja .done
    imul eax, eax, 10
    sub bl, '0'
    movzx edx, bl
    add eax, edx
    inc esi
    jmp .loop
.done:
    ret

soj_store_eax_decimal:
    pushad
    mov edi, soj_var_value
    cmp eax, 0
    jne .convert
    mov byte [edi], '0'
    mov byte [edi + 1], 0
    popad
    ret
.convert:
    mov ebx, 10
    mov ecx, 0
    mov esi, soj_line_buffer
.digits:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [esi + ecx], dl
    inc ecx
    test eax, eax
    jnz .digits
.write:
    dec ecx
    mov al, [esi + ecx]
    mov [edi], al
    inc edi
    cmp ecx, 0
    jne .write
    mov byte [edi], 0
    popad
    ret

soj_exec_from_esi:
    pushad
    mov edi, input_buffer
    mov ecx, 255
.copy:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .run
    inc esi
    inc edi
    loop .copy
    mov byte [edi], 0
.run:
    call execute_command
    popad
    ret

soj_execute_inline:
    pushad
    mov edi, soj_line_buffer
    mov ecx, 255
.copy:
    mov al, [esi]
    mov [edi], al
    test al, al
    jz .run
    inc esi
    inc edi
    loop .copy
    mov byte [edi], 0
.run:
    mov esi, soj_line_buffer
    call soj_execute_line
    popad
    ret

soj_print_expr:
    call skip_spaces
    cmp byte [esi], '$'
    jne soj_print_expanded_line
    inc esi
    call soj_compare_var_name
    test eax, eax
    jz .missing
    mov esi, soj_var_value
    call print_string
    call console_newline
    ret
.missing:
    mov esi, msg_soj_var_missing
    call print_line
    ret

soj_print_expanded_line:
    call skip_spaces
.loop:
    mov al, [esi]
    test al, al
    jz .done
    cmp al, '$'
    je .var
    call console_putc
    inc esi
    jmp .loop
.var:
    inc esi
    call soj_compare_var_name
    test eax, eax
    jz .missing
    push esi
    mov esi, soj_var_value
    call print_string
    pop esi
    call soj_skip_token
    jmp .loop
.missing:
    mov al, '$'
    call console_putc
    jmp .loop
.done:
    call console_newline
    ret

soj_compare_var_name:
    push esi
    mov edi, soj_var_name
.loop:
    mov al, [edi]
    cmp al, 0
    je .end_name
    cmp byte [esi], al
    jne .no
    inc esi
    inc edi
    jmp .loop
.end_name:
    mov al, [esi]
    cmp al, 0
    je .yes
    cmp al, ' '
    je .yes
    cmp al, 9
    je .yes
    cmp al, ';'
    je .yes
.no:
    xor eax, eax
    jmp .done
.yes:
    mov eax, 1
.done:
    pop esi
    ret

soj_compare_value_token:
    push esi
    mov edi, soj_var_value
.loop:
    mov al, [edi]
    cmp al, 0
    je .end_value
    mov bl, [esi]
    cmp bl, al
    jne .no
    inc esi
    inc edi
    jmp .loop
.end_value:
    mov bl, [esi]
    cmp bl, 0
    je .yes
    cmp bl, ' '
    je .yes
    cmp bl, 9
    je .yes
.no:
    xor eax, eax
    jmp .done
.yes:
    mov eax, 1
.done:
    pop esi
    ret

soj_skip_token:
.loop:
    cmp byte [esi], 0
    je .done
    cmp byte [esi], ' '
    je .done
    cmp byte [esi], 9
    je .done
    inc esi
    jmp .loop
.done:
    ret

command_bf:
    mov esi, input_buffer
    call first_arg
    cmp byte [esi], 0
    je .done

    push esi
    mov edi, bf_tape
    mov ecx, 256
    xor eax, eax
    rep stosb
    pop esi
    mov edi, bf_tape

.run:
    mov al, [esi]
    test al, al
    jz .done
    cmp al, '>'
    je .inc_ptr
    cmp al, '<'
    je .dec_ptr
    cmp al, '+'
    je .inc_cell
    cmp al, '-'
    je .dec_cell
    cmp al, '.'
    je .output
    cmp al, '['
    je .loop_start
    cmp al, ']'
    je .loop_end
    jmp .advance

.inc_ptr:
    inc edi
    cmp edi, bf_tape + 256
    jb .advance
    mov edi, bf_tape
    jmp .advance
.dec_ptr:
    cmp edi, bf_tape
    ja .dec_ptr_ok
    mov edi, bf_tape + 256
.dec_ptr_ok:
    dec edi
    jmp .advance
.inc_cell:
    inc byte [edi]
    jmp .advance
.dec_cell:
    dec byte [edi]
    jmp .advance
.output:
    mov al, [edi]
    call console_putc
    jmp .advance
.loop_start:
    cmp byte [edi], 0
    jne .advance
    call bf_skip_forward
    jmp .advance
.loop_end:
    cmp byte [edi], 0
    je .advance
    call bf_jump_back
.advance:
    inc esi
    jmp .run
.done:
    mov esi, msg_bf_done
    call print_line
    ret

bf_skip_forward:
    mov ecx, 1
.next:
    inc esi
    mov al, [esi]
    test al, al
    jz .done
    cmp al, '['
    je .open
    cmp al, ']'
    je .close
    jmp .next
.open:
    inc ecx
    jmp .next
.close:
    dec ecx
    jnz .next
.done:
    ret

bf_jump_back:
    mov ecx, 1
.prev:
    dec esi
    mov al, [esi]
    cmp al, ']'
    je .close
    cmp al, '['
    je .open
    jmp .prev
.close:
    inc ecx
    jmp .prev
.open:
    dec ecx
    jnz .prev
    ret

skip_spaces:
    cmp byte [esi], ' '
    je .skip
    cmp byte [esi], 9
    je .skip
    ret
.skip:
    inc esi
    jmp skip_spaces

first_arg:
    call skip_spaces
.cmd:
    cmp byte [esi], 0
    je .done
    cmp byte [esi], ' '
    je .after
    cmp byte [esi], 9
    je .after
    inc esi
    jmp .cmd
.after:
    call skip_spaces
.done:
    ret

next_arg:
.token:
    cmp byte [esi], 0
    je .done
    cmp byte [esi], ' '
    je .after
    cmp byte [esi], 9
    je .after
    inc esi
    jmp .token
.after:
    call skip_spaces
.done:
    ret

match_token:
    push esi
    push edi
.loop:
    mov al, [edi]
    cmp al, 0
    je .end_pattern
    mov bl, [esi]
    cmp bl, al
    jne .no
    inc esi
    inc edi
    jmp .loop
.end_pattern:
    mov bl, [esi]
    cmp bl, 0
    je .yes
    cmp bl, ' '
    je .yes
    cmp bl, 9
    je .yes
.no:
    xor eax, eax
    jmp .done
.yes:
    mov eax, 1
.done:
    pop edi
    pop esi
    ret

starts_with:
    push esi
    push edi
.loop:
    mov al, [edi]
    test al, al
    jz .yes
    cmp byte [esi], al
    jne .no
    inc esi
    inc edi
    jmp .loop
.yes:
    mov eax, 1
    jmp .done
.no:
    xor eax, eax
.done:
    pop edi
    pop esi
    ret

cstr_equals:
    push esi
    push edi
    push ebx
.loop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .no
    test al, al
    jz .yes
    inc esi
    inc edi
    jmp .loop
.yes:
    mov eax, 1
    jmp .done
.no:
    xor eax, eax
.done:
    pop ebx
    pop edi
    pop esi
    ret

validate_ipv4_token:
    push esi
    push ebx
    push ecx
    xor ebx, ebx
    mov ecx, 4
.octet:
    xor edx, edx
    cmp byte [esi], '0'
    jb .no
    cmp byte [esi], '9'
    ja .no
.digits:
    mov al, [esi]
    cmp al, '0'
    jb .after_digits
    cmp al, '9'
    ja .after_digits
    inc edx
    cmp edx, 3
    ja .no
    inc esi
    jmp .digits
.after_digits:
    cmp ecx, 1
    je .last
    cmp byte [esi], '.'
    jne .no
    inc esi
    dec ecx
    inc ebx
    jmp .octet
.last:
    cmp byte [esi], 0
    je .yes
    cmp byte [esi], ' '
    je .yes
    cmp byte [esi], 9
    je .yes
    jmp .no
.yes:
    cmp ebx, 3
    jne .no
    mov eax, 1
    jmp .done
.no:
    xor eax, eax
.done:
    pop ecx
    pop ebx
    pop esi
    ret

dns_build_query_from_token:
    push esi
    push edi
    push ebx
    push ecx
    push edx
    mov edi, dns_query_buf
    xor ecx, ecx
.label_start:
    cmp byte [esi], 0
    je .bad
    cmp byte [esi], ' '
    je .bad
    cmp byte [esi], 9
    je .bad
    mov ebx, edi
    mov byte [edi], 0
    inc edi
    xor edx, edx
.label_loop:
    mov al, [esi]
    cmp al, 0
    je .finish_label
    cmp al, ' '
    je .finish_label
    cmp al, 9
    je .finish_label
    cmp al, '.'
    je .finish_dot
    cmp edx, 63
    jae .bad
    cmp ecx, 62
    jae .bad
    mov [edi], al
    inc edi
    inc esi
    inc edx
    inc ecx
    jmp .label_loop
.finish_dot:
    cmp edx, 0
    je .bad
    mov [ebx], dl
    inc esi
    inc ecx
    cmp ecx, 62
    jae .bad
    jmp .label_start
.finish_label:
    cmp edx, 0
    je .bad
    mov [ebx], dl
    inc ecx
    mov byte [edi], 0
    inc edi
    inc ecx
    mov dword [net_dns_query_ptr], dns_query_buf
    mov [net_dns_query_len], ecx
    mov eax, 1
    jmp .done
.bad:
    xor eax, eax
.done:
    pop edx
    pop ecx
    pop ebx
    pop edi
    pop esi
    ret

parse_ipv4_token:
    push esi
    push ebx
    push ecx
    push edx
    xor ebx, ebx
    xor ecx, ecx
.octet:
    xor edx, edx
.digits:
    mov al, [esi]
    cmp al, '0'
    jb .store
    cmp al, '9'
    ja .store
    sub al, '0'
    movzx eax, al
    push ebx
    mov ebx, edx
    shl edx, 3
    lea edx, [edx + ebx * 2]
    add edx, eax
    pop ebx
    inc esi
    jmp .digits
.store:
    mov eax, edx
    shl eax, cl
    or ebx, eax
    cmp byte [esi], '.'
    jne .done_parse
    add cl, 8
    inc esi
    jmp .octet
.done_parse:
    mov eax, ebx
    pop edx
    pop ecx
    pop ebx
    pop esi
    ret

parse_hex32:
    call skip_spaces
    xor eax, eax
    cmp byte [esi], '0'
    jne .loop
    cmp byte [esi + 1], 'x'
    je .skip_prefix
    cmp byte [esi + 1], 'X'
    jne .loop
.skip_prefix:
    add esi, 2
.loop:
    mov bl, [esi]
    cmp bl, '0'
    jb .done
    cmp bl, '9'
    jbe .digit
    cmp bl, 'A'
    jb .lower
    cmp bl, 'F'
    jbe .upper
.lower:
    cmp bl, 'a'
    jb .done
    cmp bl, 'f'
    ja .done
    sub bl, 'a' - 10
    jmp .append
.upper:
    sub bl, 'A' - 10
    jmp .append
.digit:
    sub bl, '0'
.append:
    shl eax, 4
    movzx edx, bl
    or eax, edx
    inc esi
    jmp .loop
.done:
    ret
