%include "Helpers.asm"

SECTION .data
    cantLetras: db 26
    frecuencias: db 12.53, 1.42, 4.68, 5.86, 13.68, 0.69, 1.01, 0.70, 6.25, 0.44, 0.02, 4.97, 3.15, 6.71, 8.68, 2.51, 0.88, 6.87, 7.98, 4.63, 3.93, 0.90, 0.01, 0.22, 0.90, 0.52
    node equ 29
    nodeForest equ 12
    lastNode: db 0


SECTION .bss
    forest: resb 26 * nodeForest
    tree: resb 26 * node * 2

SECTION .text
    global _start

_start:
    mov cx, [cantLetras]
    loop1:
        print_digit rcx
        loop loop1
    exit