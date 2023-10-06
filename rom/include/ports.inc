; =====================================================
;
; I/O port numbers
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

%ifndef PORTS_INC
        %define PORTS_INC

; DIP switches & LEDs are on port 0x0
IO_LEDS equ 0x0
IO_DIPS equ 0x0
; 8255 is on ports 0x100..0x103
IO_A    equ 0x100
IO_B    equ 0x101
IO_C    equ 0x102
IO_CTRL equ 0x103

%endif
