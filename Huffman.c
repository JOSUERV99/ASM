#include<stdlib.h>
#include<stdio.h>
/* Algoritmo de Huffman
    Autor: Josué Rojas Vega
    09/11/2019
*/
#define CANTIDADLETRAS 26

struct nodoArbol {
    struct nodoArbol *izquierdo; //
    struct nodoArbol *derecho;   // puntero de 4 bytes en mi maquina
    struct nodoArbol *padre;     //
    char caracter;          // 1 byte
    float frecuencia;       // 4 bytes

    struct nodoArbol *siguiente; // 4 bytes     ?    
};

struct nodoBosque {
    struct nodoArbol *raiz; // 4 bytes
    float valor; // 4 bytes
};

struct Arbol {
    struct nodoArbol *inicio; // corresponde a la primera hoja del arbol
    struct nodoArbol *ultimo; // ultimo nodo para luego ser apuntado por huffman y recorrer el arbol
};

// declaracion de funciones
struct nodoArbol *crearNodoArbol(char, float);
struct nodoBosque *crearNodoBosque(float, struct nodoArbol *);
struct Arbol *crearArbol();
void recorrerArbol(struct nodoArbol *);

// constantes
float FRECUENCIAS[] = { 12.53 , 1.42, 4.68, 5.86, 13.68, 0.69, 1.01,
                        0.70, 6.25, 0.44, 0.02, 4.97, 3.15, 6.71, 
                         8.68, 2.51, 0.88, 6.87, 7.98, 4.63,  /// 0.31,
                        3.93, 0.90, 0.01, 0.22, 0.90, 0.52 };
// fuente: https://es.wikipedia.org/wiki/Frecuencia_de_aparici%C3%B3n_de_letras

char ABECEDARIO[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 
                     'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};


struct nodoBosque *crearNodoBosque(float valor, struct nodoArbol *raiz) {
    struct nodoBosque *nuevoNodoBosque = (struct nodoBosque *) malloc(sizeof(struct nodoBosque)); // reserva de memoria
    nuevoNodoBosque->raiz = raiz;  // valor del puntero por default
    nuevoNodoBosque->valor = valor; // // valor por default
    return nuevoNodoBosque;
}

struct nodoArbol *crearNodoArbol(char caracter, float frecuencia) {
    struct nodoArbol *nuevoNodoArbol = (struct nodoArbol *) malloc(sizeof(struct nodoArbol)); // reserva de memoria
    nuevoNodoArbol->izquierdo = nuevoNodoArbol->derecho = nuevoNodoArbol->padre = NULL;  // valor del puntero por default
    nuevoNodoArbol->caracter = caracter; // valor por default
    nuevoNodoArbol->frecuencia = frecuencia; // valor por default
    nuevoNodoArbol->siguiente = NULL;
    return nuevoNodoArbol;
}

struct Arbol *crearArbol() {
    struct Arbol *nuevoArbol = (struct Arbol *) malloc(sizeof(struct Arbol));
    nuevoArbol->inicio = nuevoArbol->ultimo = NULL;
    return nuevoArbol;
}

int main() {    
    // declaraciones
    extern float FRECUENCIAS[];
    extern char ABECEDARIO[];
    struct nodoBosque *arrayBosque[CANTIDADLETRAS], *i, *j; // punteros para recorrer el array en el bosque
    struct nodoArbol *huffman; // HUFFMAN (nodo raiz del arbol binario por crear)
    struct Arbol *arbol = crearArbol();
    int indice = 0;

    // creacion del arbol con cada una de las letras y su frecuencia
    while (indice < CANTIDADLETRAS) {
        struct nodoArbol *arbolNuevo = crearNodoArbol(ABECEDARIO[indice], FRECUENCIAS[indice]); // creacion del primero
        if (!(arbol->inicio) && !(arbol->ultimo))
            arbol->inicio = arbol->ultimo = arbolNuevo;
        else {
            arbol->ultimo->siguiente = arbolNuevo; 
            arbol->ultimo = arbol->ultimo->siguiente;
        }
        arrayBosque[indice] = crearNodoBosque(arbolNuevo->frecuencia,arbolNuevo);
        indice++;
    }

    int contador = CANTIDADLETRAS;
    while (contador != 1) {
        indice = 0;
        // se busca el primer menor
        i = arrayBosque[indice];
        int primerMenor = arrayBosque[indice]->valor;
        while (indice < CANTIDADLETRAS) {
            if (arrayBosque[indice]->valor < i->valor) {
                i = arrayBosque[indice];
                primerMenor = i->valor;
            }
            indice++;
        }

        // se busca el segundo menor
        indice = 0;
        j = arrayBosque[indice];
        while (indice < CANTIDADLETRAS) {
            if ( i != arrayBosque[indice] && arrayBosque[indice]->valor < j->valor){
                j = arrayBosque[indice];
            }
            indice++;
        }
        indice = 0;

        // siendo i y j los dos menores del arrayBosque
        j->valor += i->valor; // el valor del puntero j pasa a tener la suma de i y j
        struct nodoArbol *nuevoArbol = crearNodoArbol(0, j->valor);  // se crea un nuevo nodo y se agrega al  arbol

        // asignacion de punteros (toma en cuenta cual es menor y el mayor para ser colocado a la izquierda y derecha del arbol)
        if (i->valor > j->valor) {
            nuevoArbol->derecho = i->raiz;
            nuevoArbol->izquierdo = j->raiz;
        } else {
            nuevoArbol->izquierdo = i->raiz;
            nuevoArbol->derecho = j->raiz;
        }        

        i->raiz->padre = j->raiz->padre = nuevoArbol; // los nodos del arbol tendran por padre al nuevo nodo
        j->raiz = nuevoArbol;  // se coloca el puntero del nuevo nodo del arbol como la raiz del nodoBosque en la suma
        i->valor = __INT64_MAX__; // valor para ser descartado
        nuevoArbol->padre = NULL; 
        arbol->ultimo->siguiente = nuevoArbol; // se agrega al final del arbol
        arbol->ultimo = arbol->ultimo->siguiente;

        --contador;
    }

    huffman = arbol->ultimo; // padre del arbol binario creado
    //recorrerArbol(huffman); // DEBUG

    // entrada del usuario
    char entrada[] = "011001011011";
    int largoEntrada = sizeof(entrada)/sizeof(char);
    indice = 0; 
    
    struct nodoArbol *iteradorArbol = huffman;

    while (indice < largoEntrada) {
        if (entrada[indice] == '0')
            iteradorArbol = iteradorArbol->izquierdo;
        else if (entrada[indice] == '1')
            iteradorArbol = iteradorArbol->derecho;

        if (iteradorArbol) {
            if (iteradorArbol->caracter != 0) {
                printf("%c", iteradorArbol->caracter);
                iteradorArbol = huffman;
            }
        } else
            iteradorArbol = huffman;
        indice++;
    }

    return 0;
}

void recorrerArbol(struct nodoArbol *arbol) { // DEBUG
    if (arbol) {
        recorrerArbol(arbol->izquierdo);
        printf("%c", arbol->caracter);
        recorrerArbol(arbol->derecho);
    }
}