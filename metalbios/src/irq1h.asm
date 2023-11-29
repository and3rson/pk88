; =====================================================
;
; IRQ1 handler (keyboard via GAL22V10)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "ports.inc"
        %include "sys.inc"
        %include "bda.inc"

        extern  keyboard_read

        section .rodata

FLAG_BREAK      equ     0x01
FLAG_EXT        equ     0x02

KEYMAP:
        ; This basically maps scan codes that come from PS/2 keyboard (set 2) into BIOS scan codes (set 1).

        ;               F9              F5      F3      F1      F2      F12                     F10     F8      F6      F4      TAB     `
        dw      0x0000, 0x4300, 0x0000, 0x3F00, 0x3D00, 0x3B00, 0x3C00, 0x8600,         0x0000, 0x4400, 0x4200, 0x4000, 0x3E00, 0x0F09, 0x0000, 0x0000

        ;               LALT    LSHIFT          LCTRL   Q       1                                       Z       S       A       W       2
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x1071, 0x0231, 0x0000,         0x0000, 0x0000, 0x2C7A, 0x1F73, 0x1E61, 0x1177, 0x0332, 0x0000

        ;               C       X       D       E       4       3                               SPACE   V       F       T       R       5
        dw      0x0000, 0x2E63, 0x2D78, 0x2064, 0x1265, 0x0534, 0x0433, 0x0000,         0x0000, 0x3920, 0x2F76, 0x2166, 0x1474, 0x1372, 0x0635, 0x0000

        ;               N       B       H       G       Y       6                                       M       J       U       7       8
        dw      0x0000, 0x316E, 0x3062, 0x2368, 0x2267, 0x1579, 0x0736, 0x0000,         0x0000, 0x0000, 0x326D, 0x246A, 0x1675, 0x0837, 0x0938, 0x0000

        ;               ,       K       I       O       0       9                               .       /       L       ;       P       -
        dw      0x0000, 0x332C, 0x256B, 0x1769, 0x186F, 0x0B30, 0x0A39, 0x0000,         0x0000, 0x342E, 0x352F, 0x266C, 0x273B, 0x1970, 0x0C2D, 0x0000

        ;                       '               [       =                               CAPS    RSHIFT  ENTER   ]               "\"
        dw      0x0000, 0x0000, 0x2827, 0x0000, 0x1A5B, 0x0D3D, 0x0000, 0x0000,         0x0000, 0x0000, 0x1C0D, 0x1B5D, 0x0000, 0x2B5C, 0x0000, 0x0000

        ;                                                       BKSPC                           KP1             KP4     KP7
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0E08, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000

        ;       KP0     KP.     KP2     KP5     KP6     KP8     ESC     NUM             F11     KP+     KP3     KP-     KP*     KP9     SCRL
        dw      0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x011B, 0x0000,         0x0000, 0x4E2B, 0x0000, 0x4A2D, 0x372A, 0x0000, 0x0000, 0x0000

        ;                               F7
        dw      0x0000, 0x0000, 0x0000, 0x4100, 0x0000, 0x0000, 0x0000, 0x0000,         0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000

        section .text

; --------------------------------------------------
; IRQ 1h ISR
; --------------------------------------------------
        global  irq1h_isr
irq1h_isr:
        push    ax
        push    bx
        push    ds
        push    es

        call    keyboard_read

        ; DS = BDA segment, ES = ROM segment
        mov     bx, BDA_SEG
        mov     ds, bx
        mov     bx, ROM_SEG
        mov     es, bx

        cmp     al, 0xAA        ; Is BAT code?
        je      .done           ; Ignore
        cmp     al, 0xF0        ; Is break code marker?
        je      .break          ; Set break flag
        cmp     al, 0xE0        ; Is extended code marker?
        je      .ext            ; Set extended flag

        ; Got actual scan code

        ; Load & clear flags
        mov     ah, [BDA_KB_FLAGS]
        mov     bl, 0
        mov     [BDA_KB_FLAGS], bl

        ; Is break flag set?
        test    ah, FLAG_BREAK
        jnz     .done           ; Ignore scan code

        test    ah, FLAG_EXT    ; Is extended flag set?
        ; TODO
        jnz     .done           ; Ignore scan code

        ; Convert scan code to 16-bit key code
        xor     bx, bx
        mov     bl, al
        shl     bx, 1

        mov     ax, [es:KEYMAP + bx]
        mov     [BDA_KB_VALUE], ax

        jmp     .done

.break:
        ; Received break code marker
        or      byte [BDA_KB_FLAGS], FLAG_BREAK
        jmp     .done

.ext:
        ; Received extended code marker
        or      byte [BDA_KB_FLAGS], FLAG_EXT

.done:
        pop     es
        pop     ds
        pop     bx
        pop     ax

        iret
