:- module(dependency_routing, [evaluate/5, structure/1]).

evaluate(route_simple, [A,B], Route, Trace, Explanation) :-
    ( A =:= 0 ->
        Route = left,
        Trace = [activated(router), activated(path_left), skipped(path_right)]
    ;
        Route = right,
        Trace = [activated(router), skipped(path_left), activated(path_right)]
    ),
    Explanation = _{
        input: [A,B],
        active_rules: Trace,
        decision: Route,
        reason: "Dependency-guided execution activated a routed branch"
    }.

evaluate(_Dataset, Input, Output, Trace, Explanation) :-
    evaluate(route_simple, Input, Output, Trace, Explanation).

structure(_{
    predicate_count: 4,
    rule_count: 2,
    branch_count: 2,
    decision_depth: 2,
    recursion_depth: 0,
    dependency_count: 2,
    intermediate_values: 1,
    memoisation_entries: 0,
    index_accesses: 0,
    determinism: deterministic
}).
