%include "Helpers.asm"

SECTION .data

    msg: db "Ingrese un numero: ", 0
    menos: db "-", 0            ; Simbolo de menos
    matrix dd 9118.02, 4925.17, 8500.04, 1228.99, 4416.41, 4562.18, 6651.30, 2784.27, 3991.19, 4960.10, 5147.16, 2518.05, 8482.56, 1636.87, 5881.76, 2544.98
    ; -135816143699968
    
    ;matrix dd 9118.02, 4925.17, 8500.04, 4416.41, 4562.18, 6651.30, 3991.19, 4960.10, 5147.16
    ; -36486815744
    
    ;matrix dd 9118.02, 4925.17, 8500.04, 1228.99
    ; -30658186
    
    size equ 0x04           ; Tamano de la matriz
    vecesLlamado dd 0       ; Cantidad de veces llamada la funcion principal

    temp_num: dd 0
    diez: dd 10.0
    cantidadValores: dd 16
    
SECTION .bss
    ;matrix resb 64
    temp resb 1088          ; Cantidad de espacio disponible para las matrices
    result resq 1           ; Discriminante final
    buffer resb 8

SECTION .text
    global _start
    
_start:

    finit                           ; Limpia los registros de punto flotante
    ;mov r14, 0

    ;loopCargar:    
    ;    call string_to_fp
    ;    inc r14
    ;    cmp r14, 16
    ;    jne loopCargar
    
    finit
    callDeterminate matrix, size    ; Obtiene el discriminate
    
    ; Carga el resultado en el rax
    fld dword [rsp]
    pop rax
    fistp qword [result]
    mov rax, [result]
    
    ; Revisa si es positivo o negativo
    test rax, rax
    je positivo
    
    print_string menos
    mov rbx, -1
    mul rbx
    
    ; Imprime el numero
    positivo:
        print_digit rax
    
    exit                        ; Termina el programa

; Convierte una string en un numero flotante
string_to_fp:

    ; Lee la entrada del usuario (flotante en string)
    print_string msg
    mov rax, 3
    mov rbx, 0
    mov rcx, buffer
    mov rdx, 8
    int 0x80

    finit

    ; Limpiamos los registro rbx para la letra y rcx para el contador
    xor rbx, rbx
    xor rcx, rcx

    ; Cargamos un 0 para numeros
    fldz

    loopEntero:

        ; Obtiene la letra actual
        mov bl, [buffer + ecx]
        inc cx

        ; Revisa si es un numero valida
        cmp bl, 0
        je siguiente
        cmp bl, 10
        je siguiente

        ; Revisa si en punto
        cmp bl, 46
        je loop_decimal
 
        ; Mutilicamos el numero actual por 10
        fmul dword [diez]

        sub bl, '0'
        mov [temp_num], bx
        fiadd dword [temp_num]

        jmp loopEntero

        ; Salta el decimal
        loop_decimal:
            fldz
            jmp loopDecimal

    loopDecimal:

        ; Obtiene la letra actual
        mov bl, [buffer + ecx]
        inc cx

        sub bl, '0'
        mov [temp_num], bx
        fiadd dword [temp_num]
        fdiv dword [diez]

        mov bl, [buffer + ecx]

        sub bl, '0'
        mov [temp_num], bx
        fild dword [temp_num]
        fdiv dword [diez]
        fdiv dword [diez]
        fadd
        fadd
    
    siguiente:
        mov r11, 4
        mov rax, r14
        mul r11
        
        fstp dword [matrix + rax]
        ret


; Calcula el determinate de una funcion
; [rsp + 0x08]    Direccion de temp
; [rsp + 0x10]    i
; [rsp + 0x18]    j
; [rsp + 0x20]    firstElementIndex
; [rsp + 0x28]    Signo
; [rsp + 0x30]    Tamano de la matriz
; [rsp + 0x38]    Matriz a evaluar
; [rsp + 0x40]    Resultado
getDeterminate:
    
    ; Incrementa la cantidad de veces llamada esta funcion
    mov rax, [vecesLlamado]
    inc rax
    mov [vecesLlamado], rax
    
    mov eax, [rsp + 0x30]          ; Revisa si es de 2x2
    cmp eax, 0x02
    je calc2x2
    
    ; Carga el resultado en la pila
    fld dword [rsp + 0x40]
    
    jmp forElementIndex
    
    calc2x2:
        mov eax, [rsp + 0x38]     ; Obtiene la posicion en memoria de la matriz
        
        fld dword [eax]           ; Carga la posicion [0][0] y [1][1] y los multiplica
        fld dword [eax + 0x0c]
        fmul
        
        fld dword [eax + 0x04]     ; Carga la posicion [0][1] y [1][0] y los multiplica
        fld dword [eax + 0x08]
        fmul
        
        fsub                    ; Resta los resultados
        fstp dword [rsp + 0x40] ; y lo guarda en el resultado
        
        ret                     ; Retorna la funcion
       
    ; Calcula todas las submatrices 
    forElementIndex:
                
        ; Resetea el valor de i y j
        xor rbx, rbx
        mov [rsp + 0x18], rbx
        mov [rsp + 0x10], rbx

        mov rcx, [rsp + 0x20]           ; Carga la posicion del primer indice
        mov rdx, [rsp + 0x30]           ; y el tamano de la matriz
        cmp rdx, rcx                    ; Si son igual, terminamos
        je retMe                        ; Significa que ya calculo todas
        
        ; Calcula la siguiente matriz auxiliar
        mov rax, [vecesLlamado]
        mov rbx, 64
        mul rbx
        mov r15, rax
        add r15, temp
        
        ; Usamos r10 para las rows y r11 para las cols
        xor r10, r10
        xor r11, r11
        
        ; Itera todas las filas y columnas para crear la nueva matriz
        for_row:
            
            mov rbx, [rsp + 0x30]       ; Carga el tamano de la matriz
            cmp r10, rbx
            je continue
            
            for_col:
                mov rbx, [rsp + 0x30]       ; Carga el tamano de la matriz
                cmp r11, rbx
                je for_row_next
                
                ;;;;;;;;;;;;;; Inicio del ciclo para la nueva matriz ;;;;;;;;;;;
                
                ; Si el primera fila, ignoramos
                cmp r10, 0
                je for_col_next
                
                ; Si la columna es igual a la fila que se esta analizando...
                mov rbx, [rsp + 0x20]
                cmp r11, rbx
                je for_col_next
                
                
                ;;;;;;;;;;;;;;;;; REVISAR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
                ; Calculamos la posicion actual en la matriz temporal
                mov rax, [rsp + 0x10] ; i
                mov rbx, [rsp + 0x30] ; tamano
                dec rbx
                mul rbx
                add rax, [rsp + 0x18] ; j

                mov rbx, 4
                mul rbx
                
                add rax, r15
                mov r13, rax            ; y la guardamos en el r13
                
                
                ; Calculamos el valor que necesitamos en la matriz principal
                mov rax, r10
                mov rbx, [rsp + 0x30]
                mul rbx
                add rax, r11
                mov rbx, 4
                mul rbx
                add rax, [rsp + 0x38]
                
                ;;;;;;;;;;;;;;;;;;;;;; SIN DE REVISAR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
                ; Carga el valor de la matriz principal en la auxiliar
                fld dword [rax]
                fstp dword [r13]
                
                ; Incremente el valor de j
                mov rbx, [rsp + 0x18]
                inc rbx
                mov [rsp + 0x18], rbx
                
                ; Obtiene el tamano de la matriz -1
                mov rax, [rsp + 0x30]
                dec rax
                
                ; Revisa si son iguales
                cmp rbx, rax
                jne for_col_next
                
                ; Resetea el valor de j
                xor rbx, rbx
                mov [rsp + 0x18], rbx
                
                ; Incremente el valor de i
                mov rbx, [rsp + 0x10]
                inc rbx
                mov [rsp + 0x10], rbx
                
                ;;;;;;;;;;;;; Fin del ciclo para la nueva matriz ;;;;;;;;;;;;;;;
                
                ; Continua el ciclo de for_row
                for_col_next:
                    inc r11
                    jmp for_col
            
            ; Continua el ciclo de for_row
            for_row_next:
                xor r11, r11
                inc r10
                jmp for_row
        
        continue:
                
            ; Carga el number actual en la pila
            mov rax, [rsp + 0x20]
            mov rbx, 4
            mul rbx
            add rax, [rsp + 0x38]
            fld dword [rax]
            
            ; Carga el signo en la pila
            fld1
            mov rax, [rsp + 0x28]
            cmp rax, -1
            jne continue1
            fchs
            
            continue1:
                
                fmul                ; Multiplica el valor actual con el signo
                
                ; Reduce el tamano para enviarlo
                mov rcx, [rsp + 0x30]
                dec rcx
                
                callDeterminate r15, rcx    ; Obtiene el discriminate
                fld dword [rsp]
                pop rax
                fmul
                
                fsub                        ; Realiza al resta corresponiente
                
            ; Cambia el signo
            mov rax, [rsp + 0x28]
            mov rbx, -1
            mul rbx
            mov [rsp + 0x28], rax
                
            ; Incremente el valor de firstIndex
            mov rbx, [rsp + 0x20]
            inc rbx
            mov [rsp + 0x20], rbx
            jmp forElementIndex
        
        ; Retorna la funcion
        retMe:
            fstp dword [rsp + 0x40]
            ret