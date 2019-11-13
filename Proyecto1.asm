%include "Helpers.asm"

; Seccion de informacion
SECTION .data

    letras equ 26           ; Cantidad de letras en total
    node equ 29             ; Tamano del nodo del arbol
    nodeForest equ 12       ; Tamano del nodo del bosuqe

    cantLetras: dd letras   ; Cantidad de letras restantes de acomodar
    lastNode: dd 0          ; Posicion del ultimo nodo del arbol
    frecuencias: dd 12.53, 1.42, 4.68, 5.86, 13.68, 0.69, 1.01, 0.70, 6.25, 0.44, 0.02, 4.97, 3.15, 6.71, 8.68, 2.51, 0.88, 6.87, 7.98, 4.63, 3.93, 0.90, 0.01, 0.22, 0.90, 0.52


SECTION .bss
    forest: resb letras * nodeForest    ; Array de forest
    tree: resb letras * node * 2        ; Array del bosque

SECTION .text
    global _start

; Funcion principal en assembler
_start:
    finit                       ; resetea la pila de flotantes
    mov cx, 0                   ; Inicio del ciclo para establece los nodos iniciales

    loop1:

        ; Logica
        mov rax, 0

        ; Calcula la direccion del nodo que se esta guarda
        mov eax, ecx    ; Se multiplica al nodo actual el tamano de cada nodo
        mov ebx, node
        mul ebx
        mov r8, rax
        add r8, tree   ; Y se le suma la direccion de memoria del primer nodo

        break1:
        ; Ordena los datos del nodo
        mov eax, ecx    ; se calcula el inicio de la frecuencia del nodo
        mov ebx,  4
        mul ebx
        fld dword [frecuencias + eax]    ; almacena la frecuencia de la letra
        fstp dword [r8]                   ; almacena la frecuencia en el edx

        mov eax, 97
        add eax, ecx                     ; Suma 97 al contador

        print_digit rax

        ; Procedimiento para el for
        break:
        inc cx                  ; Incrementa el cx

        cmp cx, letras          ; Lo comparamos para ver si tenemos que salir
        jne loop1               ; si es 26, entonces terminamos

    ; Aqui sigue el codigo


    exit                        ; Cierra el programa