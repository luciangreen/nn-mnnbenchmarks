:- module(registry,
    [ benchmark/2,
      dataset_examples/3,
      algorithm/2,
      complexity/3,
      algorithm_module/2,
      benchmark_ids/1,
      algorithm_ids/1
    ]).

benchmark(
    xor,
    [ input_type(binary_vector),
      output_type(binary_class),
      train_examples(4),
      test_examples(4)
    ]).
benchmark(
    and_gate,
    [ input_type(binary_vector),
      output_type(binary_class),
      train_examples(4),
      test_examples(4)
    ]).
benchmark(
    route_simple,
    [ input_type(binary_vector),
      output_type(route_label),
      train_examples(4),
      test_examples(4)
    ]).

dataset_examples(
    xor,
    [ex([0,0],0), ex([0,1],1), ex([1,0],1), ex([1,1],0)],
    [ex([0,0],0), ex([0,1],1), ex([1,0],1), ex([1,1],0)]).

dataset_examples(
    and_gate,
    [ex([0,0],0), ex([0,1],0), ex([1,0],0), ex([1,1],1)],
    [ex([0,0],0), ex([0,1],0), ex([1,0],0), ex([1,1],1)]).

dataset_examples(
    route_simple,
    [ex([0,0],left), ex([0,1],left), ex([1,0],right), ex([1,1],right)],
    [ex([0,0],left), ex([0,1],left), ex([1,0],right), ex([1,1],right)]).

algorithm(
    rule_network_mnn,
    [ family(mnn),
      implementation('algorithms/rule_network.pl'),
      deterministic(true)
    ]).
algorithm(
    decision_tree_mnn,
    [ family(mnn),
      implementation('algorithms/decision_tree.pl'),
      deterministic(true)
    ]).
algorithm(
    memoized_lookup_mnn,
    [ family(mnn),
      implementation('algorithms/memoized_lookup.pl'),
      deterministic(true)
    ]).
algorithm(
    dependency_routing_mnn,
    [ family(mnn),
      implementation('algorithms/dependency_routing.pl'),
      deterministic(true)
    ]).

algorithm_module(rule_network_mnn, rule_network).
algorithm_module(decision_tree_mnn, decision_tree).
algorithm_module(memoized_lookup_mnn, memoized_lookup).
algorithm_module(dependency_routing_mnn, dependency_routing).

complexity(rule_network_mnn, inference, 'O(rules)').
complexity(decision_tree_mnn, inference, 'O(depth)').
complexity(memoized_lookup_mnn, inference, 'O(1) average cached lookup').
complexity(dependency_routing_mnn, inference, 'O(branches)').

benchmark_ids(IDs) :-
    findall(ID, benchmark(ID, _), IDs).

algorithm_ids(IDs) :-
    findall(ID, algorithm(ID, _), IDs).
