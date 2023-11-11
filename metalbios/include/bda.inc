; =====================================================
;
; BIOS Data Area (BDA) locations
;
; http://www.bioscentral.com/misc/bda.htm
; http://www.mcamafia.de/pdf/ps2bios3.pdf
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
BDA_COL_PER_ROW         equ     0x4A
BDA_SIZE_OF_ACTVE_VID   equ     0x4C
BDA_VIDEO_PAGE_OFFSET   equ     0x4E
BDA_CURSOR_POS_P1       equ     0x50  ; High byte (1) = row, low byte (0) = column
BDA_CURSOR_POS_P3       equ     0x54
BDA_CURSOR_POS_P4       equ     0x56
BDA_CURSOR_POS_P5       equ     0x58
BDA_CURSOR_POS_P6       equ     0x5A
BDA_CURSOR_POS_P7       equ     0x5C
BDA_CURSOR_POS_P8       equ     0x5E
BDA_CURSOR_SHAPE        equ     0x60
BDA_ACTIVE_VIDEO_PAGE   equ     0x62
BDA_VDA_PORT            equ     0x63
BDA_VDA_INT_MODE_REG    equ     0x65
BDA_COLOR_PAL           equ     0x66

%endif
