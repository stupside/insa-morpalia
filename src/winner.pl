% Check for a win in the four possible directions
win(X, Y, Color) :- 
    neighborhood(X, Y, 1, 0, Color, C1), neighborhood(X, Y, -1, 0, Color, C2), Count is C1 + C2, Count >= 3, !.
win(X, Y, Color) :- 
    neighborhood(X, Y, 0, 1, Color, C1), neighborhood(X, Y, 0, -1, Color, C2), Count is C1 + C2, Count >= 3, !.
win(X, Y, Color) :- 
    neighborhood(X, Y, 1, -1, Color, C1), neighborhood(X, Y, -1, 1, Color, C2), Count is C1 + C2, Count >= 3, !.
win(X, Y, Color) :- 
    neighborhood(X, Y, 1, 1, Color, C1), neighborhood(X, Y, -1, -1, Color, C2), Count is C1 + C2, Count >= 3, !.

neighborhood(X, Y, DX, DY, Color, Count) :-
    XNext is X + DX,
    YNext is Y + DY,
    ( pawn(XNext, YNext, Color) ->
        (neighborhood(XNext, YNext, DX, DY, Color, CountNext) ->
            Count is CountNext + 1 ; Count is 1)
    ; Count is 0).
