org 0x500
jmp 0x0000:load_menu ; TROCAR PARA «start» PARA APARECER A ANIMAÇAO!!!


str1 db 'Carregando estrutura para o kernel...',10, 13, 0
str2 db 'Configurando para o modo protegido...',10, 13, 0
str3 db 'Carregando memoria no Kernel', 10, 13, 0
str4 db 'Executando Kernel', 10, 13, 0

delay: 
;delay baseado em ax    
    push dx
    mov bp, dx
    back:
    dec bp
    nop
    jnz back
    dec dx
    cmp dx,0    
    jnz back

    pop dx
ret

printString: 
;; Printa a string que esta em si    
    
    lodsb ;carrega em al oq está em SI e incrementa SI
    cmp al, 0
    je exit

    mov ah, 0xe
    int 10h	
    
    jmp printString
exit:
ret

printaPixels:
    add cx,10
    add dx,400
    mov ah, 0ch
    mov bh, 0
    mov al,bl

    int 10h
    sub cx,10
    sub dx,400
    ret


quadrado:
xor cx,cx;largura
;mov dx,1
while2:
    mov dx,1
    ;xor cx,cx;largura
    while:
        call printaPixels
        
        inc dx
        cmp dx,10
        jne while
    mov dx,25    
    call delay
        
    inc cx
    cmp cx,40
    je printaStr1

    cmp cx,280
    je printaStr2

    cmp cx,460
    je printaStr3

    cmp cx,550
    je printaStr4

    
    cmp cx,600;fim do load
    jne while2
    
ret

printaStr1:
mov si, str1
call printString
mov dx,2000 
call delay
jmp while2

printaStr2:
mov si, str2
call printString
mov dx,2000    
call delay
jmp while2

printaStr3:
mov si, str3
call printString
mov dx,2000    
call delay
jmp while2

printaStr4:
mov si, str4
call printString
mov dx,2000
call delay
jmp while2




start:

    mov bl, 10 ; Seta cor dos caracteres para amarelo

    mov ah, 00h
    mov al, 12h
    int 10h
    mov bl,1110b;seta cor

    mov cx,20
    mov dx,30
    call quadrado

    mov dx, 9000
    call delay

    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ah, 0xb
    mov bh, 0
    mov bl, 4
    int 10h
    jmp load_menu
load_menu:
;Setando a posição do disco onde kernel.asm foi armazenado(ES:BX = [0x7E00:0x0])
    mov ax, 0x7E0	;0x7E0<<1 + 0 = 0x7E00
    mov es,ax
    xor bx,bx		;Zerando o offset

;Setando a posição da RAM onde o menu será lido
    mov ah, 0x02	;comando de ler setor do disco
    mov al, 4		;quantidade de blocos ocupados pelo menu
    mov dl, 0		;drive floppy

;Usaremos as seguintes posições na memoria:
    mov ch, 0		;trilha 0
    mov cl, 3		;setor 3
    mov dh, 0		;cabeca 0
    int 13h
    jc load_menu	;em caso de erro, tenta de novo

break:
    jmp 0x7e00		;Pula para a posição carregada

times 510-($-$$) db 0
dw 0xaa55
