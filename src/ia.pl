:- [utils].

:- [heuristics/evaluate, heuristics/threat, heuristics/sequence, heuristics/center].

:- dynamic best_move/2.

:- dynamic last_move_time/1.
:- asserta(last_move_time(0)).

% Simplified opening book
opening_move([], 4).  % First move center
opening_move([4], 3). % Response to center


% AI move selection with opening book
ai(X, Y, Color) :-
    % Try opening
    findall(Col, pawn(Col, _, _), PlayedMoves),
    (opening_move(PlayedMoves, X) ->
        % Use opening if available
        column_height(X, Count),
        Y is Count + 1,
        make_move(X, Y, Color)
    ;
        % Else use negamax
        get_time(StartTime),
        available_moves(Moves),
        (Moves = [] -> fail ; true),
        count_placed_pawns(PlacedPawns),
        calculate_dynamic_depth(PlacedPawns, Color, BaseDepth),
        Alpha is -1000000,
        Beta is 1000000,
        best_move(Moves, Color, BaseDepth, Alpha, Beta, X, _),
        make_move(X, Y, Color),
        get_time(EndTime),
        TimeSpent is EndTime - StartTime,
        retractall(last_move_time(_)),
        asserta(last_move_time(TimeSpent))
    ).

% Optimize depth based on position complexity and time
calculate_dynamic_depth(PlacedPawns, Color, Depth) :-
    base_game_phase_depth(PlacedPawns, BaseDepth),
    position_complexity_adjustment(Color, ComplexityAdj),
    time_pressure_adjustment(TimeAdj),
    InitialDepthLimit = 5,  % Limit initial search depth
    Depth is max(3, min(InitialDepthLimit, BaseDepth + ComplexityAdj + TimeAdj)).

% Modify base depth based on game phase
base_game_phase_depth(PlacedPawns, Depth) :-
    (PlacedPawns < 4 -> Depth = 4     % Very early game
    ; PlacedPawns < 8 -> Depth = 5    % Opening
    ; PlacedPawns < 16 -> Depth = 5   % Early game
    ; PlacedPawns < 28 -> Depth = 4   % Mid game
    ; Depth = 3).                     % End game

% Adjust depth based on position complexity
position_complexity_adjustment(Color, Adjustment) :-
    switch_player(Color, Opponent),
    threat_score(Color, MyThreat),
    threat_score(Opponent, OppThreat),
    (MyThreat > 500 -> Adjustment = 2      % Winning threats
    ; OppThreat > 500 -> Adjustment = 2    % Defensive threats
    ; Adjustment = 0).                     % Normal position

% Adjust depth based on available time
time_pressure_adjustment(Adjustment) :-
    last_move_time(LastMoveTime),
    (LastMoveTime > 2.0 -> Adjustment = -1     % Too slow
    ; LastMoveTime < 0.5 -> Adjustment = 1     % Very fast
    ; Adjustment = 0).                     % Normal speed

% We use negamax with alpha-beta pruning for the AI
negamax(0, Color, _, _, Score) :- !,
    evaluate_position(Color, Score).
negamax(_, _, _, _, Score) :-
    available_moves([]), !,  % This is a Draw
    Score = 0.
negamax(Depth, Color, Alpha, Beta, BestScore) :-
    Depth > 0,
    available_moves(Moves),
    Moves \= [], !,
    NewDepth is Depth - 1,
    negamax_moves(Moves, Color, NewDepth, Alpha, Beta, -1000000, BestScore).

% Negamax with alpha-beta pruning for move selection
% We used negamax instead of minmax to simplify the implementation of the AI
negamax_moves([], _, _, _, _, Score, Score) :- !.
negamax_moves([Move|Moves], Color, Depth, Alpha, Beta, CurrentScore, BestScore) :-
    (make_move(Move, _, Color) ->
        switch_player(Color, Opponent),
        negamax(Depth, Opponent, -Beta, -Alpha, Score),
        undo_move(Move),
        NegScore is -Score,
        NewScore is max(CurrentScore, NegScore),
        NewAlpha is max(Alpha, NewScore),
        (NewAlpha >= Beta ->
            BestScore = NewScore
        ;
            negamax_moves(Moves, Color, Depth, NewAlpha, Beta, NewScore, BestScore)
        )
    ;
        negamax_moves(Moves, Color, Depth, Alpha, Beta, CurrentScore, BestScore)
    ).

% Find the best move for the AI
best_move(Moves, Color, Depth, Alpha, Beta, BestMove, BestScore) :-
    best_move_loop(Moves, Color, Depth, Alpha, Beta, nil, -1000000, BestMove, BestScore),
    BestMove \= nil, !.  % Ensure we found a valid move

% Loop through moves to find the best one
best_move_loop([], _, _, _, _, CurrentMove, CurrentScore, CurrentMove, CurrentScore) :- !.
best_move_loop([Move|Moves], Color, Depth, Alpha, Beta, CurrentMove, CurrentScore, BestMove, BestScore) :-
    (make_move(Move, _, Color) ->
        switch_player(Color, Opponent),
        negamax(Depth, Opponent, -Beta, -Alpha, MoveScore),
        undo_move(Move),
        Score is -MoveScore,
        (Score > CurrentScore ->
            NewAlpha is max(Alpha, Score),
            best_move_loop(Moves, Color, Depth, NewAlpha, Beta, Move, Score, BestMove, BestScore)
        ;
            best_move_loop(Moves, Color, Depth, Alpha, Beta, CurrentMove, CurrentScore, BestMove, BestScore)
        )
    ;
        % Skip invalid moves
        best_move_loop(Moves, Color, Depth, Alpha, Beta, CurrentMove, CurrentScore, BestMove, BestScore)
    ).