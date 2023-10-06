# Defina o caminho do JAVA_HOME se ele não estiver definido
JAVA_HOME ?= /usr/lib/jvm/default-java
JNI_INCLUDE = -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/darwin

all: ConversorMaiuscula.class libmaiuscula.dylib

ConversorMaiuscula.class: ConversorMaiuscula.java
	javac $^

ConversorMaiuscula.h: ConversorMaiuscula.class
	javac -h . ConversorMaiuscula

conversormaiuscula.o: conversormaiuscula.asm
	as -o $@ $^

libmaiuscula.dylib: ConversorMaiusculaJNI.c ConversorMaiuscula.h conversormaiuscula.o
	gcc $(JNI_INCLUDE) -dynamiclib -o $@ ConversorMaiusculaJNI.c conversormaiuscula.o

run: ConversorMaiuscula.class libmaiuscula.dylib
	java -Djava.library.path=. ConversorMaiuscula

clean:
	rm -f *.class *.h *.dylib *.o

.PHONY: all run clean
