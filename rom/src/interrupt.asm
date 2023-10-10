; =====================================================
;
; BIOS interrupts
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "sys.inc"

        extern  int08h_isr
        extern  int10h_isr
        extern  int11h_isr
        extern  int12h_isr
        extern  int13h_isr
        extern  int16h_isr

        section .text

; Init interrupt table
        global  interrupt_init
interrupt_init:
        push    bx
        push    cx
        push    ds
        push    di

        ; Set DS to RAM start
        xor     bx, bx
        mov     ds, bx

        xor     cx, cx  ; Source index counter
        xor     di, di  ; Destination address counter
.next:
        ; Load ISR address into BX
        mov     bx, cx
        shl     bx, 1
        mov     bx, [cs:bx+isr_handlers]
        ; Write ISR segment and offset
        mov     [di], bx
        mov     [di + 2], cs
        ; Increase source index
        inc     cx
        ; Increase destination address
        add     di, 4
        ; Loop
        cmp     cx, isr_handlers_len
        jne     .next

        pop     di
        pop     ds
        pop     cx
        pop     bx

        ret

isr_handlers:
        dw      isr_stub        ; 0x00
        dw      isr_stub
        dw      isr_stub
        dw      isr_stub
        dw      isr_stub
        dw      isr_stub        ; 0x05 - Shift-PrtScr
        dw      isr_stub
        dw      isr_stub
        ; IRQ0..IRQ7
        dw      int08h_isr      ; IRQ0 - RTC
        dw      isr_stub        ; IRQ1 - Keyboard
        dw      isr_stub
        dw      isr_stub
        dw      isr_stub        ; IRQ4 - Serial port
        dw      isr_stub
        dw      isr_stub
        dw      isr_stub
        dw      int10h_isr      ; 0x10 - Video services
        dw      int11h_isr      ; 0x11 - Equipment list
        dw      int12h_isr      ; 0x12 - Conventional memory size
        dw      int13h_isr      ; 0x13 - Low-level disk services
        dw      isr_stub        ; 0x14 - Serial port services
        dw      isr_stub        ; 0x15 - Misc system services
        dw      int16h_isr      ; 0x16 - Keyboard services
        dw      isr_stub        ; 0x17 - Printer services
        dw      isr_stub        ; 0x18 - Execute Casette BASIC
        dw      isr_stub        ; 0x19 - Soft reboot
        dw      isr_stub        ; 0x1A - RTC services
        dw      isr_stub        ; 0x1B - CTRL-Break handler
        dw      isr_stub        ; 0x1C - Timer tick handler (called by INT 0x08)
        dw      isr_stub        ; 0x1D - Reserved (pointer to Video Parameter Table)
        dw      isr_stub        ; 0x1E - Reserved (pointer to Diskette Parameter Table)
        dw      isr_stub        ; 0x1F - Reserved (pointer to Video Graphics Character Table)
isr_handlers_len \
        equ     ($ - isr_handlers) / 2

isr_stub:
        iret

