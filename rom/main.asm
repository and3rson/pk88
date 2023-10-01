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
; HELLO_S db "0123456789012345678!", 0
; HELLO_S db "8765432109876543210!", 0

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

        ; xor al, al
; loop:
;         mov cx, 0

;         ; Delay 65536 iterations (~557 (524?) ms)
;         ; (1 iteration takes ~8 us)
; delay:
;         inc cx
;         cmp cx, 0
;         jne delay

        ;;
        ;; Init display
        ;;

        ; Delay ~256ms
; delay_256:
;         inc cx
;         cmp cx, 0x8000
;         jne delay_256
;
;         ; 8 bit, 2 lines, 5x8
;         mov dx, IO_A
;         mov al, 0b00111000
;         out dx, al
;
;
;         mov dx, IO_A
;         out dx, al
;         not al
;         jmp loop

loop:
        ; mov ax, 34
        ; push ax
        ; mov ax, 42
        ; push ax
        ;
        ; pop ax
        ; pop bx
        ; add ax, bx
        ; mov dl, IO_LEDS
        ; mov dh, 0
        ; out dx, al






;         mov ah, 0
;         call lcd_read
;         mov al, 0b00111000  ; 8 bit, 2 lines, 5x8
;         call lcd_write
;         mov ah, 1
;         call lcd_read
;         mov al, 0b00111000  ; 8 bit, 2 lines, 5x8
;         call lcd_write
;
;         ; mov ah, 1
;         ; call lcd_read
;         ;
;         ; ; mov dx, IO_LEDS
;         ; ; xchg ah, al
;         ; ; out dx, al
;         ; ; xchg ah, al
;         ;
;         ; mov al, 0b00111000  ; 8 bit, 2 lines, 5x8
;         ; call lcd_write
;
;         xor cx, cx
; loop2:
;         inc cx
;         cmp cx, 0x1000
;         jne loop2
;
;         jmp loop







        xor cx, cx
@initrepeat:
        mov ah, 0
        mov al, 0b00111000  ; 8 bit, 2 lines, 5x8
        call lcd_write
        call lcd_busy

        inc cx
        cmp cx, 0x3
        jne @initrepeat

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

        mov ah, 1
        mov si, HELLO_S
@printchar:
        mov al, [cs:si]
        cmp al, 0
        je @printed
        call lcd_write
        call lcd_busy
        inc si
        jmp @printchar

        hlt

;         xor al, al
;         mov ah, 1
; @printchar:
;         call lcd_write
;         call lcd_write
;         call lcd_write
;         call lcd_write
;         ; call lcd_busy
;         inc al
;         cmp al, 0
;         jne @printchar



        xor cx, cx
loop2:
        inc cx
        cmp cx, 0xF000
        jne loop2



        jmp @printchar
@printed:

        hlt


; Args:
;   al - data
;   ah - register
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
        mov dx, IO_LEDS ;
        out dx, al      ;

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
;   ah - register
;
; Return:
;   al - data
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

        ; xchg ah, al  ; AL = data
        ; mov dx, IO_A
        ; out dx, al
        ; xchg ah, al
        ;
        ; xchg ah, al  ; AL = register

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
@wait:
        call lcd_read
        and al, 0b10000000
        jnz @wait
        pop ax
        ret



        mov dx, IO_B
@rep:
        in al, dx
        and al, 0b10000000
        jnz @rep
        ret


 ;
 ;
	; mov ax, 0
 ;        sti

;         xor dx, dx
; endless:
; 	; inc ax
;         in al, dx
;         out dx, al
; 	jmp endless

times 0x10000-($-START)-16 db 0xAD

reset:
        jmp ROM_SEG:init
        hlt

times 0x10000-($-START)-2 db 0xAD

        db "AD"
