
// C program for Huffman Coding
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LETTERS 27

// Informacion para el arbol
// TODO: cambiar doble n por ñ
char letters[LETTERS] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
float frequencies[LETTERS] = {12.53, 1.42, 4.68, 5.86, 13.68, 0.69, 1.01, 0.70, 6.25, 0.44, 0.02, 4.97, 3.15, 6.71, 0.31, 8.68, 2.51, 0.88, 6.87, 7.98, 4.63, 3.93, 0.90, 0.01, 0.22, 0.90, 0.52};

// Nodo para el arbol de huffman
typedef struct node {

    // Letra que contiene
    char letter;

    // Frecuencia de la letra o del arbol
    float value;

    // Hijos
    struct node *left, *right;

} Node;

// Encuentra el valor menor en el array
int findSmaller (Node *array[], int differentFrom)
{
    // Instancia el indice menor y el actual
    int smaller;
    int i = 0;

    // Mientras el valor no sea -1, incrementa in indice actual
    while (array[i]->value == -1)
        i++;

    // Establece el menor como el ultimo
    smaller = i;

    // Si el indice el la diferencia
    if (i == differentFrom)
    {
        // Incrementa otra vez
        i++;

        // Repite hasta encuentrar otro valor
        while (array[i]->value == -1)
            i++;

        // Guarda otra vez el menor
        smaller = i;
    }

    // Itera todos los resultaods
    for (i = 1; i < LETTERS; i++)
    {
        // Si no tiene valor
        if (array[i]->value==-1)
            continue;

        // Si es el que no se pide
        if (i == differentFrom)
            continue;

        // Repite hasta encontrar el menor
        if (array[i]->value < array[smaller]->value)
            smaller = i;
    }

    // Retorna el indice del menor
    return smaller;
}

// Crea el arbol
Node* buildHuffmanTree()
{
    // Crea el nodo temporal
    Node *temp;

    // Crea un bosque para almacenar todos los arboles
    Node *array[LETTERS];

    // Guarda la cantidad de subarboles
    int subTrees = LETTERS;

    // Indeces para indicar los menos
    int lowest1, lowest2;

    // Crea el bosque entero
    for (int i = 0; i < 27; i++)
    {
        // Guarda el espacio en memoria
        array[i] = malloc(sizeof(Node));

        // Establece los valores
        array[i]->value = frequencies[i];
        array[i]->letter = letters[i];

        // Limpia basura de memoria
        array[i]->left = NULL;
        array[i]->right = NULL;
    }

    // Mientras haya mas de un arbol en el bosque
    while (subTrees > 1)
    {
        // Encuentra los ultimos 2
        lowest1 = findSmaller(array, -1);
        lowest2 = findSmaller(array, lowest1);

        // Guarda el ultimo arbol
        temp = array[lowest1];

        // Limpia la refencia de la lista
        array[lowest1] = malloc(sizeof(Node));

        // Establece el valor como la suma del penultimo y el ultimo
        array[lowest1]->value = temp->value + array[lowest2]->value;

        // Borra la letra
        array[lowest1]->letter=0;

        // Guarda las referencias
        array[lowest1]->left = array[lowest2];
        array[lowest1]->right=temp;

        // Borra el valor del penultimo
        array[lowest2]->value=-1;

        // Baja uno al contador de arboles
        subTrees--;
    }

    // Establece el arbol como el mas alto de todos
    return array[lowest1];
}

// Imprime los codigos
void printCodes(Node *tree, long code)
{
    // Si no existe
    if (tree == NULL)
        return;

    // Si tiene una letra, la imprime y corta
    if (tree->letter != 0)
    {
        // Castea el string
        char codeString[11];
        sprintf(codeString, "%ld", code);

        // Imprime el resultado
        printf("%s - %c\n", codeString, tree->letter);
    }

    // Sino...
    else
    {
        printCodes(tree->left, code * 10);
        printCodes(tree->right, code * 10 + 1);
    }
}

// Busca un codigo asociado a una letra
void findCode(Node *tree, char code[])
{
    // Establece el arbol como base
    Node *helper = tree;

    // Itera el codigo
    for (int i = 0; i < strlen(code); i++)
    {
        // Si topa con un caracter vacio
        if (code[i] == '\0')
            break;

        // Actualiza el valor del helper
        helper = code[i] == '0' ? helper->left : helper->right;

        // Si no tiene letra
        if (helper->letter == 0)
            continue;

        // Imprime el valor
        printf("%c", helper->letter);

        // Inicia el arbol
        helper = tree;
    }
}

// Funcion principal
int main()
{
    // Crea el arbol
    Node *tree = buildHuffmanTree();

    // Muestra como queda el arbol
    printCodes(tree, 1);

    // Aqui dice hola, :)
    char code[] = "001011100001100100";

    // Imprime el codigo
    findCode(tree, code);

    // Termina con exito
    return 0;
}
