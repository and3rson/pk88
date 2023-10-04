; =====================================================
;
; MetalBIOS - Base Input-Output System for PK-88
;
; Written by Andrew Dunai <a@dun.ai>
; October 2023
;
; =====================================================

        cpu 8086
        bits 16

        %include "include/sys.inc"
        %include "include/ports.inc"

        org ROM_SEG*16

START   equ $

HELLO_S db "Hello, KM1810VM88!", 0

        %include "lcd.asm"
        %include "syscall.asm"

init:
        ; Initialize segments
        mov ax, STK_SEG
        mov ss, ax
        mov ax, STK_LEN
        mov sp, ax

        mov ax, ROM_SEG
        mov ds, ax

        ; Initialize I/O
        mov dx, IO_CTRL
        mov al, 0b10000000
        ; 1 0 0 0 0 0 0 0
        ; ^ ^ ^ ^ ^ ^ ^ ^
        ; | | | | | | | |
        ; | | | | | | | +-- 0: Port C (lower) is output
        ; | +++ | | | +--- 0: Port B is output
        ; |  |  | | +---- 0: Mode 0
        ; |  |  | +----- 0: Port C (upper) is output
        ; |  |  +------ 0: Port A is output
        ; |  +------- 00: Mode 0
        ; +---------- 1: Mode set flag
        out dx, al

        call syscall_init
        call lcd_init

        ; Ready!

        sti

        mov ah, 0x01
        mov si, HELLO_S
        int 0x50
        hlt

;         ; Delay 65536 iterations (~557 (524?) ms)
;         ; (1 iteration takes ~8 us)
; delay:
;         inc cx
;         cmp cx, 0
;         jne delay



times 0x10000-($-START)-16 db 0xAD

reset:
        jmp ROM_SEG:init
        hlt

times 0x10000-($-START)-2 db 0xAD

        db "AD"
