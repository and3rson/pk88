; =====================================================
;
; BIOS interrupts
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        %include "include/sys.inc"

        %include "int10h.asm"

; Init interrupt table
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
        add     bx, isr_handlers
        mov     bx, [cs:bx]
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
        dw      isr_stub        ; 0x08 - RTC
        dw      isr_stub        ; 0x09 - Keyboard
        dw      isr_stub
        dw      isr_stub
        dw      isr_stub
        dw      isr_stub
        dw      isr_stub
        dw      isr_stub
        dw      int10h_isr      ; 0x10 - Video services
        dw      isr_stub        ; 0x11 - Equipment list
        dw      isr_stub        ; 0x12 - Conventional memory size
        dw      isr_stub        ; 0x13 - Low level disk services
        dw      isr_stub        ; 0x14 - Serial port services
        dw      isr_stub        ; 0x15 - Misc system services
        dw      isr_stub        ; 0x16 - Keyboard services
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

