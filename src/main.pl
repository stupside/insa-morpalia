% Dynamic predicate to represent pawns on the board
:- dynamic pawn/3.

assets(rouge, 'o', fg(red)).
assets(jaune, 'x', fg(yellow)).

next_color(jaune, rouge).
next_color(rouge, jaune).

% Clear the game board
reset_board :- retractall(pawn(_, _, _)).

% Display the board
show(X, Y) :- pawn(X, Y, rouge), assets(rouge, Char, Color), ansi_format([bold, Color], Char, []), ansi_format([fg(blue)], '|', []).
show(X, Y) :- pawn(X, Y, jaune), assets(jaune, Char, Color), ansi_format([bold, Color], Char, []), ansi_format([fg(blue)], '|', []).
show(_, _) :- write(' '), ansi_format([fg(blue)], '|', []).

board :- 
    between(1, 6, Tmp), Y is 7 - Tmp, nl, ansi_format([fg(blue)], '|', []),
    between(1, 7, X), not(show(X, Y)) ; true, !.

add(X, Y, Color) :- 
    integer(X), X >= 1, X < 8,
    column_height(X, Count), Y is Count + 1,
    integer(Y), Y >= 1, Y < 7,
    asserta(pawn(X, Y, Color)).

remove(X) :- column_height(X, Count), retract(pawn(X, Count, _)).

valid_move(X) :- between(1, 7, X), once(not(pawn(X, 6, _))).

column_height(X, Count) :- aggregate_all(count, pawn(X, _, _), Count).

play(X) :-
    (add(X, Y, rouge), ! ; write('Invalid move! Try a different column.'), nl, fail),
    board, nl,
    (check_game_over(X, Y, rouge), ! ; play_ai(jaune)).

play_ai(Color) :- 
    ia(X, Y, Color) -> (board, nl, check_game_over(X, Y, Color), ! ; true).

% Enhanced game-over check
check_game_over(X, Y, Color) :-
    Color == rouge, win(X, Y, Color), ansi_format([bold, fg(green)], 'Congratulations! You are the champion!', []), reset_board, ! ;
    Color == jaune, win(X, Y, Color), ansi_format([bold, fg(red)], 'Game over... You were defeated.', []), reset_board, ! ;
    not(valid_move(_)), ansi_format([bold, fg(orange)], 'No more moves available. Please restart the game!', []), reset_board, !.
