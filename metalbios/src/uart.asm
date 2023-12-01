; =====================================================
;
; UART functions (via 16550)
; https://media.digikey.com/pdf/Data%20Sheets/Texas%20Instruments%20PDFs/PC16550D.pdf
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "ports.inc"

        section .text

LCR_5BIT        equ     0x00
LCR_6BIT        equ     0x01
LCR_7BIT        equ     0x02
LCR_8BIT        equ     0x03
LCR_EXTRASTOP   equ     0x04
LCR_PAR_ENABLE  equ     0x08
LCR_PAR_EVEN    equ     0x10
LCR_PAR_STICK   equ     0x20
LCR_BREAK_CTRL  equ     0x40
LCR_DLAB        equ     0x80

LSR_DATA_READY  equ     0x01
LSR_THRE        equ     0x20

; ================================================
; UART
; ================================================

; --------------------------------------------------
; Initialize UART
; --------------------------------------------------
        global  uart_init
uart_init:
        push    ax

        ; Select DLAB register
        mov     al, LCR_DLAB
        out     UA_LCR, al

        ; Set bit rate
        mov     al, 0x0C  ; 9600 kbps
        out     UA_DLL, al
        xor     al, al
        out     UA_DLM, al

        ; Set LCR flags (8-N-1), clear DLAB bit
        mov     al, LCR_8BIT
        out     UA_LCR, al

        ; Disable all interrupts (clear bits 0..3 of IER)
        ; Bit 0 - received data available interrupt
        ; Bit 1 - transmitter holding register empty interrupt
        ; Bit 2 - receiver line status interrupt
        ; Bit 3 - modem status interrupt
        ; Bits 4..7 - always zero
        mov     al, 0x0
        out     UA_IER, al

        ; Enable FIFO
        mov     al, 0x01
        out     UA_FCR, al

        pop     ax
        ret

; --------------------------------------------------
; Write byte
; --------------------------------------------------
; Args:
;   AL - byte
        global  uart_send
uart_send:
        push    ax

        xchg    al, ah
.wait:
        in      al, UA_LSR
        test    al, LSR_THRE
        jz      .wait
        xchg    al, ah
        out     UA_THR, al

        pop     ax
        ret

; --------------------------------------------------
; Write word in hex format
; --------------------------------------------------
; Args:
;   AX - word
        global  uart_sendword
uart_sendword:
        xchg    al, ah
        call    uart_sendhex
        xchg    al, ah
        call    uart_sendhex

        ret

; --------------------------------------------------
; Write byte in hex format
; --------------------------------------------------
; Args:
;   AL - byte
        global  uart_sendhex
uart_sendhex:
        push    bx
        mov     bx, ax

        shr     al, 1
        shr     al, 1
        shr     al, 1
        shr     al, 1
        call    uart_sendnibble
        mov     al, bl
        call    uart_sendnibble

        mov     ax, bx
        pop     bx
        ret

uart_sendnibble:
        and     al, 0x0F
        cmp     al, 0x0A
        jb      .digit
        add     al, 'A' - 0x0A  ; 55
        jmp     .done
.digit:
        add     al, '0'
.done:
        call    uart_send

        ret

; --------------------------------------------------
; Read byte
; --------------------------------------------------
; Return:
;   AL - byte
        global  uart_receive
uart_receive:
        in      al, UA_LSR
        test    al, LSR_DATA_READY
        jz      uart_receive

        in      al, UA_RBR
        ret

; --------------------------------------------------
; Get line status
; --------------------------------------------------
; Return:
;   AL - LSR value
        global  uart_line_status
uart_line_status:
        in      al, UA_LSR
        ret

; --------------------------------------------------
; Get MODEM status
;
; WARNING: /CTS is used for SPI (MISO)
; --------------------------------------------------
; Return:
;   AL - MSR value
        global  uart_modem_status
uart_modem_status:
        in      al, UA_MSR
        ret
