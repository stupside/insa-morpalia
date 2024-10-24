% Check for a win in the four possible directions
win(X, Y, Color) :- 
    neighborhood(X, Y, 1, 0, Color, C1), % right
    neighborhood(X, Y, -1, 0, Color, C2), % left
    Count is C1 + C2, 
    Count >= 3, !.
    
win(X, Y, Color) :- 
    neighborhood(X, Y, 0, 1, Color, C1), % up
    neighborhood(X, Y, 0, -1, Color, C2), % down
    Count is C1 + C2, 
    Count >= 3, !.
    
win(X, Y, Color) :- 
    neighborhood(X, Y, 1, -1, Color, C1), % diagonal top-right to bottom-left
    neighborhood(X, Y, -1, 1, Color, C2), % diagonal bottom-left to top-right
    Count is C1 + C2, 
    Count >= 3, !.
    
win(X, Y, Color) :- 
    neighborhood(X, Y, 1, 1, Color, C1), % diagonal top-left to bottom-right
    neighborhood(X, Y, -1, -1, Color, C2), % diagonal bottom-right to top-left
    Count is C1 + C2, 
    Count >= 3, !.

% Recursive neighborhood check to count consecutive pawns of the same color
neighborhood(X, Y, DX, DY, Color, Count) :-
    XNext is X + DX,
    YNext is Y + DY,
    ( 
        pawn(XNext, YNext, Color) -> % Check if the next position has the same color pawn
        neighborhood(XNext, YNext, DX, DY, Color, CountNext), % Continue checking in the same direction
        Count is CountNext + 1
    ; 
        Count = 0 % If no matching pawn is found, stop counting
    ).
