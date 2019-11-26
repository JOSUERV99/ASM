SECTION .bss

    ; Para la impresion de digitos
    digitString resb 0x64     ; Largo del string de digitos
    digitStringPos resb 0x08  ; Reserva el largo de un digito (64 bits)
    
    ; Para la impresion de stack
    stackSpace resb 0x08
 
; Llama a la funcion getDeterminate
%macro callDeterminate 2

    push 0              ; Valor de retorno
    push %1             ; Inicio de la matriz
    push %2             ; Tamano de la matriz
    push -1             ; Signo
    push 0              ; firstElementIndex
    push 0              ; j
    push 0              ; i
    push 0              ; Direccion de temp
    
    call getDeterminate ; Llama a la funcion
    
    pop rax             ; Limpia la pila
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax

%endmacro
 
; Agrega todos los registros de uso al stack
%macro push_all 0
    push rax
    push rbx
    push rcx
    push rdx
%endmacro

; Restaura todos los registros de uso desde el stack
%macro pop_all 0
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro

; Macro para cerrar el programa
%macro exit 0
    
    mov eax, 0x01
    xor ebx, ebx
    int 0x80

%endmacro

; Macro para imprimir un string en consola
%macro print_string 1

    push_all                ; Agrega todos los registros al stack

    mov rax, %1             ; Mueve la direccion de inicio al rax
    mov [stackSpace], rax   ; y agrega el primer caracter a la direccion de inicio
    xor rdx, rdx            ; Resetea el rdx para usarlo como contador
    
    ; Funcion para imprimir los caracteres
    %%printLoop:
        inc rdx             ; Incrementa el numero
        inc rax             ; Salta a la siguiente letra
        
        mov cl, [rax]       ; Guarda el caracter ascii en el cl
        cmp cl, 0x0         ; y revisa si es 0, osea sin de string
        jne %%printLoop     ; Si no lo es, sigue
        
    ; Imprime el string
    mov eax, 0x04
    mov rbx, 0x01
    mov rcx, [stackSpace]
    int 0x80
    
    pop_all                 ; Restaura los registros
    
%endmacro

; Macro para imprimir un digito
%macro print_digit 1

    push_all                ; Agrega todos los registros al stack

    mov rax, %1                 ; Guarda el digito en el rax
    mov rcx, digitString        ; y carga el inicio del largo maximo en el rcx
    mov rbx, 0x0a               ; Guarda el caracter de \n
    
    mov [rcx], rbx              ; Inicia el string de caracter con un \n
    inc rcx                     ; salta al siguiente caracter
    mov [digitStringPos], rcx   ; y establece el inicio del string
    
    ; Ciclo para guarda lo digitos
    %%storeDigitsLoop:
        xor rdx, rdx                ; Limpia el rdx, para no afectar la division
        mov rbx, 0x0a               ; Guarda el valor de 10 para corre la coma decimal
        div rbx                     ; Ejecuta la division
        
        ;push rax                    ; Guarda el valor del restante
        add rdx, 0x30               ; Como el residuo queda en el rdx, le sumamos el valor ascii de 0 (48)
        
        mov rcx, [digitStringPos]   ; Carga la posicion de memoria de la del string
        mov [rcx], dl               ; Guarda los valor menos significativos (valor ascii del numero)
        inc rcx                     ; Aumenta la posicion
        mov [digitStringPos], rcx   ; y la guarda otra vez
        
        ;pop rax                     ; Obtengo el valor restante
        cmp rax, 0                  ; Reviso si quedan mas numeros
        jne %%storeDigitsLoop       ; Si si, sigo el ciclo
        
    ; Loop para imprimir los digitos
    %%printDigits:
        
        mov eax, 0x04               ; Imprime el digito actual
        mov ebx, 0x01
        mov ecx, [digitStringPos]
        mov edx, 0x01
        int 0x80
        
        dec ecx                     ; Va al siguiente digito
        mov [digitStringPos], ecx   ; Guarda la posicion actual
        cmp rcx, digitString        ; Revisa si la posicion actual es la inicial
        jge %%printDigits           ; Si no lo es, entonces sigue
        
    pop_all                 ; Restaura los registros
    
%endmacro

