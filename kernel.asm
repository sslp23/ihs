org 0x7e00
jmp 0x0000:_start

section .text
    global _start


; aponta <bx> para a linha e coluna especificada em <cx>, <dx> do banco de dados
%macro apontar_banco 2
    push cx
    push dx
    mov cx, %1
    mov dx, %2
    call apontar_array_banco
    pop dx
    pop cx
%endmacro
apontar_array_banco:
    mov ax, TABLE_COLUMSIZE ; numero de colunas por linha
    mov bx, cx ; linha desejada
    mul bx

    mov bx, banco_dados
    add bx, ax ; apontar para linha
    add bx, dx ; apontar para coluna
    ret

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

    ;call readString

    mov si, menu
    call printString
    
ler_opcao:
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

    jmp begin

cadastro_conta:
    call clear_screen
    call readString

    apontar_banco 0, 0
    mov [bx], si
    
    jmp ler_opcao

buscar_conta:
    call clear_screen

    apontar_banco 0, 0
    mov si, bx
    call printString

    jmp ler_opcao
    
editar_conta:
    call clear_screen

    apontar_banco 1, 0
    mov si, bx
    call printString

    jmp ler_opcao

del_conta:
    jmp ler_opcao

list_agencias:
    jmp ler_opcao

list_contas_agencias:
    jmp ler_opcao

getchar:
    mov ah, 0
    int 16h
    ret

; imprime a string que esta em <si>
printString:
    mov al,byte[si]
    cmp al,0
    je return
    mov ah,0xe
    mov bh, 0
    int 10h
    inc si
    jmp printString

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
    mov ah, 0
    mov al, 12h
    int 10h
    call reset_cursor
    ret

; move o cursor para 0, 0
reset_cursor:
    mov ah, 2
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h
    ret

section .data
intro db 'Bem-vindo ao sistema!', 13, 10, 0
choose db 'Escolha sua opcao: ', 13, 10, 0
menu db '1 - Cadastrar nova conta', 13, 10, '2 - Buscar conta', 13, 10, '3 - Editar conta', 13, 10, '4 - Deletar conta', 13, 10, '5 - Listar agencias', 13, 10, '6 - Listar contas de uma agencia', 13, 10, '0 - Sair', 13, 10, 0

; reservar espaço do array
TABLE_COLUMSIZE equ 40
TABLE_ROWSIZE equ 64
banco_dados resb TABLE_COLUMSIZE * TABLE_ROWSIZE