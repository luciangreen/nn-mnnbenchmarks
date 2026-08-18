:- module(parallels,
    [ find_parallels/2,
      candidate_parallel/2
    ]).

candidate_parallel(sparse_activation, selective_predicate_execution).
candidate_parallel(pruning, branch_elimination).
candidate_parallel(layer, predicate_stage).
candidate_parallel(weight, rule_score).
candidate_parallel(computation_graph, dependency_graph).
candidate_parallel(memoisation, activation_cache).
candidate_parallel(routing, conditional_activation).

find_parallels(BenchmarkResult, Parallels) :-
    Structural = BenchmarkResult.structural,
    findall(Parallel,
        inferred_parallel(Structural, BenchmarkResult, Parallel),
        Raw),
    sort(Raw, Parallels).

inferred_parallel(Structural, BenchmarkResult,
    parallel(memoisation, activation_cache,
        [ class(memory_parallel),
          confidence(0.82),
          evidence_source(empirical),
          evidence([runtime_reduction, repeated_subproblem]),
          benchmark_ids([BenchmarkResult.benchmark_id]),
          counterexamples([]),
          limitations([cache_warmup_cost])
        ])) :-
    get_dict(memoisation_entries, Structural, Entries),
    Entries > 0.

inferred_parallel(Structural, BenchmarkResult,
    parallel(routing, conditional_activation,
        [ class(routing_parallel),
          confidence(0.75),
          evidence_source(empirical),
          evidence([branch_selection, selective_execution]),
          benchmark_ids([BenchmarkResult.benchmark_id]),
          counterexamples([]),
          limitations([symbolic_conditions_not_gradient_based])
        ])) :-
    get_dict(branch_count, Structural, Branches),
    Branches > 1.

inferred_parallel(Structural, BenchmarkResult,
    parallel(computation_graph, dependency_graph,
        [ class(structural_parallel),
          confidence(0.7),
          evidence_source(conjecture),
          evidence([dependency_count]),
          benchmark_ids([BenchmarkResult.benchmark_id]),
          counterexamples([]),
          limitations([no_differentiable_weights])
        ])) :-
    get_dict(dependency_count, Structural, Dependencies),
    Dependencies > 0.
