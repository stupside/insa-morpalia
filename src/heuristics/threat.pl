% Threat detection
threat_score(Color, Score) :-
    findall(ThreatValue, (
        pawn(X, Y, Color),
        direction(DX, DY),
        threat_value(X, Y, DX, DY, Color, ThreatValue)
    ), Threats),
    sum_list(Threats, Score).

% Calculate the value of a threat
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
