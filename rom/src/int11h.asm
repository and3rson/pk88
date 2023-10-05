; =====================================================
;
; Equipment list (BIOS int 0x11)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

NUM_PRINTERS \
        equ     0  ; 2 bits
INTERNAL_MODEM \
        equ     0  ; 1 bit
GAME_ADAPTER \
        equ     0  ; 1 bit
RS232_PORTS \
        equ     0  ; 3 bits
NUM_DISKETTES \
        equ     0  ; 2 bit
INITIAL_VIDEO_MODE \
        equ     0  ; 2 bits
MATH_COPRORESSOR \
        equ     0  ; 1 bit
DISKETTES_PRESENT \
        equ     0  ; 1 bit

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


; BIOS 0x11 ISR
int11h_isr:
        mov     ax, EQUIPMENT_LIST

        iret
