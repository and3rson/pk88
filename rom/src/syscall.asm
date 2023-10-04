; =====================================================
;
; System calls
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        %include "include/sys.inc"

; Init interrupts
syscall_init:
        push ax
        push ds

        xor ax, ax
        mov ds, ax

        mov ax, int_0x50
        mov [0x50 * 4], ax
        mov ax, ROM_SEG
        mov [0x50 * 4 + 2], ax

        pop ds
        pop ax

        ret

; Generic interrupt handler
;
; Args:
;   AH - function number
int_0x50:
        push bx  ; Save BX to perform pointer arithmetic

        mov bl, ah
        xor bh, bh  ; BX now contains function number

        ; Load int_0x50_function_table with BX*2 offset into BX
        shl bx, 1
        add bx, int_0x50_function_table
        mov bx, [cs:bx]

        call bx  ; Call appropriate function

        pop bx

        iret

int_0x50_function_table:
        dw print_char    ; Function 0: Print char
        dw print_string  ; Function 1: Print string

; Function 0: Print char
; Args:
;   AL - char
print_char:
        push ax
        mov ah, 1
        call lcd_write
        call lcd_busy
        pop ax
        ret

; Function 1: Print string
; Args:
;   DS:SI - string
print_string:
        call lcd_print
        ret
