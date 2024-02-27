/**
 * General macros and functions shared by C files
*/

#ifndef CONSTANTS_H
#define CONSTANTS_H

#define GAMEBOARD_ROWS 3
#define GAMEBOARD_COLUMNS 3
#define SEPARATOR_LEN 12

#define EMPTY_SYMBOL '-'
#define FIRST_SYMBOL 'X'
#define SECOND_SYMBOL 'O'

#define KEEP_PLAYING 'Y'
#define STOP_PLAYING 'N'

#define BOARD_SEPARATOR '-'
#define BOARD_SPLITTER '+'

char numberToSymbol(int playerSymbol);

#endif