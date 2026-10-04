[org 0x0000]
[bits 16]

kernel_start:
    ; Atur segment data dan stack
    mov ax, 0x1000
    mov ds, ax
    mov es, ax

    ; Langsung masuk ke Desktop GUI saat boot
    call enter_gui

; ====================================================================
; SISTEM MANAJEMEN EVENT DESKTOP GUI
; ====================================================================
enter_gui:
    call set_mode_13h
    mov byte [current_app], 1   ; Default buka Kalkulator
    call refresh_gui

gui_event_loop:
    ; Tunggu input tombol keyboard
    mov ah, 0x00
    int 0x16

    ; Periksa tombol
    cmp al, '1'
    je .open_calc
    cmp al, '2'
    je .open_note
    cmp al, '3'
    je .open_info
    cmp al, '4'
    je .open_paint
    cmp al, '5'
    je .open_cli

    ; Tombol ESC / '0' untuk tutup jendela (hanya desktop)
    cmp al, 27
    je .close_app
    cmp al, '0'
    je .close_app

    ; Tombol q / shutdown
    cmp al, 'q'
    je do_shutdown

    jmp gui_event_loop

.open_calc:
    mov byte [current_app], 1
    call refresh_gui
    jmp gui_event_loop

.open_note:
    mov byte [current_app], 2
    call refresh_gui
    jmp gui_event_loop

.open_info:
    mov byte [current_app], 3
    call refresh_gui
    jmp gui_event_loop

.open_paint:
    mov byte [current_app], 4
    call refresh_gui
    jmp gui_event_loop

.close_app:
    mov byte [current_app], 0
    call refresh_gui
    jmp gui_event_loop

.open_cli:
    call set_mode_text
    jmp cli_start

refresh_gui:
    pusha
    call draw_desktop

    mov al, [current_app]
    cmp al, 1
    je .show_calc
    cmp al, 2
    je .show_note
    cmp al, 3
    je .show_info
    cmp al, 4
    je .show_paint
    jmp .done

.show_calc:
    call show_app_calc
    jmp .done

.show_note:
    call show_app_note
    jmp .done

.show_info:
    call show_app_info
    jmp .done

.show_paint:
    call show_app_paint
    jmp .done

.done:
    popa
    ret

current_app: db 1

; ====================================================================
; SUBSISTEM CLI SHELL (TEKS MODE 80x25)
; ====================================================================
cli_start:
    call clear_screen

    ; Tampilkan Banner & Selamat Datang
    mov si, banner_text
    call print_string

shell_loop:
    mov si, prompt_text
    call print_string

    mov di, cmd_buffer
    call read_line

    call execute_command
    jmp shell_loop

execute_command:
    cmp byte [cmd_buffer], 0
    je .done

    ; Cek 'gui' untuk kembali ke Desktop
    mov si, cmd_buffer
    mov di, cmd_gui
    call str_equal
    je enter_gui

    ; Cek 'help'
    mov si, cmd_buffer
    mov di, cmd_help
    call str_equal
    je do_help

    ; Cek 'about'
    mov si, cmd_buffer
    mov di, cmd_about
    call str_equal
    je do_about

    ; Cek 'clear'
    mov si, cmd_buffer
    mov di, cmd_clear
    call str_equal
    je do_clear

    ; Cek 'time'
    mov si, cmd_buffer
    mov di, cmd_time
    call str_equal
    je do_time

    ; Cek 'date'
    mov si, cmd_buffer
    mov di, cmd_date
    call str_equal
    je do_date

    ; Cek 'beep'
    mov si, cmd_buffer
    mov di, cmd_beep
    call str_equal
    je do_beep

    ; Cek 'reboot'
    mov si, cmd_buffer
    mov di, cmd_reboot
    call str_equal
    je do_reboot

    ; Cek 'shutdown'
    mov si, cmd_buffer
    mov di, cmd_shutdown
    call str_equal
    je do_shutdown

    ; Cek prefix 'echo '
    mov si, cmd_buffer
    mov di, cmd_echo_prefix
    call str_starts_with
    je do_echo

    ; Cek 'echo'
    mov si, cmd_buffer
    mov di, cmd_echo
    call str_equal
    je do_echo_empty

    ; Perintah tidak dikenali
    mov si, msg_unknown
    call print_string
    mov si, cmd_buffer
    call print_string
    mov si, msg_unknown_end
    call print_string

.done:
    ret

; ====================================================================
; HANDLER PERINTAH CLI
; ====================================================================
do_help:
    mov si, msg_help
    call print_string
    ret

do_about:
    mov si, msg_about_head
    call print_string

    clc
    int 0x12
    push ax
    mov si, msg_about_ram
    call print_string
    pop ax
    call print_dec
    mov si, msg_about_ram_kb
    call print_string

    mov si, msg_about_tail
    call print_string
    ret

do_clear:
    call clear_screen
    ret

do_time:
    mov ah, 0x02
    int 0x1a
    jc .err

    mov si, msg_time_prefix
    call print_string

    mov al, ch
    call print_bcd
    mov al, ':'
    call print_char
    mov al, cl
    call print_bcd
    mov al, ':'
    call print_char
    mov al, dh
    call print_bcd

    call print_newline
    ret

.err:
    mov si, msg_rtc_err
    call print_string
    ret

do_date:
    mov ah, 0x04
    int 0x1a
    jc .err

    mov si, msg_date_prefix
    call print_string

    mov al, ch
    call print_bcd
    mov al, cl
    call print_bcd
    mov al, '-'
    call print_char
    mov al, dh
    call print_bcd
    mov al, '-'
    call print_char
    mov al, dl
    call print_bcd

    call print_newline
    ret

.err:
    mov si, msg_rtc_err
    call print_string
    ret

do_beep:
    mov si, msg_beep
    call print_string

    mov al, 0xB6
    out 0x43, al
    mov ax, 1193
    out 0x42, al
    mov al, ah
    out 0x42, al

    in al, 0x61
    or al, 3
    out 0x61, al

    mov ah, 0x86
    mov cx, 0x0003
    mov dx, 0xD090
    int 0x15

    in al, 0x61
    and al, 0xFC
    out 0x61, al
    ret

do_echo:
    mov si, cmd_buffer + 5
    call print_string
    call print_newline
    ret

do_echo_empty:
    call print_newline
    ret

do_reboot:
    mov si, msg_reboot
    call print_string
    int 0x19
    ret

do_shutdown:
    mov si, msg_shutdown
    call print_string

    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax

    mov ax, 0x5301
    xor bx, bx
    int 0x15
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

    cli
.hlt_loop:
    hlt
    jmp .hlt_loop

; ====================================================================
; ROUTINES BANTUAN CLI
; ====================================================================
clear_screen:
    mov ah, 0x06
    xor al, al
    mov bh, 0x0F
    xor cx, cx
    mov dx, 0x184F
    int 0x10

    mov ah, 0x02
    xor bh, bh
    xor dx, dx
    int 0x10
    ret

read_line:
    xor cx, cx
.loop:
    mov ah, 0x00
    int 0x16

    cmp al, 13
    je .done

    cmp al, 8
    je .backspace

    cmp al, 32
    jb .loop

    cmp cx, 60
    jae .loop

    stosb
    inc cx
    call print_char
    jmp .loop

.backspace:
    jcxz .loop
    dec di
    dec cx
    mov al, 8
    call print_char
    mov al, ' '
    call print_char
    mov al, 8
    call print_char
    jmp .loop

.done:
    xor al, al
    stosb
    call print_newline
    ret

print_string:
    lodsb
    or al, al
    jz .done
    call print_char
    jmp print_string
.done:
    ret

print_char:
    mov ah, 0x0E
    mov bx, 0x000F
    int 0x10
    ret

print_newline:
    mov al, 13
    call print_char
    mov al, 10
    call print_char
    ret

print_bcd:
    push ax
    shr al, 4
    add al, '0'
    call print_char
    pop ax
    and al, 0x0F
    add al, '0'
    call print_char
    ret

print_dec:
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
.div_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .div_loop
.print_loop:
    pop ax
    add al, '0'
    call print_char
    loop .print_loop
    pop dx
    pop cx
    pop bx
    ret

str_equal:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    or al, al
    jz .equal
    inc si
    inc di
    jmp .loop
.equal:
    xor ax, ax
    ret
.not_equal:
    or ax, 1
    ret

str_starts_with:
.loop:
    mov bl, [di]
    or bl, bl
    jz .match
    mov al, [si]
    cmp al, bl
    jne .no_match
    inc si
    inc di
    jmp .loop
.match:
    xor ax, ax
    ret
.no_match:
    or ax, 1
    ret

; ====================================================================
; DATA STRINGS CLI
; ====================================================================
banner_text:
    db "=============================================================================", 13, 10
    db "  ____  _                      ___  ____  ", 13, 10
    db " |  _ \(_)_ __   __ _  __ _ _ / _ \/ ___|    RinganOS v2.0 (GUI & CLI)", 13, 10
    db " | |_) | | '_ \ / _` |/ _` | | | | \___ \    Sistem Super Ringan (~5.5 KB)", 13, 10
    db " |  _ <| | | | | (_| | (_| | | |_| |___) |   Mode: x86 16-Bit Real Mode", 13, 10
    db " |_| \_\_|_| |_|\__,_|\__,_|_|\___/|____/    Ketik 'gui' untuk kembali ke Desktop!", 13, 10
    db "=============================================================================", 13, 10
    db " Ketik 'help' untuk melihat daftar perintah yang tersedia.", 13, 10, 13, 10, 0

prompt_text:        db "RinganOS> ", 0

cmd_gui:            db "gui", 0
cmd_help:           db "help", 0
cmd_about:          db "about", 0
cmd_clear:          db "clear", 0
cmd_time:           db "time", 0
cmd_date:           db "date", 0
cmd_beep:           db "beep", 0
cmd_reboot:         db "reboot", 0
cmd_shutdown:       db "shutdown", 0
cmd_echo_prefix:    db "echo ", 0
cmd_echo:           db "echo", 0

msg_help:
    db "Daftar Perintah Tersedia di RinganOS:", 13, 10
    db "  gui         - Kembali ke antarmuka grafis (Desktop GUI)", 13, 10
    db "  help        - Menampilkan menu bantuan ini", 13, 10
    db "  about       - Menampilkan informasi sistem dan memori RAM", 13, 10
    db "  time        - Menampilkan waktu saat ini (RTC clock)", 13, 10
    db "  date        - Menampilkan tanggal saat ini (RTC date)", 13, 10
    db "  echo <teks> - Menampilkan kembali teks yang dimasukkan", 13, 10
    db "  beep        - Membunyikan suara speaker internal (PC speaker)", 13, 10
    db "  clear       - Membersihkan layar monitor", 13, 10
    db "  reboot      - Menyalakan ulang sistem (warm reboot)", 13, 10
    db "  shutdown    - Mematikan komputer virtual (power off)", 13, 10, 0

msg_about_head:
    db "--------------------------------------------------------", 13, 10
    db " [ INFORMASI SISTEM RINGANOS ]", 13, 10
    db " Nama OS         : RinganOS GUI Edition v2.0", 13, 10
    db " Total Size      : ~5.5 KB (Bootloader + Kernel + GUI + Apps)", 13, 10
    db " Mode Eksekusi   : x86 16-Bit Real Mode", 13, 10, 0

msg_about_ram:
    db " Konvensional RAM: ", 0

msg_about_ram_kb:
    db " KB terdeteksi oleh BIOS", 13, 10, 0

msg_about_tail:
    db " Author          : Antigravity AI & Pengguna", 13, 10
    db " Status          : Berjalan stabil di bare-metal & QEMU", 13, 10
    db "--------------------------------------------------------", 13, 10, 0

msg_time_prefix:    db "Waktu Sistem (RTC): ", 0
msg_date_prefix:    db "Tanggal Sistem (RTC): ", 0
msg_rtc_err:        db "Error: Jam RTC tidak merespons!", 13, 10, 0
msg_beep:           db "*BEEP!* Menyalakan PC speaker hardware...", 13, 10, 0
msg_reboot:         db "Melakukan restart sistem...", 13, 10, 0
msg_shutdown:       db "Mematikan sistem...", 13, 10, 0
msg_unknown:        db "Perintah '", 0
msg_unknown_end:    db "' tidak dikenal. Ketik 'help' untuk bantuan.", 13, 10, 0

cmd_buffer:         times 64 db 0

; ====================================================================
; INCLUDE MODUL GRAFIS & APLIKASI
; ====================================================================
%include "gui.asm"
%include "apps.asm"

; Padding kernel hingga tepat 16 sektor (8192 byte = 8 KB)
times 8192 - ($ - $$) db 0
