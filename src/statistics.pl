:- module(statistics, [summary/2]).

summary([], _{min:0,max:0,mean:0,median:0,stddev:0}).
summary(Values, Summary) :-
    msort(Values, Sorted),
    Sorted = [Min|_],
    last(Sorted, Max),
    length(Sorted, N),
    sum_list(Sorted, Sum),
    Mean is Sum / N,
    median(Sorted, Median),
    variance(Sorted, Mean, Var),
    Stddev is sqrt(Var),
    Summary = _{min:Min, max:Max, mean:Mean, median:Median, stddev:Stddev}.

median(Sorted, Median) :-
    length(Sorted, N),
    Mid is N // 2,
    ( 0 is N mod 2 ->
        nth0(Mid, Sorted, A),
        Mid0 is Mid - 1,
        nth0(Mid0, Sorted, B),
        Median is (A + B) / 2
    ;
        nth0(Mid, Sorted, Median)
    ).

variance([], _, 0).
variance(Values, Mean, Var) :-
    findall(D2,
        (member(V, Values), D is V - Mean, D2 is D * D),
        Squares),
    sum_list(Squares, SumSquares),
    length(Values, N),
    Var is SumSquares / N.
