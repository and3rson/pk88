; =====================================================
;
; Serial port (BIOS int 0x14)
; https://www.plantation-productions.com/Webster/www.artofasm.com/DOS/ch13/CH13-3.html
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "macros.inc"

        section .text

        extern  uart_init
        extern  uart_send
        extern  uart_receive
        extern  uart_line_status
        extern  uart_modem_status

; --------------------------------------------------
; BIOS 0x14 ISR
; --------------------------------------------------
; Args:
;   AH - function number
        global  int14h_isr
int14h_isr:
        push    bx  ; Save BX to perform pointer arithmetic

        mov     bl, ah
        xor     bh, bh  ; BX now contains function number

        ; Load int14h_function_table with BX*2 offset into BX
        shl     bx, 1
        mov     bx, [cs:bx+int14h_function_table]

        call    bx  ; Call appropriate function

        pop     bx

        iretc

int14h_function_table:
        dw      init_serial_port
        dw      transmit_byte
        dw      receive_byte
        dw      serial_port_status

; --------------------------------------------------
; Function 00h: Init serial port
; --------------------------------------------------
; Args:
;   DX - port number (ignored)
;   AL - parameters (ignored)
;       AL[7:5] - baud rate (001=150, 010=300, ..., 111=9600)
;       AL[4] - 1 = odd, 0 = even parity
;       AL[3] - parity enable
;       AL[2] - 0 = 1 stop bit, 1 = 2 stop bits
;       AL[1:0] - byte size (00=5, 01=6, 10=7, 11=8)
init_serial_port:
        call    uart_init
        clc
        ret

; --------------------------------------------------
; Function 01h: Transmit byte
; --------------------------------------------------
; Args:
;   DX - port number (ignored)
;   AL - byte
;   AH - error status, bit 7 set on error (ignored)
transmit_byte:
        call    uart_send
        xor     ah, ah
        clc
        ret

; --------------------------------------------------
; Function 02h: Receive byte
; --------------------------------------------------
; Args:
;   DX - port number (ignored)
; Return:
;   AL - byte
;   AH - error status, bit 7 set on error (ignored)
receive_byte:
        call    uart_receive
        xor     ah, ah
        clc
        ret

; --------------------------------------------------
; Function 03h: Serial port status
; --------------------------------------------------
; Return:
;   DX - port number (ignored)
;   AX - status
;       AX[15] - timeout error
;       AX[14] - transmitter shift register empty
;       AX[13] - transmitter holding register empty
;       AX[12] - break detection error
;       AX[11] - framing error
;       AX[10] - parity error
;       AX[9] - overrun error
;       AX[8] - data available
;       AX[7] - receive line signal detect
;       AX[6] - ring indicator
;       AX[5] - data set ready (DSR)
;       AX[4] - clear to sent (CTS)
;       AX[3] - delta receive line signal detect
;       AX[2] - trailing edge ring detector
;       AX[1] - delta data set ready
;       AX[0] - delta clear to send
serial_port_status:
        ; AH = 16550 LSR
        ; AL = 16550 MSR
        call    uart_line_status
        xchg    al, ah
        call    uart_modem_status
        clc
        ret
