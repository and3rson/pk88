; =====================================================
;
; PPI functions (via 8255 PPI)
; http://aturing.umcs.maine.edu/~meadow/courses/cos335/Intel8255A.pdf
; https://www.renesas.com/us/en/document/dst/82c55a-datasheet
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "ports.inc"
        %include "bda.inc"

        section .text

; -----------------------------------------------------
; Initialize PPI
;
; Port A: input (mode 1, strobed)
;   Bit 0: PS/2 data
; Port B: output, mode 0
;   Bit 0: buzzer enable
;   Bit 4: MCB (pulled down, disables BIOS ROM when high and maps 0xF0000-0xFFFFF to RAM)
; Port C: control lines
;   Bit 3: INT on PS/2 bit receive
;   Bit 4: PS/2 clock input
; -----------------------------------------------------
        global  ppi_init
ppi_init:
        push    ax
        push    es

        mov     al, 0b1_0110_000  ; Port A: input (mode 1, strobed), port B: output (mode 0)
        ; 1 X X X X X X X
        ; ^ ^ ^ ^ ^ ^ ^ ^
        ; | | | | | | | |
        ; | | | | | | | +-- Port C (lower), 1 = input, 0 = output
        ; | +++ | | | +--- Port B, 1 = input, 0 = output
        ; |  |  | | +---- Mode for group B
        ; |  |  | |
        ; |  |  | +----- Port C (upper), 1 = input, 0 = output
        ; |  |  +------ Port A, 1 = input, 0 = output
        ; |  +------- Mode for group A
        ; |
        ; +---------- 1: Mode set flag
        out     PPI_CTL, al

        ; Enable interrupts for port A by writing 1 to port C bit 4
        mov     al, 0b0_000_100_1
        ; 0 - - - X X X X
        ; ^ ^ ^ ^ ^ ^ ^ ^
        ; | | | | | | | |
        ; | +++++ +++++ +-- 1 = set, 0 = reset
        ; |   |     |
        ; |   |     +----- Bit number
        ; |   |
        ; |   +---------- Don't care
        ; |
        ; +------------- 0: Bit set/reset flag
        out     PPI_CTL, al

        ; Clear IBF_A flag by reading port A
        in      al, PPI_A

        ; Init keyboard buffers
        ; TODO: Move this out
        mov     ax, BDA_SEG
        mov     es, ax
        mov     word [es:BDA_KB_VALUE], 0
        mov     byte [es:BDA_KB_FLAGS], 0
        mov     byte [es:BDA_KB_MODS], 0

        pop     es
        pop     ax
        ret
