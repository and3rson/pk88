; =====================================================
;
; Keyboard functions (GAL22V10)
; http://forum.6502.org/viewtopic.php?f=10&t=7833
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "sys.inc"
        %include "ports.inc"

        section .text

; -----------------------------------------------------
; Initialize keyboard controller
; -----------------------------------------------------
        global  keyboard_init
keyboard_init:
        out     KB_RES, al

        ret

; -----------------------------------------------------
; Read byte from keyboard buffer & clear it
; -----------------------------------------------------
; Returns:
;   AL - PS/2 byte
        global  keyboard_read
keyboard_read:
        ; Read keyboard byte
        in      al, KB_DAT
        ; xor     al, 0xFF

        ; Reset keyboard controller
        out     KB_RES, al

        ret
