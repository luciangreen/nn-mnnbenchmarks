:- module(counterexamples, [find_counterexamples/2]).

find_counterexamples(parallel(memoisation, activation_cache, _),
    [counterexample(no_cache_benefit_on_unique_inputs)]).
find_counterexamples(parallel(routing, conditional_activation, _),
    [counterexample(symbolic_branching_not_soft_attention)]).
find_counterexamples(parallel(computation_graph, dependency_graph, _),
    [counterexample(unification_and_backtracking_have_no_direct_nn_equivalent)]).
find_counterexamples(_, []).
