[bits 16]

; ====================================================================
; ROUTINE GRAFIS VGA MODE 13h (320x200, 256 Warna)
; ====================================================================

font_seg:   dw 0
font_off:   dw 0
char_cur_x: dw 0
char_cur_y: dw 0
char_fg:    db 0
char_bg:    db 0

text_x:     dw 0
text_y:     dw 0

; Inisialisasi Mode Grafis 13h dan Font ROM BIOS
set_mode_13h:
    push ax
    push bx
    push es
    push bp

    ; Set Mode 13h (320x200, 256 warna)
    mov ax, 0x0013
    int 0x10

    ; Ambil pointer font 8x8 dari BIOS ROM
    mov ax, 0x1130
    mov bh, 0x03            ; 8x8 ROM font
    int 0x10
    mov [cs:font_seg], es
    mov [cs:font_off], bp

    pop bp
    pop es
    pop bx
    pop ax
    ret

; Set video mode kembali ke Mode 03h (80x25 Teks)
set_mode_text:
    mov ax, 0x0003
    int 0x10
    ret

; Gambar persegi terisi:
; Input:
;   AX = X (0..319)
;   BX = Y (0..199)
;   SI = Width
;   BP = Height
;   DL = Warna (0..255)
draw_rect:
    push es
    push ds
    pusha

    mov cx, 0xA000
    mov es, cx

    push ax                 ; Simpan X original di stack [esp]

.row_loop:
    cmp bp, 0
    jle .done

    ; Offset = Y * 320 + X = (Y * 256) + (Y * 64) + X
    mov di, bx
    shl di, 8               ; Y * 256
    mov cx, bx
    shl cx, 6               ; Y * 64
    add di, cx
    add di, [esp]           ; + X original

    mov cx, si              ; Lebar baris
    mov al, dl              ; Warna
    rep stosb

    inc bx                  ; Y++
    dec bp                  ; Height--
    jmp .row_loop

.done:
    pop ax                  ; Hapus saved X
    popa
    pop ds
    pop es
    ret

; Gambar garis horizontal: AX=X, BX=Y, SI=Width, DL=Warna
draw_hline:
    push bp
    mov bp, 1
    call draw_rect
    pop bp
    ret

; Gambar garis vertikal: AX=X, BX=Y, BP=Height, DL=Warna
draw_vline:
    push si
    mov si, 1
    call draw_rect
    pop si
    ret

; Cetak satu karakter pada koordinat piksel (AX=X, BX=Y)
; Input:
;   AX = X (0..312)
;   BX = Y (0..192)
;   CL = Karakter ASCII
;   CH = Warna foreground
;   DL = Warna background (0xFF untuk transparan)
draw_char_pixel:
    pusha
    push ds
    push es

    ; Simpan parameter ke variabel dengan CS override
    mov [cs:char_cur_x], ax
    mov [cs:char_cur_y], bx
    mov [cs:char_fg], ch
    mov [cs:char_bg], dl

    ; Baca font_off dan font_seg
    mov si, [cs:font_off]
    mov ds, [cs:font_seg]
    xor ah, ah
    mov al, cl
    shl ax, 3               ; Karakter * 8 byte
    add si, ax

    mov ax, 0xA000
    mov es, ax

    mov bx, [cs:char_cur_y]
    mov bp, 8               ; 8 baris font
.row_loop:
    lodsb                   ; AL = bitmap baris ini (8 bit)
    mov dl, al              ; DL = bit mask

    ; Hitung offset layar di ES:DI
    mov di, bx
    shl di, 8               ; Y * 256
    mov ax, bx
    shl ax, 6               ; Y * 64
    add di, ax
    add di, [cs:char_cur_x]

    mov cx, 8               ; 8 pixel
.bit_loop:
    test dl, 0x80
    jz .bg_pixel
    mov al, [cs:char_fg]    ; Warna teks murni!
    mov [es:di], al
    jmp .next_bit

.bg_pixel:
    cmp byte [cs:char_bg], 0xFF
    je .next_bit
    mov al, [cs:char_bg]
    mov [es:di], al

.next_bit:
    inc di
    shl dl, 1
    loop .bit_loop

    inc bx                  ; Y++
    dec bp                  ; Baris font--
    jnz .row_loop

    pop es
    pop ds
    popa
    ret

; Cetak teks string null-terminated pada koordinat piksel (AX=X, BX=Y)
; Input:
;   AX = X (0..312)
;   BX = Y (0..192)
;   SI = Pointer string null-terminated
;   CH = Warna foreground
;   DL = Warna background (0xFF = transparan)
draw_text_pixel:
    pusha
    mov [cs:text_x], ax
    mov [cs:text_y], bx
.str_loop:
    mov al, [si]
    inc si
    or al, al
    jz .str_done

    mov cl, al              ; CL = Karakter
    mov ax, [cs:text_x]
    mov bx, [cs:text_y]
    call draw_char_pixel

    add word [cs:text_x], 8 ; Geser X sebesar 8 pixel
    jmp .str_loop
.str_done:
    popa
    ret

; Gambar Jendela (Window) bergaya klasik 3D:
; Input:
;   AX = X, BX = Y, SI = Width, BP = Height
;   DI = Pointer string judul jendela
draw_window:
    pusha

    ; 1. Bayangan jendela (Drop Shadow)
    push ax
    push bx
    push si
    push bp
    add ax, 4
    add bx, 4
    mov dl, 8               ; Dark gray shadow
    call draw_rect
    pop bp
    pop si
    pop bx
    pop ax

    ; 2. Background bodi jendela (Abu-abu muda: 7)
    mov dl, 7
    call draw_rect

    ; 3. Border 3D:
    ; Garis putih atas dan kiri (Warna 15)
    mov dl, 15
    call draw_hline
    call draw_vline

    ; Garis abu-abu gelap bawah dan kanan (Warna 8)
    push ax
    push bx
    add bx, bp
    dec bx
    mov dl, 8
    call draw_hline         ; Bawah
    pop bx
    pop ax

    push ax
    add ax, si
    dec ax
    mov dl, 8
    call draw_vline         ; Kanan
    pop ax

    ; 4. Title Bar (Biru klasik: Warna 1)
    push ax
    push bx
    push si
    push bp
    add ax, 3
    add bx, 3
    sub si, 6
    mov bp, 12
    mov dl, 1               ; Biru tua
    call draw_rect

    ; Tombol Tutup [X] di pojok kanan title bar
    add ax, si
    sub ax, 12
    mov si, 11
    mov bp, 11
    mov dl, 12              ; Merah
    call draw_rect

    ; Cetak 'X' pada tombol tutup
    push ax
    push bx
    add ax, 2
    add bx, 2
    mov si, str_close_x
    mov ch, 15              ; Putih
    mov dl, 0xFF            ; Transparan
    call draw_text_pixel
    pop bx
    pop ax

    pop bp
    pop si
    pop bx
    pop ax

    ; 5. Cetak Judul Jendela (Teks Putih di Title Bar)
    push ax
    push bx
    add ax, 6
    add bx, 5
    mov si, di              ; Pointer judul
    mov ch, 15              ; Putih
    mov dl, 0xFF            ; Transparan
    call draw_text_pixel
    pop bx
    pop ax

    popa
    ret

; Gambar Tombol 3D:
; Input: AX = X, BX = Y, SI = Width, BP = Height, DI = Teks label, DL = Warna body
draw_button:
    pusha
    push dx
    call draw_rect          ; Body
    pop dx

    ; Garis terang atas & kiri (Warna 15)
    mov dl, 15
    call draw_hline
    call draw_vline

    ; Garis gelap bawah & kanan (Warna 8)
    push ax
    push bx
    add bx, bp
    dec bx
    mov dl, 8
    call draw_hline
    pop bx
    pop ax

    push ax
    add ax, si
    dec ax
    mov dl, 8
    call draw_vline
    pop ax

    ; Label teks tombol
    cmp di, 0
    je .done_label

    push ax
    push bx
    add ax, 4
    add bx, 3
    mov si, di
    mov ch, 0               ; Teks hitam
    mov dl, 0xFF            ; Transparan
    call draw_text_pixel
    pop bx
    pop ax

.done_label:
    popa
    ret

str_close_x: db "x", 0
