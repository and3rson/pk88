; =====================================================
;
; IRQ1 handler (keyboard via 8255 PPI)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "sys.inc"
        %include "ports.inc"
        %include "bda.inc"

        section .rodata

FLAG_BREAK      equ     0x01
FLAG_EXT        equ     0x02

; KEYMAP:
;             db "?????????????\t`?" ; 00-0F
;             db "?????q1???zsaw2?" ; 10-1F
;             db "?cxde43?? vftr5?" ; 20-2F
;             db "?nbhgy6???mju78?" ; 30-3F
;             db "?,kio09??./l;p-?" ; 40-4F
;             db "??'?[=????",0x0a,"]?\\??" ; 50-5F
;             db "??????",0x08,"??1?47???" ; 60-6F
;             db "0.2568",0x1b,"??+3-*9??" ; 70-7F
;             db "????????????????" ; 80-8F
;             db "????????????????" ; 90-9F
;             db "????????????????" ; A0-AF
;             db "????????????????" ; B0-BF
;             db "????????????????" ; C0-CF
;             db "????????????????" ; D0-DF
;             db "????????????????" ; E0-EF
;             db "????????????????" ; F0-FF
KEYMAP:
        ;               F9              F5      F3      F1      F2      F12                     F10     F8      F6      F4      TAB     `
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,

        ;               LALT    LSHIFT          LCTRL   Q       1                                       Z       S       A       W       2
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x1F73, 0x1E61, 0x0000, 0x0000, 0x0000,

        ;               C       X       D       E       4       3                               SPACE   V       F       T       R       5
        dw      0x0000, 0x0000, 0x0000, 0x1F64, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,

        ;               N       B       H       G       Y       6                                       M       J       U       7       8
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,

        ;               ,       K       I       O       0       9                               .       /       L       ;       P       -
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,

        ;                       '               [       =                                       CAPS    RSHIFT  ENTER   ]               \
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,

        ;                                                       BKSPC                           KP1             KP4     KP7
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,

        ;       KP0     KP.     KP2     KP5     KP6     KP8     ESC     NUM             F11     KP+     KP3     KP-     KP*     KP9     SCRL
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,

        ;                               F7
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,


; KEYMAP_SHIFTED:
;             db "????????????? ~?" ; 00-0F
;             db "?????Q!???ZSAW@?" ; 10-1F
;             db "?CXDE#$?? VFTR%?" ; 20-2F
;             db "?NBHGY^???MJU&*?" ; 30-3F
;             db "?<KIO)(??>?L:P_?" ; 40-4F
;             db "??",'"',"?{+?????}?|??" ; 50-5F
;             db "?????????1?47???" ; 60-6F
;             db "0.2568???+3-*9??" ; 70-7F
;             db "????????????????" ; 80-8F
;             db "????????????????" ; 90-9F
;             db "????????????????" ; A0-AF
;             db "????????????????" ; B0-BF
;             db "????????????????" ; C0-CF
;             db "????????????????" ; D0-DF
;             db "????????????????" ; E0-EF
;             db "????????????????" ; F0-FF

        section .text

; --------------------------------------------------
; BIOS 0x09 ISR
; --------------------------------------------------
        global  int09h_isr
int09h_isr:
        ; Timing is extremely tight here @ 5 MHz.
        ;
        ; This takes ~25us for first 10 bits of PS/2 packet, and INT 0x8 handler takes roughly the same amount of time.
        ; Together with some INT overhead, they take ~50us, which is almost 10KHz and just enough to miss PS/2 interrupt,
        ; since 8259 will deassert INT 1 if we miss it, so the bit will be lost.
        ;
        ; If any slow code is added into INT 0x1C handler, we're going to miss data here.
        ; This is a problem with bit-banging. It's a magical hell.
        ;
        ; I might use an actual hardware driver for PS/2 in the future.

        push    ax
        push    ds

        ; mov     al, 0b00001010  ; SCK = 1
        ; out     UA_MCR, al      ; Write SCK

        mov     ax, BDA_SEG
        mov     ds, ax

        ; Read bit 0 from PPI port A
        in      al, PPI_A

        ; Shift data bit into buffer
        rcr     al, 1           ; Shift data bit to carry flag
        mov     ax, [BDA_KB_BITBANG_BUFFER]
        rcr     ax, 1           ; Shift data bit into buffer
        mov     [BDA_KB_BITBANG_BUFFER], ax

        test    al, 0b00100000  ; Has start bit been shifted in?
        jnz     .done           ; No, frame not ready yet

        ; Byte ready
        shl     ax, 1
        shl     ax, 1
        xchg    al, ah
        call    process_frame

        ; Reset buffer
        mov     word [BDA_KB_BITBANG_BUFFER], 0xFFFF

.done:
        ; mov     al, 0b00001011  ; SCK = 0
        ; out     UA_MCR, al      ; Write SCK

        pop     ds
        pop     ax

        iret

; --------------------------------------------------
; Process received byte
; --------------------------------------------------
; Args:
;   AL - received byte
;   DS - must contain BDA_SEG
process_frame:
        push    ax
        push    bx
        push    es

        mov     bx, ROM_SEG
        mov     es, bx

        cmp     al, 0xAA        ; Is BAT code?
        je      .done
        cmp     al, 0xF0        ; Is break code marker?
        je      .break
        cmp     al, 0xE0        ; Is extended code marker?
        je      .ext

.normal:
        ; Received scan code
        mov     ah, [BDA_KB_BITBANG_FLAGS]
        mov     bl, 0
        mov     [BDA_KB_BITBANG_FLAGS], bl

        and     ah, FLAG_BREAK
        jnz     .done           ; Don't process break codes

        ; TODO: handle FLAG_EXT
        xor     bx, bx
        mov     bl, al
        shl     bx, 1
        ;
        mov     ax, es:[KEYMAP+bx]
        ; xor     ah, ah
        ;
        mov     [BDA_KB_BITBANG_VALUE], ax
        jmp     .done

.break:
        ; Received break code marker
        or      byte [BDA_KB_BITBANG_FLAGS], FLAG_BREAK
        jmp     .done

.ext:
        ; Received extended code marker
        or      byte [BDA_KB_BITBANG_FLAGS], FLAG_EXT
        jmp     .done

.done:
        pop     es
        pop     bx
        pop     ax
        ret
