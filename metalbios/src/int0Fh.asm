; =====================================================
;
; IRQ7 handler (keyboard via GAL22V10)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "ports.inc"

        extern  keyboard_read
        extern  lcd_printbyte

        section .text

; --------------------------------------------------
; BIOS 0x0F ISR
; --------------------------------------------------
        global  int0Fh_isr
int0Fh_isr:
        push    ax

        call    keyboard_read
        call    lcd_printbyte

        pop     ax

        iret
