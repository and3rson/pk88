; =====================================================
;
; 8253 PIT functions
; https://www.cpcwiki.eu/imgs/e/e3/8253.pdf
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "sys.inc"
        %include "ports.inc"

        section .text

COUNT   equ     0x8000  ; 24 ms @ 16.384 MHz

; -----------------------------------------------------
; Initialize 8253 PIT
; -----------------------------------------------------
        global  pit_init
pit_init:
        push    ax
        ; Control word:
        ; 0 0 1 1 0 0 0 0
        ; ^ ^ ^ ^ ^ ^ ^ ^
        ; | | | | | | | |
        ; | | | | +++++ |
        ; | | +++   |   +-- 0 - 16-bit binary counter, 1 - 4-digit BCD counter
        ; +++  |    +----- mode (0-5)
        ;  |   +--------- 00 - counter latching operation, 01 - read/write LSB only, 10 - read/write MSB only, 11 - read/write LSB then MSB
        ;  +------------ 00 - channel 0, 01 - channel 1, 10 - channel 2

        ; Timer 0
        mov     al, 00_11_000_0b  ; LSB then MSB, mode 0, 16-bit binary counter
        out     TIM_CMD, al
        mov     ax, COUNT
        out     TIM0, al        ; High/low bytes must be written separately
        xchg    al, ah
        out     TIM0, al

        ; Timer 1
        mov     al, 01_11_000_0b  ; LSB then MSB, mode 0, 16-bit binary counter
        out     TIM_CMD, al

        ; Timer 2
        ; TODO: Square wave generator for buzzer
        mov     al, 10_11_000_0b  ; LSB then MSB, mode 0, 16-bit binary counter
        out     TIM_CMD, al

        pop     ax
        ret

; -----------------------------------------------------
; Restart timer 0
; -----------------------------------------------------
        global  pit_restart_timer0
pit_restart_timer0:
        push    ax

        ; Write control word
        mov     al, 00_11_000_0b  ; LSB then MSB, mode 0, 16-bit binary counter

        ; Write count
        mov     al, (COUNT & 0xFF)
        out     TIM0, al        ; High/low bytes must be written separately
        mov     al, ((COUNT >> 8) & 0xFF)
        out     TIM0, al

        pop     ax

        ret
