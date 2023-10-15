; =====================================================
;
; MetalBIOS - Base Input-Output System for PK-88
;
; Written by Andrew Dunai <a@dun.ai>
; October 2023
;
; =====================================================

        cpu     8086
        bits    16

        %include "sys.inc"
        %include "ports.inc"

        extern equipment_list_init
        extern interrupt_init
        extern lcd_init
        extern uart_init
        extern uart_send

        ; org     ROM_SEG*16

        section .rodata

HELLO_S db      "Hello, KM1810VM88!", 0

        ; %include "lcd.asm"
        ; %include "interrupt.asm"

        section .text

init:
        ; Initialize segments
        mov     ax, STK_SEG
        mov     ss, ax
        mov     ax, STK_LEN
        mov     sp, ax

        mov     ax, ROM_SEG
        mov     ds, ax

        ; Initialize I/O
        mov     dx, IO_CTRL
        mov     al, 0b10000000
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
        out     dx, al

        call    equipment_list_init
        call    interrupt_init
        call    uart_init
        call    lcd_init

        ; Ready!

        sti

        ; Send stuff to UART
        mov     al, 0x20
.send:
        call    uart_send
        inc     al
        cmp     al, 0x7F
        jne     .send

        ; Print string
        mov     ax, ROM_SEG
        mov     es, ax
        mov     ah, 0x13
        mov     bp, HELLO_S
        int     0x10

;         xor     dx, dx
;         mov     ds, dx
; .again:
;         xor     ax, ax
;         in      al, dx
;         mov     bx, ax
;         mov     al, [ds:bx]
;         out     dx, al
;         jmp     .again

        hlt

;         ; Delay 65536 iterations (~557 (524?) ms)
;         ; (1 iteration takes ~8 us)
; delay:
;         inc cx
;         cmp cx, 0
;         jne delay



; times 0x10000-($-START)-16 \
;         db      0xAD

        section .reset
reset:
        jmp     ROM_SEG:init
        hlt

times 0x10-($-reset)-2 db 0xAD

        db      "AD"
