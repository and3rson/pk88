; =====================================================
;
; Keyboard functions (BIOS int 0x16)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "bda.inc"
        %include "sys.inc"
        %include "macros.inc"

        extern  lcd_write
        extern  lcd_busy
        extern  lcd_print
        extern  lcd_printbyte
        extern  lcd_printm

        section .rodata

STUB_S  db      "!0x16:", 0

        section .text

; --------------------------------------------------
; BIOS 0x16 ISR
; --------------------------------------------------
; Args:
;   AH - function number
        global  int16h_isr
int16h_isr:
        push    si
        push    bx  ; Save BX to perform pointer arithmetic

        mov     bl, ah
        xor     bh, bh  ; BX now contains function number

        ; Load int16h_function_table with BX*2 offset into BX
        shl     bx, 1
        mov     bx, [cs:bx+int16h_function_table]

        mov     si, bx
        pop     bx
        ; NOTE: SI will be clobbered in the called function
        call    si  ; Call appropriate function
        pop     si

        iretc

int16h_function_table:
        dw      wait_for_keypress  ; ELKS
        dw      peek_char  ; ELKS
        dw      int16h_nop
        dw      int16h_nop
        dw      int16h_nop
        dw      int16h_nop
        dw      int16h_nop
        dw      int16h_nop

; --------------------------------------------------
; No-op (unimplemented) function
; --------------------------------------------------
int16h_nop:
        push    bp
        push    es
        push    ax

        mov     ax, ROM_SEG
        mov     es, ax
        mov     ah, 0x13
        mov     bp, STUB_S
        int     0x10

        pop     ax
        xchg    ah, al
        call    lcd_printbyte
        xchg    ah, al
        pop     es
        pop     bp

        stc
        ret

; --------------------------------------------------
; Function 0x00 - Wait for keypress, halt until pressed
; --------------------------------------------------
; Returns:
;   AH - scan code
;   AL - ASCII character or zero if special key
wait_for_keypress:
        call    lcd_printm
        db      "!WFK", 13, 10, 0
        hlt
        ; stc
        ; ret

; --------------------------------------------------
; Function 0x01 - Peek character from keyboard buffer
; --------------------------------------------------
; Returns:
;   ZF - 0 if a key is pressed (even Ctrl-Break)
;   AX - 0 if no scan code is available
;   AH - scan code
;   AL - ASCII character or zero if special function key
peek_char:
        call    lcd_printm
        db      "!PC", 13, 10, 0
        hlt
        ; stc
        ; ret
