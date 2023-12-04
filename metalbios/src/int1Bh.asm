; =====================================================
;
; CTRL-Break handler stub (called by int 09h)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "macros.inc"

; --------------------------------------------------
; BIOS 0x1B ISR
; --------------------------------------------------
        global  int1Bh_isr
int1Bh_isr:
        sti

        ; no-op
        iret
