org 0x7c00 
jmp 0x0000:start

string db 'AP2 de IHS', 13, 10, 0
stringlen equ $ - string
setcur db 10, 10, 10, 10, 10, 10, 10, 10, 10, '                                                       ', 0

start:
	; nunca se esqueca de zerar o ds,
	; pois apartir dele que o processador busca os 
	; dados utilizados no programa.
	xor ax, ax
	mov ds, ax

	;Início do seu código
    ;Cria a interrupção baseada no endereço 40h
    push ds ; Salva o contexto
    xor ax, ax ; Zera AX
    mov ds, ax ; Zera DS
    mov di, 0100H ; Move DI para o valor correspondente na IVT
    mov word[di], print_string ; Passa o endereço exato para IP a ser somado com CS
    mov word[di+2], 0; Passa 0 com CS pois ele será somado com IP e terá que resultar no endereço real
    pop ds; Volta para a rotina principal

    call set_graphic_mode; Seta o modo gráfico

    mov si, setcur
    call print; Printa a string setcur que serve para mudar a posição do cursor na tela

    mov bx, string; Passa a string para BX
    mov cx, stringlen; Passa o tamanho da string para CX
    int 40h

jmp end

print:; Função que printa uma string em SI
    lodsb
    cmp al, 0
    je print_ret
    
    mov ah, 0eh
    int 10h
jmp print
    

set_graphic_mode:; Habilita o modo gráfico 320 x 200 de 256 cores
    mov ah, 4fh
    mov al, 02h
    mov bx, 13h
    int 10h
ret

print_string:; Printa a string movida em BX e usa um valor como parâmetro de laço em CX
    cld

    .putchar:
        cmp cx, 0
        je end_print

        mov ah, 0eh
        mov al, byte [bx]; Passa o 
        int 10h

        inc bx
        dec cx
    jmp .putchar 
    
end_print:; Usada para voltar ao programa principal que chamou a ISR
    iret

print_ret:; Retorna o valor para indicar o fim da função print normal
    ret

end:
    jmp $

times 510-($-$$) db 0		; preenche o resto do setor com zeros 
dw 0xaa55			; coloca a assinatura de boot no final
				; do setor (x86 : little endian)
