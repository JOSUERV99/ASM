%include "Helpers.asm"

SECTION .data
    
    letras equ 26
    node equ 29
    nodeForest equ 12
    
    cantLetras: dd letras
    lastNode: dd 0
    frecuencias: dd 12.53, 1.42, 4.68, 5.86, 13.68, 0.69, 1.01, 0.70, 6.25, 0.44, 0.02, 4.97, 3.15, 6.71, 8.68, 2.51, 0.88, 6.87, 7.98, 4.63, 3.93, 0.90, 0.01, 0.22, 0.90, 0.52


SECTION .bss
    forest: resb letras * nodeForest
    tree: resb letras * node * 2

SECTION .text
    global _start

_start:
    mov cx, [cantLetras]
    loop1:
        print_digit rcx
        loop loop1
    exit