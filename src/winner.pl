% Check if a player has won the game
win(X, Y, Color) :-
    nonvar(X), nonvar(Y), nonvar(Color),  % Ensure arguments are instantiated
    direction(DX, DY),
    count_direction(X, Y, DX, DY, Color, Count),
    Count >= 4.

% Count consecutive pieces in a given direction
count_direction(X, Y, DX, DY, Color, Count) :-
    NextX is X + DX,
    NextY is Y + DY,
    (within_board(NextX, NextY), pawn(NextX, NextY, Color) ->
        count_direction(NextX, NextY, DX, DY, Color, NextCount),
        Count is NextCount + 1
    ;
        Count = 1
    ).

% Count consecutive pieces in a given direction in both directions
count_both_direction(X, Y, DX, DY, Color, Count) :-
    count_direction(X, Y, DX, DY, Color, Count1), % Count in one direction
    count_direction(X, Y, -DX, -DY, Color, Count2), % Count in the opposite direction
    Count is Count1 + Count2 - 1. % Subtract 1 to avoid counting the same piece twice

% Directions to check for a win
direction(1, 0).  % Horizontal
direction(0, 1).  % Vertical
direction(1, 1).  % Diagonal down-right
direction(1, -1). % Diagonal up-right
direction(0, -1). % Vertical up
direction(-1, -1).% Diagonal up-left
direction(-1, 0). % Horizontal left
direction(-1, 1). % Diagonal down-left
