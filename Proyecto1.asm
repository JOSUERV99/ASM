%include "Helpers.asm"

; Seccion de informacion
SECTION .data

    LETRAS_TOTALES equ 26           ; Cantidad de letras en total
    
    NODE_TREE equ 29                ; Tamano del nodo del arbol
    ; Frecuencia (4 bits) - Caracter (1 bit) - Nodo padre (8 bits) - Hijos izquierdo y derecho (16 bits)
    
    NODE_FOREST equ 12              ; Tamano del nodo del bosuqe
    ; Frecuencia (4 bits) - Puntero al nodo del arbol (8 bits)

    cantLetras: dd LETRAS_TOTALES   ; Cantidad de letras restantes de acomodar
    lastNode: dd 0                  ; Posicion del ultimo nodo del arbol
    frecuencias: dd 12.53, 1.42, 4.68, 5.86, 13.68, 0.69, 1.01, 0.70, 6.25, 0.44, 0.02, 4.97, 3.15, 6.71, 8.68, 2.51, 0.88, 6.87, 7.98, 4.63, 3.93, 0.90, 0.01, 0.22, 0.90, 0.52


SECTION .bss
    forest: resb LETRAS_TOTALES * NODE_FOREST           ; Array de forest
    tree: resb LETRAS_TOTALES * NODE_TREE * 2           ; Array del bosque

SECTION .text
    global _start

; Funcion principal en assembler
_start:
    finit                       ; resetea la pila de flotantes
    mov cx, 0                   ; Inicio del ciclo para establece los nodos iniciales
   
    ; Este ciclo establece los nodos principales en el arbol como hojas
    loop1:

        ; Calcula la direccion del nodo que se esta guarda
        get_node_addr rcx, NODE_TREE, tree
        mov r8, rax

        ; Ordena los datos del nodo
        mov eax, ecx                        ; Se calcula el inicio de la frecuencia del nodo
        mov ebx,  4
        mul ebx
        fld dword [frecuencias + eax]       ; Almacena la frecuencia de la letra
        fstp dword [r8]                     ; y la suelta en el inicio del nodo

        mov eax, 97
        add eax, ecx                        ; Suma 97 al contador, para obtener la otra, ya que 97 es a en ASCII

        mov [r8 + 4], rax                     ; Ponemos el caracter en el nodo
        mov [lastNode], rcx                 ; Guardamos la posicion del ultimo nodo

        ; Procedimiento para el for
        inc cx                  ; Incrementa el cx

        cmp cx, LETRAS_TOTALES          ; Lo comparamos para ver si tenemos que salir
        jne loop1                       ; si es 26, entonces terminamos

    ; Aqui sigue el codigo
    xor rcx, rcx                    ; Reinicia el loop
    mov r9, forest                  ; Obtenemos la direccion del forest para iniciar los punteros
    finit                           ; Reinicia la pila de flotantes
    
    ; Carga las hojas del arbol en el bosuqe
    loop2:
    
        ; Calcula la direccion del nodo que se esta guarda
        get_node_addr rcx, NODE_TREE, tree
        
        fld dword [rax]             ; Carga la frecuencia a la pila
        fstp dword [r9]             ; Guarda la frecuencia en el inicio del nodo

        mov [r9 + 4], rax           ; Guarda el puntero al nodo del arbol

        ; Procedimiento para el for
        inc cx                  ; Incrementa el cx
        add r9, NODE_FOREST     ; Salta al siguiente nodo del bosque

        cmp cx, LETRAS_TOTALES  ; Lo comparamos para ver si tenemos que salir
        jne loop2               ; si es 26, entonces terminamos

    mov r10, INFINITO
    call findSmallest
    mov r10, r15
    mov r14, r15
    
    fld dword [r15]
    call findSmallest
    
    ; En este momento, r14 tiene el menor y r15 el segundo menor
    mov r14, [r14 + 4]
    mov r14, [r14 + 4]
    print_digit r14
    mov r15, [r15 + 4]
    mov r15, [r15 + 4]
    print_digit r15

    exit                        ; Cierra el programa
    
    
; Busca el nodo con menor frecuencia en el bosque
findSmallest:
    
    xor r15, r15                ; Usemos r15 para nodo
    xor rcx, rcx                ; y el rcx para llevar el contador
    
    ; Ciclo para buscar el menor
    loopFindSmallest:
        
        get_node_addr rcx, NODE_FOREST, forest  ; Obtiene la direccion del nodo en el bosque
        
        fld dword [r10]
        fld dword [eax]                         ; Carga la frecuencia actual
        fcomip                                  ; y la compara con el valor no deseado
        fstp
        
        a:
        je continueLoopFindSmallest             ; y si son igual, salta
        
        cmp r15, 0                              ; Revisa si ya tenemos un nodo
        je setSmallest
        
        fld dword [eax]                         ; Carga el valor del actual junto con el menor encontrado antes
        fld dword [r15d]
        fcomip                                  ; Y los compara
        fstp
        
        jb continueLoopFindSmallest             ; Si el es mayor, ignora
                
        ; Guarda el valor del nodo actual no esta establecido ninguno
        setSmallest:
            mov r15, rax
        
        ; Continua el ciclo
        continueLoopFindSmallest:
            inc rcx
            cmp rcx, LETRAS_TOTALES
            jne loopFindSmallest
            
    fstp

    ret                         ; Retorna la funcion
    