org 0x7e00
jmp 0x0000:start

start:
    ; setup
    xor ax, ax    ; ax <- 0
    mov ds, ax    ; ds <- 0
    mov es, ax    ; es <- 0
    mov ds, ax    ; ds <- 0

    ; [int 10h 00h] - modo de video
    mov al, 12h ; [modo de video VGA 640x480 16 color graphics]
    mov ah, 00h 
    int 10h

    ; [int 10h 0bh] - atributos de video
	mov bh, 0
	mov bl, 08h ; cor da tela 
    mov ah, 0bh
	int 10h

    jmp halt

halt:
    jmp $
