; =====================================================
;
; Video functions (BIOS int 0x10)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "bda.inc"
        %include "macros.inc"

        extern  lcd_printchar
        extern  lcd_putchar
        extern  lcd_printstr
        extern  lcd_scrollup
        extern  lcd_gotoxy
        extern  uart_send
        extern  uart_sendword

        section .text

; --------------------------------------------------
; BIOS 0x10 ISR
; --------------------------------------------------
; Args:
;   AH - function number
        global  int10h_isr
int10h_isr:
        sti

        ; push    ax
        ; mov     al, 'A'
        ; call    uart_send
        ; mov     al, 'X'
        ; call    uart_send
        ; mov     al, '='
        ; call    uart_send
        ; pop     ax
        ;
        ; call    uart_sendword
        ;
        ; push    ax
        ; mov     al, ' '
        ; call    uart_send
        ; mov     al, 'D'
        ; call    uart_send
        ; mov     al, 'X'
        ; call    uart_send
        ; mov     al, '='
        ; call    uart_send
        ; mov     ax, dx
        ; call    uart_sendword
        ;
        ; mov     al, 0xD
        ; call    uart_send
        ; mov     al, 0xA
        ; call    uart_send
        ; pop     ax

        push    si
        push    bx  ; Save BX to perform pointer arithmetic

        mov     bl, ah
        xor     bh, bh  ; BX now contains function number

        ; Load int10h_function_table with BX*2 offset into BX
        shl     bx, 1
        mov     bx, [cs:bx+int10h_function_table]

        mov     si, bx
        pop     bx
        ; NOTE: SI will be clobbered in the called function
        call    si  ; Call appropriate function
        pop     si

        iretc

int10h_function_table:
        dw      set_video_mode
        dw      set_cursor_shape
        dw      set_cursor_position  ; ELKS
        dw      get_cursor_position_and_shape  ; ELKS
        dw      get_light_pen_position
        dw      set_display_page  ; ELKS
        dw      scroll_screen_up  ; ELKS
        dw      scroll_screen_down  ; ELKS
        dw      read_character_and_attribute_at_cursor
        dw      write_character_and_attribute_at_cursor  ; ELKS
        dw      write_character_only_at_cursor
        dw      set_border_color
        dw      write_graphics_pixel
        dw      read_graphics_pixel
        dw      write_character_in_tty_mode  ; ELKS, DOS
        dw      get_video_mode  ; ELKS

        dw      set_palette_registers  ; EGA, VGA, SVGA
        dw      character_generator  ; EGA, VGA, SVGA
        dw      alternate_select_functions  ; EGA, VGA, SVGA (ELKS - get EGA video config?)
        dw      write_string  ; Function 0x13: Print string
        dw      int10h_nop
        dw      int10h_nop
        dw      int10h_nop
        dw      int10h_nop
        dw      int10h_nop
        dw      int10h_nop
        dw      get_or_set_display_combination_code  ; VGA, SVGA (ELKS - get VGA video config?)
        dw      get_functionality_information  ; VGA, SVGA
        dw      save_or_restore_video_state  ; VGA, SVGA
        dw      int10h_nop
        dw      int10h_nop
        dw      int10h_nop

; --------------------------------------------------
; No-op (unimplemented) function
; --------------------------------------------------
int10h_nop:
        stc
        ret

; --------------------------------------------------
; Function 00h: Set video mode
; --------------------------------------------------
set_video_mode:
        stc
        ret

; --------------------------------------------------
; Function 01h: Set cursor shape
; --------------------------------------------------
set_cursor_shape:
        stc
        ret

; --------------------------------------------------
; Function 02h: Set cursor position
; --------------------------------------------------
set_cursor_position:
        push    cx
        mov     cx, dx
        call    lcd_gotoxy
        pop     cx
        clc
        ret

; --------------------------------------------------
; Function 03h: Get cursor position and shape
; --------------------------------------------------
get_cursor_position_and_shape:
        push    es
        mov     dx, BDA_SEG
        mov     es, dx
        mov     dx, [es:BDA_CURSOR_POS_P1]
        xor     ax, ax
        xor     cx, cx
        pop     es
        clc
        ret

; --------------------------------------------------
; Function 04h: Get light pen position
; --------------------------------------------------
get_light_pen_position:
        stc
        ret

; --------------------------------------------------
; Function 05h: Set display page
; --------------------------------------------------
set_display_page:
        stc
        ret

; --------------------------------------------------
; Function 06h: Scroll screen up
; --------------------------------------------------
scroll_screen_up:
        ; TODO: This always scrolls up by one line.
        call    lcd_scrollup
        clc
        ret

; --------------------------------------------------
; Function 07h: Scroll screen down
; --------------------------------------------------
scroll_screen_down:
        stc
        ret

; --------------------------------------------------
; Function 08h: Read character and attribute at cursor
; --------------------------------------------------
read_character_and_attribute_at_cursor:
        stc
        ret

; --------------------------------------------------
; Function 09h: Write character and attribute at cursor
; --------------------------------------------------
write_character_and_attribute_at_cursor:
        push    cx
.again:
        call    lcd_putchar
        loop    .again
        pop     cx
        clc
        ret

; --------------------------------------------------
; Function 0Ah: Write character only at cursor
; --------------------------------------------------
write_character_only_at_cursor equ write_character_and_attribute_at_cursor

; --------------------------------------------------
; Function 0Bh: Set border color
; --------------------------------------------------
set_border_color:
        stc
        ret

; --------------------------------------------------
; Function 0Ch: Write graphics pixel
; --------------------------------------------------
write_graphics_pixel:
        stc
        ret

; --------------------------------------------------
; Function 0Dh: Read graphics pixel
; --------------------------------------------------
read_graphics_pixel:
        stc
        ret

; --------------------------------------------------
; Function 0Eh: Write character in TTY mode
; Required by DOS 1.0
; --------------------------------------------------
; Args:
;   AH - function number (0x0E)
;   AL - character
;   BH - page number (ignored)
;   BL - foreground color (ignored)
write_character_in_tty_mode:
        call    lcd_printchar
        clc
        ret

; --------------------------------------------------
; Function 0Fh: Get video mode
; --------------------------------------------------
get_video_mode:
        mov     al, 7   ; 80x25 text mode
        mov     ah, 40  ; 40 columns
        mov     bh, 0   ; Page 0
        clc
        ret

; --------------------------------------------------
; Function 10h: Set palette registers
; --------------------------------------------------
set_palette_registers:
        stc
        ret

; --------------------------------------------------
; Function 11h: Character generator
; --------------------------------------------------
character_generator:
        stc
        ret

; --------------------------------------------------
; Function 12h: Alternate select functions
; --------------------------------------------------
; Args:
;   BL=10 - Get video configuration information
; Return:
;   BH - 0 if color, 1 if monochrome
;   BL - 0 = 64k EGA, 1 = 128k EGA, 2 = 192k EGA, 3 = 256k EGA
;   CH - feature bits
;   CL - switch settings
alternate_select_functions:
        ; mov     bh, 1   ; Monochrome
        ; mov     bl, 0   ; 64k EGA
        ; mov     ch, 0   ; No features
        ; mov     cl, 0   ; No switches
        ; Don't touch any registers, just return to inform caller that we don't support any fancy graphics
        stc
        ret

; --------------------------------------------------
; Function 13h: Print string
; TODO: Not used by DOS 1.0?
; --------------------------------------------------
; Args:
;   AH - function number (0x13)
;   ES:BP - string
write_string:
        push    ax
        call    lcd_printstr
        pop     ax
        clc
        ret


; --------------------------------------------------
; Function 1Ah: Get or set display combination code
; --------------------------------------------------
get_or_set_display_combination_code:
        stc
        ret

; --------------------------------------------------
; Function 1Bh: Get functionality information
; --------------------------------------------------
get_functionality_information:
        stc
        ret

; --------------------------------------------------
; Function 1Ch: Save or restore video state
; --------------------------------------------------
save_or_restore_video_state:
        stc
        ret
