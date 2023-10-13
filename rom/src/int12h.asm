; =====================================================
;
; Memory size (BIOS int 0x12)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

MEMORY  equ     640

; https://stanislavs.org/helppc/int_12.html

        section .text

; --------------------------------------------------
; BIOS 0x12 ISR
; --------------------------------------------------
        global  int12h_isr
int12h_isr:
        mov     ax, MEMORY

        iret
