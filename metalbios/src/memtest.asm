; =====================================================
;
; RAM test
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        extern  lcd_printchar

        section .text

; --------------------------------------------------
; RAM test
; --------------------------------------------------
; Return:
;   AX - 0x0000 if RAM test passed
;   BX:DI - Address of first bad byte if RAM test failed
; Clobbers:
;   CX, ES

        global  memtest
memtest:
        pop     cx      ; Save return address

        ; Write & read bytes to RAM range 0x10000-0xEFFFF, segment by segment
        mov     bx, 0x1000  ; Segment
        mov     es, bx
        mov     di, 0x0000  ; Offset

        ; Write bytes to segment
.write_byte:
        mov     al, 0xAA
        mov     [es:di], al     ; Write byte
        add     di, 63          ; Increment offset (skip 63 bytes for faster test)
        cmp     di, 0x002F      ; End of segment? (47 = 63 - (65536 % 63))
        jne     .write_byte     ; No, continue
        ; End of segment reached

        ; Read bytes from segment
        mov     di, 0x0000
.read_byte:
        mov     al, [es:di]     ; Read byte
        cmp     al, 0xAA        ; Byte read OK?
        jne     .error          ; No, error
        add     di, 63          ; Increment offset
        cmp     di, 0x002F      ; End of segment?
        jne     .read_byte      ; No, continue
        ; End of segment reached

        add     bx, 0x1000      ; Next segment
        cmp     bx, 0xF000      ; End of RAM?
        je      .success        ; Yes, end

        ; mov     al, '.'
        ; call    lcd_printchar

        ; Start next segment
        mov     es, bx
        mov     di, 0x0000      ; Offset
        jmp     .write_byte     ; Continue

.success:
        xor     ax, ax
        jmp     .end

.error:
        mov     ax, 0x01        ; Error

.end:
        push    cx              ; Restore return address
        ret
