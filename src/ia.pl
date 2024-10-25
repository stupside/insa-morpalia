% Alpha-Beta Minimax algorithm

% Y is ommitted in the minmax predicate beccause it not useful for the calculation
% alpha and beta are initiated to -inf and +inf respectively
ia(X, Y, Color) :- minmax(5, Color, _, X, -1000000, 1000000), add(X, Y, Color).

% Minimax with alpha-beta pruning
minmax(P, _, Value, _, _, _) :- P == 0, Value = 0, !.

% Maximize for 'jaune' player
minmax(P, jaune, Value, Coup, Alpha, Beta) :-
    P > 0,
    NewAlpha is Alpha, % Ensure that Alpha is instantiated
    aggregate_all(max(V, X), (simulate(P, jaune, V, X, Alpha, Beta), V > Alpha), max(Value, Coup)),
    Value =:= max(Alpha, Value), % Avoid the issue with instantiation
    NewAlpha < Beta, !.

% Minimize for 'rouge' player
minmax(P, rouge, Value, Coup, Alpha, Beta) :-
    P > 0,
    NewBeta is Beta, % Ensure that Beta is instantiated
    aggregate_all(min(V, X), (simulate(P, rouge, V, X, Alpha, Beta), V < Beta), min(Value, Coup)),
    Value =:= min(Beta, Value), % Avoid the issue with instantiation
    NewBeta > Alpha, !.

% Simulate possible moves and evaluate them
simulate(P, Color, Value, X, Alpha, Beta) :-
    ( valid_move(X), % Ensure X is instantiated
      Coeff is 10 - P,
      once((is_terminal(X, Color, V), Value is Coeff * V) ; (
            add(X, _, Color),
            Pm is P - 1,
            ( Color == jaune, minmax(Pm, rouge, Value, _, Alpha, Beta)
            ; Color == rouge, minmax(Pm, jaune, Value, _, Alpha, Beta)),
            remove(X) ; true ))
    ; Value is 0
    ).

% A move is terminal if it is a winning move or the last move possible
is_terminal(X, Color, Value) :-
    column_height(X, Count), Y is Count + 1, Y < 7,
    ( Color == rouge, win(X, Y, rouge), Value = -1000000, !
    ; Color == jaune, win(X, Y, jaune), Value = 1000000, !
    ).