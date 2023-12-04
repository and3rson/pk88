; =====================================================
;
; Boot system (called after POST)
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

        cpu     8086
        bits    16

        extern  sdc_read_single_block

        section .text

; --------------------------------------------------
; BIOS 0x19 ISR
; --------------------------------------------------
        global  int19h_isr
int19h_isr:
        sti

        ; https://thestarman.pcministry.com/asm/mbr/95BMEMBR.htm
        ; Load bootsector
        xor     ax, ax
        mov     es, ax
        mov     bx, 0x7C00
        call    sdc_read_single_block
        ; Initialize segments
        xor     ax, ax
        mov     ds, ax
        mov     es, ax
        ; Init stack at 0x0000:0x0400
        xor     ax, ax
        mov     ss, ax
        mov     sp, 0x0400
        ; Tell bootsector that we are booting from HDD
        mov     dl, 0x80
        xor     dh, dh          ; bit 5 is 0 - means that device is supported via int 13h
        ; Execute bootsector
        jmp     0x0000:0x7C00

        ; No need to return here :)
