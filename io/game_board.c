#include <stdio.h>
#include <stdlib.h>

#include "../macros.h"

/**
 * Game board related functions
*/

/**
 * In the game logic, each player symbol is represented by an integer;
 * Given an integer-encoded symbol, it returns the corrisponding character.
*/
char numberToSymbol(int playerSymbol) {
    char convertedCharacter;

    switch (playerSymbol) {
        case -1:
            convertedCharacter = EMPTY_SYMBOL;
        break;
        case 0:
            convertedCharacter = SECOND_SYMBOL;
        break;
        case 1:
            convertedCharacter = FIRST_SYMBOL;
        break;
    }

    return convertedCharacter;
}

void printRow(const int row[], unsigned short separator) {
    for (int i = 0; i < GAMEBOARD_COLUMNS; i++)
        printf(" %c |", numberToSymbol(row[i]));

    printf("\n");

    if (separator) {
        for (size_t i = 1; i <= SEPARATOR_LEN; i++) {
            if (i % 4 == 0)
                printf("%c", BOARD_SPLITTER);
            else
                printf("%c", BOARD_SEPARATOR);
        }
    }
}

void intPrintGameBoard(const int** gameBoard) {
    system("clear");

    for (size_t i = 0; i < GAMEBOARD_ROWS; i++) {
        int separatorNeeded = i != 2;
        
        printf("\n");
        printRow(gameBoard[i], separatorNeeded);
    }

    printf("\n");
}