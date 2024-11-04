% Center control scoring
center_score(Color, Score) :-
    findall(Weight, (
        pawn(X, _, Color),
        column_weight(X, Weight) % Assign a weight to each column
    ), Weights),
    sum_list(Weights, Score). % Sum the weights of the columns

column_weight(1, 1). % The center column is the most important
column_weight(2, 2). % The columns next to the center are the second most important
column_weight(3, 3). % The columns next to the second most important columns are the third most important
column_weight(4, 4). % The columns next to the third most important columns are the fourth most important
column_weight(5, 3). % The columns next to the fourth most important columns are the third most important
column_weight(6, 2). % The columns next to the third most important columns are the second most important
column_weight(7, 1). % The columns next to the second most important columns are the most important
