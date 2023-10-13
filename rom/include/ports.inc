; =====================================================
;
; I/O port numbers
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

%ifndef PORTS_INC
        %define PORTS_INC

; UCI6963 LCD (40x08)
; https://www.buydisplay.com/download/ic/UCi6963C.pdf
LCD     equ     0x08
LCD_DAT equ     LCD + 0
LCD_CMD equ     LCD + 1

; 8259 PIC
PIC     equ     0x20
PIC_CMD equ     PIC + 0
PIC_DAT equ     PIC + 1

; 8253 PIT
PIT     equ     0x40
TIM0    equ     PIT + 0
TIM1    equ     PIT + 1
TIM2    equ     PIT + 2
TIM_CMD equ     PIT + 3

; 8255 PPI
PPI     equ     0x60
IO_A    equ     PPI + 0
IO_B    equ     PPI + 1
IO_C    equ     PPI + 2
IO_CTRL equ     PPI + 3

; 8251 UART
; https://media.digikey.com/pdf/Data%20Sheets/Texas%20Instruments%20PDFs/PC16550D.pdf
UART    equ     0xf8
; DLAB = 0
UA_RBR  equ     UART + 0  ; Received Buffer Register (READ)
UA_THR  equ     UART + 0  ; Transmitter Holding Register (WRITE)
UA_IER  equ     UART + 1  ; Interrupt Enable Register
UA_IIR  equ     UART + 2  ; Interrupt Identification Register (READ)
UA_FCR  equ     UART + 2  ; FIFO Control Register (WRITE)
UA_LCR  equ     UART + 3  ; Line Control Register (bit 7 = DLAB)
UA_MCR  equ     UART + 4  ; MODEM Control Register
UA_LSR  equ     UART + 5  ; Line Status Register
UA_MSR  equ     UART + 6  ; MODEM Status Register
UA_SCR  equ     UART + 7  ; Scratch Register
; DLAB = 1
UA_DLL  equ     UART + 0  ; Divisor Latch (LS)
UA_DLM  equ     UART + 1  ; Divisor Latch (MS)

%endif
