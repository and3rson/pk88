; =====================================================
;
; Low-level disk functions (BIOS int 0x13)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "disk.inc"

        extern  disk_chs_to_lba

        section .text

; BIOS 0x13 ISR
;
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

        iret

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
        ; TODO: Implement the rest?

; No-op (unimplemented) function
int13h_nop:
        ret

; Function 00h: Reset disk system
;
; Args:
;   AH - function number (0x00)
reset_disk_system:
        ret

; Function 01h: Get status of last drive operation
;
; Args:
;   AH - function number (0x01)
;   DL - drive number (0x00 = floppy, 0x80 = hard disk)
;
; Return:
;   Carry flag set on error
;   AH - status code
get_status_of_last_drive_operation:
        ret

; Function 02h: Read sectors from drive
;
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

        ; TODO: Read sectors from uSD card

        pop     dx
        pop     cx
        pop     bx

        ret

; Function 03h: Write sectors to drive
;
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

        ; TODO: Read sectors from uSD card

        pop     dx
        pop     cx
        pop     bx

        ret

; Function 08h: Read drive parameters
;
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
        mov     ah, -1
        lodsb
        mov     cx, \
                        (DISK_CYLINDER_LAST & 0xFF) << 8 | \
                        DISK_CYLINDER_LAST >> 2 & 0xC0 | DISK_SECTOR_LAST
        mov     dh, DISK_HEAD_LAST
        mov     dl, -1
        mov     bl, -1
