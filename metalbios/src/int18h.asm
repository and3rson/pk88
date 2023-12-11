; =====================================================
;
; BASIC stub (BIOS int 0x11)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "sys.inc"

        section .rodata

type    BASIC_S object
BASIC_S db      "BASIC STUB", 0

        section .text

; --------------------------------------------------
; BIOS 0x18 ISR
; --------------------------------------------------
        global  int18h_isr
int18h_isr:
        sti

        mov     ax, ROM_SEG
        mov     es, ax
        mov     ah, 0x13
        mov     bp, BASIC_S
        int     0x10
        cli
        jmp     $
