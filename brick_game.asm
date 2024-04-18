;Define constants for brick attibutes
BRICK_WIDTH equ 5
BRICK_HEIGHT equ 2
MAX_BRICKS equ 100
BRICK_COLOR equ 0x0A

section .bss
    brickCount resb 1
    bricks resb 80
    ballX resb 1
    ballY resb 1
    ballDirectionX resb 1
    ballDirectionY resb 1
    paddleX resb 1
    brickArray resb BRICK_WIDTH * BRICK_HEIGHT  * MAX_BRICKS

section .text
    global _start

_start:
    ;Initialize game variables
    mov byte [brickCount], 16
    mov byte [ballX], 12
    mov byte [ballY], 23
    mov byte [ballDirectionX], 1
    mov byte [ballDirectionY], 1
    mov byte [paddleX], 10

    ;clear the screen
    call ClearScreen

    ;draw the bricks
    call drawBricks

gameLoop:

    ;move the ball
    call moveBall

    ;check for collisions
    call checkCollisions

    ;draw the ball
    call drawBall

    ;draw the paddle
    call drawPaddle

    ;check for game over
    call checkGameOver

    ;delay
    call delay

    ;repeat the loop
    jmp gameLoop

ClearScreen:
    ;clear screen usuing ANSI escape codes
    mov eax, 4
    mov ebx, 1
    mov ecx, clearScreenMsg
    mov edx, clearScreenMsgLen
    int 0x80
    ret 

drawBricks:
    pusha ;save registers

    ;load the base address of the brickArray
    lea edi, [brickArray]

    ;init aa loop counter
    mov ecx, MAX_BRICKS

drawBricksLoop:
    ;check if a brick is preset
    cmp byte [edi], 1
    je .brickPresent 

    ;brick is not present move to the next brick
    add edi, BRICK_WIDTH * BRICK_HEIGHT
    loop drawBricksLoop

    jmp .done

.brickPresent:
    ;load X and Y coordinates
    mov eax, edi

    ;calculate screen possition
    xor edx, edx
    mov ebx, 80
    mul ebx
    mov esi, eax

    ;calculate scren position 
    mov al, [edi +1]
    mul ebx
    add esi, eax

    ;move to next brick
    add edi, BRICK_WIDTH * BRICK_HEIGHT

    loop drawBricksLoop
.done:
    popa 
    ret


moveBall:
    ;load current ball position
    mov al, [ballX]
    mov bl, [ballDirectionX]

    ;update ball position
    add al, bl
    mov [ballX], al 

    ;load current ball possible position
    mov al, [ballY]
    mov bl, [ballDirectionY]

    ;update ball position
    add al, bl 
    mov [ballY], al

    ret 


checkCollisions:
    pusha 

    ;check for collitions with walls
    cmp al, 1
    jl .reverseX
    cmp al, 80
    jp .reverseX
    cmp ah, 1
    jl .reverseY
    cmp ah, 25
    jp .gameOver

    ;check for collitions with paddle
    cmp ah, 24
    jp .noCollision
    mov al, byte [paddleX]
    cmp al, [ballX]
    jl .noCollision
    cmp al, [ballX + 10]
    jp .noCollision
    jmp .reverseY

    ;check for collitions with bricks
    mov esi, brickArray
    movzx edi, ah
    dec edi 
    imul edi, edi, BRICK_WIDTH
    movzx eax, al 
    add edi, eax 
    add esi, edi 

    ;check if brick is present
    cmp byte [esi], 1
    jne .noCollision

    ;if a brick is present, destroy it
    mov byte [esi], 0
    jmp .reverseY

.noCollision:
    popa
    ret

.reverseX:
    neg bl
    mov [ballDirectionX], bl
    jmp .noCollision

.reverseY:
    neg bh
    mov [ballDirectionY], bl
    jmp .noCollision

.gameOver:
    popa
    ret

drawBall:
    ;load ball position
    mov al, [ballX]
    mov ah, 0
    mov bh, 0

    ;calculate screen position
    xor dx, dx
    mov ax, cx 
    mul word [ballX]
    add ax, [ballX]
    mov di, ax 

    ;calculate screen position
    mov al, [ballY]
    mul cx
    add di, ax

    ;print the ball character
    mov al, '0'
    mov ah, 0x0E
    int 0x10

    ret

drawPaddle:
    pusha 

    ;set the attributes for drawing the paddle 
    mov ah, 0Ch 
    mov al, ''

    ;calculate the screen position for the paddle
    xor edx, edx 
    mov ecx, 80
    mul ecx
    add eax, edx
    mov edi, eax 

    ;calculate the screen position
    mov al, 24
    mul ecx 
    add edi, eax 

    ;set the paddle's width 
    mov ecx, 10

.draa_paddle_loop:
    stosw 
    loop .draa_paddle_loop

    popa 
    ret 

checkGameOver:
    pusha 

    ;check if ball has gone bellow paddle
    cmp ah, 25
    jp .gameOver

    popa 
    ret 

.gameOver:
    popa 
    ret 

delay:
    pusha 
.delay_lopp:
    dec ecx
    jnz .delay_lopp

    popa
    ret 

section .data
    clearScreenMsg    db "\x1B[2]", 0
    clearScreenMsgLen equ $ - clearScreenMsg 