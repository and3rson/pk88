; =====================================================
;
; INT 3 handler
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        extern  lcd_printm
        extern  lcd_printword

        section .text

; --------------------------------------------------
; BIOS 0x08 ISR
;
; Dump all register to screen and halt
; --------------------------------------------------
        global  int03h_isr
int03h_isr:
        push    ax

        call    lcd_printm
        db      13, 10, "AX=", 0
        call    lcd_printword

        call    lcd_printm
        db      " BX=", 0
        mov     ax, bx
        call    lcd_printword

        call    lcd_printm
        db      " CX=", 0
        mov     ax, cx
        call    lcd_printword

        call    lcd_printm
        db      " DX=", 0
        mov     ax, dx
        call    lcd_printword

        call    lcd_printm
        db      10, 13, 0

        call    lcd_printm
        db      "SI=", 0
        mov     ax, si
        call    lcd_printword

        call    lcd_printm
        db      " DI=", 0
        mov     ax, di
        call    lcd_printword

        call    lcd_printm
        db      " BP=", 0
        mov     ax, bp
        call    lcd_printword

        call    lcd_printm
        db      " SP=", 0
        mov     ax, sp
        add     ax, 2
        call    lcd_printword

        call    lcd_printm
        db      10, 13, 0

        call    lcd_printm
        db      "CS=", 0
        mov     ax, cs
        call    lcd_printword

        call    lcd_printm
        db      " DS=", 0
        mov     ax, ds
        call    lcd_printword

        call    lcd_printm
        db      " ES=", 0
        mov     ax, es
        call    lcd_printword

        call    lcd_printm
        db      " SS=", 0
        mov     ax, ss
        call    lcd_printword

        call    lcd_printm
        db      10, 13, 0

        pop     ax

        hlt
