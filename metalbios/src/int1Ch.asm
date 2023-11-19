; =====================================================
;
; RTC handler stub (called by int 08h)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

; --------------------------------------------------
; BIOS 0x1C ISR
; --------------------------------------------------
        global  int1Ch_isr
int1Ch_isr:
        ; no-op
        clc
        iret
