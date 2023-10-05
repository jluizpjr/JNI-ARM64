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
