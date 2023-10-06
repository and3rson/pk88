; =====================================================
;
; Virtual disk configuration
;
; This file is part of MetalBIOS for PK-88.
;
; =====================================================

%ifndef DISK_INC
        %define DISK_INC

; Virtual 32M disk geometry (32117760 bytes)
DISK_CYLINDERS  equ     615
DISK_HEADS      equ     6
DISK_SECTORS    equ     17

DISK_CYLINDER_LAST      equ  DISK_CYLINDERS-1
DISK_HEAD_LAST          equ  DISK_HEADS-1
DISK_SECTOR_LAST        equ  DISK_SECTORS

%endif

