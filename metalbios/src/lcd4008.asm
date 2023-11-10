; =====================================================
;
; LCD functions for T6963C LCD (240x64, 40x08 characters)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "ports.inc"
        %include "bda.inc"

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

        mov     ax, 0x0000  ; X=0, Y=0
        call    cmd_set_cursor_pos
        call    cmd_set_addr_pointer

        call    lcd_clear

        ; Set video mode to 7
        mov     ax, BDA_SEG
        mov     es, ax
        mov     al, 0x07
        mov     [es:BDA_VIDEO_MODE_ACTIVE], al

        pop     es
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
        sub     al, 0x20
        ; TODO: handle CR/LF, backspace, etc
        call    cmd_write_data_increment_adp
        add     al, 0x20
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
