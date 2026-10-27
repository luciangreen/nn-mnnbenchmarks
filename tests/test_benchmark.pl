:- begin_tests(mnn_nn_benchmarks).

:- use_module('../benchmark.pl').
:- use_module('../src/registry.pl').
:- use_module('../adapters/imported_csv.pl').


test(benchmark_registry_contains_xor) :-
    once(benchmark(xor, Meta)),
    memberchk(train_examples(4), Meta).


test(run_benchmark_generates_report) :-
    once(mnn_nn_benchmark(rule_network_mnn, xor, [runs(3), warmup(1), seed(42)], Report)),
    is_dict(Report),
    _ = Report.benchmark_id,
    _ = Report.performance,
    _ = Report.output,
    format(atom(JsonPath), 'results/~w.json', [Report.benchmark_id]),
    exists_file(JsonPath).


test(parallel_classification_present) :-
    once(mnn_nn_benchmark(memoized_lookup_mnn, xor, [runs(3), warmup(0), seed(7)], Report)),
    Report.parallels \= [].


test(verify_equivalence_xor_algorithms) :-
    dataset_examples(xor, _Train, Test),
    verify_equivalence(rule_network_mnn, decision_tree_mnn, Test, equivalent).


test(reference_results_are_imported_from_csv) :-
    nn_adapter(imported_csv, Adapter),
    sub_atom(Adapter.source, _, _, _, 'nn_reference_results.csv'),
    once(nn_reference_result(xor, reference_model, Reference)),
    Reference.accuracy =:= 1.0,
    Reference.training_time_ms =:= 1.1.


test(reproduction_command_preserves_run_options) :-
    once(mnn_nn_benchmark(rule_network_mnn, xor,
        [runs(2), warmup(0), seed(99)], Report)),
    once(sub_atom(Report.reproduction.command, _, _, _, 'runs(2),warmup(0),seed(99)')).

:- end_tests(mnn_nn_benchmarks).
