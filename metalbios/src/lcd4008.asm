; =====================================================
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

%macro skipchar 1
        %rep %1
        db 0b11011
        db 0b11011
        db 0b11011
        db 0b11011
        db 0b11011
        db 0b00000
        db 0b11011
        db 0b00000
        %endrep
%endmacro

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
        skipchar        15
; 0x90-0x9F
        skipchar        16
; 0xA0-0xA4
        skipchar        5
; 0xA5 - ¥
        db 0b00001
        db 0b11111
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b00000
; 0xA6-0xA9
        skipchar        4
; 0xAA - ª
        db 0b01110
        db 0b10001
        db 0b10000
        db 0b11110
        db 0b10000
        db 0b10001
        db 0b01110
        db 0b00000
; 0xAB-0xAE
        skipchar        4
; 0xAF - ¯
        db 0b01010
        db 0b01110
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b01110
        db 0b00000
; 0xB0-0xB1
        skipchar        2
; 0xB2 - ²
        db 0b01110
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b01110
        db 0b00000
; 0xB3 - ³
        db 0b00100
        db 0b00000
        db 0b01100
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b01110
        db 0b00000
; 0xB4 - ´
        db 0b00000
        db 0b00001
        db 0b11111
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b00000
; 0xB5-0xB9
        skipchar        5
; 0xBA - º
        db 0b00000
        db 0b00000
        db 0b01110
        db 0b10001
        db 0b11100
        db 0b10001
        db 0b01110
        db 0b00000
; 0xBB-0xBE
        skipchar        4
; 0xBF - ¿
        db 0b01010
        db 0b00000
        db 0b01100
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b01110
        db 0b00000
; 0xC0-0xCE - ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏ
; À
        db 0b00100
        db 0b01010
        db 0b10001
        db 0b10001
        db 0b11111
        db 0b10001
        db 0b10001
        db 0b00000
; Á
        db 0b11111
        db 0b10000
        db 0b10000
        db 0b11110
        db 0b10001
        db 0b10001
        db 0b11110
        db 0b00000
; Â
        db 0b11110
        db 0b10001
        db 0b10001
        db 0b11110
        db 0b10001
        db 0b10001
        db 0b11110
        db 0b00000
; Ã
        db 0b11111
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b00000
; Ä
        db 0b01110
        db 0b01010
        db 0b01010
        db 0b01010
        db 0b01010
        db 0b01010
        db 0b11111
        db 0b10001
; Å
        db 0b11111
        db 0b10000
        db 0b10000
        db 0b11110
        db 0b10000
        db 0b10000
        db 0b11111
        db 0b00000
; Æ
        db 0b10101
        db 0b10101
        db 0b01110
        db 0b00100
        db 0b01110
        db 0b10101
        db 0b10101
        db 0b00000
; Ç
        db 0b01110
        db 0b10001
        db 0b00001
        db 0b00110
        db 0b00001
        db 0b10001
        db 0b01110
        db 0b00000
; È
        db 0b10001
        db 0b10001
        db 0b10011
        db 0b10101
        db 0b11001
        db 0b10001
        db 0b10001
        db 0b00000
; É
        db 0b00100
        db 0b10001
        db 0b10011
        db 0b10101
        db 0b11001
        db 0b10001
        db 0b10001
        db 0b00000
; Ê
        db 0b10001
        db 0b10010
        db 0b10100
        db 0b11000
        db 0b10100
        db 0b10010
        db 0b10001
        db 0b00000
; Ë
        db 0b00011
        db 0b00101
        db 0b01001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b00000
; Ì
        db 0b10001
        db 0b10001
        db 0b11011
        db 0b10101
        db 0b10101
        db 0b10001
        db 0b10001
        db 0b00000
; Í
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b11111
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b00000
; Î
        db 0b01110
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b01110
        db 0b00000
; Ï
        db 0b11111
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b00000
; 0xD0-0xDE - ÐÑÒÓÔÕÖ×ØÙ
; Ð
        db 0b11110
        db 0b10001
        db 0b10001
        db 0b11110
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b00000
; Ñ
        db 0b01110
        db 0b10001
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b10001
        db 0b01110
        db 0b00000
; Ò
        db 0b11111
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00000
; Ó
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b01010
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00000
; Ô
        db 0b00100
        db 0b01110
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b01110
        db 0b00100
        db 0b00000
; Õ
        db 0b10001
        db 0b10001
        db 0b01010
        db 0b00100
        db 0b01010
        db 0b10001
        db 0b10001
        db 0b00000
; Ö
        db 0b10010
        db 0b10010
        db 0b10010
        db 0b10010
        db 0b10010
        db 0b10010
        db 0b11111
        db 0b00001
; ×
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b11111
        db 0b00001
        db 0b00001
        db 0b00001
        db 0b00000
; Ø
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b11111
        db 0b00000
; Ù
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b11111
        db 0b00001
; 0xDA-0xDB - russian garbage
        skipchar        2
; 0xDC - Ü
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b11110
        db 0b10001
        db 0b10001
        db 0b11110
        db 0b00000
; 0xDD - russian garbage
        skipchar        1
; 0xDE-0xDF - Þß
; Þ
        db 0b10010
        db 0b10101
        db 0b10101
        db 0b11101
        db 0b10101
        db 0b10101
        db 0b10010
        db 0b00000
; ß
        db 0b01111
        db 0b10001
        db 0b10001
        db 0b01111
        db 0b00101
        db 0b01001
        db 0b10001
        db 0b00000
; 0xE0-0xEF - àáâãäåæçèéêëìíîï
; à
        db 0b00000
        db 0b00000
        db 0b01110
        db 0b00001
        db 0b01111
        db 0b10001
        db 0b01111
        db 0b00000
; á
        db 0b00000
        db 0b00000
        db 0b11111
        db 0b10000
        db 0b11110
        db 0b10001
        db 0b11110
        db 0b00000
; â
        db 0b00000
        db 0b00000
        db 0b11110
        db 0b10001
        db 0b11110
        db 0b10001
        db 0b11110
        db 0b00000
; ã
        db 0b00000
        db 0b00000
        db 0b11111
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b10000
        db 0b00000
; ä
        db 0b00000
        db 0b00000
        db 0b00000
        db 0b01110
        db 0b01010
        db 0b01010
        db 0b11111
        db 0b10001
; å
        db 0b00000
        db 0b00000
        db 0b01110
        db 0b10001
        db 0b11111
        db 0b10000
        db 0b01110
        db 0b00000
; æ
        db 0b00000
        db 0b00000
        db 0b10101
        db 0b10101
        db 0b01110
        db 0b10101
        db 0b10101
        db 0b00000
; ç
        db 0b00000
        db 0b00000
        db 0b01110
        db 0b10001
        db 0b00110
        db 0b10001
        db 0b01110
        db 0b00000
; è
        db 0b00000
        db 0b00000
        db 0b10001
        db 0b10011
        db 0b10101
        db 0b11001
        db 0b10001
        db 0b00000
; é
        db 0b00000
        db 0b00100
        db 0b10001
        db 0b10011
        db 0b10101
        db 0b11001
        db 0b10001
        db 0b00000
; ê
        db 0b00000
        db 0b00000
        db 0b01001
        db 0b01010
        db 0b01100
        db 0b01010
        db 0b01001
        db 0b00000
; ë
        db 0b00000
        db 0b00000
        db 0b00011
        db 0b00101
        db 0b01001
        db 0b10001
        db 0b10001
        db 0b00000
; ì
        db 0b00000
        db 0b00000
        db 0b10001
        db 0b11011
        db 0b10101
        db 0b10001
        db 0b10001
        db 0b00000
; í
        db 0b00000
        db 0b00000
        db 0b10001
        db 0b10001
        db 0b11111
        db 0b10001
        db 0b10001
        db 0b00000
; î
        db 0b00000
        db 0b00000
        db 0b01110
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b01110
        db 0b00000
; ï
        db 0b00000
        db 0b00000
        db 0b11111
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b10001
        db 0b00000
; 0xF0-0xFE - ðñòóôõö÷øù
; ð
        db 0b00000
        db 0b00000
        db 0b11110
        db 0b10001
        db 0b11110
        db 0b10000
        db 0b10000
        db 0b00000
; ñ
        db 0b00000
        db 0b00000
        db 0b01110
        db 0b10001
        db 0b10000
        db 0b10001
        db 0b01110
        db 0b00000
; ò
        db 0b00000
        db 0b00000
        db 0b11111
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00100
        db 0b00000
; ó
        db 0b00000
        db 0b00000
        db 0b10001
        db 0b10001
        db 0b01010
        db 0b00100
        db 0b00100
        db 0b00000
; ô
        db 0b00000
        db 0b00000
        db 0b00100
        db 0b01110
        db 0b10101
        db 0b01110
        db 0b00100
        db 0b00000
; õ
        db 0b00000
        db 0b00000
        db 0b10001
        db 0b01010
        db 0b00100
        db 0b01010
        db 0b10001
        db 0b00000
; ö
        db 0b00000
        db 0b00000
        db 0b10010
        db 0b10010
        db 0b10010
        db 0b10010
        db 0b11111
        db 0b00001
; ÷
        db 0b00000
        db 0b00000
        db 0b10001
        db 0b10001
        db 0b11111
        db 0b00001
        db 0b00001
        db 0b00000
; ø
        db 0b00000
        db 0b00000
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b11111
        db 0b00000
; ù
        db 0b00000
        db 0b00000
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b10101
        db 0b11111
        db 0b00001
; 0xFA-0xFB - russian garbage
        skipchar        2
; 0xFC - ü
        db 0b00000
        db 0b00000
        db 0b10000
        db 0b10000
        db 0b11110
        db 0b10001
        db 0b11110
        db 0b00000
; 0xFD - russian garbage
        skipchar        1
; 0xFE-0xFF - þÿ
; þ
        db 0b00000
        db 0b00000
        db 0b10010
        db 0b10101
        db 0b11101
        db 0b10101
        db 0b10010
        db 0b00000
; ÿ
        db 0b00000
        db 0b00000
        db 0b00111
        db 0b01001
        db 0b00111
        db 0b01001
        db 0b10001
        db 0b00000


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

        ; Set display size in BDA
        mov     ax, 40
        mov     [es:BDA_COL_PER_ROW], ax

        ; Set video mode
        mov     al, 7
        mov     [es:BDA_VIDEO_MODE_ACTIVE], al

        ; Set video param control block
        xor     ax, ax
        mov     [es:BDA_VID_PARM_CTRL_BLK], ax
        mov     [es:BDA_VID_PARM_CTRL_BLK + 2], ax

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
; Return:
;   AX - number of chars printed (excluding zero terminator)
        global  lcd_printstr
lcd_printstr:
        push    cx
        push    bp

        xor     cx, cx

        mov     ah, 1
.next:
        mov     al, [es:bp]
        cmp     al, 0
        je      .done
        call    lcd_printchar
        inc     bp
        inc     cx
        jmp     .next

.done:
        mov     ax, cx
        pop     bp
        pop     cx

        ret

; --------------------------------------------------
; Print string that's located directly after the call instruction
; --------------------------------------------------
        global  lcd_printm
lcd_printm:
        push    si
        mov     si, sp
        push    ax
        push    bp
        push    es

        ; IP of next instruction = [SI+2]

        ; Load string address
        mov     ax, ROM_SEG
        mov     es, ax
        mov     bp, [ss:si+2]      ; IP
        call    lcd_printstr
        ; Update return address to point at instruction right after the printed string
        add     bp, ax
        inc     bp      ; Skip zero terminator
        ; Overwrite return address
        mov     [ss:si+2], bp

        pop     es
        pop     bp
        pop     ax
        pop     si
        ret

; --------------------------------------------------
; Print character to LCD in teletype mode
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
        ; Print ASCII char

        call    cmd_write_data_increment_adp
        inc     cl
        cmp     cl, 40
        je      .crlf
        ; mov     [es:BDA_CURSOR_POS_P1], cx
        call    lcd_gotoxy
        jmp     .end

.cr:
        ; Print CR (X := 0)
        xor     cl, cl
        call    lcd_gotoxy
        jmp     .end

.lf:
        ; Print LF (Y := Y + 1)
        ; TODO: Scroll display if Y = 7
        cmp     ch, 7
        je      .scrollup

        inc     ch
        call    lcd_gotoxy
        jmp     .end

.crlf:
        ; Move cursor to start of next line, scroll display if needed
        xor     cl, cl
        call    lcd_gotoxy

        jmp     .lf

        ; Print CR
        ; call    lcd_gotoxy


        ; jne     .movecursor     ; No scroll needed
        ; je      .scrollup
        ; call    lcd_gotoxy
        jmp     .end

.scrollup:
        call    lcd_scrollup_full
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
; Print character to LCD without moving cursor
; --------------------------------------------------
; Args:
;   AL - character
        global  lcd_putchar
lcd_putchar:
        push    ax

        cmp     al, 0x80
        jae     .char
        sub     al, 0x20

.char:
        ; Print ASCII char

        call    cmd_write_data_nonvariable_adp

        pop     ax
        ret

; --------------------------------------------------
; Scroll display up, do not change cursor position
; --------------------------------------------------
lcd_scrollup_full:
        ; Move row 2 to row 1, row 3 to row 2, etc.
        ; TODO: Interrupts might mess autowrite parts up if they attempt to print to LCD

        push    ax
        push    cx
        push    di
        push    es

        mov     ax, BDA_SEG
        mov     es, ax

        mov     ch, 0
.nextrow:
        ; Set LCD addr pointer to row start
        inc     ch
        mov     cl, 0
        call    cmd_set_addr_pointer_xy

        ; Read row into buffer
        mov     di, BDA_LCD_TMP_BUF
        call    cmd_autoread_on
.readchar:
        call    autoread
        mov     [es:di], al
        inc     di
        inc     cl
        cmp     cl, 40
        jne     .readchar
        call    cmd_auto_reset

        ; Set LCD addr pointer to previous row start
        mov     cl, 0
        dec     ch
        call    cmd_set_addr_pointer_xy

        ; Write row from buffer
        mov     di, BDA_LCD_TMP_BUF
        call    cmd_autowrite_on
.writechar:
        mov     al, [es:di]
        call    autowrite
        inc     di
        inc     cl
        cmp     cl, 40
        jne     .writechar
        call    cmd_auto_reset

        ; Move to next row
        inc     ch
        cmp     ch, 7
        jne     .nextrow

        ; Clear last row
        mov     al, 0           ; Space
        mov     cl, 0
        call    cmd_set_addr_pointer_xy
        call    cmd_autowrite_on
.clearchar:
        call    autowrite
        inc     cl
        cmp     cl, 40
        jne     .clearchar
        call    cmd_auto_reset

        ; Restore cursor & addr pointer
        mov     cx, [es:BDA_CURSOR_POS_P1]
        call    lcd_gotoxy

        pop     es
        pop     di
        pop     cx
        pop     ax
        ret

; --------------------------------------------------
; Scroll part of line
; --------------------------------------------------
; Args:
;   AL - number of lines to scroll
;   BL - scroll direction (0 = up, 1 = down)
;   CH - start Y
;   CL - start X
;   DL - end X
        global  lcd_scroll_part
lcd_scroll_part:
        push    ax
        push    di
        push    es

        mov     ax, BDA_SEG
        mov     es, ax

        ; Read line part into buffer
        call    cmd_set_addr_pointer_xy
        mov     di, BDA_LCD_TMP_BUF
        call    cmd_autoread_on
        push    cx
.readchar:
        call    autoread
        mov     [es:di], al
        inc     di
        inc     cl
        cmp     cl, dl
        jne     .readchar
        call    cmd_auto_reset
        pop     cx

        ; Clear line part
        call    cmd_set_addr_pointer_xy
        mov     al, 0           ; Space
        call    cmd_autowrite_on
        push    cx
.clearchar:
        call    autowrite
        inc     cl
        cmp     cl, dl
        jne     .clearchar
        call    cmd_auto_reset
        pop     cx

        ; Calculate destination Y
        test    bl, bl
        jnz     .down
.up:
        add     ch, al
        cmp     ch, 7
        jbe     .writedest
        jmp     .end
.down:
        sub     ch, al
        jc      .end

.writedest:
        ; Write line part from buffer
        call    cmd_set_addr_pointer_xy
        mov     di, BDA_LCD_TMP_BUF
        call    cmd_autowrite_on
        push    cx
.writechar:
        mov     al, [es:di]
        call    autowrite
        inc     di
        inc     cl
        cmp     cl, dl
        jne     .writechar
        call    cmd_auto_reset
        pop     cx

.end:
        ; Restore cursor & addr pointer
        mov     cx, [es:BDA_CURSOR_POS_P1]
        call    lcd_gotoxy

        pop     es
        pop     di
        pop     ax
        ret

; --------------------------------------------------
; Print word as hex
; --------------------------------------------------
; Args:
;   AX - byte
        global  lcd_printword
lcd_printword:
        xchg    al, ah
        call    lcd_printbyte
        xchg    al, ah
        call    lcd_printbyte

        ret

; --------------------------------------------------
; Print byte as hex
; --------------------------------------------------
; Args:
;   AL - byte
        global  lcd_printbyte
lcd_printbyte:
        push    bx
        mov     bx, ax

        shr     al, 1
        shr     al, 1
        shr     al, 1
        shr     al, 1
        call    lcd_printnibble
        mov     al, bl
        call    lcd_printnibble

        mov     ax, bx
        pop     bx
        ret

; --------------------------------------------------
; Print nibble as hex
; --------------------------------------------------
; Args:
;   AL - nibble (lower 4 bits are used)
; Clobbers:
;   AL
        global  lcd_printnibble
lcd_printnibble:
        and     al, 0x0F
        cmp     al, 0x0A
        jb      .digit
        add     al, 'A' - 0x0A  ; 55
        jmp     .done
.digit:
        add     al, '0'
.done:
        call    lcd_printchar

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
        push    es

        mov     ax, BDA_SEG
        mov     es, ax

        mov     [es:BDA_CURSOR_POS_P1], cx

        ; Set cursor pos
        mov     ax, cx
        call    cmd_set_cursor_pos
        ; Set address pointer
        call    cmd_set_addr_pointer_xy

        pop     es
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
; Set address pointer (text home address) using row & column
;
; This is a convenience wrapper around cmd_set_addr_pointer
; ------------------------------------------------
; Args:
;   CL - column
;   CH - row
cmd_set_addr_pointer_xy:
        push    ax
        push    bx
        push    cx
        xor     ax, ax
        mov     al, ch  ; AL = Y
        mov     bh, 40
        mul     bh      ; AX = Y * 8
        xor     ch, ch
        add     ax, cx  ; AX = Y * 8 + X
        call    cmd_set_addr_pointer
        pop     cx
        pop     bx
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
