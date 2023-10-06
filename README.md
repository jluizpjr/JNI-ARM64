# Usando JNI para fazer Java e Assembly conversarem

Olá, amantes da programação! 🚀

Já se perguntaram como fazer seu código Java “conversar” diretamente com Assembly, especialmente no novíssimo ARM64 dos Macs M1? Então, sente-se, pegue um café (ou chá, se preferir), porque vou te mostrar exatamente como fazer isso usando o Java Native Interface (JNI).

## 1. O que é JNI?
Em resumo, JNI (Java Native Interface) é uma interface de programação que permite que o código Java interaja com programas escritos em outras linguagens, como C, C++ e, no nosso caso, Assembly.

## 2. Preparando o Terreno
Primeiro, você precisa ter o JDK instalado. Se não tiver, corra lá e instale!

## 3. Nosso Programa Java
Vamos começar criando uma classe Java simples que invocará um método nativo. Chamaremos essa classe de ConversorMaiuscula. Salve o código abaixo como `ConversorMaiuscula.java`

```
public class ConversorMaiuscula {
    static {
        System.loadLibrary("maiuscula");
    }

    public native String paraMaiuscula(String texto);

    public static void main(String[] args) {
        ConversorMaiuscula conversor = new ConversorMaiuscula();
        String original = "Hello World!";
        String maiuscula = conversor.paraMaiuscula(original);

        System.out.println("Original: " + original);
        System.out.println("Maiúscula: " + maiuscula);
    }
}
```
## 4. Código Assembly
Agora precisamos implementar uma função que converte uma string para maiúsculas, usando assembly ARM64 (sim, aquele dos novos Macs M1) . Chamaremos esta função de `converter_para_maiuscula`. Salve o código abaixo como `conversormaiuscula.asm`

```
.section __TEXT, __text
.globl _converter_para_maiuscula
.align 4

_converter_para_maiuscula:
    stp     x29, x30, [sp, #-16] ; Prepara o stack frame.
    mov     x29, sp

processa_caractere:
    ldrb    w2, [x0]             ; Carrega o próximo byte (caractere) da string em w2.
    cbz     w2, termina          ; Se encontramos o byte nulo (final da string), terminamos.

    cmp     w2, #'a'             ; Verifica se o caractere é menor que 'a' (ou seja, não é uma letra minúscula).
    blo     nao_e_minusculo      ; Se sim, pula a conversão.

    cmp     w2, #'z'             ; Verifica se o caractere é maior que 'z' (ou seja, não é uma letra minúscula).
    bhi     nao_e_minusculo      ; Se sim, pula a conversão.

    
    sub     w2, w2, #('a' - 'A') ; Converte a letra minúscula em maiúscula.
    strb    w2, [x0]             ; Armazena o caractere convertido de volta na string.

nao_e_minusculo:
    add     x0, x0, #1           ; Move para o próximo caractere na string.
    b       processa_caractere

termina:
    ldp     x29, x30, [sp], #16  ; Restaura o stack frame.
    ret
```

## 5. Ponte JNI
Vamos criar nosso código em C que atuará como uma “ponte” entre Java e Assembly usando JNI. Esse código irá virar uma biblioteca dinâmica (.dylib). Salve o código abaixo como `conversormaiusculaJNI.c`. O código ficará assim:
```
#include <jni.h>
#include "ConversorMaiuscula.h"

extern void converter_para_maiuscula(const char* entrada);

JNIEXPORT jstring JNICALL Java_ConversorMaiuscula_paraMaiuscula(JNIEnv *env, jobject obj, jstring textoJava) {
    const char* entrada = (*env)->GetStringUTFChars(env, textoJava, NULL);

    converter_para_maiuscula(entrada);

    jstring resultado = (*env)->NewStringUTF(env, entrada);

    (*env)->ReleaseStringUTFChars(env, textoJava, entrada);
    return resultado;
}
```
## 6. Compilando e Rodando
Agora vem a parte divertida (e um pouco complicada)! Precisamos compilar e vincular tudo.

### 1.Compile o código Java:
`javac ConversorMaiuscula.java`

### 2. Compile o código assembly:
`as -o conversormaiuscula.o conversormaiuscula.asm`

### 3. Gere o cabeçalho JNI:
`javac -h . ConversorMaiuscula.java`

Esse passo gera o arquivo `ConversorMaiuscula.h` com o protótipo da nossa função. O conteúdo do arquivo será:
```
/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class ConversorMaiuscula */

#ifndef _Included_ConversorMaiuscula
#define _Included_ConversorMaiuscula
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     ConversorMaiuscula
 * Method:    paraMaiuscula
 * Signature: (Ljava/lang/String;)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_ConversorMaiuscula_paraMaiuscula
  (JNIEnv *, jobject, jstring);

#ifdef __cplusplus
}
#endif
#endif
```

### 4. Compile e vincule (link) o código C JNI e o objeto gerado pelo código Assembly, gerando nossa biblioteca dinâmica:
`gcc -dynamiclib -o libmaiuscula.dylib -I$JAVA_HOME/include -I$JAVA_HOME/include/darwin ConversorMaiusculaJNI.c conversormaiuscula.o`

### 5. Execute o programa Java:
`java -Djava.library.path=. ConversorMaiuscula`

E aí está! Você acabou de criar um programa Java que invoca código Assembly no ARM64!

Todo o código está no meu github: https://github.com/jluizpjr/JNI-ARM64

## Conclusão
Integrar Java com Assembly através do JNI pode parecer um pouco “nerd demais”, mas é super legal e poderoso! Se você mergulhar mais profundamente, verá que as possibilidades são infinitas. Então vá em frente, experimente, quebre coisas, conserte-as e continue codificando!

Gostou do tutorial? Deixe seu 👏 e compartilhe com seus amigos! Até a próxima aventura de código! 💻🎉
