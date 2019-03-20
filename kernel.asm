org 0x7e00
jmp 0x0000:start

helloWorld db 'Hello Romildo', 13, 10, 0

start:
    ; setup
    xor ax, ax    ; ax <- 0
    mov ds, ax    ; ds <- 0
    mov es, ax    ; es <- 0
    mov ds, ax    ; ds <- 0

    mov bl, 10 ; seta cor dos caracteres para amarelo

    mov ah, 00h
    mov al, 12h
    int 10h
    mov bl,1110b ; seta cor
    ;call readString

	mov si, helloWorld
	call printString

    jmp halt

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
