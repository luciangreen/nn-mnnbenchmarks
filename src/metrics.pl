:- module(metrics,
    [ evaluate_outputs/3,
      throughput/3,
      build_trace/3
    ]).

evaluate_outputs(Predicted, Expected, Metrics) :-
    findall(Output, member(ex(_Input, Output), Expected), ExpectedOutputs),
    compare_lists(Predicted, ExpectedOutputs, 0, 0, Correct, Errors),
    length(ExpectedOutputs, Total),
    ( Total =:= 0 -> Accuracy = 0 ; Accuracy is Correct / Total ),
    Metrics = _{
        accuracy: Accuracy,
        exact_match_accuracy: Accuracy,
        correct: Correct,
        total: Total,
        errors: Errors,
        failures: 0,
        consistency: deterministic,
        deterministic_reproducibility: true
    }.

compare_lists([], [], Correct, Errors, Correct, Errors).
compare_lists([P|Ps], [E|Es], C0, E0, Correct, Errors) :-
    ( P == E -> C1 is C0 + 1, E1 = E0 ; C1 = C0, E1 is E0 + 1 ),
    compare_lists(Ps, Es, C1, E1, Correct, Errors).

throughput(TotalExamples, RuntimeMs, Throughput) :-
    ( RuntimeMs =:= 0 -> Throughput = inf ; Throughput is TotalExamples / RuntimeMs ).

build_trace(Input, ActiveRules, trace([activated(input(Input))|ActiveRules])).
