#!/bin/bash

rjal="Romildo Juliano de Almeida Lira"
acn2="Ariovaldo Capuano Neto"
gtbo="Gabriel Toscano de Brito Oliveira"
sslp="Sergio de Souza Leao Pessoa"
mgpp="Marcos Gabriel Pereira da Paz"

NASMVERSION() {
	nasm -v;
}

COMPILE_EXECUTE() {
	nasm -elf32 -o ap4.o ap4.asm;
	#NOT EXECUTING YET
}

GROUP() {
	echo "";
	echo "AP4 [IHS 2019.1]"; 
	echo "Integrantes do grupo:";
	echo "rjal: $rjal";
	echo "acn2: $acn2";
	echo "gtbo: $gtbo";
	echo "sslp: $sslp";
	echo "mgpp: $mgpp";
	echo "";
}

GROUP
echo "Compilando programa...";
echo "Versão do nasm: ";
NASMVERSION
COMPILE_EXECUTE



