        cpu 8086
        bits 16

START   equ $
ROM_SEG equ 0xF000
STK_SEG equ 0x7800
STK_LEN equ 0x8000  ; 32 KB stack

; DIP switches & LEDs are on port 0x0
IO_LEDS equ 0x0
IO_DIPS equ 0x0
; 8255 is on ports 0x100..0x103
IO_A    equ 0x100
IO_B    equ 0x101
IO_C    equ 0x102
IO_CTRL equ 0x103

        org ROM_SEG*16

HELLO_S db "Hello, KM1810VM88!", 0

init:
        ; Initialize segments
        mov ax, STK_SEG
        mov ss, ax
        mov ax, STK_LEN
        mov sp, ax

        ; Initialize I/O
        mov dx, IO_CTRL
        mov al, 0b10000000
        ; 1 0 0 0 0 0 0 0
        ; ^ ^ ^ ^ ^ ^ ^ ^
        ; | | | | | | | |
        ; | | | | | | | +-- 0: Port C (lower) is output
        ; | +++ | | | +--- 0: Port B is output
        ; |  |  | | +---- 0: Mode 0
        ; |  |  | +----- 0: Port C (upper) is output
        ; |  |  +------ 0: Port A is output
        ; |  +------- 00: Mode 0
        ; +---------- 1: Mode set flag
        out dx, al

        call lcd_init
        mov si, HELLO_S
        call lcd_print
        hlt

;         ; Delay 65536 iterations (~557 (524?) ms)
;         ; (1 iteration takes ~8 us)
; delay:
;         inc cx
;         cmp cx, 0
;         jne delay

; Initialize LCD
lcd_init:
        push ax
        push cx

        xor cx, cx
.longinit:
        mov ah, 0
        mov al, 0b00111000  ; 8 bit, 2 lines, 5x8
        call lcd_write
        call lcd_busy

        inc cx
        cmp cx, 0x3
        jne .longinit

        mov al, 0b00001111  ; Display on, cursor on, blink on
        call lcd_write
        call lcd_busy

        mov al, 0b00000001  ; Clear display
        call lcd_write
        call lcd_busy

        mov al, 0b00000110  ; Increment cursor, no shift
        call lcd_write
        call lcd_busy

        mov al, 0b00000010  ; Return home
        call lcd_write
        call lcd_busy

        mov al, 0b10000000  ; Set DDRAM address
        call lcd_write
        call lcd_busy

        pop cx
        pop ax

        ret

; Print string to LCD
; Args:
;   DS:SI - string
lcd_print:
        push ax
        push si

        mov ah, 1
        mov si, HELLO_S
.next:
        mov al, [ds:si]
        cmp al, 0
        je .done
        call lcd_write
        call lcd_busy
        inc si
        jmp .next

.done:
        pop si
        pop ax

        ret


; Args:
;   AL - data
;   AH - register
lcd_write:
        push bx
        push dx
        mov bx, ax

        mov dx, IO_CTRL
        ; in al, dx
        ; and al, 0b11101111  ; Set port A to output
        ; or al, 0b10000000  ; Mode set flag
        mov al, 0b10000000
        out dx, al

        mov al, bl  ; Restore AL = data

        xchg ah, al  ; AL = register
        and al, 0b11111101  ; R/W = 0
        mov dx, IO_B
        out dx, al

        xchg ah, al  ; AL = data
        mov dx, IO_A
        out dx, al

        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        xchg ah, al  ; AL = register
        or al, 0b00000100  ; E = 1
        mov dx, IO_B
        out dx, al
        ; mov dx, IO_LEDS
        ; out dx, al

        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        and al, 0b11111011  ; E = 0
        mov dx, IO_B
        out dx, al

        mov ax, bx  ; Restore args
        pop dx
        pop bx

        ret

; Args:
;   AH - register
;
; Return:
;   AL - data
lcd_read:
        push bx
        push dx
        mov bx, ax

        mov dx, IO_CTRL
        ; in al, dx
        ; or al, 0b10010000  ; Set port A to input
        mov al, 0b10010000
        out dx, al

        mov al, bl  ; Restore AL = data

        xchg ah, al  ; AL = register
        or al, 0b00000010  ; R/W = 1
        mov dx, IO_B
        out dx, al

        or al, 0b00000100  ; E = 1
        mov dx, IO_B
        out dx, al

        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        xchg ah, al  ; AL = data
        mov dx, IO_A
        in al, dx  ; Read data

        xchg ah, al  ; AL = register, AH = data
        and al, 0b11111011  ; E = 0
        mov dx, IO_B
        out dx, al

        xchg ah, al  ; AL = data, AH = register

        mov ah, bh  ; Restore AH = register
        pop dx
        pop bx

        ret


; Block while LCD is busy
lcd_busy:
        push ax
        mov ah, 0
.wait:
        call lcd_read
        and al, 0b10000000
        jnz .wait
        pop ax
        ret

times 0x10000-($-START)-16 db 0xAD

reset:
        jmp ROM_SEG:init
        hlt

times 0x10000-($-START)-2 db 0xAD

        db "AD"
