
global tanh_asm
global silnia
global power

%idefine x [ebp + 8] ; float is 2 byte
; %idefine n [ebp + 12] ; int is 1 byte
%idefine n 2000

tanh_asm:
	push ebp
	mov ebp, esp

    mov ecx, n

    finit ; Init FPU
    fldz ; push 1 (initial return value)

    jmp exp_loop

exp_loop:
    ; st0 = pow(x, n)/ n! + st0
    cmp ecx, 0
    je return

    call power ; fpu: pow(x, ecx), n!
    call silnia ; fpu: ecx!

    fdivp ; pow(x, n)/n!

    faddp ; st0  = st0 + pow(x, n)/n!

    dec ecx
    jmp exp_loop

return:
    ; Compute the actual e^2x - 1 / e^2x + 1
    fadd dword [one]
    fld st0            ; duplicate => ST(0)= e^(2*x)-1, ST(1)= e^(2*x)-1
    fsub dword [two]       ; ST(0)= (e^(2*x)-1)+2 = e^(2*x)+1

    ; st(0)=denominator, st(1)=numerator => do st(1)/st(0)
    fdivp st1, st0     ; => st(1) = ( e^(2*x)-1 ) / ( e^(2*x)+1 ), pop st(0)

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
    fadd st0, st0
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


section .data
one: dd 1.0
two: dd 2.0
