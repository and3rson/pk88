; =====================================================
;
; Equipment list (BIOS int 0x11)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

NUM_PRINTERS            equ     0  ; 2 bits
INTERNAL_MODEM          equ     0  ; 1 bit
GAME_ADAPTER            equ     0  ; 1 bit
RS232_PORTS             equ     1  ; 3 bits
NUM_DISKETTES           equ     0  ; 2 bit
INITIAL_VIDEO_MODE      equ     0  ; 2 bits
MATH_COPRORESSOR        equ     0  ; 1 bit
DISKETTES_PRESENT       equ     0  ; 1 bit

; https://grandidierite.github.io/bios-interrupts/
; Section "Interrupt 11H (int 11h) Read Equipment-List"
EQUIPMENT_LIST \
        equ ( \
                NUM_PRINTERS << 14 | \
                INTERNAL_MODEM << 13 | \
                GAME_ADAPTER << 12 | \
                RS232_PORTS << 9 | \
                NUM_DISKETTES << 6 | \
                INITIAL_VIDEO_MODE << 4 | \
                MATH_COPRORESSOR << 2 | \
                DISKETTES_PRESENT \
        )

        %include "bda.inc"

        section .text

; Init BDA for equipment list
        global  equipment_list_init
equipment_list_init:
        push    ax
        push    es

        mov     ax, BDA_SEG
        mov     es, ax
        mov     [es:BDA_EQUIP_WORD], word EQUIPMENT_LIST

        pop     es
        pop     ax
        ret

; --------------------------------------------------
; BIOS 0x11 ISR
; --------------------------------------------------
        global  int11h_isr
int11h_isr:
        push    ax
        push    es

        mov     ax, BDA_SEG
        mov     es, ax
        mov     ax, [es:BDA_EQUIP_WORD]

        pop     es
        pop     ax

        clc
        iret
