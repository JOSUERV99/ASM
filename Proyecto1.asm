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

        mov [r9 + 4], rax             ; Guarda el puntero al nodo del arbol

        ; Procedimiento para el for
        inc cx                  ; Incrementa el cx
        add r9, NODE_FOREST     ; Salta al siguiente nodo del bosque

        cmp cx, LETRAS_TOTALES          ; Lo comparamos para ver si tenemos que salir
        jne loop2               ; si es 26, entonces terminamos

    ;push 100
    ;call findSmallest
    ;print_digit rdx
    ;pop rax

    exit                        ; Cierra el programa
    
; Retorna nodo con la menor frecuencia
findSmallest:
    
    finit                   ; Limpia la pila de punto flotante

    xor edx, edx            ; Usa el rdx como puntero al menor
    xor ecx, ecx            ; y el ecx como contador
    
    fld1                    ; Agrega un -1 a la pila para comparacion
    fchs
    
    while1:
    

        ; Calcula la direccion del nodo que se esta guarda
        mov eax, ecx    ; Se multiplica al nodo actual el tamano de cada nodo
        mov ebx, NODE_FOREST
        mul ebx
        add eax, forest                 ; Y se le suma la direccion de memoria del primer nodo
        
        a:
        fld dword [eax]                 ; Mueve la frencuencia del nodo actual a la pila
        fcomip                          ; Revisa si el valor actual es un menos 1
        
        jne continue                    ; Si no es, continua
        
        inc ecx                         ; Si, incrementa el contador del nodos
        jmp while1                      ; y repite el ciclo
        
    continue:
        mov edx, ecx                    ; Guarda el valor del minimo como el contador
        cmp edx, ebx                    ; Revisa si el valor no es el mismo para comparar
        je recalculate                  ; Si es, tiene que recalcularlo
        mov ecx, 0x01                   ; Resetea el count en 1
        jmp next                        ; Si es diferente, continua
        
    ; Recalcula el nodo de menor valor
    recalculate:
        inc ecx                         ; Apunta al siguiente nodo
        
        while2:
            
            ; Calcula la direccion del nodo que se esta guarda
            mov eax, ecx                    ; Se multiplica al nodo actual el tamano de cada nodo
            mov ebx, NODE_FOREST
            mul ebx
            add eax, forest                 ; Y se le suma la direccion de memoria del primer nodo
            
            fld dword [eax]             ; Mueve la frencuencia del nodo actual a la pila
            fcomip                          ; Revisa si el valor actual es un menos 1                          ; Revisa si el valor actual es un menos 1
            
            jne continue2                   ; Si no es, continua
            
            inc ecx                         ; Si, incrementa el contador del nodos
            jmp while2                      ; y repite el ciclo
        
        continue2:
            mov edx, ecx                    ; Guarda el valor de minimo
            mov ecx, 0x01                   ; Resetea el count en 1
            jmp next                        ; y sigue
            
    ; Encuentra el menor del tood
    next:
    
        cmp ecx, LETRAS_TOTALES                 ; Si llego al maximo de nodos
        je retMe                            ; Retorna del todo
    
        ; Calcula la direccion del nodo que se esta guarda
        mov eax, ecx    ; Se multiplica al nodo actual el tamano de cada nodo
        mov ebx, NODE_FOREST
        mul ebx
        add eax, forest                 ; Y se le suma la direccion de memoria del primer nodo
        
        fld dword [eax]              ; Carga su frencuencia en la pila
        fcomip                              ; y la compara con el -1
        je skip                             ; y si es -1, ingora el resto
        
        cmp ecx, [rsp + 8]                  ; Revisa si no es el que no se quiere
        je skip                             ; y si es -1, ingora el resto
        
        fld dword [eax]              ; Carga su frencuencia en la pila
    
        ; Calcula la direccion del nodo que se esta guarda
        mov eax, edx    ; Se multiplica al nodo actual el tamano de cada nodo
        mov ebx, NODE_FOREST
        mul ebx
        add eax, forest                 ; Y se le suma la direccion de memoria del primer nodo
        
        fld dword [eax]              ; y lo agrega a la pila
        
        eval:
            fcomip                          ; Compara los dos valores
            jae cool
            jmp skip   
        
        cool:
            mov edx, ecx                    ; Guarda el valor actual
            jmp skip    
        
        skip:
            fcomp                           ; Limpia la pila
            inc ecx                         ; Apunta al siguiente nodo
            jmp next                        ; y sigue el ciclo
        
    ; Retorna la funcion
    retMe:
        finit
        ret