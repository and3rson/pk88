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
        %include "bda.inc"

        extern lcd_init
        extern lcd_printstr
        extern lcd_printbyte
        extern lcd_printword
        extern lcd_printchar
        extern lcd_printm
        extern memtest
        extern equipment_list_init
        extern interrupt_init
        extern uart_init
        extern uart_send
        extern pit_init
        extern ppi_init
        extern keyboard_init
        extern sdc_init
        extern sdc_read_single_block
        extern sdc_write_single_block

        ; org     ROM_SEG*16

        section .rodata

type    HELLO_S object
HELLO_S         db      "               ",0x80," œK-88 ", 0x80, 13, 10, 0
type    MEMTEST_S object
MEMTEST_S       db      "œÂÂ‚≥Í‡ Ô‡Ï'ˇÚ≥: ", 0
type    MEMTEST_OK_S object
MEMTEST_OK_S    db      "‘¿…ÕŒ", 13, 10, 0
type    MEMTEST_FAIL_S object
MEMTEST_FAIL_S  db      "Õ≈ Œ  @ ", 0
type    SD_OK_S object
SD_OK_S         db      "SD-Í‡Ú‡:          ‘¿…Õ¿", 13, 10, 0
type    SD_FAIL_S object
SD_FAIL_S       db      "SD-Í‡Ú‡:          Õ≈ Œ : ", 0

        section .text

init:
        ; Initialize segments
        mov     ax, STK_SEG
        mov     ss, ax
        mov     ax, STK_LEN
        mov     sp, ax

        mov     ax, ROM_SEG
        mov     ds, ax

        ; Init base I/O
        call    lcd_init
        call    uart_init
        call    equipment_list_init
        call    interrupt_init
        call    pit_init
        call    ppi_init
        call    keyboard_init

        ; Welcome message
        mov     ax, ROM_SEG
        mov     es, ax
        mov     bp, HELLO_S
        call    lcd_printstr

        ; Memory test
        mov     bp, MEMTEST_S
        call    lcd_printstr
        call    memtest
        cmp     ax, 0
        jne     .memtest_fail
.memtest_ok:
        mov     bx, ROM_SEG
        mov     es, bx
        mov     bp, MEMTEST_OK_S
        call    lcd_printstr
        jmp     .memtest_end
.memtest_fail:
        push    di
        push    bx
        mov     bx, ROM_SEG
        mov     es, bx
        mov     bp, MEMTEST_FAIL_S
        call    lcd_printstr
        pop     ax
        call    lcd_printword
        mov     al, ':'
        call    lcd_printchar
        pop     ax
        call    lcd_printword
        mov     al, 13
        call    lcd_printchar
        mov     al, 10
        call    lcd_printchar
        hlt
.memtest_end:

        ; Init SD card
        call    sdc_init

        mov     bx, ROM_SEG
        mov     es, bx
        mov     ah, 0x13
        cmp     al, 0
        jne     .sd_fail
.sd_ok:
        mov     bp, SD_OK_S
        int     0x10
        jmp     .sd_end
.sd_fail:
        mov     bp, SD_FAIL_S
        int     0x10
        add     al, '0'
        mov     ah, 0x0E
        int     0x10
        mov     al, 13
        int     0x10
        mov     al, 10
        int     0x10
        hlt
.sd_end:

        ; Ready! Boot the system
        int     0x19

        section .reset
reset:
        jmp     ROM_SEG:init
        hlt

times 0x10-($-reset)-2 db 0xAD

        db      "AD"
