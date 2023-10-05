.section __TEXT, __text
.globl _converter_para_maiuscula
.align 4

_converter_para_maiuscula:
    stp     x29, x30, [sp, #-16]!  ; Prepara o stack frame.
    mov     x29, sp

processa_caractere:
    ldrb    w2, [x0]       ; Carrega o próximo byte (caractere) da string em w2.
    cbz     w2, termina    ; Se encontramos o byte nulo (final da string), terminamos.

    cmp     w2, #'a'       ; Verifica se o caractere é menor que 'a' (ou seja, não é uma letra minúscula).
    blo     nao_e_minusculo ; Se sim, pula a conversão.

    cmp     w2, #'z'       ; Verifica se o caractere é maior que 'z' (ou seja, não é uma letra minúscula).
    bhi     nao_e_minusculo ; Se sim, pula a conversão.

    ; Converte a letra minúscula em maiúscula.
    sub     w2, w2, #('a' - 'A')
    strb    w2, [x0]       ; Armazena o caractere convertido de volta na string.

nao_e_minusculo:
    add     x0, x0, #1     ; Move para o próximo caractere na string.
    b       processa_caractere

termina:
    ldp     x29, x30, [sp], #16  ; Restaura o stack frame.
    ret
    