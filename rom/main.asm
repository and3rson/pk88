        cpu 8086
        bits 16

START   equ $
ROM_SEG equ 0xF000
STK_SEG equ 0x7800
STK_LEN equ 0x8000  ; 32 KB stack

        org ROM_SEG*16

init:
        mov ax, STK_SEG
        mov ss, ax
        mov ax, STK_LEN
        mov sp, ax
	mov ax, 0
        sti

endless:
	inc ax
	jmp endless

times 0x10000-($-START)-16 db 0xAD

reset:
        jmp ROM_SEG:init
        hlt

times 0x10000-($-START)-2 db 0xAD

        db "AD"
