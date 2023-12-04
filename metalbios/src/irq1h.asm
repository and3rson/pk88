; =====================================================
;
; IRQ1 handler (keyboard via GAL22V10)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        extern  keyboard_process

        section .text

; --------------------------------------------------
; IRQ 1h ISR
; --------------------------------------------------
        global  irq1h_isr
irq1h_isr:
        ; Keyboard controller has PS/2 byte available

        call    keyboard_process

        iret
