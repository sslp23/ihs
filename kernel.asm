org 0x7e00
jmp 0x0000:start

; constantes
VERTICAL equ 0
HORIZONTAL equ 1
CARD_SIZE_X equ 72
CARD_SIZE_Y equ 102

DECK equ 0
ATTACK equ 1

; cada carta ocupa 5 bits
; cartas
TRAC equ 0 ; 000|00-000
GLIB equ 1 ; 000|00-001
LOTT equ 2 ; 000|00-010
FOHG equ 3 ; 000|00-011
BICC equ 4 ; 000|00-100
; cores
RED  equ 0x0c
GRN  equ 0x02
BLU  equ 0x09

MASK_GLYPH equ 0b111 ; AND mask para encontrar o tipo da carta

draw_linha:    
    ; desenhar
    int 10h
    inc dx

    ; size representa o numero total
    ; de pixels a ser printado
    dec word [size]	
    cmp word [size], 0
    jg draw_linha
    ret

draw_barras:
    mov word [x_coord], cx
    mov word [y_coord], dx
    mov word [width], ax
    mov word [length], si

    mov word [x_init], cx
    mov word [y_init], dx

    mov ah, 0ch
    mov bh, 0
    mov al, byte [color]

    .draw:
        mov si, word [length]
        mov word [size], si
        mov cx, word [x_coord]
        mov dx, word [y_coord]
        call draw_linha

        inc word [x_coord]
        dec word [width]
        cmp word [width], 0
        jg .draw
    ret

x_coord dw 0
y_coord dw 0
width dw 0
length dw 0

gridx dw 0
gridy dw 0

; (x, y)
; calcula a grade para posicionamento
; das cartas, guarda em «ax», «bx»
%macro get_grid 2
    mov ax, %1
    mov bx, %2
    call calc_grid
%endmacro

calc_grid:
    cmp bx, 0
    je .top
    cmp bx, 1
    je .mid
    jmp .bot

    .top:
        mov bx, 20
        imul ax, 92
        add ax, 20
        jmp .end
    .mid:
        mov bx, 185
        imul ax, 92
        add ax, 100
        jmp .end
    .bot:
        mov bx, 356
        imul ax, 92
        add ax, 360
        jmp .end
    
    .end:
        mov word [gridx], ax
        mov word [gridy], bx
        ret
        

; (x, y, width, length, color)
; desenha um retângulo em («x», «y»)
; de tamanho «width», «length»
; de cor «color»
%macro rect 5
    mov cx, %1
    mov dx, %2
    mov ax, %3
    mov si, %4
    mov byte [color], %5
    call draw_barras
%endmacro

; (x, y, width, length)
; desenha um retângulo em («x», «y»)
; de tamanho «width», «length»
; de cor pré-definida pela variavel «byte color_var»
%macro rect_color_var 4
    mov cl, byte [color_var]
    mov byte [color], cl
    mov cx, %1
    mov dx, %2
    mov ax, %3
    mov si, %4
    call draw_barras
%endmacro

select_start dw 0
select_end dw 0

; (gridx, griy, color)
; de cor pré-definida pela variavel «byte color_var»
%macro draw_selection 2
    get_grid %1, %2
    call draw_select
%endmacro

draw_select:
    sub ax, 6
    add bx, CARD_SIZE_Y
    add bx, 6
    mov word [select_start], ax
    mov word [select_end], bx
    rect_color_var word [select_start], word [select_end], CARD_SIZE_X + 12, 5
    ret

x_init_sp dw 0
y_init_sp dw 0

; (x, y)
%macro draw_card 2
    get_grid %1, %2
    rect ax, bx, CARD_SIZE_X, CARD_SIZE_Y, 0x0f
%endmacro

; (x, y)
%macro erase_card 2
    get_grid %1, %2
    rect ax, bx, CARD_SIZE_X, CARD_SIZE_Y, 0x00
%endmacro

%macro add_x 1
    add word [x_init], %1
%endmacro

%macro sub_x 1
    sub word [x_init], %1
%endmacro

%macro add_y 1
    add word [y_init], %1
%endmacro

%macro sub_y 1
    sub word [y_init], %1
%endmacro

; (x, y, color)
; card start x, y
%macro draw_glib 3
    draw_card %1, %2

    add_x 30
    add_y 28
    rect_color_var word [x_init], word [y_init], 9, 35
    add_y 26
    sub_x 13   
    rect_color_var word [x_init], word [y_init], 36, 9
%endmacro

; (x, y, color)
; card start x, y
%macro draw_fohg 3
    draw_card %1, %2

    add_x 29 ; x = 11
    add_y 51 ; y = 51
    rect_color_var word [x_init], word [y_init], 30, 9
    sub_x 15  ; x = 16
    sub_y 16 ; y = 35
    rect_color_var word [x_init], word [y_init], 9, 35
    sub_y 5 ; y = 30
    add_x 15 ; x = 15
    rect_color_var word [x_init], word [y_init], 9, 50
%endmacro

; (x, y, color)
; card start x, y
%macro draw_trac 3
    draw_card %1, %2

    add_x 16 ; x = 16
    add_y 28 ; y = 28
    rect_color_var word [x_init], word [y_init], 9, 20
    add_y 20 ; y = 48
    rect_color_var word [x_init], word [y_init], 40, 9
%endmacro

; (x, y, color)
; card start x, y
%macro draw_lott 3
    draw_card %1, %2

    add_x 16 ; x = 16
    add_y 48 ; y = 48
    rect_color_var word [x_init], word [y_init], 40, 9
    sub_y 20 ; y = 28
    rect_color_var word [x_init], word [y_init], 9, 50
    add_x 20 ; x = 32
    add_y 41 ; y = 48
    rect_color_var word [x_init], word [y_init], 20, 9
%endmacro

; (x, y, color)
; card start x, y
%macro draw_bicc 3
    draw_card %1, %2

    add_y 30 ; y = 62
    add_x 31 ; x = 31
    rect_color_var word [x_init], word [y_init], 9, 45
    add_x 16 ; x = 47
    add_y 30 ; y = 50
    rect_color_var word [x_init], word [y_init], 9, 15
%endmacro


x_init dw 0
y_init dw 0

color db 0
color_var db 0

color_value db 0 ; usado para salvar a carta escolhida

size 	  dw 0
direction db 0

%macro save_card 1
    or dword [cards_player], %1
    call record_card
%endmacro

%macro save_card_attack 1
    or dword [cards_attack], %1
    call record_card_attack
%endmacro

record_card:
    inc byte [cards_dealt]
    shl dword [cards_player], 3
    ret

record_card_attack:
    shl dword [cards_attack], 3
    ret

; (deck [DECK ou ATTACK], jogador, carta)
; procura uma carta e salva em dl
%macro search_card 3
    mov al, %1
    mov byte [query_deck], al
    mov al, %2
    mov byte [query_player], al
    mov ax, %3
    mov word [query_card], ax
    call search_carta
%endmacro

%macro random 1
    mov word [modulo], %1
    call rand
%endmacro

; rand é salvo em «dl»
rand:
    mov ah, 00h  ; interrupts to get system time
    int 1ah      ; CX:DX now hold number of clock ticks since midnight
    mov ax, dx
    xor dx, dx
    mov cx, word [modulo]
    div cx
    mov cx, 1
    ret

modulo dw 0

; gera uma cor aleatoria e carrega em «color»
random_color:
    random 3

    cmp dl, 0
    je .red
    cmp dl, 1
    je .green
    jmp .blue
    
    .red:
        mov byte [color_var], 0x0c
        ret
    .green:
        mov byte [color_var], 0x02
        ret
    .blue:
        mov byte [color_var], 0x09
        ret

refresh_video:
    ; [int 10h 00h] - modo de video
    mov al, 13h ; [modo de video VGA]
    mov ah, 00h
    int 10h
    ret

clear_selection:
    push word [color_var]
    mov word [color_var], 0x00
    draw_selection word [p_selection], word [p_number]
    pop word [color_var]
    ret

game_loop:

    .read:
        ; [int 16h 00h] - ler teclado
        mov ah, 00h
        int 16h ; salva tecla em «ah, al»
        cmp ah, 4bh ; seta esquerda
        je .left
        cmp ah, 4dh ; seta direita
        je .right
        cmp al, 0dh ; enter
        je .select_card
        jmp game_loop

        .left:
            call clear_selection
            dec word [p_selection]
            cmp word [p_selection], 0
            jge .draw
            mov word [p_selection], 2
            jmp .draw          

        .right:
            call clear_selection
            inc word [p_selection]
            cmp word [p_selection], 2
            jle .draw
            mov word [p_selection], 0
            jmp .draw

        .select_card:
            call clear_selection

            erase_card word [p_selection], word [p_number]
            
            mov eax, dword [cards_player]
            mov dword [cards_player_temp], eax

            shr dword [cards_player_temp], 3 ; tirar os bits da carta do centro
            
            inc byte [round_number]

            cmp word [p_number], 2
            je .goto_p_one
            jmp .goto_p_two
            .goto_p_one:
                ; player 2 tem os 9 primeiros bits (menos significantes)
                ; então não precisamos de shift

                search_card DECK, byte [p_number], word [p_selection]
                call move_card

                mov word [p_number], 0
                mov word [color_var], RED
                jmp .draw
            .goto_p_two:
                ; player 1 tem os 9 proximos bits depois de player 2

                search_card DECK, byte [p_number], word [p_selection]
                call move_card

                mov word [p_number], 2
                mov word [color_var], BLU
                jmp .draw
        
        .draw: ; posicao da carta coluna, na linha tal que é dada por p_number
            draw_selection word [p_selection], word [p_number]

        jmp game_loop

; Move a carta selecionada para o centro
move_card:
    ; encontrar posiçao para por a carta
    mov eax, dword [cards_player_temp]
    save_card_attack eax

    cmp byte [round_number], 2
    jg .sec_round
    jmp .fst_round
    .fst_round:
        cmp word [p_number], 0
        je .f_p1
        jmp .f_p2
        .f_p1:
            mov word [current_x], 1
            jmp .skip
        .f_p2:
            mov word [current_x], 3
            jmp .skip
    .sec_round:
        cmp word [p_number], 0
        je .s_p1
        jmp .s_p2
        .s_p1:
            mov word [current_x], 4
            call play_cards
            shr word [cards_attack], 3
            jmp end_game
            ;jmp .skip
        .s_p2:
            mov word [current_x], 0
            jmp .skip
            
    .skip:
    call play_cards
    ret

; o codigo da carta encontrada é salvo em «dl»
search_carta:
    cmp byte [query_deck], DECK
    je .deck
    jmp .attack

    .deck:
        mov eax, dword [cards_player]
        jmp .skip
    .attack:
        mov eax, dword [cards_attack]

    .skip:
    mov dword [cards_player_temp], eax

    cmp byte [query_player], 0
    je .player_1
    cmp byte [query_player], 1
    je .next
    cmp byte [query_player], 2
    je .player_2

    .player_1:
        shr dword [cards_player_temp], 12
        jmp .next
    .player_2:
        shr dword [cards_player_temp], 3
        jmp .next
    .next:

    mov cl, 6
    imul ax, word [query_card], 3
    sub cl, al
    shr dword [cards_player_temp], cl
    and dword [cards_player_temp], MASK_GLYPH

    ; carta é encontrada e salva em «dl»
    mov dl, byte [cards_player_temp]

    ret

query_deck db 0
query_player db 0
query_card dw 0

; variavel que determina se o programa está
; distribuindo as cartas ou apenas as desenhando
is_dealing db 0

; carta selecionada pelo player
p_selection dw 0

; numero do jogador atual (0 ou 2)
p_number dw 0

; numero do "round" (quantas vezes já trocou de jogador)
round_number db 0

; "array" de cartas geradas
cards_player dd 0
; "array" de cartas escolhidas
cards_attack dd 0
; "array" temporario para calculos
cards_player_temp dd 0

; numero de cartas colocadas (counter)
cards_dealt db 0

current_x dw 0
current_y dw 0
max_cards dw 0

; usado para saber qual player esta sendo calculado os pontos
p_to_score db 0

; usados para comparaçao
carta_atacada db 0
carta_atacante db 0

; pontuaçao dos players
pontos_p1 db 0
pontos_p2 db 0


compare_glyph:
    xor cx, cx
    mov dh, byte [carta_atacada]
    mov dl, byte [carta_atacante]
    
    cmp dl, 0
    je .trac

    cmp dl, 1
    je .glib

    cmp dl, 2
    je .lott
    
    cmp dl, 3
    je .fohg

    cmp dl, 4
    je .bicc

    .trac:
        cmp dh, BICC
        je .win
        cmp dh, GLIB
        je .win
        jmp .lose
    .glib:
        cmp dh, LOTT
        je .win
        cmp dh, BICC
        je .win
        jmp .lose
    .lott:
        cmp dh, TRAC
        je .win
        cmp dh, FOHG
        je .win
        jmp .lose
    .fohg:
        cmp dh, GLIB
        je .win
        cmp dh, TRAC
        je .win
        jmp .lose
    .bicc:
        cmp dh, FOHG
        je .win
        cmp dh, LOTT
        je .win
        jmp .lose

    .win:
        add cl, 1
        jmp .score
    .lose:
        sub cl, 2
        jmp .score

    
    .score:
        cmp byte [p_to_score], 0
        je .p_one
        jmp .p_two
        .p_one:
            add byte [pontos_p1], cl
            jmp .finish
        .p_two:
            add byte [pontos_p2], cl
            jmp .finish
    
    .finish:
        ret

end_game:
    ; salvar carta do centro
    search_card DECK, 1, 2
    mov byte [carta_atacada], dl

    ; comparar player 2 -> centro
    mov byte [p_to_score], 2
    search_card ATTACK, 2, 0
    mov byte [carta_atacante], dl
    call compare_glyph

    ; comparar player 1 -> centro
    mov byte [p_to_score], 0
    search_card ATTACK, 1, 0
    mov byte [carta_atacante], dl
    call compare_glyph

    ; comparar player 2 (carta 2) -> player 1
    mov byte [p_to_score], 2
    search_card ATTACK, 1, 1 ;
    mov byte [carta_atacante], dl
    search_card ATTACK, 1, 0
    mov byte [carta_atacada], dl
    call compare_glyph

    ; comparar player 1 (carta 2) -> player 2
    mov byte [p_to_score], 0
    search_card ATTACK, 1, 2
    mov byte [carta_atacante], dl
    search_card ATTACK, 2, 0
    mov byte [carta_atacada], dl
    call compare_glyph

    mov al, byte [pontos_p1]

    cmp al, byte [pontos_p2]
    jl  .p2_wins
    jg  .p1_wins
    jmp .draw
    
    .p2_wins:
        rect 0, 336, 15, 144, BLU
        jmp .finish
    .p1_wins:
        rect 625, 0, 15, 144, RED
        jmp .finish
    .draw:
        rect 625, 0, 15, 144, 0x0b
        rect 0, 336, 15, 144, 0x0b
        jmp .finish

    .finish:
        jmp halt

; (current x, current y, num_cartas, cor)
; colocar cartas aleatorias na mesa
; começando da posicao «x», «y»
; até «num_cartas»
; de cor «cor»
%macro lay_cards 4
    mov word [current_x], %1
    mov word [current_y], %2
    mov word [max_cards], %3
    mov word [color_var], %4
    call play_cards
%endmacro

play_cards:
    cmp byte [is_dealing], 1
    je .random
    jmp .play

    .random:
        random 5
        mov byte [cards_player_temp], dl
        mov eax, dword [cards_player_temp]
        save_card eax

    .play:

        cmp dl, 0
        je .trac

        cmp dl, 1
        je .glib

        cmp dl, 2
        je .lott
        
        cmp dl, 3
        je .fohg

        cmp dl, 4
        je .bicc

        .trac:
            draw_trac word [current_x], word [current_y], 0
            jmp .next
        .glib:
            draw_glib word [current_x], word [current_y], 0
            jmp .next
        .lott:
            draw_lott word [current_x], word [current_y], 0 
            jmp .next
        .fohg:
            draw_fohg word [current_x], word [current_y], 0 
            jmp .next
        .bicc:
            draw_bicc word [current_x], word [current_y], 0 
            jmp .next

        .next:
            mov dx, word [max_cards]
            inc word [current_x]
            cmp word [current_x], dx ; dx cartas para cada jogador
            jl .random
            jmp .finish

        .finish:
            ret

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

    ; tabuleiro
    rect 0, 144, 640, 6, RED
    rect 0, 330, 640, 6, BLU

    rect 0, 150, 640, 180, 0x06
    ; tabuleiro

    mov byte [is_dealing], 1
    lay_cards 0, 0, 3, RED
    lay_cards 0, 2, 3, BLU
    lay_cards 2, 1, 1, GRN
    mov byte [is_dealing], 0

    shr dword [cards_player], 3 ; ultimos 3 bits nao sao usados

    mov word [p_number], 2 ; o jogador a ir primeiro
    mov word [color_var], BLU ; a cor do seletor é dada pela variavel «color_var»
    draw_selection 0, 2 ; seletor na linha 2, posição 0
    call game_loop

    jmp halt

halt:
    jmp $
