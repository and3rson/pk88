; =====================================================
;
; LCD functions
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "include/ports.inc"

        section .text

; Initialize LCD
        global  lcd_init
lcd_init:
        push    ax
        push    cx

        xor     cx, cx
.longinit:
        mov     ah, 0
        mov     al, 0b00111000  ; 8 bit, 2 lines, 5x8
        call    lcd_write
        call    lcd_busy

        inc     cx
        cmp     cx, 0x3
        jne     .longinit

        mov     al, 0b00001111  ; Display on, cursor on, blink on
        call    lcd_write
        call    lcd_busy

        mov     al, 0b00000001  ; Clear display
        call    lcd_write
        call    lcd_busy

        mov     al, 0b00000110  ; Increment cursor, no shift
        call    lcd_write
        call    lcd_busy

        mov     al, 0b00000010  ; Return home
        call    lcd_write
        call    lcd_busy

        mov     al, 0b10000000  ; Set DDRAM address
        call    lcd_write
        call    lcd_busy

        pop     cx
        pop     ax

        ret

; Print string to LCD
;
; Args:
;   ES:BP - string
        global  lcd_print
lcd_print:
        push    ax
        push    bp

        mov     ah, 1
.next:
        mov     al, [es:bp]
        cmp     al, 0
        je      .done
        call    lcd_write
        call    lcd_busy
        inc     bp
        jmp     .next

.done:
        pop     bp
        pop     ax

        ret


; Write to LCD
;
; Args:
;   AL - data
;   AH - register
        global  lcd_write
lcd_write:
        push    bx
        push    dx
        mov     bx, ax

        mov     dx, IO_CTRL
        ; in al, dx
        ; and al, 0b11101111  ; Set port A to output
        ; or al, 0b10000000  ; Mode set flag
        mov     al, 0b10000000
        out     dx, al

        mov     al, bl  ; Restore AL = data

        xchg    ah, al  ; AL = register
        and     al, 0b11111101  ; R/W = 0
        mov     dx, IO_B
        out     dx, al

        xchg    ah, al  ; AL = data
        mov     dx, IO_A
        out     dx, al

        xchg    ah, al  ; AL = register
        or      al, 0b00000100  ; E = 1
        mov     dx, IO_B
        out     dx, al
        ; mov dx, IO_LEDS
        ; out dx, al

        and     al, 0b11111011  ; E = 0
        mov     dx, IO_B
        out     dx, al

        mov     ax, bx  ; Restore args
        pop     dx
        pop     bx

        ret

; Read from LCD
;
; Args:
;   AH - register
;
; Return:
;   AL - data
lcd_read:
        push    bx
        push    dx
        mov     bx, ax

        mov     dx, IO_CTRL
        ; in al, dx
        ; or al, 0b10010000  ; Set port A to input
        mov     al, 0b10010000
        out     dx, al

        mov     al, bl  ; Restore AL = data

        xchg    ah, al  ; AL = register
        or      al, 0b00000010  ; R/W = 1
        mov     dx, IO_B
        out     dx, al

        or      al, 0b00000100  ; E = 1
        mov     dx, IO_B
        out     dx, al

        xchg    ah, al  ; AL = data
        mov     dx, IO_A
        in      al, dx  ; Read data

        xchg    ah, al  ; AL = register, AH = data
        and     al, 0b11111011  ; E = 0
        mov     dx, IO_B
        out     dx, al

        xchg    ah, al  ; AL = data, AH = register

        mov     ah, bh  ; Restore AH = register
        pop     dx
        pop     bx

        ret


; Block while LCD is busy
        global  lcd_busy
lcd_busy:
        push    ax
        mov     ah, 0
.wait:
        call    lcd_read
        and     al, 0b10000000
        jnz     .wait
        pop     ax
        ret
