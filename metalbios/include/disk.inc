; =====================================================
;
; Virtual disk configuration
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

%ifndef DISK_INC
        %define DISK_INC

; Virtual 8.4 GB disk geometry
; DISK_CYLINDERS  equ     1023
; DISK_HEADS      equ     255
; DISK_SECTORS    equ     63

; Virtual 134 MB disk geometry
; DISK_CYLINDERS  equ     128
; DISK_HEADS      equ     64
; DISK_SECTORS    equ     32

; Virtual 32 MB disk geometry
DISK_CYLINDERS  equ     63
DISK_HEADS      equ     16
DISK_SECTORS    equ     63

DISK_CYLINDER_LAST      equ  DISK_CYLINDERS-1
DISK_HEAD_LAST          equ  DISK_HEADS-1
DISK_SECTOR_LAST        equ  DISK_SECTORS

%endif

