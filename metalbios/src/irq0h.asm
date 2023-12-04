; =====================================================
;
; IRQ0 handler (Real time clock interrupt)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        extern  pit_restart_timer0

        section .text

; --------------------------------------------------
; IRQ 0h ISR
; --------------------------------------------------
        global  irq0h_isr
irq0h_isr:
        ; Restart timer & trigger user ISR

        call    pit_restart_timer0
        int     0x1C

        iret
