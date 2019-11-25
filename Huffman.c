#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LETTERS 26

/**
 * Array con todos las frecuencias
 */
float frequencies[LETTERS] = {12.53, 1.42, 4.68, 5.86, 13.68, 0.69, 1.01, 0.70, 6.25, 0.44, 0.02, 4.97, 3.15, 6.71, 8.68, 2.51, 0.88, 6.87, 7.98, 4.63, 3.93, 0.90, 0.01, 0.22, 0.90, 0.52};

/**
 * Estructura de cada nodo del arbol
 */
struct _node
{
    /**
     * Punteros a los hijos izquierdos y al papa
     */
    struct _node *left, *right, *father;

    /**
     * Caracter del nodo
     */
    char character;

    /**
     * Frecuencia del nodo
     */
    float frequency;
};

/**
 * Nodo para representar el bosque
 */
struct _forest
{
    /**
     * Frencuencia del nodo
     */
    float frequency;

    /**
     * Puntero al nodo representado
     */
    struct _node *node;
};

/**
 * Definicion al puntero
 */
typedef struct _forest *Forest;
typedef struct _node *Node;

/**
 *
 * @param forest Puntero a la lista del bosuqe
 * @return Retorna un puntero al mas pequeno
 */
Forest findSmallest(Forest forest[], float differentFrom)
{
    // Puntero al bosque
    Forest pointer = NULL;

    for (int i = 0; i < LETTERS; i++)
    {
        Forest aux = forest[i];

        if (aux->frequency == differentFrom)
            continue;

        if (!pointer)
        {
            pointer = aux;
            continue;
        }

        if (aux->frequency < pointer->frequency)
            pointer = aux;
    }

    // Retorna un para evitar errores
    return pointer;
}

// Busca un codigo asociado a una letra
void findCode(Node tree, char code[])
{
    // Establece el arbol como base
    Node helper = tree;

    // Itera el codigo
    for (int i = 0; i < strlen(code); i++)
    {
        // Si topa con un caracter vacio
        if (code[i] == '\0')
            break;

        // Actualiza el valor del helper
        helper = code[i] == '0' ? helper->left : helper->right;

        // Si no tiene letra
        if (helper->character == 0)
            continue;

        // Imprime el valor
        printf("%c", helper->character);

        // Inicia el arbol
        helper = tree;
    }

    // Imprime una nueva linea
    printf("\n");
}

/**
 * Imprime los nodos
 * @param tree Raiz del arbol
 * @param code Codigo a imprimir
 */
void printCodes(Node tree, long code)
{
    // Si no existe
    if (tree == NULL)
        return;

    // Si tiene una letra, la imprime y corta
    if (tree->character != 0)
    {
        // Castea el string
        char codeString[11];
        sprintf(codeString, "%ld", code);

        // Imprime el resultado
        printf("%s - %c\n", codeString, tree->character);
    }

        // Sino...
    else
    {
        printCodes(tree->left, code * 10);
        printCodes(tree->right, code * 10 + 1);
    }
}

/**
 * Funcion principal en cualquier programa de C
 * @return El codigo de salida del programa
 */
int main()
{
    /**
     * Bosque y arbol
     * Se reserva suficiente espacio para el abol
     */
    Forest forest[LETTERS];
    Node nodes[LETTERS * 2];

    // Cantidad de nodos y posicion del ultimo
    int currentNodeCount = LETTERS;
    int lastNode = 0;

    // Inicia los nodos, esto es innecesario en assembler, se reserva en el bss
    for (int i = 0; i < LETTERS * 2; i++)
        nodes[i] = (Node)malloc(sizeof(struct _node));

    // Establece el inicio
    for (int i = 0; i < LETTERS; i++)
    {
        // Obtiene el nodo
        Node newNode = nodes[i];

        // Limpia los punteros
        newNode->right = newNode->left = newNode->father = NULL;

        // Guarda la frecuencia y el caracter
        newNode->frequency = frequencies[i];
        newNode->character = 97 + i;

        // Guarda la referencia
        nodes[i] = newNode;

        // Guarda el ultimo
        lastNode = i;
    }

    // Innecesario en assembly, ya que se reservo en el bss
    for (int i = 0; i < LETTERS; ++i)
        forest[i] = (Forest)malloc(sizeof(struct _forest));

    // Carga los punteros en el bosque
    for (int i = 0; i < LETTERS; i++)
    {
        // Obtiene los dos nodos
        Node pointer = nodes[i];
        Forest node = forest[i];

        // Guarda las relaciones
        node->frequency = pointer->frequency;
        node->node = pointer;

        // Guarda el nodo
        forest[i] = node;
    }

    // Mientras haya mas nodos
    while (currentNodeCount != 1)
    {
        // Busca los dos menores
        Forest smallest1 = findSmallest(forest, 100);
        Forest smallest2 = findSmallest(forest, smallest1->frequency);

        // Obtiene el ultimo nodo y aumenta
        Node currentNode = nodes[++lastNode];

        // Guarda la frecuencia
        currentNode->frequency = smallest1->frequency + smallest2->frequency;
        currentNode->right = smallest1->node;
        currentNode->left = smallest2->node;

        // Configura los hijos
        smallest1->node->father = smallest2->node->father = currentNode;

        // Guarda el nodo
        smallest2->node = currentNode;
        smallest2->frequency = currentNode->frequency;

        // Sube la frencuencia
        smallest1->frequency = 100;

        // Disminuye el contador
        currentNodeCount--;
    }

    // Obtiene el arbol
    Node huffman = nodes[lastNode];

    // Imprime el arbol
    // P.D. Ignoren el primer 1
    printCodes(huffman, 1);

    char *codes = "11011000001100";
    findCode(huffman, codes);


    // Retorna que salio bien
    return 0;
}
