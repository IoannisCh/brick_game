;Define constants for brick attibutes
BRICK_WIDTH equ 5
BRICK_HEIGHT equ 2
BRICK_COLOR equ 0x0A

section .bss
    brickCount resb 1
    bricks resb 80
    ballX resb 1
    ballY resb 1
    ballDerectionX resb 1
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
    mov byte [ballDerectionX], 1
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
    pushhad ;save registers

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
    mov bl, [ballDerectionX]

    ;update ball position
    add al, bl
    mov [ballX], al 

    ;load current ball possible position
    mov al, [ballY]
    mov bl, [ballDerectionY]

    ;update ball position
    add al, bl 
    mov [ballY], al

    ret 


checkCollisions:

drawBall:

drawPaddle:

checkGameOver:

delay:
    pushhad 
.delay_lopp:
    dec ecx
    jnz .delay_lopp

    popad
    ret 

section .data
    clearScreenMsg    db "\x1B[2]", 0
    clearScreenMsgLen equ $ - clearScreenMsg 