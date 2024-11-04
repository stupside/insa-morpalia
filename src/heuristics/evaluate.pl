:- [center, sequence, threat].

% Evaluate position based on combined heuristics
evaluate_position(Color, Score) :-
    switch_player(Color, Opponent),

    % Sequence heuristic
    sequence_score(Color, MySeqScore),
    sequence_score(Opponent, OppSeqScore),

    % Center control heuristic
    center_score(Color, MyCenterScore),
    center_score(Opponent, OppCenterScore),

    % Threat detection heuristic
    threat_score(Color, MyThreatScore),
    threat_score(Opponent, OppThreatScore),

    % Combine the scores
    Score is (MySeqScore * 2) - (OppSeqScore * 3) +
            (MyCenterScore * 1.5) - (OppCenterScore * 1.5) +
            (MyThreatScore * 4) - (OppThreatScore * 5).
