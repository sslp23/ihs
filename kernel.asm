org 0x7e00
jmp 0x0000:_start

; muda a cor do texto
%define stcolor(color) mov byte [current_text_color], color

; aponta <bx> para a linha e coluna especificada 
;
; linha: entrada do banco
; coluna: informacoes de uma entrada
%macro apontar_banco 2
    mov ax, TABLE_COLUMSIZE ; numero de colunas por linha
    mov bx, %1 ; linha desejada
    mul bx

    mov bx, banco_dados
    add bx, ax ; apontar para linha
    add bx, %2 ; apontar para coluna
%endmacro

_start:
    ; setup
    xor ax, ax    ; ax <- 0
    mov ds, ax    ; ds <- 0
    mov es, ax    ; es <- 0
    mov ds, ax    ; ds <- 0

begin:
    mov bl, 10 ; seta cor dos caracteres para amarelo
    mov ah, 00h
    mov al, 12h
    int 10h
    mov bl, 1110b ; seta cor

    stcolor(COLOR_MAIN)
    xor ax, ax
    mov word [free_index], 0
    mov word [current_index], 0
    
ler_opcao:
    call clear_screen

    stcolor(COLOR_MAIN)
    mov si, menu
    call printString

    call getchar

    cmp al, '1'
    je cadastro_conta

    cmp al, '2'
    je buscar_conta

    cmp al, '3'
    je editar_conta

    cmp al, '4'
    je del_conta

    cmp al, '5'
    je list_agencias

    cmp al, '6'
    je list_contas_agencias

    cmp al, '0'
    je halt

    jmp ler_opcao

; edita uma conta
editar_conta:
    ; aponta <bx> para o endereco do banco
    apontar_banco word [free_index], OFFSET_NOME
    
    ; nome
    .read_nome:
        call clear_screen
        mov si, title_cadastro_nome
        call print_ln

        mov cx, SIZE_NOME
        call read_char

    ; pular os caracteres do nome (e um delimitador)
    apontar_banco word [free_index], OFFSET_CPF
    
    ; cpf
    .read_cpf:
        call clear_screen
        mov si, title_cadastro_cpf
        call print_ln

        mov cx, SIZE_CPF
        call read_char

    apontar_banco word [free_index], OFFSET_AGENCIA

    ; agencia
    .read_agencia:
        call clear_screen
        mov si, title_cadastro_agencia
        call print_ln

        mov cx, SIZE_AGENCIA
        call read_char

    apontar_banco word [free_index], OFFSET_CONTA

    ; conta
    .read_conta:
        call clear_screen
        mov si, title_cadastro_conta
        call print_ln

        mov cx, SIZE_CONTA
        call read_char
        jmp .end
    
    .end:
        ; incrementar o num do index livre
        inc word [free_index]
        jmp ler_opcao

buscar_conta:
    call clear_screen

    mov si, title_search_cpf
    call print_ln

    ; ler input
    mov cx, SIZE_CPF
    call read_char

    mov word [string1], bx
    sub word [string1], SIZE_CPF

    ; encontrar
    call conta.find

    cmp word [current_index], -1
    je .not_found
    jne .found

    ; conta encontrada
    .found:
        ;mov word [current_index], 0
        call conta.print
        jmp .end

    ; conta nao encontrada
    .not_found:
        ;call clear_screen
        mov si, title_search_not_found
        call print_ln
        jmp .end

    .end:

    ;call getchar
    jmp halt

conta:
    ; encontra o index da conta com o cpf salvo em <bx>
    ; retorna index em <current_index>, ou -1 caso conta nao exista
    .find:
        ; numero de registros
        mov cx, word [free_index]
        ;dec cx
        mov word [current_index], cx

        add cx, '0'
        mov al, cl
        call print_char

        jmp halt

        call clear_screen
        mov si, word [string1]
        call print_ln

        .search_contas:
            ; CPF atual em <bx>
            apontar_banco word [current_index], OFFSET_CPF
            mov word [count], SIZE_CPF
            mov word [string2], bx
            sub word [string2], SIZE_CPF + 2

            .for:
                dec word [count]
                cmp word [count], 0
                je .end ; cpf encontrado

                mov ax, word [string1]
                mov bx, word [string2]
                inc word [string1]
                inc word [string2]
                cmp ax, bx
                je .for
                jne .next_conta

            .next_conta:
                dec word [current_index]
                cmp word [current_index], -1
                je .end
                jne .search_contas
    
        jmp .end

    ; imprime a conta que esta em |current_index|
    .print:
        call clear_screen

        ; nome
        .print_nome:
            stcolor(COLOR_MAIN)
            mov si, title_cadastro_nome
            call print_ln

            stcolor(COLOR_ALT)
            apontar_banco word [current_index], OFFSET_NOME
            mov si, bx
            call print_ln
        
        ; cpf
        .print_cpf:
            stcolor(COLOR_MAIN)
            mov si, title_cadastro_cpf
            call print_ln

            ; pular os caracteres do nome (e um delimitador)
            stcolor(COLOR_ALT)
            apontar_banco word [current_index], OFFSET_CPF
            mov si, bx
            call print_ln

        ; agencia
        .print_agencia:
            stcolor(COLOR_MAIN)
            mov si, title_cadastro_agencia
            call print_ln

            ; pular os caracteres do nome (e um delimitador)
            stcolor(COLOR_ALT)
            apontar_banco word [current_index], OFFSET_AGENCIA
            mov si, bx
            call print_ln

        ; conta
        .print_conta:
            stcolor(COLOR_MAIN)
            mov si, title_cadastro_conta
            call print_ln

            ; pular os caracteres do nome (e um delimitador)
            stcolor(COLOR_ALT)
            apontar_banco word [current_index], OFFSET_CONTA
            mov si, bx
            call print_ln

        ; final
        jmp .end

    .end:
        ret
    
cadastro_conta:
    call editar_conta
    jmp ler_opcao

del_conta:
    jmp ler_opcao

list_agencias:
    jmp ler_opcao

list_contas_agencias:
    jmp ler_opcao

; salva o que for lido em <bx>
; limite de caracteres definido por <cx>
read_char:
    .read:
        call getchar
        mov [bx], al ; salvar caractere
        inc bx ; proxima coluna do vetor
        dec cx

        ; printar o char
        stcolor(COLOR_ALT)
        call print_char

        ; <cx> = numero de caracteres para o campo
        cmp cx, 0 ; max de caracteres lidos
        je .return

        cmp al, 13 ; enter pressionado
        je .return

        jmp .read

    .return:
        stcolor(COLOR_MAIN)
        ret

; salva char em <al>
getchar:
    mov ah, 0
    int 16h
    ret

; printa o char em <al>
print_char:
    push bx
    mov ah, 0xe
    mov bh, 0
    mov bl, [current_text_color]
    int 10h
    pop bx
    ret

; imprime a string que esta em <si>
printString:
    push bx

    .print:
        lodsb
        cmp al, 0
        je .end
        mov ah, 0xe
        mov bh, 0
        mov bl, [current_text_color]
        int 10h
        jmp .print

    .end:
        pop bx
        ret

; imprime o que esta em <si> e imprime uma nova linha
print_ln:
    push ax
    call printString
    mov al, 13
    call print_char
    mov al, 10
    call print_char
    xor si, si
    pop ax
    ret

return:
    ret

; le string do teclado
; salva o resultado no endereco apontado por <si>
readString:
    mov ah,0
    int 16h
    cmp al,13
    je doneRead

    cmp al,8
    je backspace

    mov ah,0xe
    mov bh, 0
    int 10h
    mov byte[si],al
    inc si
    jmp readString

backspace:
    dec si
    mov al,0
    mov byte[si],al

    mov al,8
    mov ah,0xe
    mov bl,0x6
    int 10h

    mov al,0
    mov ah,0xe
    mov bl,0x6
    int 10h
    
    mov al,8
    mov ah,0xe
    mov bl,0x6
    int 10h
    jmp readString

doneRead:
    mov al,13
    mov ah,0xe
    mov bl,0x6
    int 10h
    mov al,10
    int 10h
    ret

halt:
    jmp $

; limpa a tela
clear_screen:
    push ax
    mov ah, 0
    mov al, 12h
    int 10h
    pop ax
    call reset_cursor
    ret

; move o cursor para 0, 0
reset_cursor:
    push ax
    push bx
    mov ah, 2
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h
    pop bx
    pop ax
    ret

intro db 'Bem-vindo ao sistema!', 13, 10, 0
choose db 'Escolha sua opcao: ', 13, 10, 0
menu db '1 - Cadastrar nova conta', 13, 10, '2 - Buscar conta', 13, 10, '3 - Editar conta', 13, 10, '4 - Deletar conta', 13, 10, '5 - Listar agencias', 13, 10, '6 - Listar contas de uma agencia', 13, 10, '0 - Sair', 13, 10, 0

title_cadastro_nome db 'Nome da conta (20 caracteres):', 0
title_cadastro_cpf db 'CPF (11 digitos):', 0
title_cadastro_agencia db 'Agencia (5 digitos):', 0
title_cadastro_conta db 'Conta (6 digitos):', 0

title_search_cpf db 'Insira o CPF da conta (11 digitos):', 0
title_search_not_found db 'Conta nao encontrada', 0

; reservar espaço do array
TABLE_COLUMSIZE equ SIZE_NOME + SIZE_CPF + SIZE_AGENCIA + SIZE_CONTA + 6
TABLE_ROWSIZE equ 10
banco_dados resb TABLE_COLUMSIZE * TABLE_ROWSIZE

SIZE_NOME equ 20
SIZE_CPF equ 11
SIZE_AGENCIA equ 5
SIZE_CONTA equ 6

OFFSET_NOME    equ 0
OFFSET_CPF     equ OFFSET_NOME + SIZE_NOME + 2
OFFSET_AGENCIA equ OFFSET_CPF + SIZE_CPF + 2
OFFSET_CONTA   equ OFFSET_AGENCIA + SIZE_AGENCIA + 2

COLOR_MAIN equ 0ah
COLOR_ALT equ 07h

string1 resw 1
string2 resw 1
count resw 1

; index livre para o banco de dados
free_index resw 1

; index sendo editado atualmente
current_index resw 1

; cor do texto atual
current_text_color resb 1
