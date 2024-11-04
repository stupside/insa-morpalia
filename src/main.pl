:- [ia, utils].

% Dynamic predicate to represent pawns on the board
:- dynamic pawn/3.

assets(rouge, 'o', fg(red)).
assets(jaune, 'x', fg(yellow)).

% Clear the game board
reset_board :- retractall(pawn(_, _, _)).

% Display the board
show(X, Y) :- 
    pawn(X, Y, Color),
    assets(Color, Char, Style),
    ansi_format([bold, Style], Char, []),
    ansi_format([fg(blue)], '|', []).
show(_, _) :- 
    write(' '), 
    ansi_format([fg(blue)], '|', []).

% Display the game board
board :- 
    forall(
        (between(1, 6, Tmp), Y is 7 - Tmp),
        (
            nl,
            ansi_format([fg(blue)], '|', []),
            forall(
                between(1, 7, X),
                show(X, Y)
            )
        )
    ),
    nl,
    write(' 1 2 3 4 5 6 7'),
    nl.

% Add a pawn to the given column
make_move(X, Y, Color) :-
    column_height(X, Count),
    Y is Count + 1,
    within_board(X, Y),
    asserta(pawn(X, Y, Color)).

% Remove the last pawn from the given column
undo_move(X) :- 
    column_height(X, Count), 
    retract(pawn(X, Count, _)).

% Play the game
play(X) :-
    (make_move(X, Y, rouge) ->
        board,
        (check_game_over(X, Y, rouge) -> true ; play_ai(jaune))
    ;
        write('Invalid move! Try a different column.'), nl, fail
    ),
    !.

% AI's turn
play_ai(Color) :- 
    (ai(X, Y, Color) -> 
        (
            write('AI placed at column '), write(X), 
            write(' row '), write(Y), nl,
            board, 
            nl, 
            check_game_over(X, Y, Color)
        ) 
    ; 
        true
    ).

% Check if the game is over after a move
check_game_over(X, Y, Color) :-
    Color == rouge, win(X, Y, Color),
    ansi_format([bold, fg(green)], 'Congratulations! You are the champion!', []),
    reset_board, ! ;
    Color == jaune, win(X, Y, Color),
    ansi_format([bold, fg(red)], 'Game over... You were defeated.', []),
    reset_board, ! ;
    not(valid_move(_)),
    ansi_format([bold, fg(orange)], 'No more moves available. Please restart the game!', []),
    reset_board, !.