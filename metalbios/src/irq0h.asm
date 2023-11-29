; =====================================================
;
; IRQ0 handler (Real time clock interrupt)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "ports.inc"

        extern  pit_restart_timer0

        section .text

; --------------------------------------------------
; IRQ 0h ISR
; --------------------------------------------------
        global  irq0h_isr
irq0h_isr:
        ; Restart timer & trigger user ISR
        ; push    ax
        ;
        ; mov     al, 0b00001010  ; SCK = 1
        ; out     UA_MCR, al      ; Write SCK

        call    pit_restart_timer0
        int     0x1C

        ; mov     al, 0b00001011  ; SCK = 0
        ; out     UA_MCR, al      ; Write SCK

        ; pop     ax

        iret
