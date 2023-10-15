; =====================================================
;
; BIOS Data Area (BDA) locations
; http://www.bioscentral.com/misc/bda.htm
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

%ifndef BDA_INC
        %define BDA_INC

BDA_SEG                 equ     0x40

BDA_COM1_ADDR           equ     0x00
BDA_COM2_ADDR           equ     0x02
BDA_COM3_ADDR           equ     0x04
BDA_COM4_ADDR           equ     0x06
BDA_LPT0_ADDR           equ     0x08
BDA_LPT1_ADDR           equ     0x0A
BDA_LPT2_ADDR           equ     0x0C
BDA_LPT3_ADDR           equ     0x0E
BDA_EQUIP_WORD          equ     0x10
BDA_INT_FLAG_MF_TST     equ     0x12
BDA_MEM_SIZE_KB         equ     0x13
BDA_AT_ERROR_CODES      equ     0x15  ; Error codes for AT+; Adapter memory size for PC and XT
BDA_KBD_SFT_FLG1        equ     0x17
BDA_KBD_SFT_FLG2        equ     0x18
BDA_ALT_NMPD_WRK_AREA   equ     0x19
BDA_KBD_NEXT_CHAR_PTR   equ     0x1A
BDA_KBD_LAST_CHAR_PTR   equ     0x1C
BDA_KBD_BUFFER          equ     0x1E  ; 32 bytes
BDA_FLOP_CALIBR_STAT    equ     0x3E
BDA_FLOP_MOTOR_STAT     equ     0x3F
BDA_FLOP_MOTOR_TIMEOUT  equ     0x40
BDA_FLOP_STAT           equ     0x41
BDA_HDD_FLOP_CTRL_STAT  equ     0x42
BDA_FLOP_CTRL_STAT1     equ     0x43
BDA_FLOP_CTRL_STAT2     equ     0x44
BDA_FLOP_CYL_NUM        equ     0x45
BDA_FLOP_HEAD_NUM       equ     0x46
BDA_FLOP_SECTOR_NUM     equ     0x47
BDA_FLOP_BYTES_WRITTEN  equ     0x48
BDA_VIDEO_MODE_ACTIVE   equ     0x49  ; Should be 7 for ELKS BIOS console to force 1 page?




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
