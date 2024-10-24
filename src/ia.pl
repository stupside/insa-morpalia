% Load the heuristic files
:- [heuristic/neighborhood].

% Alpha-Beta Minimax algorithm

maximizer(jaune, 1).
maximizer(rouge, -1).

% Random move for the first turn
ia_random(X, Y, Color) :- X is random(8), add(X, Y, Color), ! .

% Y is ommitted in the minmax predicate beccause it not useful for the calculation
% alpha and beta are initiated to -inf and +inf respectively
ia(X, Y, Color) :- minmax(5, Color, _, X, -1000000, 1000000), add(X, Y, Color).

% Minimax with alpha-beta pruning
minmax(Depth, _, Value, _, _, _) :- Depth == 0, Value = 0, !.

% Maximize for 'jaune' player
minmax(Depth, jaune, Value, Coup, Alpha, Beta) :-
    Depth > 0,
    NewAlpha is Alpha, % Ensure that Alpha is instantiated
    aggregate_all(max(V, X), (simulate(Depth, jaune, V, X, Alpha, Beta), V > Alpha), max(Value, Coup)),
    Value =:= max(Alpha, Value), % Avoid the issue with instantiation
    NewAlpha < Beta, !.

% Minimize for 'rouge' player
minmax(Depth, rouge, Value, Coup, Alpha, Beta) :-
    Depth > 0,
    NewBeta is Beta, % Ensure that Beta is instantiated
    aggregate_all(min(V, X), (simulate(Depth, rouge, V, X, Alpha, Beta), V < Beta), min(Value, Coup)),
    Value =:= min(Beta, Value),
    NewBeta > Alpha, !.

% Simulate possible moves and evaluate with the refined scoring
simulate(Depth, Color, Value, X, Alpha, Beta) :-
    ( valid_move(X),
      once(
        (
            isTerminal(X, Color, TerminalValue),
            Value is TerminalValue
        ) ; (
            add(X, _, Color),
            NewDepth is Depth - 1,
            ( Color == jaune -> minmax(NewDepth, rouge, V, _, Alpha, Beta)
            ; Color == rouge -> minmax(NewDepth, jaune, V, _, Alpha, Beta)),
            evaluate(X, Color, EvalValue),
            Value is EvalValue,
            remove(X)
        )
      )
    ; Value is 0
    ).

% A move is terminal if it is a winning move or the last move possible
isTerminal(X, Color, Value) :-
    column_height(X, Count), Y is Count + 1, Y < 7,
    ( Color == rouge, win(X, Y, rouge), Value = -10, !
    ; Color == jaune, win(X, Y, jaune), Value = 10, !
    ).

evaluate(X, Color, Value) :- 
    column_height(X, Count),

    % Assume this function is well defined
    h_neighborhood(X, Count, Color, HeuristicValue),
    
    % Combine this with additional criteria if necessary
    Value is HeuristicValue * 10 + Count. % or any other metric to enhance heuristic.
