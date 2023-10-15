; =====================================================
;
; Video functions (BIOS int 0x10)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        extern  lcd_printchar
        extern  lcd_printstr

        section .text

; --------------------------------------------------
; BIOS 0x10 ISR
; --------------------------------------------------
; Args:
;   AH - function number
        global  int10h_isr
int10h_isr:
        push    bx  ; Save BX to perform pointer arithmetic

        mov     bl, ah
        xor     bh, bh  ; BX now contains function number

        ; Load int10h_function_table with BX*2 offset into BX
        shl     bx, 1
        mov     bx, [cs:bx+int10h_function_table]

        call    bx  ; Call appropriate function

        pop     bx

        iret

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
        ret

; --------------------------------------------------
; Function 00h: Set video mode
; --------------------------------------------------
set_video_mode:
        ret

; --------------------------------------------------
; Function 01h: Set cursor shape
; --------------------------------------------------
set_cursor_shape:
        ret

; --------------------------------------------------
; Function 02h: Set cursor position
; --------------------------------------------------
set_cursor_position:
        ret

; --------------------------------------------------
; Function 03h: Get cursor position and shape
; --------------------------------------------------
get_cursor_position_and_shape:
        ret

; --------------------------------------------------
; Function 04h: Get light pen position
; --------------------------------------------------
get_light_pen_position:
        ret

; --------------------------------------------------
; Function 05h: Set display page
; --------------------------------------------------
set_display_page:
        ret

; --------------------------------------------------
; Function 06h: Scroll screen up
; --------------------------------------------------
scroll_screen_up:
        ret

; --------------------------------------------------
; Function 07h: Scroll screen down
; --------------------------------------------------
scroll_screen_down:
        ret

; --------------------------------------------------
; Function 08h: Read character and attribute at cursor
; --------------------------------------------------
read_character_and_attribute_at_cursor:
        ret

; --------------------------------------------------
; Function 09h: Write character and attribute at cursor
; --------------------------------------------------
write_character_and_attribute_at_cursor:
        ret

; --------------------------------------------------
; Function 0Ah: Write character only at cursor
; --------------------------------------------------
write_character_only_at_cursor:
        ret

; --------------------------------------------------
; Function 0Bh: Set border color
; --------------------------------------------------
set_border_color:
        ret

; --------------------------------------------------
; Function 0Ch: Write graphics pixel
; --------------------------------------------------
write_graphics_pixel:
        ret

; --------------------------------------------------
; Function 0Dh: Read graphics pixel
; --------------------------------------------------
read_graphics_pixel:
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
        ret

; --------------------------------------------------
; Function 0Fh: Get video mode
; --------------------------------------------------
get_video_mode:
        ret

; --------------------------------------------------
; Function 10h: Set palette registers
; --------------------------------------------------
set_palette_registers:
        ret

; --------------------------------------------------
; Function 11h: Character generator
; --------------------------------------------------
character_generator:
        ret

; --------------------------------------------------
; Function 12h: Alternate select functions
; --------------------------------------------------
alternate_select_functions:
        ret

; --------------------------------------------------
; Function 13h: Print string
; TODO: Not used by DOS 1.0?
; --------------------------------------------------
; Args:
;   AH - function number (0x13)
;   ES:BP - string
write_string:
        call    lcd_printstr
        ret


; --------------------------------------------------
; Function 1Ah: Get or set display combination code
; --------------------------------------------------
get_or_set_display_combination_code:
        ret

; --------------------------------------------------
; Function 1Bh: Get functionality information
; --------------------------------------------------
get_functionality_information:
        ret

; --------------------------------------------------
; Function 1Ch: Save or restore video state
; --------------------------------------------------
save_or_restore_video_state:
        ret
