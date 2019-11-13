%include "Helpers.asm"

; Seccion de informacion
SECTION .data

    LETRAS_TOTALES equ 26           ; Cantidad de letras en total
    NODE_TREE equ 29             ; Tamano del nodo del arbol
    NODE_FOREST equ 12       ; Tamano del nodo del bosuqe

    cantLetras: dd LETRAS_TOTALES   ; Cantidad de letras restantes de acomodar
    lastNode: dd 0          ; Posicion del ultimo nodo del arbol
    frecuencias: dd 12.53, 1.42, 4.68, 5.86, 13.68, 0.69, 1.01, 0.70, 6.25, 0.44, 0.02, 4.97, 3.15, 6.71, 8.68, 2.51, 0.88, 6.87, 7.98, 4.63, 3.93, 0.90, 0.01, 0.22, 0.90, 0.52


SECTION .bss
    forest: resb LETRAS_TOTALES * NODE_FOREST    ; Array de forest
    tree: resb LETRAS_TOTALES * NODE_TREE * 2        ; Array del bosque

SECTION .text
    global _start

; Funcion principal en assembler
_start:
    finit                       ; resetea la pila de flotantes
    mov cx, 0                   ; Inicio del ciclo para establece los nodos iniciales

    loop1:

        ; Logica
        xor rax, rax

        ; Calcula la direccion del nodo que se esta guarda
        mov eax, ecx    ; Se multiplica al nodo actual el tamano de cada nodo
        mov ebx, NODE_TREE
        mul ebx
        mov r8, rax
        add r8, tree   ; Y se le suma la direccion de memoria del primer nodo

        ; Ordena los datos del nodo
        mov eax, ecx    ; se calcula el inicio de la frecuencia del nodo
        mov ebx,  4
        mul ebx
        fld dword [frecuencias + eax]    ; almacena la frecuencia de la letra
        fstp dword [r8]                   ; almacena la frecuencia en el edx

        mov eax, 97
        add eax, ecx                     ; Suma 97 al contador

        mov [r8+4], rax                  ; Ponemos el caracter en el nodo
        mov [lastNode], rcx                ; Guardamos la posicion del ultimo nodo

        ; Procedimiento para el for
        inc cx                  ; Incrementa el cx

        cmp cx, LETRAS_TOTALES          ; Lo comparamos para ver si tenemos que salir
        jne loop1               ; si es 26, entonces terminamos

    ; Aqui sigue el codigo
    mov cx, 0       ; Reinicia el loop
    mov r9, forest       ; obtenemos la direccion del nodoForest
    finit           ; Reinicia la pila de flotantes
    loop2:
        ; Cargar los punteros en el bosque
        ; Logica
        xor rax, rax

        ; Calcula la direccion del nodo que se esta guarda
        mov eax, ecx    ; Se multiplica al nodo actual el tamano de cada nodo
        mov ebx, NODE_TREE
        mul ebx
        mov r8, rax
        add r8, tree   ; Y se le suma la direccion de memoria del primer nodo
        break:
        fld dword [r8]  ; Carga la frecuencia a la pila
        fstp dword [r9] ; Guarda la frecuencia en el inicio del nodo

        mov [r9+4], r8
        

        ; Procedimiento para el for
        inc cx                  ; Incrementa el cx

        cmp cx, LETRAS_TOTALES          ; Lo comparamos para ver si tenemos que salir
        jne loop2               ; si es 26, entonces terminamos




    exit                        ; Cierra el programa