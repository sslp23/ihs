section .data
    limite equ 1000
    i db 0 
    um dw 1
section .bss
    valor resd 1
    result resd 1
    %macro leibniz 2   
        shl %1; multiplica o valor de eax por 2 => eax <- 2*eax
        mov dword[valor], %1; move valor de eax (2*i) na memória
        fld dword[valor]; coloca valor (2*i) na pilha

        fld1; adiciona o valor (1) à pilha
        faddp; soma valor de st0 com st1 e salva em st0 => st0 <- (2*i+1)

        mov dword[valor], %2; move valor de edx (1 ou -1) para memória
        fld dword[valor]; coloca valor (-1 ou 1) na pilha
        
        fdivrp; st0 <- ((±1) / (2*i + 1))
        fst dword[valor]; salva o valor na posição de memória de result

        vpmovdw eax, dword[valor]; Comprime o valor de 64 bits para 32 bits e move para eax
        add dword[result], eax; usa o endereço de result como acumulador
        
    %endmacro

;daqui pra baixo, TOP (sergio)
section .text
    mov ecx, limite; quantidade de iterações 
    mov dword[result], 0 ;Seta o valor de result para 0
    leibniz_serie:
        mov ebx, limite; ebx <- limite
        sub eax, ecx; eax(valor de i) <- eax - ecx(contador)
        
        mov ebx, eax; passa valor de eax para ebx
        and ebx, 1 ;ve se o ultimo bit do valor de i eh igual 1
        cmp ebx, 1 ;se for igual 1, eh impar
        je set_i_neg ;se for impar, o numerador eh igual -1

        mov edx, 1
        .back: ;volta da negacao (se negou neh)
        call leibniz edx, eax ;chama o esgoto (macro)
        loop leibniz_serie ;loop top
    print_result:
        ;printar valor calculado
    fim_serie:
        mov eax, 1
        mov ebx, 0
        int 80h; retorna 0 para o sistema operacional (se não, deveria)

set_i_neg:
    mov edx, 1
    neg edx
    jmp .back
