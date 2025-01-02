global cos_asm
global silnia
global power

%idefine x [ebp + 8] ; float is 2 byte
%idefine n [ebp + 12] ; int is 1 byte

cos_asm:
	push ebp
	mov ebp, esp

    mov ecx, n

    finit ; Init FPU
    fld1 ; push 1 (initial return value)

    mov edx, 0

    jmp cos_loop

cos_loop:
    ; st0 = pow(x, n)/ n! + st0
    cmp ecx, 0
    je return

    call power ; fpu: pow(x, ecx), n!
    call silnia ; fpu: ecx!

    fdivp ; pow(x, n)/n!

    faddp ; st0  = st0 + pow(x, n)/n!

    dec ecx
    jmp cos_loop

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

raw_ret:
    ret