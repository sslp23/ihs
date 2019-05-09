extern printf

section .data
    limite equ 1000
    i db 0 
    um dw 1
    ask: db 'Calculadora de Pi pela Serie de Taylor!', 0
    answer: db 'O valor achado foi: ', 0
    fmt:    db "%s", 10, 0 ; printf format string follow by a newline(10) and a null terminator(0), "\n",'0'
    fmt2: db "%f", 13, 10, 0
    integer: db "%d", 10, 0
section .bss
    valor resd 1
    result resd 1
    %macro leibniz 2   
        shl %1, 1; multiplica o valor de eax por 2 => eax <- 2*eax
        mov dword[valor], %1; move valor de eax (2*i) na memória
        fld dword[valor]; coloca valor (2*i) na pilha

        fld1; adiciona o valor (1) à pilha
        faddp; soma valor de st0 com st1 e salva em st0 => st0 <- (2*i+1)

        mov dword[valor], %2; move valor de edx (1 ou -1) para memória
        fld dword[valor]; coloca valor (-1 ou 1) na pilha
        
        fdivrp; st0 <- ((±1) / (2*i + 1))
        fst dword[valor]; salva o valor na posição de memória de result

        mov eax, dword[valor]; Comprime o valor de 64 bits para 32 bits e move para eax
        add dword[result], eax; usa o endereço de result como acumulador
    
    %endmacro

;daqui pra baixo, TOP (sergio)
section .text
    global main
main:
    finit; Inicializa a pilha
    push ask
    push fmt
    call printf
    add esp, 8
    mov ecx, limite; quantidade de iterações 
    mov dword[result], 0 ;Seta o valor de result para 0

    leibniz_serie:
        mov eax, limite ; 
        sub eax, ecx; eax(valor de i) <- eax - ecx(contador)
        
        mov ebx, eax; passa valor de eax para ebx
        and ebx, 1 ;ve se o ultimo bit do valor de i eh igual 1
        cmp ebx, 1 ;se for igual 1, eh impar
        je set_i_neg ;se for impar, o numerador eh igual -1

        mov edx, 1
        back: ;volta da negacao (se negou neh)
            leibniz edx, eax ;chama o esgoto (macro)
        loop leibniz_serie ;loop top

    jmp print_result
    set_i_neg:
        mov edx, 1
        neg edx
        jmp back
    
    print_result:    
        push answer
        push fmt
        call printf
        add esp, 8
        push dword[result]
        push fmt2
        call printf
        add esp, 8

    mov eax, 0
ret        
