:- dynamic best_move/2.

:- dynamic last_move_time/1.
:- asserta(last_move_time(0)).

% Opening book moves
opening_move([], 4).  % First move always in center
opening_move([4], 3). % Response to center
opening_move([3], 4). % Response to column 3
opening_move([5], 4). % Response to column 5

% AI move selection with opening book
ai(X, Y, Color) :-
    % Try opening book first
    findall(Col, pawn(Col, _, _), PlayedMoves),
    (opening_move(PlayedMoves, X) ->
        % Use book move if available
        column_height(X, Count),
        Y is Count + 1,
        make_move(X, Y, Color)
    ;
        % Otherwise use regular search
        get_time(StartTime),
        available_moves(Moves),
        (Moves = [] -> fail ; true),
        count_pieces(PieceCount),
        calculate_dynamic_depth(PieceCount, Color, BaseDepth),
        Alpha is -1000000,
        Beta is 1000000,
        best_move(Moves, Color, BaseDepth, Alpha, Beta, X, _),
        make_move(X, Y, Color),
        get_time(EndTime),
        TimeSpent is EndTime - StartTime,
        retractall(last_move_time(_)),
        asserta(last_move_time(TimeSpent))
    ).

% Optimize initial depth calculation
calculate_dynamic_depth(PieceCount, Color, Depth) :-
    base_game_phase_depth(PieceCount, BaseDepth),
    position_complexity_adjustment(Color, ComplexityAdj),
    time_pressure_adjustment(TimeAdj),
    InitialDepthLimit = 5,  % Limit initial search depth
    Depth is max(3, min(InitialDepthLimit, BaseDepth + ComplexityAdj + TimeAdj)).

% Modified base depth for faster early game
base_game_phase_depth(PieceCount, Depth) :-
    (PieceCount < 4 -> Depth = 4     % Very early game
    ; PieceCount < 8 -> Depth = 5    % Opening
    ; PieceCount < 16 -> Depth = 5   % Early game
    ; PieceCount < 28 -> Depth = 4   % Mid game
    ; Depth = 3).                    % End game

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
    last_move_time(LastTime),
    (LastTime > 2.0 -> Adjustment = -1     % Too slow
    ; LastTime < 0.5 -> Adjustment = 1     % Very fast
    ; Adjustment = 0).                     % Normal speed

% Debug evaluation of position
debug_eval(Move, Color) :-
    evaluate_position(Color, Score),
    write('Initial eval for move '), write(Move), 
    write(' color '), write(Color),
    write(' score '), write(Score), nl.

% Helper to find best scored move
best_scored_move(Scores, BestMove, BestScore) :-
    findall(Score-Move, member([Move, Score], Scores), ScoredMoves),
    keysort(ScoredMoves, Sorted),
    last(Sorted, BestScore-BestMove).

% Simplified negamax with better termination
negamax(0, Color, _, _, Score) :- !,
    evaluate_position(Color, Score).
negamax(_, _, _, _, Score) :-
    available_moves([]), !,  % Game is drawn
    Score = 0.
negamax(Depth, Color, Alpha, Beta, BestScore) :-
    Depth > 0,
    available_moves(Moves),
    Moves \= [], !,
    NewDepth is Depth - 1,
    negamax_moves(Moves, Color, NewDepth, Alpha, Beta, -1000000, BestScore).

% Simplified move processing
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

% Enhanced position evaluation
evaluate_position(Color, Score) :-
    switch_player(Color, Opponent),
    % Get sequence scores
    sequence_score(Color, MySeqScore),
    sequence_score(Opponent, OppSeqScore),
    % Get center control score
    center_control_score(Color, MyCenterScore),
    center_control_score(Opponent, OppCenterScore),
    % Get threat score
    threat_score(Color, MyThreatScore),
    threat_score(Opponent, OppThreatScore),
    % Combine scores with weights
    Score is (MySeqScore * 2) - (OppSeqScore * 3) +
            (MyCenterScore * 1.5) - (OppCenterScore * 1.5) +
            (MyThreatScore * 4) - (OppThreatScore * 5).

% Evaluate sequences with better scoring
sequence_score(Color, Score) :-
    findall(S, (
        pawn(X, Y, Color),
        direction(DX, DY),
        count_both_direction(X, Y, DX, DY, Color, Length),
        sequence_value(Length, S)
    ), Scores),
    sum_list(Scores, Score).

% Value of sequences based on length
sequence_value(Length, Score) :-
    (Length >= 4 -> Score = 100000
    ; Length = 3 -> Score = 1000
    ; Length = 2 -> Score = 100
    ; Score = 10).

% Center control scoring
center_control_score(Color, Score) :-
    findall(Weight, (
        pawn(X, _, Color),
        column_weight(X, Weight)
    ), Weights),
    sum_list(Weights, Score).

% Column weights favoring center positions
column_weight(1, 1).
column_weight(2, 2).
column_weight(3, 3).
column_weight(4, 4). % Center column has highest weight
column_weight(5, 3).
column_weight(6, 2).
column_weight(7, 1).

% Enhanced threat detection
threat_score(Color, Score) :-
    findall(ThreatValue, (
        pawn(X, Y, Color),
        direction(DX, DY),
        threat_value(X, Y, DX, DY, Color, ThreatValue)
    ), Threats),
    sum_list(Threats, Score).

% Calculate threat value for a position
threat_value(X, Y, DX, DY, Color, Value) :-
    count_both_direction(X, Y, DX, DY, Color, Count),
    NextX1 is X + (DX * Count),
    NextY1 is Y + (DY * Count),
    PrevX is X - DX,
    PrevY is Y - DY,
    (is_empty_and_playable(NextX1, NextY1),
     is_empty_and_playable(PrevX, PrevY) ->
        Value is Count * Count * 100
    ; is_empty_and_playable(NextX1, NextY1) ->
        Value is Count * 50
    ; is_empty_and_playable(PrevX, PrevY) ->
        Value is Count * 50
    ; Value = 0).

% Check if position is empty and playable
is_empty_and_playable(X, Y) :-
    within_board(X, Y),
    \+ pawn(X, Y, _),
    (Y = 1 ; Y1 is Y - 1, pawn(X, Y1, _)).

% Simplified best move selection
best_move(Moves, Color, Depth, Alpha, Beta, BestMove, BestScore) :-
    best_move_loop(Moves, Color, Depth, Alpha, Beta, nil, -1000000, BestMove, BestScore),
    BestMove \= nil, !.  % Ensure we found a valid move

% More robust best move loop
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

% Helper predicate for max of list
max_list([X], X) :- !.
max_list([H|T], Max) :-
    max_list(T, TMax),
    Max is max(H, TMax).