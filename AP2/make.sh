#!/bin/bash
clear
nasm -f bin AP2_$1.asm -o AP$1
qemu-system-i386 AP$1
