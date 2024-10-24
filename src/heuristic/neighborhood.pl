h_neighborhood(X, Y, Color, Count) :- 
    neighborhood(X, Y, 1, 0, Color, C1), % right
    neighborhood(X, Y, -1, 0, Color, C2), % left
    h_neighborhood_valuate(C1, C2, Value1),

    neighborhood(X, Y, 0, 1, Color, C3), % up % redundant
    neighborhood(X, Y, 0, -1, Color, C4), % down
    h_neighborhood_valuate(C3, C4, Value2),

    neighborhood(X, Y, 1, -1, Color, C5), % diagonal top-right to bottom-left
    neighborhood(X, Y, -1, 1, Color, C6), % diagonal bottom-left to top-right
    h_neighborhood_valuate(C5, C6, Value3),

    neighborhood(X, Y, 1, 1, Color, C7), % diagonal top-left to bottom-right
    neighborhood(X, Y, -1, -1, Color, C8), % diagonal bottom-right to top-left
    h_neighborhood_valuate(C7, C8, Value4),

    maximizer(Color, Multiplier),

    Count is Multiplier * (Value1 + Value2 + Value3 + Value4).

h_neighborhood_valuate(C1, C2, Value) :- 
    ( 
        C1 + C2 > 3 -> Value is 10000
    ; 
        C1 + C2 == 3 -> Value is 1000
    ; 
        C1 + C2 == 2 -> Value is 100
    ; 
        C1 + C2 == 1 -> Value is 10
    ; 
        Value is 0
    ).
