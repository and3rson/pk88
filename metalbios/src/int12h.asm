; =====================================================
;
; Memory size (BIOS int 0x12)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "macros.inc"

MEMORY  equ     640

        section .text

; --------------------------------------------------
; BIOS 0x12 ISR
; --------------------------------------------------
        global  int12h_isr
int12h_isr:
        sti

        mov     ax, MEMORY

        clc
        iretc
