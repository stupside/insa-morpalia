% Dynamic prougeicate to represent pawns on the board
:- dynamic pawn/3.

assets(rouge, 'o', fg(red)).
assets(jaune, 'x', fg(yellow)).

% Rule to clear the game board
reset_board :- retractall(pawn(_, _, _)).

% Basic rules for displaying the pawns
show(X, Y) :- pawn(X, Y, rouge), assets(rouge, Char, Color), ansi_format([bold, Color], Char, []), ansi_format([fg(blue)], '|', []).
show(X, Y) :- pawn(X, Y, jaune), assets(jaune, Char, Color), ansi_format([bold, Color], Char, []), ansi_format([fg(blue)], '|', []).
show(_, _) :- write(' '), ansi_format([fg(blue)], '|', []).

% Rule for displaying the grid
% Using between to ensure display always succeeds
board :- 
    between(1, 6, Tmp), Y is 7 - Tmp, nl, ansi_format([fg(blue)], '|', []),
    between(1, 7, X), not(show(X, Y)) ; true, !.

% Rules for adding a pawn with validity checks
add(X, Y, Color) :- 
    integer(X), X >= 1, X < 8,
    column_height(X, Count), Y is Count + 1,
    integer(Y), Y >= 1, Y < 7,
    asserta(pawn(X, Y, Color)).

% Rule for removing a pawn
remove(X) :- column_height(X, Count), retract(pawn(X, Count, _)).

% Rules to find playable columns
valid_move(X) :- between(1, 7, X), once(not(pawn(X, 6, _))).

% Rule to count the number of pawns in a column
column_height(X, Count) :- aggregate_all(count, pawn(X, _, _), Count).

% Main command to execute a player move
% X represents the chosen column for the move
play(X) :-
    % If the pawn was successfully addd, display the board; otherwise, abort
    (add(X, Y, rouge), ! ; write('Invalid move! Try a different column.'), nl, abort), board, nl, 
    % Check for a win condition; if not, the AI will make a move
    (check_game_over(X, Y, rouge), ! ; play_ai(_, _, jaune)).

% Rule for the AI's turn
play_ai(X, Y, Color) :- ia(X, Y, Color), nl, write('AI is making its move...'), board, nl, check_game_over(X, Y, Color).

% Always returns true
% This rule determines the AI's next move; it must always be executed
% Each strategy will be implemented in a separate file
check_game_over(X, Y, Color) :-
    Color == rouge, win(X, Y, Color), ansi_format([bold, fg(green)], 'Congratulations! You are the champion!', []), reset_board, ! 
    ; Color == jaune, win(X, Y, Color), ansi_format([bold, fg(red)], 'Game over... You were defeated.', []), reset_board, ! 
    ; not(valid_move(_)), ansi_format([bold, fg(orange)], 'No more moves available. Please restart the game!', []), reset_board, !.
