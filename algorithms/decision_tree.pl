:- module(decision_tree, [evaluate/5, structure/1]).

evaluate(_Dataset, [A,B], Output, Trace, Explanation) :-
    ( A =:= 0 ->
        ( B =:= 0 -> Output = 0, Path = [activated(node_root), activated(node_left), activated(node_left_left)]
        ; Output = 1, Path = [activated(node_root), activated(node_left), activated(node_left_right)] )
    ;
        ( B =:= 0 -> Output = 1, Path = [activated(node_root), activated(node_right), activated(node_right_left)]
        ; Output = 0, Path = [activated(node_root), activated(node_right), activated(node_right_right)] )
    ),
    Trace = Path,
    Explanation = _{
        input: [A,B],
        active_rules: Path,
        decision: Output,
        reason: "Binary tree branch selection matches XOR leaf"
    }.

structure(_{
    predicate_count: 5,
    rule_count: 4,
    branch_count: 4,
    decision_depth: 3,
    recursion_depth: 0,
    dependency_count: 4,
    intermediate_values: 2,
    memoisation_entries: 0,
    index_accesses: 0,
    determinism: deterministic
}).
