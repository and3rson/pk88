; =====================================================
;
; Disk interface
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        %include "disk.inc"

        section .text

; --------------------------------------------------
; Convert CHS to LBA while respecting the 1024 cylinder limit (upper 2 bits of CL)
; Supports disks up to 32GiB in size (65535 LBA sectors)
;
; CX =       ---CH--- ---CL---
; cylinder : 76543210 98
; sector   :            543210;
; cylinder = (CL & 0x3F) << 8 | CH
; sector   = CL & 0b00111111
;
; Formula: LBA = (cylinder * HEADS + head) * SECTORS + sector - 1
; --------------------------------------------------
; Args:
;   CH - cylinder number
;   CL - sector number (starting at 1)
;   DH - head number
;
; Return:
;   AX - LBA
        global  disk_chs_to_lba
disk_chs_to_lba:
        push    cx

        ; AX = cylinder
        xchg    ch, cl          ; CX = 98xxxxxx 76543210
        and     ch, 11000000b   ; CX = 98000000 76543210
        ror     ch, 1
        ror     ch, 1
        ror     ch, 1
        ror     ch, 1
        ror     ch, 1
        ror     ch, 1           ; CX = 00000098 76543210 (
        clc
        mov     ax, cx          ; AX = cylinder number

        ; AX = cylinder * HEADS
        mov     cx, DISK_HEADS
        push    dx
        mul     cx  ; clobbers DX, never overflows
        pop     dx

        ; AX = (cylinder * HEADS) + head
        xor     cx, cx
        mov     cl, dh
        add     ax, cx

        ; AX = (cylinder * HEADS + head) * SECTORS
        mov     cx, DISK_SECTORS
        push    dx
        mul     cx  ; clobbers DX, never overflows
        pop     dx

        ; AX = (cylinder * HEADS + head) * SECTORS + sector
        pop     cx
        push    cx
        and     cx, 0x003F
        dec     cl
        add     ax, cx

        pop     cx

        ret

