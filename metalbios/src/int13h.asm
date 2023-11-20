; =====================================================
;
; Low-level disk functions (BIOS int 0x13)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "sys.inc"
        %include "disk.inc"
        %include "macros.inc"

        extern  disk_chs_to_lba
        extern  sdc_read_single_block
        extern  sdc_write_single_block
        extern  lcd_printbyte

        section .rodata

STUB_S  db      "!0x13:", 0

        section .text

; --------------------------------------------------
; BIOS 0x13 ISR
; --------------------------------------------------
; Args:
;   AH - function number
        global  int13h_isr
int13h_isr:
        push    bx  ; Save BX to perform pointer arithmetic

        mov     bl, ah
        xor     bh, bh  ; BX now contains function number

        ; Load int13h_function_table with BX*2 offset into BX
        shl     bx, 1
        mov     bx, [cs:bx+int13h_function_table]

        call    bx  ; Call appropriate function

        pop     bx

        iretc

int13h_function_table:
        ; https://en.wikipedia.org/wiki/INT_13H#List_of_INT_13h_services
        dw      reset_disk_system  ; ELKS
        dw      get_status_of_last_drive_operation
        dw      read_sectors_from_drive  ; ELKS
        dw      write_sectors_to_drive  ; ELKS
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      read_drive_parameters  ; ELKS
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop  ; 0x10
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop  ; 0x20
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop  ; 0x30
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop
        dw      int13h_nop  ; 0x40
        dw      test_extensions  ; 0x41 - test whether extensions are available

        ; TODO: Implement the rest?

; --------------------------------------------------
; No-op (unimplemented) function
; --------------------------------------------------
int13h_nop:
        push    bp
        push    es
        push    ax

        mov     ax, ROM_SEG
        mov     es, ax
        mov     ah, 0x13
        mov     bp, STUB_S
        int     0x10

        pop     ax
        xchg    ah, al
        call    lcd_printbyte
        xchg    ah, al
        pop     es
        pop     bp

        stc
        ret

; --------------------------------------------------
; Function 00h: Reset disk system
; --------------------------------------------------
; Args:
;   AH - function number (0x00)
reset_disk_system:
        clc
        ret

; --------------------------------------------------
; Function 01h: Get status of last drive operation
; --------------------------------------------------
; Args:
;   AH - function number (0x01)
;   DL - drive number (0x00 = floppy, 0x80 = hard disk)
;
; Return:
;   Carry flag set on error
;   AH - status code
get_status_of_last_drive_operation:
        stc
        ret

; --------------------------------------------------
; Function 02h: Read sectors from drive
; --------------------------------------------------
; Args:
;   AH - function number (0x02)
;   AL - number of sectors to read
;   CH - cylinder number
;   CL - sector number (starting at 1)
;   DH - head number
;   DL - drive number (0x00 = floppy, 0x80 = hard disk)
;   ES:BX - pointer to buffer
;
; Return:
;  Carry flag set on error
;  AH - status code
;  AL - number of sectors read
read_sectors_from_drive:
        push    ax
        push    bx
        push    cx
        push    dx

        ; Calculate LBA
        ; TODO: Use DL to determine drive type?
        push    ax
        call    disk_chs_to_lba
        pop     cx
        xor     ch, ch
        ; AX = LBA, CX = number of sectors to read

.read_sector:
        push    ax
        call    sdc_read_single_block
        test    ax, ax
        pop     ax
        jnz     .err
        add     bx, 512
        inc     ax
        loop    .read_sector

.ok:
        clc
        jmp     .end

.err:
        stc

.end:
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        xor     ah, ah

        clc
        ret

; --------------------------------------------------
; Function 03h: Write sectors to drive
; --------------------------------------------------
; Args:
;   AH - function number (0x03)
;   AL - number of sectors to write
;   CH - track
;   CL - sector
;   DH - head
;   DL - drive number (0x00 = floppy, 0x80 = hard disk)
;   ES:BX - pointer to buffer
;
; Return:
;   Carry flag set on error
;   AH - status code
;   AL - number of sectors written
write_sectors_to_drive:
        push    ax
        push    bx
        push    cx
        push    dx

        ; Calculate LBA
        ; TODO: Use DL to determine drive type?
        push    ax
        call    disk_chs_to_lba
        pop     cx
        xor     ch, ch
        ; AX = LBA, CX = number of sectors to write

.write_sector:
        push    ax
        call    sdc_write_single_block
        test    ax, ax
        pop     ax
        jnz     .err
        add     bx, 512
        inc     ax
        loop    .write_sector

.ok:
        clc
        jmp     .end

.err:
        stc

.end:
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        xor     ah, ah

        ret

; --------------------------------------------------
; Function 08h: Read drive parameters
; --------------------------------------------------
; Args:
;   AH - function number (0x08)
;   DL - drive number (0x00 = floppy, 0x80 = hard disk)
;
; Return:
;   Carry flag set on error
;   AH - status code
;   DL - number of hard disk drives
;   DH - logical last index of heads (count - 1)
;   CX - logical last index of cylinders (count - 1) and sectors (count)
;       Cylinder count = CX[7:6][15:8]
;       Sector count = CL[5:0]
;   BL - drive type (only AT/PS2 floppies)
read_drive_parameters:
        ; TODO: Handle DL?
        mov     ah, 0x00
        mov     dl, 0x01
        mov     dh, DISK_HEAD_LAST
        mov     ch, DISK_CYLINDER_LAST & 0xFF
        mov     cl, (DISK_CYLINDER_LAST >> 2 & 0xC0) | DISK_SECTOR_LAST

        clc
        ret

; --------------------------------------------------
; Function 41h: Test extensions
; --------------------------------------------------
test_extensions:
        stc     ; Extensions not supported; maybe I'll implement them someday since I'm converting CHS to LBA anyway
        ret
