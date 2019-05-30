extern printf

section .data
	limite: equ 7
	ask: db 'Calculadora de Pi pela Serie de Taylor!', 0
    answer: db 'O valor achado foi: ', 0
    string:    db "%s", 10, 0
    integer: dd "%d", 0xA, 0
    double: db "%f", 0xA, 0
    four: dd 4.0
    um: dd 1
    menosum: dd -1	

section .bss
	result: resd 1
	aux: resd 1
	sum: resd 1
	i: resd 1

section .text
	global main

main:
	finit
	push ask
	push string
	call printf
	add esp, 8
	mov ecx, limite ;quantidade de iterações
	mov dword[sum], 0
	mov edx, 0

	serie:
		;mov eax, 11	
		mov eax, limite
		sub eax, ecx; eax(valor de i) <- eax - ecx(contador)

		mov ebx, eax; passa valor de eax para ebx
        and ebx, 1 ;ve se o ultimo bit do valor de i eh igual 1
        cmp ebx, 1 ;se for igual 1, eh impar
        je set_i_neg ;se for impar, o numerador eh igual -1

        fild dword[um] ; st: +1
        back:
        	mov ebx, 2
        	mul ebx ; eax = 2*i
        	add eax, 1; eax = 2*i+1
        	mov dword[aux], eax
        	fild dword[aux]; st: (2*i+1), (+-1)
        	fxch ; st: (+-1), (2*i+1)
        	fdiv st0, st1; st: +-1/(2*i+1)
        	fstp dword[i]
        	fld dword[sum] ;st0 = sum
        	fadd dword[i] ; st0 = sum + i (i eh o valor achado nessa iteração)
        	fstp dword[sum] ;sum recebe o novo somatorio
        	
        	loop serie

    jmp end
   	
   	set_i_neg:
        fild dword[menosum] ; st= -1
  		
        jmp back

	end:

		sub esp, 8 ;espaco na pilha pra um double
		fld dword[sum] ;carrega o valor do somatorio
		fmul dword[four] ;multiplica por 4 p pegar pi
		fstp qword[esp] ;tira da pilha
		push double ;passa o formato
		call printf ;printa em c
		add esp, 12

	mov eax, 0
	ret
