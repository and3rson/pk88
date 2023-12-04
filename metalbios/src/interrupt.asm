; =====================================================
;
; BIOS interrupts
;
; This file is part of MetalBIOS for PK-88.
;
; https://pdf.datasheetcatalog.com/datasheet/oki/MSM82C53-2JS.pdf
;
; =====================================================

        cpu     8086
        bits    16

        %include "sys.inc"
        %include "ports.inc"
        %include "macros.inc"

        extern  int03h_isr
        extern  irq0h_isr
        extern  irq1h_isr
        extern  int0Fh_isr
        extern  int10h_isr
        extern  int11h_isr
        extern  int12h_isr
        extern  int13h_isr
        extern  int16h_isr
        extern  int19h_isr
        extern  int1Bh_isr
        extern  int1Ch_isr
        extern  int88h_isr
        extern  lcd_printbyte

        section .rodata

STUB_S  db      "!0x", 0

        section .text

; --------------------------------------------------
; Init interrupt table
; --------------------------------------------------
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

        ; Set INT 0x88 ISR
        mov     bx, int88h_isr
        mov     [0x88 * 4], bx
        mov     [0x88 * 4 + 2], cs

        ; Initialize 8259 PIC
        ; https://www.geeksforgeeks.org/command-words-of-8259-pic/

        ; ICW1
        mov     al, 0b00010111
        ; 0 0 0 1 0 1 1 1
        ; ^ ^ ^ ^ ^ ^ ^ ^
        ; | | | | | | | |
        ; | | | | | | | +-- 1: ICW4 needed
        ; +++++ | | | +--- 1: single mode
        ;   |   | | +---- 1: CALL address interval (4)
        ;   |   | +----- 0: Edge triggered mode
        ;   |   +------ 1: D4 must be 1 for ICW1
        ;   +-------- 000: MCS-80/85 mode only
        out     PIC_A0, al

        ; ICW2
        mov     al, 0b00001000  ; IRQ0 = INT 0x08 (D7..D3 = T7..T3)
        out     PIC_A1, al

        ; ICW4
        mov     al, 0b00000011
        ; 0 0 0 0 0 X 1 1
        ; ^ ^ ^ ^ ^ ^ ^ ^
        ; | | | | | | | |
        ; | | | | +++ | +- 1: 8086/8088 mode
        ; +++++ |  |  +-- 1: auto end-of-interrupt
        ;   |   |  +---- 0X: non-buffered mode
        ;   |   +------ 0: not special fully nested mode
        ;   +-------- 000
        out     PIC_A1, al

        pop     di
        pop     ds
        pop     cx
        pop     bx

        ret

isr_handlers:
        ; Interrupts 0x00..0x07
        dw      isr_stub00      ; 0x00 - Divide error
        dw      isr_stub01      ; 0x01 - Single step
        dw      isr_stub02      ; 0x02 - NMI
        dw      int03h_isr      ; 0x03 - 1-byte int instruction
        dw      isr_stub04      ; 0x04 - Overflow
        dw      isr_stub05      ; 0x05 - Shift-PrtScr
        dw      isr_stub06
        dw      isr_stub07
        ; IRQ0..IRQ7 (interrupts 0x08..0x0F)
        dw      irq0h_isr       ; IRQ0 - RTC
        dw      irq1h_isr       ; IRQ1 - Keyboard
        dw      isr_stub0A
        dw      isr_stub0B
        dw      isr_stub0C      ; IRQ4 - Serial port
        dw      isr_stub0D
        dw      isr_stub0E
        dw      isr_stub0F
        ; Interrupts 0x10..0x1F
        dw      int10h_isr      ; 0x10 - Video services
        dw      int11h_isr      ; 0x11 - Equipment list
        dw      int12h_isr      ; 0x12 - Conventional memory size
        dw      int13h_isr      ; 0x13 - Low-level disk services
        dw      isr_stub14      ; 0x14 - Serial port services
        dw      isr_stub15      ; 0x15 - Misc system services
        dw      int16h_isr      ; 0x16 - Keyboard services
        dw      isr_stub17      ; 0x17 - Printer services
        dw      isr_stub18      ; 0x18 - Execute Casette BASIC
        dw      int19h_isr      ; 0x19 - Boot/reboot system, called after POST
        dw      isr_stub1A      ; 0x1A - RTC services
        dw      int1Bh_isr      ; 0x1B - CTRL-Break handler
        dw      int1Ch_isr      ; 0x1C - Timer tick handler (called by INT 0x08)
        dw      isr_stub1D      ; 0x1D - Reserved (pointer to Video Parameter Table)
        dw      isr_stub1E      ; 0x1E - Reserved (pointer to Diskette Parameter Table)
        dw      isr_stub1F      ; 0x1F - Reserved (pointer to Video Graphics Character Table)
isr_handlers_len \
        equ     ($ - isr_handlers) / 2

isr_stub00:
        push    cx
        mov     cl, 0x00
        jmp     isr_stub

isr_stub01:
        push    cx
        mov     cl, 0x01
        jmp     isr_stub

isr_stub02:
        push    cx
        mov     cl, 0x02
        jmp     isr_stub

isr_stub04:
        push    cx
        mov     cl, 0x04
        jmp     isr_stub

isr_stub05:
        push    cx
        mov     cl, 0x05
        jmp     isr_stub

isr_stub06:
        push    cx
        mov     cl, 0x06
        jmp     isr_stub

isr_stub07:
        push    cx
        mov     cl, 0x07
        jmp     isr_stub

isr_stub09:
        push    cx
        mov     cl, 0x09
        jmp     isr_stub

isr_stub0A:
        push    cx
        mov     cl, 0x0A
        jmp     isr_stub

isr_stub0B:
        push    cx
        mov     cl, 0x0B
        jmp     isr_stub

isr_stub0C:
        push    cx
        mov     cl, 0x0C
        jmp     isr_stub

isr_stub0D:
        push    cx
        mov     cl, 0x0D
        jmp     isr_stub

isr_stub0E:
        push    cx
        mov     cl, 0x0E
        jmp     isr_stub

isr_stub0F:
        push    cx
        mov     cl, 0x0E
        jmp     isr_stub

isr_stub14:
        push    cx
        mov     cl, 0x14
        jmp     isr_stub

isr_stub15:
        push    cx
        mov     cl, 0x15
        jmp     isr_stub

isr_stub17:
        push    cx
        mov     cl, 0x17
        jmp     isr_stub

isr_stub18:
        push    cx
        mov     cl, 0x18
        jmp     isr_stub

isr_stub19:
        push    cx
        mov     cl, 0x19
        jmp     isr_stub

isr_stub1A:
        push    cx
        mov     cl, 0x1A
        jmp     isr_stub

isr_stub1B:
        push    cx
        mov     cl, 0x1B
        jmp     isr_stub

isr_stub1C:
        push    cx
        mov     cl, 0x1C
        jmp     isr_stub

isr_stub1D:
        push    cx
        mov     cl, 0x1D
        jmp     isr_stub

isr_stub1E:
        push    cx
        mov     cl, 0x1E
        jmp     isr_stub

isr_stub1F:
        push    cx
        mov     cl, 0x1F
        jmp     isr_stub

isr_stub:
        push    ax
        push    bp
        push    es

        mov     ax, ROM_SEG
        mov     es, ax
        mov     ah, 0x13
        mov     bp, STUB_S
        int     0x10

        mov     al, cl
        call    lcd_printbyte

        pop     es
        pop     bp
        pop     ax
        pop     cx

        stc
        iretc
