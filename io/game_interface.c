#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#include "../macros.h"

/**
 * Functions/Subroutines that allow I/O interaction with the user;
 * They are designed to be called by Assembly when needed;
 * It's important to note that each function begins with "int", representing the "interface" between the two languages.
*/

typedef enum {
    DRAW = -1,
    FIRST_PLAYER_WINS,
    SECOND_PLAYER_WINS
} GameOutcome;

void flushStdin() {
    int currentCharacter;

    while ((currentCharacter = getchar()) != '\n' && currentCharacter != EOF);
}

int intGetPlayerSymbol() {
    int playerSymbol;

    do {
        printf("\nInserisci il simbolo del primo giocatore: \n");
        printf(" -> 1 per il simbolo %c\n", FIRST_SYMBOL);
        printf(" -> 0 per il simbolo %c\n\n", SECOND_SYMBOL);

        scanf("%d", &playerSymbol);
        flushStdin();

        if (playerSymbol < 0 || playerSymbol > 1)
            printf("\nSimbolo non riconosciuto!\n");

    } while (playerSymbol < 0 || playerSymbol > 1);

    printf("\n");

    return playerSymbol;
}

/**
 * Given the chosen column by the player, it converts it in an ASM-like offset;
 * For example:
  - If the user chooses to place their symbol in the third column, the input will be converted to the number 8 and returned to Assembly;
  - By doing this, the third element in the corrisponding row can easily be accessed by doing (First Element Pointer + Offset)
*/

int coordinateToOffset(int coordinate) {
    int coordinateOffset = 0;

    switch (coordinate) {
        case 2:
            coordinateOffset = 4;
        break;
        case 3:
            coordinateOffset = 8;
        break;
    }

    return coordinateOffset;
}

int intGetCoordinate(int isRow) {
    int coordinate = 0;
    const char *coordinateType = isRow ? "riga" : "colonna";

    do {
        printf("In quale %s vuoi posizionarti? ", coordinateType);
        scanf("%d", &coordinate);
        flushStdin();

        if (coordinate < 1 || coordinate > 3)
            printf("\nNumero %s non riconosciuta! Immagina il gioco come una matrice 3x3.\n", coordinateType);

    } while (coordinate < 1 || coordinate > 3);

    return isRow ? coordinate - 1 : coordinateToOffset(coordinate);
}

void intOccupied() {
    printf("\nPosizione già occupata! Riprova.\n");
}

char getSecondPlayerSymbol(int firstPlayerSymbol) {
    return numberToSymbol(firstPlayerSymbol) == 'X' ? 'O' : 'X';
}

void intGameEnded(GameOutcome gameOutcome, const int score[], int playerSymbol) {
    const char *spacing = "\t\t";

    switch (gameOutcome) {
        case DRAW:
            printf("\n%sLa partita e' terminata con un pareggio!\n", spacing);
        break;
        case FIRST_PLAYER_WINS:
            printf("\n%sPartita terminata. Il giocatore (%c) vince!\n", spacing, numberToSymbol(playerSymbol));
        break;
        case SECOND_PLAYER_WINS:
            printf("\n%sPartita terminata. Il giocatore (%c) vince!\n", spacing, getSecondPlayerSymbol(playerSymbol));
        break;
    }

    printf("\n%s\t\t Punteggio:\n", spacing);
    printf("%s\t     -> Giocatore %c: %d\n", spacing, numberToSymbol(playerSymbol), score[0]);
    printf("%s\t     -> Giocatore %c: %d\n", spacing, getSecondPlayerSymbol(playerSymbol), score[1]);
}

int intKeepPlaying() {
    char decision;

    do {
        printf("\nVuoi continuare a giocare?\n");
        printf(" * %c -> Sì\n", KEEP_PLAYING);
        printf(" * %c -> No\n", STOP_PLAYING);
        
        scanf(" %c", &decision);
        flushStdin();

        decision = toupper(decision);
    } while (decision != KEEP_PLAYING && decision != STOP_PLAYING);

    return decision == KEEP_PLAYING ? 1 : 0;
}

void intClearScreen() {
    system("clear");
}