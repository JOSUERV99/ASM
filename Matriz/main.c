#include <stdio.h>

// Define el tamano de la funcion
#define SIZE 4

// Calcula el discriminante
float getDeterminate(float matrix[SIZE][SIZE], int size)
{
    // Instancia el resultado inicial
    float result = 0;

    // Si es de 2x2
    if (size == 2)
        return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];

    // Indicador si hay que sumar o restar
    int sign = -1;

    // Itera toda la primera fila
    for (int firstElementIndex = 0; firstElementIndex < size; firstElementIndex++)
    {
        // Obtiene el numero actual
        float currentNumber = matrix[0][firstElementIndex];

        // Instancia una matriz temporal
        float temp[SIZE][SIZE];

        // Contadores para las fijas y columnas de la matriz temporal
        int i = 0, j = 0;


        /******* VOY POR AQUI *********/

        // Itera las filas y columnas
        for (int row = 0; row < size; row++)
            for (int col = 0; col < size; ++col)
            {
                // Si no es la primera fila y si la columna no es la misma que el indice inicial
                if (row == 0)
                    continue;

                if (col == firstElementIndex)
                    continue;

                // Agrega el valor a la matriz
                temp[i][j++] = matrix[row][col];

                // Si la columna es la final
                if (j == size - 1)
                {
                    // Resetea el contador de columnas e incrementa el de filas
                    j = 0;
                    i++;
                }
            }


        // Agrega el resultado a la suma
        result -= sign * currentNumber * getDeterminate(temp, size - 1);

        // Invierte el signo
        sign = -sign;
    }

    // Retorna el resultado
    return result;
}

// Funcion principal en cualquier programa de C
int main()
{
    // Matriz de prueba
    // TODO: Pedir los datos con cin
    float matriz[SIZE][SIZE] = {
        51,23,53,43,
        52,62,72,82,
        46,47,48,49,
        21,22,23,24
    };

    // Calcula el discriminante de la matriz y lo imprime
    printf("%f", getDeterminate(matriz, SIZE));

    // Cierra el programa
    return 0;
}