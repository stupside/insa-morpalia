% Alpha-Beta Minimax algorithm

% Players configuration
maximizer(jaune, 1).
maximizer(rouge, -1).

% Random move for the first turn
ia_random(X, Y, Color) :- 
    X is random(7) + 1, 
    column_height(X, Y), % Ensure Y represents the next row in this column
    add(X, Y, Color), !.

% Main IA call: Executes a move for the specified color
ia(X, Y, Color) :- 
    write('Starting AI move selection...'), nl,
    findall(Move, valid_move(Move), PossibleMoves),
    PossibleMoves \= [], % Ensure there are valid moves
    write('Possible moves: '), write(PossibleMoves), nl,
    minmax(5, Color, BestValue, BestMove, -1000000, 1000000, PossibleMoves),
    ( nonvar(BestMove), BestMove \= -1 ->
        X = BestMove,
        write('AI selected move: '), write(X), write(' with value '), write(BestValue), nl,
        column_height(X, Y),
        add(X, Y, Color),
        write('AI move executed at: ('), write(X), write(', '), write(Y), write(')'), nl,
        board  % Refresh the board display
    ; 
        write('AI did not select a valid move.'), nl, fail
    ).

% Minimax with alpha-beta pruning and depth control, with improved fallback
minmax(0, Color, Value, X, _, _, PossibleMoves) :-
    evaluate(Color, Value),
    (PossibleMoves = [X | _] ; X = -1),  % Default X to -1 if no valid moves exist
    write('Evaluating at depth 0: Column '), write(X), write(' with value '), write(Value), nl, !.

% Enhanced debugging in minmax
minmax(Depth, Color, Value, Move, Alpha, Beta, PossibleMoves) :-
    write('Entering minmax with Depth='), write(Depth), write(', Color='), write(Color),
    write(', Alpha='), write(Alpha), write(', Beta='), write(Beta), nl,
    Depth > 0,
    (Color == jaune -> maximize(PossibleMoves, Depth, Color, Value, Move, Alpha, Beta)
    ; minimize(PossibleMoves, Depth, Color, Value, Move, Alpha, Beta)).

% Maximize helper with alpha-beta pruning and fallback if no moves available
maximize([], _, _, Alpha, Coup, Alpha, _) :- 
    write('Maximizer found no valid moves. Returning Alpha: '), write(Alpha), nl, 
    Coup = -1.

maximize([X | Moves], Depth, Color, Value, Coup, Alpha, Beta) :- 
    do_move(X, Color),
    write('Maximizing move at Column '), write(X), write(' for '), write(Color), nl,
    findall(NextMove, valid_move(NextMove), NextMoves),
    (NextMoves \= [] -> write('Next possible moves at Depth='), write(Depth), write(': '), write(NextMoves), nl ; 
     write('No valid moves found in maximize, returning false'), nl, fail),
    minmax(Depth - 1, rouge, NewValue, _, Alpha, Beta, NextMoves),
    undo_move(X),
    write('Move '), write(X), write(' yielded value '), write(NewValue), nl,
    ( NewValue > Alpha -> NewAlpha = NewValue, BestMove = X ; NewAlpha = Alpha, BestMove = Coup ),
    ( NewAlpha >= Beta -> 
        write('Pruning in maximize at move: '), write(X), nl,
        Value = NewAlpha, Coup = BestMove, ! 
    ; 
        maximize(Moves, Depth, Color, Value, Coup, NewAlpha, Beta) 
    ).

% Minimize helper with alpha-beta pruning and fallback if no moves available
minimize([], _, _, Beta, Coup, _, Beta) :- 
    write('Minimizer found no valid moves. Returning Beta: '), write(Beta), nl, 
    Coup = -1.

minimize([X | Moves], Depth, Color, Value, Coup, Alpha, Beta) :- 
    do_move(X, Color),
    write('Minimizing move at Column '), write(X), write(' for '), write(Color), nl,
    findall(NextMove, valid_move(NextMove), NextMoves),
    (NextMoves \= [] -> write('Next possible moves at Depth='), write(Depth), write(': '), write(NextMoves), nl ; 
     write('No valid moves found in minimize, returning false'), nl, fail),
    minmax(Depth - 1, jaune, NewValue, _, Alpha, Beta, NextMoves),
    undo_move(X),
    write('Move '), write(X), write(' yielded value '), write(NewValue), nl,
    ( NewValue < Beta -> NewBeta = NewValue, BestMove = X ; NewBeta = Beta, BestMove = Coup ),
    ( Alpha >= NewBeta -> 
        write('Pruning in minimize at move: '), write(X), nl,
        Value = NewBeta, Coup = BestMove, ! 
    ; 
        minimize(Moves, Depth, Color, Value, Coup, Alpha, NewBeta) 
    ).

% Temporarily simulate a move by adding a pawn in the specified column for the given color.
do_move(X, Color) :-
    column_height(X, Y), % Determine the current height to get the next available row
    add(X, Y, Color). % Add a pawn temporarily for AI evaluation

% Undo the simulated move by removing the most recent pawn in the specified column.
undo_move(X) :-
    column_height(X, Y),
    Y > 0, % Ensure there's a pawn to remove
    remove(X). % Remove the pawn at the current height

% Enhanced heuristic evaluation function
evaluate(Color, Value) :- 
    maximizer(Color, Sign),
    findall(Score, h_neighborhood(_, _, Color, Score), Scores),  % Sum scores of potential moves
    sum_list(Scores, TotalScore),
    Value is Sign * TotalScore,
    write('Evaluation for Color='), write(Color), write(' yields Value='), write(Value), nl.

% Check if a move leads to a game over state
is_terminal(X, Color, Value) :-
    column_height(X, Count), Y is Count + 1, Y < 7,
    ( (win(X, Y, Color), (Color == jaune -> Value = 1000000 ; Value = -1000000), !)
    ; (not(valid_move(_)), Value = 0)  % Draw condition.
    ).
