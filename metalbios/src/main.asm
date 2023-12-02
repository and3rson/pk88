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

HELLO_S         db      "               ",0x80," œK-88 ", 0x80, 13, 10, 0
MEMTEST_S       db      "œÂÂ‚≥Í‡ Ô‡Ï'ˇÚ≥: ", 0
MEMTEST_OK_S    db      "‘¿…ÕŒ", 13, 10, 0
MEMTEST_FAIL_S  db      "Õ≈ Œ  @ ", 0
SD_OK_S         db      "SD-Í‡Ú‡:          ‘¿…Õ¿", 13, 10, 0
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

        ; Ready!

        sti

        mov     ax, BDA_SEG
        mov     es, ax

; .read_kb:
;         ; ; in      al, PPI_A
;         ; ; and     al, 0x01
;         ; ; add     al, '0'
;         ; ; call    lcd_printchar
;         ; ; mov     al, 0x02
;         ; ; out     PPI_B, al
;         ; ; mov     al, 0x00
;         ; ; out     PPI_B, al
;         ; mov     ax, [es:BDA_KB_BITBANG_VALUE]
;         ; test    ax, ax
;         ; jz      .read_kb
;         ; call    lcd_printword
;         ; ; mov     ah, 0x0E
;         ; ; int     0x10
;         ; xor     ax, ax
;         ; mov     [es:BDA_KB_BITBANG_VALUE], ax
;         ; jmp     .read_kb
;         mov     ah, 0x01
;         int     0x16
;         ; ; mov     al, '0'
;         ; ; mov     ah, 0x0E
;         ; ; int     0x10
;         jz      .read_kb
;
;         xor     ah, ah
;         int     0x16
;         call    lcd_printword
;         jmp     .read_kb
; ;
; ;         cmp     al, 'c'
; ;         jne     .not_c
; ;         mov     al, 13
; ;         jmp     .done
; ; .not_c:
; ;         cmp     al, 'r'
; ;         jne     .not_r
; ;         mov     al, 10
; ;         jmp     .done
; ; .not_r:
;
; .done:
;         ; call    lcd_printword
;         call    lcd_printchar
;         ; jmp     .read_kb
;
;         jmp     .read_kb

;         mov     ch, 0
;         mov     cl, 0
; .printch:
;         mov     al, ch
;         add     al, '0'
;         mov     ah, 0x0E
;         int     0x10
;         inc     cl
;         cmp     cl, 40
;         jne     .printch
;         mov     cl, 0
;         inc     ch
;         cmp     ch, 7
;         jne     .printch
;
;         ; Scroll screen up by 1 line (lines 3-4, columns 10-20)
;         mov     ax, 0x0601
;         mov     cx, 0x030A
;         mov     dx, 0x0414
;         int     0x10
;
;         jmp     $


        ; https://thestarman.pcministry.com/asm/mbr/95BMEMBR.htm
        ; Load bootsector
        xor     ax, ax
        mov     es, ax
        mov     bx, 0x7C00
        call    sdc_read_single_block
        ; Initialize segments
        xor     ax, ax
        mov     ds, ax
        mov     es, ax
        ; Init stack at 0x0000:0x0400
        xor     ax, ax
        mov     ss, ax
        mov     sp, 0x0400
        ; Tell bootsector that we are booting from HDD
        mov     dl, 0x80
        xor     dh, dh          ; bit 5 is 0 - means that device is supported via int 13h
        ; Execute bootsector
        jmp     0x0000:0x7C00

        section .reset
reset:
        jmp     ROM_SEG:init
        hlt

times 0x10-($-reset)-2 db 0xAD

        db      "AD"
