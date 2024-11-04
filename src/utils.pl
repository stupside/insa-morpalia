:- [winner].

% Player switching
switch_player(jaune, rouge).
switch_player(rouge, jaune).

% Board validation
within_board(X, Y) :-
    X >= 1, X =< 7,
    Y >= 1, Y =< 6.

% Move utilities
valid_move(X) :-     
    between(1, 7, X),
    column_height(X, H),
    H < 6.

available_moves(Moves) :-
    findall(M, valid_move(M), Moves).

column_height(X, Count) :-
    aggregate_all(count, pawn(X, _, _), Count).

count_placed_pawns(Count) :-
    aggregate_all(count, pawn(_, _, _), Count).

is_empty_and_playable(X, Y) :-
    within_board(X, Y),
    \+ pawn(X, Y, _),
    (Y = 1 ; Y1 is Y - 1, pawn(X, Y1, _)).
