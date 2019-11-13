; Retorna nodo con la menor frecuencia
findSmallest:
    
    finit                   ; Limpia la pila de punto flotante

    xor edx, edx            ; Usa el rdx como puntero al menor
    xor ecx, ecx            ; y el ecx como contador
    
    fld1                    ; Agrega un -1 a la pila para comparacion
    fchs
    
    while1:
    
        getNodeAddr ecx                 ; Calcula el puntero donde guarda la informacion
        
        fld dword [eax + 1]             ; Mueve la frencuencia del nodo actual a la pila
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
            
            getNodeAddr ecx                 ; Calcula el puntero donde guarda la informacion
            
            fld dword [eax + 1]             ; Mueve la frencuencia del nodo actual a la pila
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
    
        cmp ecx, forestSize                 ; Si llego al maximo de nodos
        je retMe                            ; Retorna del todo
    
        getNodeAddr ecx                     ; Calcula el puntero donde guarda la informacion
        
        fld dword [eax + 0x01]              ; Carga su frencuencia en la pila
        fcomip                              ; y la compara con el -1
        je skip                             ; y si es -1, ingora el resto
        
        cmp ecx, [rsp + 8]                  ; Revisa si no es el que no se quiere
        je skip                             ; y si es -1, ingora el resto
        
        fld dword [eax + 0x01]              ; Carga su frencuencia en la pila
    
        getNodeAddr edx                     ; Calcula el puntero donde guarda la informacion
        
        fld dword [eax + 0x01]              ; y lo agrega a la pila
        
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
