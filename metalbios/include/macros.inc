%ifndef MACROS_INC
        %define MACROS_INC

; Set/clear carry flag inside interrupt routines before returning from interrupt
; https://forum.vcfed.org/index.php?threads/x86-assembly-question-modifying-flags-register-on-the-stack.61589/post-746823
; This is required since `iret` will restore the flags from the stack, so we modify the flags directly on the stack
%macro  iretc   0
        ; Flags are in [SP+4]
        push    bp
        mov     bp, sp
        ; Flags are now in [BP+6]
        push    ax
        mov     al, [bp+6]      ; Get lower flags byte from stack
        and     al, 0xFE        ; Clear carry flag in flags
        adc     al, 0           ; Apply carry flag to flags
        mov     [bp+6], al      ; Update flags in stack
        pop     ax
        pop     bp
        iret
%endmacro

%endif
