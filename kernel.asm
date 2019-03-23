org 0x7e00
jmp 0x0000:start

intro db 'Bem-vindx ax sistemx!', 13, 10, 0
choose db 'Escolha sua opcao: ', 13, 10, 0
menu db '1 - Cadastrar nova conta', 13, 10, '2 - Buscar conta', 13, 10, '3 - Editar conta', 13, 10, '4 - Deletar conta', 13, 10, '5 - Listar agencias', 13, 10, '6 - Listar contas de uma agencia', 13, 10, '0 - Sair', 13, 10, 0

start:
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
	call cadastro_conta

	cmp al, '2'
	call buscar_conta

	cmp al, '3'
	call editar_conta

	cmp al, '4'
	call del_conta

	cmp al, '5'
	call list_agencias

	cmp al, '6'
	call list_contas_agencias

	cmp al, '0'
	je halt

	jmp begin

cadastro_conta:
	ret

buscar_conta:
	ret
	
editar_conta:
	ret

del_conta:
	ret

list_agencias:
	ret

list_contas_agencias:
	ret

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

