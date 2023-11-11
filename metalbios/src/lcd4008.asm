; =====================================================
; Ï
; LCD functions for T6963C LCD (240x64, 40x08 characters)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "sys.inc"
        %include "ports.inc"
        %include "bda.inc"

        section .rodata

CHAR_DATA:
        ; 0x80 - Trident
        db 0b00100
        db 0b10101
        db 0b10101
        db 0b11011
        db 0b11111
        db 0b10101
        db 0b11111
        db 0b00100

        ; 0x81-0x8F
times 15*8      db      0
        ; 0x90-0x9F
times 16*8      db      0
        ; 0xA0-0xA4
times 5*8       db      0
        ; 0xA5 - ¥
times 1*8       db      0
        ; 0xA6-0xA9
times 4*8       db      0
        ; 0xAA - ª
times 1*8       db      0
        ; 0xAB-0xAE
times 4*8       db      0
        ; 0xAF - ¯
times 1*8       db      0
        ; 0xB0-0xB1
times 2*8       db      0
        ; 0xB2 - ²
times 1*8       db      0
        ; 0xB3 - ³
times 1*8       db      0
        ; 0xB4 - ´
times 1*8       db      0
        ; 0xB5-0xB9
times 5*8       db      0
        ; 0xBA - º
times 1*8       db      0
        ; 0xBB-0xBE
times 4*8       db      0
        ; 0xBF - ¿
times 1*8       db      0
        ; 0xC0-0xCE - ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎ
times 15*8      db      0
        ; 0xCF - Ï
        db 0b11111
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b00000
        ; 0xD0-0xD9 - ÐÑÒÓÔÕÖ×ØÙ
times 10*8      db      0
        ; 0xDA-0xDB - russian garbage
times 2*8       db      0
        ; 0xDC - Ü
times 1*8       db      0
        ; 0xDD - russian garbage
times 1*8       db      0
        ; 0xDE-0xDF - Þß
times 2*8       db      0

CHAR_DATA_LEN   equ     $ - CHAR_DATA

        section .text

; ================================================
; High-level functions
; ================================================

; --------------------------------------------------
; Initialize LCD
; --------------------------------------------------
        global  lcd_init
lcd_init:
        push    ax
        push    bx
        push    es

        xor     ax, ax
        call    cmd_set_text_home_addr

        mov     ax, 0x2000
        call    cmd_set_graphic_home_addr

        mov     ax, 0x0028  ; 40 columns
        call    cmd_set_text_area

        mov     ax, 0x0028  ; 40 columns
        call    cmd_set_graphic_area

        call    cmd_set_or_mode

        mov     ax, 0x0002
        call    cmd_set_offset_register

        mov     al, 0x07  ; Graphics off, text on, cursor on, blink on
        call    cmd_set_display_mode

        mov     al, 0x07  ; 8-line cursor
        call    cmd_set_cursor_pattern

        ; Write custom chars
        mov     ax, 0x1400  ; CGRAM start address
        call    cmd_set_addr_pointer
        call    cmd_autowrite_on
        mov     ax, ROM_SEG
        mov     es, ax
        mov     bx, CHAR_DATA
        mov     cx, CHAR_DATA_LEN
.writebyte:
        mov     al, [es:bx]
        call    autowrite
        inc     bx
        loop    .writebyte
        call    cmd_auto_reset

        ; Reset cursor pos & data addr pointer

        mov     ax, 0x0000  ; X=0, Y=0
        call    cmd_set_cursor_pos
        call    cmd_set_addr_pointer

        call    lcd_clear

        ; Set video mode to 7
        mov     ax, BDA_SEG
        mov     es, ax
        mov     al, 0x07
        mov     [es:BDA_VIDEO_MODE_ACTIVE], al

        ; Set cursor pos in BDA
        xor     ax, ax
        mov     [es:BDA_CURSOR_POS_P1], ax

        pop     es
        pop     bx
        pop     ax
        ret

; --------------------------------------------------
; Clear screen & set cursor pos & address to first char
; --------------------------------------------------
        global  lcd_clear
lcd_clear:
        push    ax
        push    cx

        call    cmd_autowrite_on

        xor     ax, ax
        mov     cx, 8 * 40  ; 8 rows
.again:
        call    autowrite
        loop    .again

        call    cmd_auto_reset

        mov     ax, 0x0000  ; X=0, Y=0
        call    cmd_set_cursor_pos
        call    cmd_set_addr_pointer

        pop     cx
        pop     ax

        ret

; --------------------------------------------------
; Print string to LCD
; --------------------------------------------------
; Args:
;   ES:BP - string
        global  lcd_printstr
lcd_printstr:
        push    ax
        push    bp

        mov     ah, 1
.next:
        mov     al, [es:bp]
        cmp     al, 0
        je      .done
        call    lcd_printchar
        inc     bp
        jmp     .next

.done:
        pop     bp
        pop     ax

        ret

; --------------------------------------------------
; Print character to LCD
; --------------------------------------------------
; Args:
;   AL - character
        global  lcd_printchar
lcd_printchar:
        push    ax
        push    bx
        push    cx
        push    es

        mov     cx, BDA_SEG
        mov     es, cx

        mov     cx, [es:BDA_CURSOR_POS_P1]  ; Y:X

        cmp     al, 0x0A
        je      .lf
        cmp     al, 0x08
        je      .backspace
        cmp     al, 0x0D
        je      .cr
        cmp     al, 0x80
        jae     .char
        sub     al, 0x20

.char:
        ; TODO: CR/LF if X = 39
        call    cmd_write_data_increment_adp
        inc     cl
        mov     [es:BDA_CURSOR_POS_P1], cx
        jmp     .end

.cr:  ; X = 0
        xor     cl, cl
        call    lcd_gotoxy
        jmp     .end
.lf:  ; Y = Y + 1
        ; TODO: Scroll display if Y = 7
        ; Calculate new cursor pos
        inc     ch
        call    lcd_gotoxy
        jmp     .end
.backspace:
        jmp     .end

.end:
        pop     es
        pop     cx
        pop     bx
        pop     ax
        ret

; --------------------------------------------------
; Move cursor
; --------------------------------------------------
; Args:
;   CL - X
;   CH - Y
        global  lcd_gotoxy
lcd_gotoxy:
        push    ax
        push    bx

        mov     [es:BDA_CURSOR_POS_P1], cx

        ; Set cursor pos
        mov     ax, cx
        call    cmd_set_cursor_pos
        ; Set address pointer
        xor     ax, ax
        mov     al, ch  ; AL = Y
        mov     bh, 40
        mul     bh      ; AX = Y * 8
        xor     ch, ch
        add     ax, cx  ; AX = Y * 8 + X
        call    cmd_set_addr_pointer

        pop     bx
        pop     ax
        ret

; ==================================================
; Low-level functions
; ==================================================

; --------------------------------------------------
; Block while LCD is busy
; --------------------------------------------------
busy:
        push    ax
.wait:
        in      al, LCD_CMD
        and     al, 0x3
        cmp     al, 0x3
        jne     .wait
        pop     ax
        ret

; --------------------------------------------------
; Block while LCD bit 3 is set
; --------------------------------------------------
autowritebusy:
        push    ax
.wait:
        in      al, LCD_CMD
        and     al, 0x8
        cmp     al, 0x8
        jne     .wait
        pop     ax
        ret

; --------------------------------------------------
; Block while LCD bit 2 is set
; --------------------------------------------------
autoreadbusy:
        push    ax
.wait:
        in      al, LCD_CMD
        and     al, 0x4
        cmp     al, 0x4
        jne     .wait
        pop     ax
        ret

; --------------------------------------------------
; Write data byte to LCD
; --------------------------------------------------
; Args:
;   AL - data
writedata:
        call    busy
        out     LCD_DAT, al
        ret

; --------------------------------------------------
; Write data word to LCD
; --------------------------------------------------
; Args:
;   AL - D1
;   AH - D2
writedata2:
        ; TODO: reduce this to 1 `out` instruction if endianess is correct?
        call    busy
        out     LCD_DAT, al
        xchg    al, ah
        call    busy
        out     LCD_DAT, al
        xchg    al, ah
        ret

; --------------------------------------------------
; Write command byte to LCD
; --------------------------------------------------
; Args:
;   AL - command
writecmd:
        call    busy
        out     LCD_CMD, al
        ret

; --------------------------------------------------
; Write data while in auto data write mode
; --------------------------------------------------
; Args:
;   AL - data
autowrite:
        call    autowritebusy
        out     LCD_DAT, al
        ret

; --------------------------------------------------
; Read data while in auto data read mode
; --------------------------------------------------
; Return:
;   AL - data
autoread:
        call    autoreadbusy
        in      al, LCD_DAT
        ret

; ==============================
; Protocol commands
; ==============================

; --------------------------------------------------
; Set text home address
; ------------------------------------------------
; Args:
;   AX - addr
cmd_set_text_home_addr:
        push    ax
        call    writedata2
        mov     al, 0x40
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Set graphic home address
; ------------------------------------------------
; Args:
;   AX - home addr
cmd_set_graphic_home_addr:
        push    ax
        call    writedata2
        mov     al, 0x42
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Set text area
; ------------------------------------------------
; Args:
;    AX - columns
cmd_set_text_area:
        push    ax
        call    writedata2
        mov     al, 0x41
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Set graphic area
; ------------------------------------------------
; Args:
;    AX - columns
cmd_set_graphic_area:
        push    ax
        call    writedata2
        mov     al, 0x43
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Set OR mode
; ------------------------------------------------
cmd_set_or_mode:
        mov     ax, 0x80
        call    writecmd
        ret

; --------------------------------------------------
; Set offset register
; ------------------------------------------------
; Args:
;   AX - data
cmd_set_offset_register:
        push    ax
        call    writedata2
        mov     al, 0x22
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Set display mode
; ------------------------------------------------
; Args:
;   AL[3] - graphics on
;   AL[2] - text on
;   AL[1] - cursor on
;   AL[0] - blink on
cmd_set_display_mode:
        push    ax
        and     al, 0x0F
        or      al, 0x90
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Set cursor pattern
; ------------------------------------------------
; Args:
;   AL[2:0] - cursor height (0..7 -> 1..8 pixels)
cmd_set_cursor_pattern:
        push    ax
        and     al, 0x07
        or      al, 0xA0
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Set cursor pos
; ------------------------------------------------
; Args:
;   AL - X pos
;   AH - Y pos
cmd_set_cursor_pos:
        push    ax
        call    writedata2
        mov     al, 0x21
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Set address pointer (text home address)
; ------------------------------------------------
; Args:
;   AX - address
cmd_set_addr_pointer:
        push    ax
        call    writedata2
        mov     al, 0x24
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Print character (increase ADP)
; ------------------------------------------------
; Args:
;   AL - character
cmd_write_data_increment_adp:
        push    ax
        call    writedata
        mov     al, 0xC0
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Print character (don't change ADP)
; ------------------------------------------------
cmd_write_data_nonvariable_adp:
        push    ax
        call    writedata
        mov     al, 0xC4
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Enable auto-write mode
; ------------------------------------------------
cmd_autowrite_on:
        push    ax
        ; Auto data write on
        mov     al, 0xB0
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Enable auto-read mode
; ------------------------------------------------
cmd_autoread_on:
        push    ax
        ; Auto data write on
        mov     al, 0xB1
        call    writecmd
        pop     ax
        ret

; --------------------------------------------------
; Disable auto-write mode
; ------------------------------------------------
cmd_auto_reset:
        push    ax
        ; Auto data write off
        mov     al, 0xB2
        call    writecmd
        pop     ax
        ret
