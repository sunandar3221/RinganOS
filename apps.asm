[bits 16]

; ====================================================================
; APLIKASI BAWAAN DAN DESKTOP GUI RINGANOS
; ====================================================================

; Gambar Desktop Utama RinganOS
draw_desktop:
    pusha

    ; 1. Latar Belakang Desktop: Biru Klasik (Warna 1)
    xor ax, ax
    xor bx, bx
    mov si, 320
    mov bp, 200
    mov dl, 1               ; Navy Blue
    call draw_rect

    ; 2. Top Bar (Status Bar Atas: Y=0..13)
    xor ax, ax
    xor bx, bx
    mov si, 320
    mov bp, 13
    mov dl, 7               ; Abu-abu muda
    call draw_rect

    ; Garis pembatas bawah top bar
    mov bx, 13
    mov dl, 8               ; Abu-abu gelap
    call draw_hline

    ; Teks Menu di Top Bar
    mov ax, 4
    mov bx, 3
    mov si, str_top_title
    mov ch, 0               ; Teks hitam
    mov dl, 0xFF            ; Transparan
    call draw_text_pixel

    ; Jam RTC di pojok kanan Top Bar
    call draw_top_clock

    ; 3. Bottom Taskbar / App Dock (Y=184..199)
    xor ax, ax
    mov bx, 184
    mov si, 320
    mov bp, 16
    mov dl, 7               ; Abu-abu
    call draw_rect

    ; Garis terang atas taskbar (3D)
    mov bx, 184
    mov dl, 15
    call draw_hline

    ; Tombol-tombol aplikasi di Taskbar:
    ; Tombol 1: [1:Calc]
    mov ax, 3
    mov bx, 186
    mov si, 58
    mov bp, 12
    mov di, str_btn_calc
    mov dl, 7
    call draw_button

    ; Tombol 2: [2:Note]
    mov ax, 65
    mov bx, 186
    mov si, 58
    mov bp, 12
    mov di, str_btn_note
    mov dl, 7
    call draw_button

    ; Tombol 3: [3:Info]
    mov ax, 127
    mov bx, 186
    mov si, 58
    mov bp, 12
    mov di, str_btn_info
    mov dl, 7
    call draw_button

    ; Tombol 4: [4:Paint]
    mov ax, 189
    mov bx, 186
    mov si, 60
    mov bp, 12
    mov di, str_btn_paint
    mov dl, 7
    call draw_button

    ; Tombol 5: [5:CLI]
    mov ax, 253
    mov bx, 186
    mov si, 64
    mov bp, 12
    mov di, str_btn_cli
    mov dl, 7
    call draw_button

    ; 4. Ikon-ikon Desktop di sebelah kiri
    call draw_desktop_icons

    popa
    ret

draw_desktop_icons:
    pusha
    ; Ikon 1: Kalkulator (X=14, Y=22)
    mov ax, 14
    mov bx, 22
    mov si, 24
    mov bp, 22
    mov dl, 7               ; Abu-abu
    call draw_rect
    mov dl, 15
    call draw_hline
    call draw_vline
    mov ax, 17
    mov bx, 25
    mov si, 18
    mov bp, 16
    mov dl, 9               ; Light Blue
    call draw_rect

    mov ax, 10
    mov bx, 46
    mov si, str_icon_calc
    mov ch, 15              ; Teks putih
    mov dl, 0xFF
    call draw_text_pixel

    ; Ikon 2: Catatan (X=14, Y=60)
    mov ax, 14
    mov bx, 60
    mov si, 24
    mov bp, 22
    mov dl, 15              ; Putih
    call draw_rect
    mov ax, 17
    mov bx, 63
    mov si, 18
    mov bp, 16
    mov dl, 7
    call draw_rect

    mov ax, 10
    mov bx, 84
    mov si, str_icon_note
    mov ch, 15
    mov dl, 0xFF
    call draw_text_pixel

    ; Ikon 3: Info Sistem (X=14, Y=98)
    mov ax, 14
    mov bx, 98
    mov si, 24
    mov bp, 22
    mov dl, 2               ; Hijau
    call draw_rect
    mov ax, 17
    mov bx, 101
    mov si, 18
    mov bp, 16
    mov dl, 10
    call draw_rect

    mov ax, 10
    mov bx, 122
    mov si, str_icon_info
    mov ch, 15
    mov dl, 0xFF
    call draw_text_pixel

    ; Ikon 4: Paint (X=14, Y=136)
    mov ax, 14
    mov bx, 136
    mov si, 24
    mov bp, 22
    mov dl, 4               ; Merah
    call draw_rect
    mov ax, 17
    mov bx, 139
    mov si, 18
    mov bp, 16
    mov dl, 14              ; Kuning
    call draw_rect

    mov ax, 8
    mov bx, 160
    mov si, str_icon_paint
    mov ch, 15
    mov dl, 0xFF
    call draw_text_pixel

    popa
    ret

draw_top_clock:
    pusha
    ; Baca RTC time (CH=jam, CL=menit, DH=detik)
    mov ah, 0x02
    int 0x1a
    jc .done

    mov [cs:clk_ch], ch
    mov [cs:clk_cl], cl

    ; Cetak jam di X=240, Y=3
    mov ax, 240
    mov bx, 3
    mov si, str_clock_prefix
    mov ch, 0               ; Hitam
    mov dl, 0xFF
    call draw_text_pixel

    ; Digit Jam 1
    mov ax, 256
    mov bx, 3
    mov cl, [cs:clk_ch]
    shr cl, 4
    add cl, '0'
    mov ch, 0
    mov dl, 0xFF
    call draw_char_pixel

    ; Digit Jam 2
    mov ax, 264
    mov bx, 3
    mov cl, [cs:clk_ch]
    and cl, 0x0F
    add cl, '0'
    mov ch, 0
    mov dl, 0xFF
    call draw_char_pixel

    ; Separator ':'
    mov ax, 272
    mov bx, 3
    mov cl, ':'
    mov ch, 0
    mov dl, 0xFF
    call draw_char_pixel

    ; Digit Menit 1
    mov ax, 280
    mov bx, 3
    mov cl, [cs:clk_cl]
    shr cl, 4
    add cl, '0'
    mov ch, 0
    mov dl, 0xFF
    call draw_char_pixel

    ; Digit Menit 2
    mov ax, 288
    mov bx, 3
    mov cl, [cs:clk_cl]
    and cl, 0x0F
    add cl, '0'
    mov ch, 0
    mov dl, 0xFF
    call draw_char_pixel

    ; Suffix ']'
    mov ax, 296
    mov bx, 3
    mov cl, ']'
    mov ch, 0
    mov dl, 0xFF
    call draw_char_pixel

.done:
    popa
    ret

clk_ch: db 0
clk_cl: db 0

; ====================================================================
; APLIKASI 1: KALKULATOR
; ====================================================================
show_app_calc:
    pusha
    ; Jendela Kalkulator
    mov ax, 65
    mov bx, 22
    mov si, 190
    mov bp, 145
    mov di, str_title_calc
    call draw_window

    ; Layar LCD Putih
    mov ax, 75
    mov bx, 42
    mov si, 170
    mov bp, 26
    mov dl, 15              ; Putih
    call draw_rect
    mov dl, 0               ; Border hitam
    call draw_hline
    call draw_vline

    ; Teks pada layar LCD
    mov ax, 82
    mov bx, 45
    mov si, str_calc_disp1
    mov ch, 0               ; Hitam
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 82
    mov bx, 56
    mov si, str_calc_disp2
    mov ch, 1               ; Biru
    mov dl, 0xFF
    call draw_text_pixel

    ; Tombol-tombol Kalkulator
    call draw_calc_buttons

    popa
    ret

draw_calc_buttons:
    pusha
    ; Baris 1: 7, 8, 9, /
    mov bx, 74
    mov bp, 14
    mov si, 36

    mov ax, 78
    mov di, str_c7
    mov dl, 7
    call draw_button

    mov ax, 120
    mov di, str_c8
    mov dl, 7
    call draw_button

    mov ax, 162
    mov di, str_c9
    mov dl, 7
    call draw_button

    mov ax, 204
    mov di, str_cdiv
    mov dl, 14              ; Kuning
    call draw_button

    ; Baris 2: 4, 5, 6, *
    mov bx, 92
    mov ax, 78
    mov di, str_c4
    mov dl, 7
    call draw_button

    mov ax, 120
    mov di, str_c5
    mov dl, 7
    call draw_button

    mov ax, 162
    mov di, str_c6
    mov dl, 7
    call draw_button

    mov ax, 204
    mov di, str_cmul
    mov dl, 14
    call draw_button

    ; Baris 3: 1, 2, 3, -
    mov bx, 110
    mov ax, 78
    mov di, str_c1
    mov dl, 7
    call draw_button

    mov ax, 120
    mov di, str_c2
    mov dl, 7
    call draw_button

    mov ax, 162
    mov di, str_c3
    mov dl, 7
    call draw_button

    mov ax, 204
    mov di, str_csub
    mov dl, 14
    call draw_button

    ; Baris 4: C, 0, =, +
    mov bx, 128
    mov ax, 78
    mov di, str_cc
    mov dl, 12              ; Merah muda
    call draw_button

    mov ax, 120
    mov di, str_c0
    mov dl, 7
    call draw_button

    mov ax, 162
    mov di, str_ceq
    mov dl, 10              ; Hijau muda
    call draw_button

    mov ax, 204
    mov di, str_cadd
    mov dl, 14
    call draw_button

    popa
    ret

; ====================================================================
; APLIKASI 2: CATATAN (NOTEPAD)
; ====================================================================
show_app_note:
    pusha
    mov ax, 55
    mov bx, 20
    mov si, 250
    mov bp, 150
    mov di, str_title_note
    call draw_window

    ; Lembar kertas putih
    mov ax, 65
    mov bx, 40
    mov si, 230
    mov bp, 120
    mov dl, 15              ; Putih
    call draw_rect
    mov dl, 8               ; Border abu-abu
    call draw_hline
    call draw_vline

    ; Teks catatan
    mov ax, 72
    mov bx, 45
    mov si, str_note_l1
    mov ch, 1               ; Biru
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 55
    mov si, str_note_div
    mov ch, 7               ; Abu-abu
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 67
    mov si, str_note_l2
    mov ch, 0               ; Hitam
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 81
    mov si, str_note_l3
    mov ch, 0
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 95
    mov si, str_note_l4
    mov ch, 2               ; Hijau
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 109
    mov si, str_note_l5
    mov ch, 0
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 125
    mov si, str_note_l6
    mov ch, 4               ; Merah
    mov dl, 0xFF
    call draw_text_pixel

    popa
    ret

; ====================================================================
; APLIKASI 3: INFORMASI SISTEM
; ====================================================================
show_app_info:
    pusha
    mov ax, 55
    mov bx, 22
    mov si, 245
    mov bp, 145
    mov di, str_title_info
    call draw_window

    ; Kotak panel putih
    mov ax, 65
    mov bx, 42
    mov si, 225
    mov bp, 115
    mov dl, 15
    call draw_rect
    mov dl, 8
    call draw_hline
    call draw_vline

    ; Detail Info
    mov ax, 72
    mov bx, 47
    mov si, str_info_name
    mov ch, 1               ; Biru
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 57
    mov si, str_info_div
    mov ch, 7
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 69
    mov si, str_info_mode
    mov ch, 0
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 83
    mov si, str_info_size
    mov ch, 2               ; Hijau
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 97
    mov si, str_info_arch
    mov ch, 0
    mov dl, 0xFF
    call draw_text_pixel

    ; Memori RAM konvensional dari BIOS INT 12h
    mov ax, 72
    mov bx, 111
    mov si, str_info_ram
    mov ch, 4               ; Merah
    mov dl, 0xFF
    call draw_text_pixel

    ; Baca RAM via INT 12h (mengembalikan KB di AX)
    clc
    int 0x12
    mov dx, ax              ; DX = nilai RAM dalam KB
    mov ax, 120             ; Posisi X
    mov bx, 111             ; Posisi Y
    call draw_gui_dec

    mov ax, 150
    mov bx, 111
    mov si, str_info_kb
    mov ch, 4
    mov dl, 0xFF
    call draw_text_pixel

    mov ax, 72
    mov bx, 127
    mov si, str_info_status
    mov ch, 1
    mov dl, 0xFF
    call draw_text_pixel

    popa
    ret

; Cetak angka desimal di DX pada koordinat (AX, BX)
draw_gui_dec:
    pusha
    mov [cs:dec_x], ax
    mov [cs:dec_y], bx

    mov ax, dx              ; AX = angka
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
    pop dx
    push cx
    mov cl, dl
    add cl, '0'
    mov ax, [cs:dec_x]
    mov bx, [cs:dec_y]
    mov ch, 4               ; Warna merah
    mov dl, 0xFF
    call draw_char_pixel
    add word [cs:dec_x], 8
    pop cx
    loop .print_loop

    popa
    ret

dec_x: dw 0
dec_y: dw 0

; ====================================================================
; APLIKASI 4: MINI PAINT (KANVAS GAMBAR)
; ====================================================================
show_app_paint:
    pusha
    mov ax, 50
    mov bx, 18
    mov si, 255
    mov bp, 155
    mov di, str_title_paint
    call draw_window

    ; Kanvas Gambar Putih
    mov ax, 60
    mov bx, 38
    mov si, 235
    mov bp, 108
    mov dl, 15              ; Putih
    call draw_rect
    mov dl, 0               ; Border hitam
    call draw_hline
    call draw_vline

    ; Gambar Karya Seni Mini (Rumah, Matahari, Pohon)
    ; Badan Rumah (Biru)
    mov ax, 110
    mov bx, 65
    mov si, 46
    mov bp, 42
    mov dl, 9
    call draw_rect

    ; Atap Rumah (Merah)
    mov ax, 104
    mov bx, 52
    mov si, 58
    mov bp, 13
    mov dl, 12
    call draw_rect

    ; Jendela Rumah (Putih & Biru)
    mov ax, 116
    mov bx, 72
    mov si, 12
    mov bp, 12
    mov dl, 15
    call draw_rect

    ; Pintu Rumah (Kuning)
    mov ax, 136
    mov bx, 82
    mov si, 14
    mov bp, 25
    mov dl, 14
    call draw_rect

    ; Batang Pohon (Cokelat)
    mov ax, 185
    mov bx, 80
    mov si, 10
    mov bp, 27
    mov dl, 6
    call draw_rect

    ; Daun Pohon (Hijau)
    mov ax, 172
    mov bx, 55
    mov si, 36
    mov bp, 28
    mov dl, 10
    call draw_rect

    ; Matahari (Kuning Cerah)
    mov ax, 235
    mov bx, 44
    mov si, 22
    mov bp, 22
    mov dl, 14
    call draw_rect

    ; Palet warna di bawah kanvas
    call draw_paint_palette

    popa
    ret

draw_paint_palette:
    pusha
    mov bx, 152
    mov bp, 12
    mov si, 16

    mov ax, 65
    mov dl, 4               ; Red
    call draw_rect
    mov ax, 85
    mov dl, 2               ; Green
    call draw_rect
    mov ax, 105
    mov dl, 1               ; Blue
    call draw_rect
    mov ax, 125
    mov dl, 14              ; Yellow
    call draw_rect
    mov ax, 145
    mov dl, 3               ; Cyan
    call draw_rect
    mov ax, 165
    mov dl, 5               ; Magenta
    call draw_rect
    mov ax, 185
    mov dl, 0               ; Black
    call draw_rect
    mov ax, 205
    mov dl, 15              ; White
    call draw_rect

    mov ax, 228
    mov bx, 154
    mov si, str_palette_label
    mov ch, 0
    mov dl, 0xFF
    call draw_text_pixel

    popa
    ret

; ====================================================================
; DATA STRINGS
; ====================================================================
str_top_title:      db "[RinganOS v2.0 GUI Desktop]", 0
str_clock_prefix:   db "[ ", 0

str_btn_calc:       db "1:Calc", 0
str_btn_note:       db "2:Note", 0
str_btn_info:       db "3:Info", 0
str_btn_paint:      db "4:Paint", 0
str_btn_cli:        db "5:CLI", 0

str_icon_calc:      db "Calc", 0
str_icon_note:      db "Note", 0
str_icon_info:      db "Info", 0
str_icon_paint:     db "Paint", 0

; Window Titles
str_title_calc:     db "Kalkulator Ringan", 0
str_title_note:     db "Catatan RinganOS", 0
str_title_info:     db "Informasi Sistem", 0
str_title_paint:    db "Ringan Paint", 0

; Calc strings
str_calc_disp1:     db "128 + 256", 0
str_calc_disp2:     db "= 384", 0
str_c7: db " 7 ", 0
str_c8: db " 8 ", 0
str_c9: db " 9 ", 0
str_cdiv: db " / ", 0
str_c4: db " 4 ", 0
str_c5: db " 5 ", 0
str_c6: db " 6 ", 0
str_cmul: db " * ", 0
str_c1: db " 1 ", 0
str_c2: db " 2 ", 0
str_c3: db " 3 ", 0
str_csub: db " - ", 0
str_cc: db " C ", 0
str_c0: db " 0 ", 0
str_ceq: db " = ", 0
str_cadd: db " + ", 0

; Note strings
str_note_l1:        db "RinganOS Text Editor v1.0", 0
str_note_div:       db "------------------------------", 0
str_note_l2:        db "* Sistem Operasi x86 16-Bit", 0
str_note_l3:        db "* VGA Mode 13h (320x200 256c)", 0
str_note_l4:        db "* Ukuran total hanya ~8.5 KB!", 0
str_note_l5:        db "* GUI + Desktop + 4 Aplikasi", 0
str_note_l6:        db "* Sangat hemat memori & cepat!", 0

; Info strings
str_info_name:      db "RinganOS GUI Edition v2.0", 0
str_info_div:       db "------------------------------", 0
str_info_mode:      db "Layar : 320x200 (Mode 13h)", 0
str_info_size:      db "Ukuran: 8.5 KB Total Image", 0
str_info_arch:      db "Arch  : x86 Real Mode", 0
str_info_ram:       db "RAM   : ", 0
str_info_kb:        db " KB terdeteksi", 0
str_info_status:    db "Status: Berjalan normal", 0

; Paint strings
str_palette_label:  db "Palet", 0
