section .bss
    brickCount resb 1
    bricks resb 80
    ballX resb 1
    ballY resb 1
    ballDerectionX resb 1
    ballDirectionY resb 1
    paddleX resb 1

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