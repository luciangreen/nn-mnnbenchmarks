:- module(memoized_lookup, [evaluate/5, structure/1, reset_cache/0]).

:- dynamic cache/2.

reset_cache :-
    retractall(cache(_, _)).

evaluate(_Dataset, Input, Output, Trace, Explanation) :-
    ( cache(Input, Output) ->
        Trace = [activated(cache_hit(Input))],
        MemoEntries = 1
    ;
        compute_xor(Input, Output),
        asserta(cache(Input, Output)),
        Trace = [activated(cache_miss(Input)), activated(store_cache(Input))],
        MemoEntries = 1
    ),
    Explanation = _{
        input: Input,
        active_rules: Trace,
        decision: Output,
        reason: "Memoized lookup reused prior activation result",
        memo_entries: MemoEntries
    }.

compute_xor([A,B], Output) :-
    (A =:= B -> Output = 0 ; Output = 1).

structure(_{
    predicate_count: 4,
    rule_count: 3,
    branch_count: 2,
    decision_depth: 2,
    recursion_depth: 0,
    dependency_count: 3,
    intermediate_values: 1,
    memoisation_entries: 1,
    index_accesses: 1,
    determinism: deterministic
}).
