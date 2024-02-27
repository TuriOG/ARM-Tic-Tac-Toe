.global asm_start_game

.section .data

first_row:
    .word -1, -1, -1

second_row:
    .word -1, -1, -1

third_row:
    .word -1, -1, -1

game_board:
    .word first_row, second_row, third_row

score:
    .word 0, 0

first_player_symbol:
    .word -1

.section .text

@ R4 Register => Tracks the current turn. Each game lasts a maximum of 9 turns, which results in a draw.
@ R5 Register => Stores the address contained in the Link Register (LR).
@ R7 Register => Stores the player who is currently playing. 

asm_start_game:
    MOV R4, #0

    MOV R5, LR
    BL intClearScreen
    MOV LR, R5

    BL print_gameboard
    MOV LR, R5

    @ We check if the players have already selected the symbol they want to use
    LDR R0, =first_player_symbol
    LDR R1, [R0]
    CMP R1, #-1
    BNE game_loop

get_players_symbol:
    BL intGetPlayerSymbol
    MOV LR, R5
    
    LDR R1, =first_player_symbol
    STR R0, [R1]
    MOV R7, R0

game_loop:
    @ R5 Register => Stores the chosen row by the current player.
    @ R6 Register => Stores the chosen column by the current player.
    
    CMP R4, #9
    BEQ game_drawn

    @ Parameter for the intGetCoordinate function.
    MOV R0, #1

    MOV R5, LR
    BL intGetCoordinate
    MOV LR, R5

    @ Stores the return value, which is the chosen row.
    MOV R5, R0

    @ Parameter for the intGetCoordinate function.
    MOV R0, #0
    
    MOV R6, LR
    BL intGetCoordinate
    MOV LR, R6

    @ Stores the return value, which is the chosen column.
    MOV R6, R0

    ADD R4, R4, #1

store_round:
    LDR R0, =game_board

    CMP R5, #0
    BEQ store_first_row

    CMP R5, #1
    BEQ store_second_row

    B store_third_row

store_first_row:
    LDR R1, [R0]
    B check_occupied

store_second_row:
    LDR R1, [R0, #4]
    B check_occupied

store_third_row:
    LDR R1, [R0, #8]

@ Checks if the chosen point in the game board is already occupied by the other player.
check_occupied:
    ADD R1, R1, R6

    LDR R2, [R1]
    CMP R2, #-1
    BEQ store

    @ It is occupied, the round does not count.
    SUB R4, R4, #1

    MOV R5, LR
    BL intOccupied
    MOV LR, R5

    B game_loop

store:
    STR R7, [R1]
    
    @ Until four turns have been played, there cannot be a winner.
    @ Therefore, it is uselees to check for winning conditions.
    CMP R4, #4
    BLE change_round

    MOV R3, #3
    LDR R0, =game_board

@ Iterates through all the rows.
check_winning_rows:
    @ If all the rows have been visited and there is no winner,
    @ we move on to check other winning conditions.
    CMP R3, #0
    BEQ check_winning_columns

    SUB R3, R3, #1
    
    MOV R2, #3
    LDR R5, [R0], #4

    PUSH {LR}
    BL check_row
    POP {LR}

    @ After a row has been scanned, we need to check if there is a winner.
    CMP R0, #2
    BLT game_ended

    B check_winning_rows

@ Iterates through all the elements of a given row and checks if it is a winning one.
check_row:
    @ If all the elements are visited, it means they are all equal.
    @ Therefore, we found a winning row.
    CMP R2, #0
    BEQ winning_combination_found

    LDR R1, [R5], #4
    CMP R1, R7
    BNE end_check

    SUB R2, R2, #1
    B check_row

@ Iterates through all the columns.
check_winning_columns:
    MOV R3, #3
    MOV R5, #0

check_columns_loop:
    LDR R0, =game_board

    @ If all the columns have been visited and there is no winner,
    @ we move on to check other winning conditions.
    CMP R3, #0
    BEQ check_winning_diagonals

    SUB R3, R3, #1

    MOV R2, #3
    PUSH {LR}
    BL check_column
    POP {LR}

    @ After a column has been scanned, we need to check if there is a winner.
    CMP R0, #2
    BLT game_ended

    ADD R5, R5, #4
    B check_columns_loop

@ Iterates through all the elements of a given column and checks if it is a winning one.
check_column:
    @ If all the elements are visited, it means they are all equal.
    @ Therefore, we found a winning column.
    CMP R2, #0
    BEQ winning_combination_found

    SUB R2, R2, #1

    LDR R1, [R0], #4
    LDR R6, [R1, R5]
    CMP R6, R7
    BNE end_check

    B check_column

@ Iterates through the two diagonals.
check_winning_diagonals:
    @ Offset used to jump columns. It initially starts from 0 to check the main diagonal:
        @ Check
            @ Check
                @ Check
    
    @ Once it reaches the offset of the last element, we decrease it to check the secondary diagonal:
                @ Check
            @ Check
        @ Check
    MOV R5, #0

    MOV R3, #2

    @ Flag used to determine whether we are checking the main or the secondary diagonal.
    MOV R6, #1

check_diagonals_loop:
    LDR R0, =game_board
    
    @ If the diagonals have been visited and there is no winner,
    @ we move on with an another round.
    CMP R3, #0
    BEQ change_round

    @ R5 starts from 0 to check the main diagonal.
    CMP R6, #1
    BEQ check_diagonals

    @ If we are checking the secondary diagonal, it starts from the last element.
    MOV R5, #8

check_diagonals:
    MOV R2, #3
    PUSH {LR}
    BL check_diagonal
    POP {LR}

    @ After a diagonal has been scanned, we need to check if there is a winner.
    CMP R0, #2
    BLT game_ended

    ADD R6, R6, #1
    SUB R3, R3, #1
    B check_diagonals_loop

check_diagonal:
    CMP R2, #0
    BEQ winning_combination_found

    SUB R2, R2, #1

    LDR R1, [R0], #4
    LDR R8, [R1, R5]
    CMP R8, R7
    BNE end_check

    CMP R6, #1
    BEQ increment_offset
    SUB R5, R5, #4
    B check_diagonal

@ If we are checking the main diagonal, the offset must be increased.
@ To check the secondary diagonal, it must be decreased instead.
increment_offset:
    ADD R5, R5, #4
    B check_diagonal

winning_combination_found:
    PUSH {LR}
    BL print_gameboard
    POP {LR}

    LDR R0, =first_player_symbol
    LDR R1, [R0]

    CMP R1, R7
    BEQ first_player_wins
    B second_player_wins

end_check:
    BX LR

first_player_wins:
    MOV R0, #1

    LDR R1, =score
    LDR R2, [R1]

    MOV R0, #0
    B update_score

second_player_wins:
    MOV R0, #2
    
    LDR R1, =score
    LDR R2, [R1, #4]!
    MOV R0, #1

update_score:
    ADD R2, R2, #1
    STR R2, [R1]

    BX LR

change_round:
    MOV R5, LR
    BL print_gameboard
    MOV LR, R5

    CMP R7, #0
    BEQ second_player_round

    MOV R7, #0
    B game_loop

second_player_round:
    MOV R7, #1
    B game_loop

print_gameboard:
    LDR R0, =game_board

    PUSH {LR}
    BL intPrintGameBoard
    POP {LR}
    
    BX LR

game_drawn:
    MOV R0, #-1

game_ended:
    @ The game outcome is determined by the value of R0:
        @ -1 => Draw;
        @ 0 => First player wins;
        @ 1 => Second player wins.

    LDR R1, =score
    LDR R6, =first_player_symbol

    LDR R2, [R6]
    PUSH {R2}

    MOV R5, LR
    BL intGameEnded
    MOV LR, R5

    POP {R2}

    @ We switch the player who plays first in the next round.
    CMP R2, #1
    BEQ second_player_starts
    MOV R7, #1
    B update_turn

second_player_starts:
    MOV R7, #0

update_turn:
    STR R7, [R6]

    @ We exchange the players' score as their turns are swapped in the next game. 
    @ For example, if the current score is 1-0, it becomes 0-1 since the players are swapping their turn (the current first player becomes the second).
    LDR R0, =score
    LDR R1, [R0]
    LDR R2, [R0, #4]

    STR R2, [R0]
    STR R1, [R0, #4]

    MOV R5, LR
    BL intKeepPlaying
    MOV LR, R5

    CMP R0, #1
    BEQ board_cleanup
    BX LR

@ If the user chooses to play again, the current board state must be erased.
board_cleanup:
    LDR R0, =game_board
    MOV R1, #3

start_cleanup:
    CMP R1, #0
    BEQ asm_start_game

    LDR R2, [R0], #4

    MOV R3, #3
    PUSH {R4}

    MOV R5, LR
    BL clean_row
    MOV LR, R5

    SUB R1, R1, #1
    B start_cleanup

clean_row:
    CMP R3, #0
    BEQ end_clean_row

    MOV R4, #-1
    STR R4, [R2], #4

    SUB R3, R3, #1
    B clean_row

end_clean_row:
    POP {R4}
    BX LR