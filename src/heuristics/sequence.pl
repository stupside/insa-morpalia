% Evaluate sequences on the board
sequence_score(Color, Score) :-
    findall(S, (
        pawn(X, Y, Color),
        direction(DX, DY),
        count_both_direction(X, Y, DX, DY, Color, Length),
        sequence_value(Length, S)
    ), Scores),
    sum_list(Scores, Score).

% Count consecutive pieces in a given direction
sequence_value(Length, Score) :-
    (Length >= 4 -> Score = 100000
    ; Length = 3 -> Score = 1000
    ; Length = 2 -> Score = 100
    ; Score = 10).
