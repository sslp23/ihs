section .data
    limite equ 1000
    i db 0 
    dois dw 2
section .bss
    valor resd 1
    %macro leibniz 2   
        mov dword[valor], %1; move valor de edx (1 ou -1) para memória
        fld dword[valor]; coloca valor (-1 ou 1) na pilha
        shl edx
        mov dword[valor], %2; move valor de eax (i) na memória
        fld dword[valor]; coloca valor (i) na pilha
        fadd st1, st2
        fdivp st1, st2        

;daqui pra baixo, TOP (sergio)
section .text
    mov byte [valor], 1
    mov ecx, limite
leibniz_serie:
        mov ebx, limite; ebx <- limite
        sub ebx, ecx; ebx(valor de i) <- ebx - ecx(contador)
        and ebx, 1 ;ve se o ultimo bit do valor de i eh igual 1
        cmp ebx, 1 ;se for igual 1, eh impar
        je set_i_neg ;se for impar, o numerador eh igual -1
        mov edx, 1
        .back: ;volta da negacao (se negou neh)
        call leibniz eax, edx ;chama o esgoto (macro)
        loop leibniz_serie ;loop top
fim_serie:
    


set_i_neg:
    mov edx, 1
    neg edx
    jmp .back

    
