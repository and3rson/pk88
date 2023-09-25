        cpu 8086
        bits 16

        org 0xF0000

START   equ $
ROM_SEG equ 0xF000
STK_SEG equ 0x7800
STK_LEN equ 0x8000  ; 32 KB stack

init:
        mov ax, STK_SEG
        mov ss, ax
        mov ax, STK_LEN
        mov sp, ax
	mov ax, 0
        cli

@loop:
	inc ax
	jmp @loop

times 0x10000-($-START)-16 db 0xAD

        jmp ROM_SEG:init
