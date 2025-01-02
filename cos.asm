global cos_asm
global silnia
global power

%idefine x [ebp + 8] ; float is 2 byte
%idefine n [ebp + 12] ; int is 1 byte

cos_asm:
	push ebp
	mov ebp, esp

    finit ; Init FPU
    fldz ; push 1 (initial return value)
    mov ecx, n; number of iterations

    mov edx, 0

    jmp cos_loop

cos_loop:
    push eax       ; Save the term index (n)

    shl eax, 1     ; eax = 2 * n (calculate 2n)
    push eax
    call power     ; Compute x^(2n)
    add esp, 4     ; Cleanup stack

    push eax
    call silnia    ; Compute (2n)!
    add esp, 4     ; Cleanup stack

    fdivp          ; x^(2n) / (2n)!

    ; Apply the alternating sign (-1)^n
    mov eax, [esp] ; Get n back
    and eax, 1     ; Check if n is odd or even
    cmp eax, 0
    je add_term    ; If even, add the term

    fchs           ; If odd, negate the term

return:
    leave
    jmp raw_ret

power:
    push ecx
    fld1 ; initial return value

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

    fld1 ; initial return value

    call silnia_loop

    pop ecx
    ret

silnia_loop:
    cmp ecx, 1
    jle raw_ret

    push ecx
    fild dword [esp]
    pop ecx

    fmulp ; (prev + 1)*prev

    dec ecx
    jmp silnia_loop

add_term:
    faddp          ; Add the current term to the total
    pop eax        ; Restore n
    inc eax        ; Increment n for the next term

cos_loop_check:
    cmp eax, ecx   ; Check if we've computed all terms
    jl cos_loop

    leave
    ret

raw_ret:
    ret