:- module(rule_network, [evaluate/5, structure/1]).

evaluate(_Dataset, Input, Output, Trace, Explanation) :-
    rule_network_predict(Input, Output, ActiveRules),
    Trace = [activated(input(Input))|ActiveRules],
    Explanation = _{
        input: Input,
        active_rules: ActiveRules,
        decision: Output,
        reason: "Rule conjunction/disjunction pattern selected the XOR class"
    }.

rule_network_predict([A,B], Output, [activated(rule_xor)]) :-
    (A =:= B -> Output = 0 ; Output = 1).

structure(_{
    predicate_count: 3,
    rule_count: 1,
    branch_count: 1,
    decision_depth: 1,
    recursion_depth: 0,
    dependency_count: 2,
    intermediate_values: 1,
    memoisation_entries: 0,
    index_accesses: 0,
    determinism: deterministic
}).
