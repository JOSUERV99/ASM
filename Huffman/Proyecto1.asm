%include "Helpers.asm"

; Hola -> 101110000001100100

; Seccion de informacion
SECTION .data

    LETRAS_TOTALES equ 0x1a         ; Cantidad de letras en total (26)
    
    NODE_TREE equ 0x1d              ; Tamano del nodo del arbol (29)
    ; Frecuencia (4 bits) - Caracter (1 bit) - Nodo padre (8 bits) - Hijos izquierdo y derecho (16 bits)
    
    NODE_FOREST equ 0x0c            ; Tamano del nodo del bosque (12)
    ; Frecuencia (4 bits) - Puntero al nodo del arbol (8 bits)

    cantLetras: dd LETRAS_TOTALES   ; Cantidad de letras restantes de acomodar
    lastNode: dd 0x0                ; Posicion del ultimo nodo del arbol
    frecuencias: dd 12.53, 1.42, 4.68, 5.86, 13.68, 0.69, 1.01, 0.70, 6.25, 0.44, 0.02, 4.97, 3.15, 6.71, 8.68, 2.51, 0.88, 6.87, 7.98, 4.63, 3.93, 0.90, 0.01, 0.22, 0.90, 0.52

    request: db "Ingrese el codigo: ", 0x0      ; Mensaje a mostrar cuando se solicita un string
    newLine: db 0x0a, 0x0                       ; Mensaje para imprimir una nueva letra
    charToPrint: db 0x0, 0x0                    ; Byte para imprimir cuando solo se quiere imprimir un byte

SECTION .bss
    forest: resb LETRAS_TOTALES * NODE_FOREST           ; Array de forest
    tree: resb LETRAS_TOTALES * NODE_TREE * 0x02        ; Array del bosque
    input: resb 0x64                                    ; Reserva 100 bytes para la palabra


SECTION .text
    global _start

; Funcion principal en assembler
_start:
    finit                       ; Resetea la pila de flotantes
    mov cx, 0x0                 ; Inicio del ciclo para establece los nodos iniciales
   
    ; Este ciclo establece los nodos principales en el arbol como hojas
    loop1:

        ; Calcula la direccion del nodo que se esta guarda
        get_node_addr rcx, NODE_TREE, tree
        mov r8, rax
        
        ; Ordena los datos del nodo
        mov eax, ecx                        ; Se calcula el inicio de la frecuencia del nodo
        mov ebx, 0x04
        mul ebx
        fld dword [frecuencias + eax]       ; Almacena la frecuencia de la letra
        fstp dword [r8]                     ; y la suelta en el inicio del nodo

        mov eax, 0x61
        add rax, rcx                        ; Suma 97 al contador, para obtener la otra, ya que 97 es a en ASCII

        mov [r8 + 0x04], rax                ; Ponemos el caracter en el nodo
        mov [lastNode], rcx                 ; Guardamos la posicion del ultimo nodo

        ; Procedimiento para el for
        inc cx                          ; Incrementa el cx

        cmp cx, LETRAS_TOTALES          ; Lo comparamos para ver si tenemos que salir
        jne loop1                       ; si es 26, entonces terminamo


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

        mov [r9 + 0x04], rax        ; Guarda el puntero al nodo del arbol

        ; Procedimiento para el for
        inc cx                  ; Incrementa el cx
        add r9, NODE_FOREST     ; Salta al siguiente nodo del bosque

        cmp cx, LETRAS_TOTALES  ; Lo comparamos para ver si tenemos que salir
        jne loop2               ; si es 26, entonces terminamos


    xor rdx, rdx

    while:
        mov r10, INFINITO   ; Metemos el caracter mas pequeno que no nos sirve
        call findSmallest   ; llama la funcion
        mov r10, r15        ; Guarda el resultado en el r10
        mov r14, r15        ; Duplica el valor, para no perderlo

        call findSmallest   ; cambia la condicion del ciclo

        ;finit              ; Se asegura de limpia los flotantes

        mov r13, [lastNode] ; Incrementa lastNode
        inc r13
        mov [lastNode], r13

        ; Obtiene el ultimo nodo
        get_node_addr r13, NODE_TREE, tree

        fld dword [r14]     ; Sumar las 2 frecuencias mas pequennas
        fld dword [r15]
        fadd
        fstp dword [rax]    ; y las guardar en current Node

        ; Obtiene la direccion del nodo actual
        mov rcx, [lastNode]
        get_node_addr rcx, NODE_TREE, tree

        ; Coloca los hijos
        mov r9, [r15 + 0x04]
        mov [rax + 0x0d], r9 ; Colocar hijo izquierdo
        
        mov r9, [r14 + 0x04]
        mov [rax + 0x15], r9   ; Colocar hijo derecho

        mov r9, [r14 + 0x04]
        mov [r9 + 0x05], rax    ; Colocarle el padre a r14  (smallest 1)

        mov r9, [r15 + 0x04]
        mov [r9 + 0x05], rax    ; Colocarle el padre a r15 (smallest 2)

        ; Carga el ultimo nodo
        mov r10, [lastNode]
        get_node_addr r10, NODE_TREE, tree
        mov r12, [rax + 0x15]

        fld dword [rax] ;guarda en el nodoArbol la frecuencia
        fstp dword [r15] ;guarda la suma en nodo bosque
        mov [r15 + 0x04], rax

        load_infinity
        fstp dword [r14]

        inc rdx
        cmp dx, LETRAS_TOTALES

        jne while

        ; Obtiene la direccion de memoria del arbol
        mov r11, [lastNode]
        get_node_addr r11, NODE_TREE, tree
        mov rax, [rax + 0x15]
        
        ; Imprime el arbol, envia la direccion donde inicia
        call_print_tree rax, 1
        
        ; Se prepara para recibir codigos
        infiteLoop:
        
            ; Solicita un codigo al usuario
            print_string request
            call get_input
            
            call read_code      ; Lee el codigo enviado
            
            jmp infiteLoop      ; Continua el bucle infinito

    exit                        ; Cierra el programa

; Lee el codigo presente en el input
read_code:

    xor rbx, rbx                ; Limpia el rbx para guarda la letra actual

    ; Obtiene el inicio del arbol
    mov r11, [lastNode]
    get_node_addr r11, NODE_TREE, tree
    mov rax, [rax + 0x15]
    
    ; Bucle para buscar el codigo
    xor rcx, rcx                ; Limpia el rcx para usarlo como contador
    loopSearch:
        
        ; Obtiene el numero actual
        mov bl, [input + rcx]
       
        ; Revisa si es una caracter valido
        cmp bl, 0x0
        je retRead
        
        cmp bl, 0xa
        je retRead

        ; Revisa asi a donde se tiene que mover
        cmp bl, 0x30
        je moveLeft
        cmp bl, 0x31
        je moveRight
        
        ; Se mueve asi la izquierda
        moveLeft:
            mov rax, [rax + 0x0d]
            jmp continueSearch
            
        ; Se mueve a la derecha
        moveRight:
            mov rax, [rax + 0x15]
            jmp continueSearch
   
        continueSearch:
            
            ; Obtiene la letra
            mov bl, [rax + 0x04]
            cmp bl, 0x0
            je nextLoop
            
            mov [charToPrint], bl
            print_string charToPrint

            ; Obtiene el inicio del arbol
            mov r11, [lastNode]
            get_node_addr r11, NODE_TREE, tree
            mov rax, [rax + 0x15]
                    
        ; Salga al siguiente ciclo
        nextLoop:
            inc rcx
            jmp loopSearch
   
    ; Retorna la funcion
    retRead:
        
        ; Imprime una nueva linea
        print_string newLine
        
        ; Retorna la funcion
        ret

; Imprime un arbol
; [rsp + 16] arbol actual
; [rsp + 08] codigo actual (sin el primer 1)
print_tree:
    
    xor rcx, rcx
    xor rbx, rbx                    ; Limpia el rbx para usarlo para pasar direcciones
    mov rax, [rsp + 0x10]             ; Obtiene la posicion de inicio del arbol
    
    cmp rax, 0x0                      ; Si no es una direccion valida, retorna
    je retMe
    
    xor rbx, rbx                    ; Obtiene la letra actual
    mov bl, [rax + 0x4]
    
    cmp rbx, 0x0                      ; Si no es uan letra valida, retorna
    je next
    
    mov rcx, [rsp + 0x08]              ; Imprime la letra y su codigo
    print_digit rbx
    print_digit rcx
    
    ret                             ; Retorna la funcion
    
    ; Imprime los hijos del arbol
    next:
        
        ; Imprime el hijo izquierdo
        mov r15, [rsp + 0x10]
        mov r15, [r15 + 0x0d]
        
        mov rax, [rsp + 0x08]
        mov rbx, 0x0a
        mul rbx
        
        call_print_tree r15, rax
        
        ; Imprime el hijo derecho
        mov r15, [rsp + 0x10]
        mov r15, [r15 + 0x15]
        
        mov rax, [rsp + 0x08]
        mov rbx, 0x0a
        mul rbx
        inc rax
        
        call_print_tree r15, rax            ; Imprime lo
        
    
    ; Retorna la funcion
    retMe:
        ret
    
; Busca el nodo con menor frecuencia en el bosque
findSmallest:
    
    xor r15, r15                ; Usemos r15 para nodo
    xor rcx, rcx                ; y el rcx para llevar el contador
    
    ; Ciclo para buscar el menor
    loopFindSmallest:
        
        get_node_addr rcx, NODE_FOREST, forest  ; Obtiene la direccion del nodo en el bosque
        
        fld dword [r10]   ; Read user input into str
    
        fld dword [eax]                         ; Carga la frecuencia actual
        fcomip                                  ; y la compara con el valor no deseado
        fstp
        

        je continueLoopFindSmallest             ; y si son igual, salta
        
        cmp r15, 0x0                              ; Revisa si ya tenemos un nodo
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
    
; Obtiene el input del usuario
get_input:

    ; Solicita el input del sistema operativo
    mov rax, 0x03
    mov rbx, 0x0
    mov rcx, input
    mov rdx, 0x64
    int 0x80
    
    ; Retorna la funcion
    ret