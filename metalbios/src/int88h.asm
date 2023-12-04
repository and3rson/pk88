; =====================================================
;
; Homebrew API for ELKS
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        section .text

; --------------------------------------------------
; BIOS 0x88 ISR
; --------------------------------------------------
; Args:
;   AH - function number
        global  int88h_isr
int88h_isr:
        sti

        push    si
        push    bx  ; Save BX to perform pointer arithmetic

        mov     bl, ah
        xor     bh, bh  ; BX now contains function number

        ; Load int88h_function_table with BX*2 offset into BX
        shl     bx, 1
        mov     bx, [cs:bx+int88h_function_table]

        mov     si, bx
        pop     bx
        ; NOTE: SI will be clobbered in the called function
        call    si  ; Call appropriate function
        pop     si

        iret

int88h_function_table:
        dw      get_display_columns
        dw      get_display_rows

; --------------------------------------------------
; Get display columns
; --------------------------------------------------
get_display_columns:
        mov     ax, 40
        ret

; --------------------------------------------------
; Get display rows
; --------------------------------------------------
get_display_rows:
        mov     ax, 8
        ret
