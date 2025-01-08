global cos_asm
global silnia
global power

; Approximate cos(x) with 20 terms of the series.
%idefine x [ebp + 8]  ; 'x' is at [ebp+8]
%idefine n 20

; -----------------------------
; cos(x) = sum_{k=0}^{∞} [(-1)^k * x^(2k) / (2k)!]
; Truncate at k = 20.
; -----------------------------

cos_asm:
    push ebp
    mov  ebp, esp

    mov  ecx, n          ; Count down from 20 to 1 for the series
    finit                ; Initialize the FPU
    fld1                 ; st(0) <- 1.0  (this is the running sum, includes k=0 term)

    jmp cos_loop

cos_loop:
    cmp ecx, 0
    je  return           ; If ecx == 0, we are done

    ;------------------------------------
    ; 1) Compute x^(2*ecx)
    ;    Do this by temporarily storing 2*ecx in 'edx'
    ;    then moving that into 'ecx' so that 'power' sees the right exponent.
    ;------------------------------------
    mov edx, ecx
    shl edx, 1           ; edx = 2 * ecx

    push ecx             ; save the loop counter
    mov  ecx, edx        ; ecx <- 2*ecx
    call power           ; => FPU top = x^(2*old_ecx)
    pop ecx              ; restore the loop counter

    ;------------------------------------
    ; 2) Compute (2*ecx)!
    ;    Same trick with 'edx'
    ;------------------------------------
    mov edx, ecx
    shl edx, 1           ; edx = 2 * ecx

    push ecx
    mov  ecx, edx
    call silnia          ; => FPU top = (2*old_ecx)!
    pop ecx

    ;------------------------------------
    ; 3) Divide: x^(2k) / (2k)!
    ;------------------------------------
    fdivp    ; st(1) = st(1) / st(0), pop st(0)

    ;------------------------------------
    ; 4) Apply (-1)^k
    ;    If k is odd, flip the sign
    ;------------------------------------
    test ecx, 1
    jz  add_term
    fchs            ; flip sign if ecx is odd

add_term:
    ;------------------------------------
    ; 5) Accumulate into our running sum
    ;------------------------------------
    faddp           ; st(1) = st(1) + st(0), pop st(0)

    ;------------------------------------
    ; 6) Decrement ecx and repeat
    ;------------------------------------
    dec ecx
    jmp cos_loop

return:
    leave
    jmp raw_ret

power:
    push ecx
    fld1                ; Initialize return value to 1.0

    call power_loop

    pop ecx
    ret

power_loop:
    cmp ecx, 0
    jle raw_ret

    fld dword x
    fmulp
    dec ecx
    jmp power_loop

silnia:
    push ecx
    fld1                ; Initialize return value to 1.0

    call silnia_loop

    pop ecx
    ret

silnia_loop:
    cmp ecx, 1
    jle raw_ret

    push ecx
    fild dword [esp]    ; Load ecx as float
    pop ecx

    fmulp               ; Multiply top of FPU stack by this integer
    dec ecx
    jmp silnia_loop

raw_ret:
    ret
