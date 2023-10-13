; =====================================================
;
; IRQ0 handler (Real time clock interrupt)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        extern  int1Ch_isr

        section .text

; --------------------------------------------------
; BIOS 0x08 ISR
; --------------------------------------------------
        global  int08h_isr
int08h_isr:
        ; Do nothing, simply trigger user ISR
        jmp     int1Ch_isr
