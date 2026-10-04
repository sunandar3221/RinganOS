[org 0x7c00]
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov [boot_drive], dl

    ; Baca 16 sektor (8 KB) kernel ke 0x1000:0000
    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    mov ah, 0x02
    mov al, 16              ; Baca 16 sektor (8 KB)
    mov ch, 0               ; Cylinder 0
    mov cl, 2               ; Sektor 2
    mov dh, 0               ; Head 0
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    jmp 0x1000:0000

disk_error:
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
.halt:
    hlt
    jmp .halt

boot_drive: db 0

times 510 - ($ - $$) db 0
dw 0xAA55
