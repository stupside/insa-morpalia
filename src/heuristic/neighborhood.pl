h_neighborhood(X, Y, Color, Value) :-
    neighborhood(X, Y, 1, 0, Color, C1), neighborhood(X, Y, -1, 0, Color, C2), h_neighborhood_valuate(C1, C2, Value1),
    neighborhood(X, Y, 0, 1, Color, C3), neighborhood(X, Y, 0, -1, Color, C4), h_neighborhood_valuate(C3, C4, Value2),
    neighborhood(X, Y, 1, -1, Color, C5), neighborhood(X, Y, -1, 1, Color, C6), h_neighborhood_valuate(C5, C6, Value3),
    neighborhood(X, Y, 1, 1, Color, C7), neighborhood(X, Y, -1, -1, Color, C8), h_neighborhood_valuate(C7, C8, Value4),

    maximizer(Color, Multiplier),

    TotalValue is Value1 + Value2 + Value3 + Value4,
    
    Value is Multiplier * TotalValue.

h_neighborhood_valuate(C1, C2, Value) :-
    ( C1 + C2 > 3 -> Value is 10000
    ; C1 + C2 =:= 3 -> Value is 1000
    ; C1 + C2 =:= 2 -> Value is 100
    ; C1 + C2 =:= 1 -> Value is 10
    ; Value = 0).
