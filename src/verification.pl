:- module(verification, [verify_equivalence/4]).

:- use_module(src/registry).
:- use_module(algorithms/rule_network, []).
:- use_module(algorithms/decision_tree, []).
:- use_module(algorithms/memoized_lookup, []).
:- use_module(algorithms/dependency_routing, []).

verify_equivalence(Original, Optimised, Tests, Result) :-
    test_dataset(Tests, Dataset),
    findall(OriginalOut-OptimisedOut,
        ( member(ex(Input,_), Tests),
          eval_algorithm(Original, Dataset, Input, OriginalOut),
          eval_algorithm(Optimised, Dataset, Input, OptimisedOut)
        ), Pairs),
    ( forall(member(A-B, Pairs), A == B) ->
        Result = equivalent
    ;
        Result = not_equivalent(Pairs)
    ).



eval_algorithm(Algorithm, Dataset, Input, Output) :-
    algorithm_module(Algorithm, Module),
    call(Module:evaluate(Dataset, Input, Output, _Trace, _Explanation)).

test_dataset(Tests, Dataset) :-
    dataset_examples(Dataset, _Train, Tests),
    !.
test_dataset(Tests, _) :-
    throw(error(domain_error(registered_dataset_test_split, Tests), verify_equivalence/4)).
