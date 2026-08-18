:- module(runner,
    [ run_benchmark/4,
      explain_result/2
    ]).

:- use_module(library(option)).
:- use_module(library(random)).
:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(src/registry).
:- use_module(src/statistics, [summary/2]).
:- use_module(src/metrics).
:- use_module(src/parallels).
:- use_module(src/counterexamples).
:- use_module(src/reports).
:- use_module(src/publishing).
:- use_module(adapters/imported_csv).
:- use_module(algorithms/rule_network, []).
:- use_module(algorithms/decision_tree, []).
:- use_module(algorithms/memoized_lookup, []).
:- use_module(algorithms/dependency_routing, []).

:- dynamic stored_explanation/2.

run_benchmark(Algorithm, Dataset, Options, Report) :-
    must_be(atom, Algorithm),
    must_be(atom, Dataset),
    benchmark(Dataset, BenchmarkMeta),
    algorithm(Algorithm, AlgorithmMeta),
    stringify_terms(BenchmarkMeta, BenchmarkMetaText),
    stringify_terms(AlgorithmMeta, AlgorithmMetaText),
    option(runs(Runs), Options, 100),
    option(warmup(Warmup), Options, 10),
    option(seed(Seed), Options, 12345),
    set_random(seed(Seed)),
    dataset_examples(Dataset, _Train, Test),
    run_warmup(Algorithm, Dataset, Test, Warmup),
    run_trials(Algorithm, Dataset, Test, Runs, TrialStats, FinalOutputs, FinalTrace, FinalExplanation),
    extract_metrics(TrialStats, Test, FinalOutputs, Performance, OutputMetrics),
    algorithm_module(Algorithm, _Module),
    call_algorithm_structure(Algorithm, Structural),
    complexity(Algorithm, inference, Complexity),
    gather_env(Environment),
    now_iso(Timestamp),
    git_commit(Commit),
    benchmark_id(Algorithm, Dataset, Commit, Timestamp, BenchmarkID),
    reproduction_command(Algorithm, Dataset, Runs, Command),
    nn_reference_result(Dataset, reference_model, NNReference),
    stringify_terms(FinalTrace, FinalTraceText),
    BeforeRuntime = Performance.wall_clock_ms.mean,
    BeforeMemory = Performance.memory_bytes.mean,
    BeforeInferences = Performance.inferences.mean,
    Partial = _{
        benchmark_id: BenchmarkID,
        algorithm_id: Algorithm,
        implementation_version: 'basic-v1',
        git_commit: Commit,
        dataset: Dataset,
        benchmark_metadata: BenchmarkMetaText,
        algorithm_metadata: AlgorithmMetaText,
        options: _{runs:Runs,warmup:Warmup,seed:Seed},
        environment: Environment,
        timestamp: Timestamp,
        performance: Performance,
        structural: Structural,
        output: OutputMetrics,
        optimization: _{
            before_runtime: BeforeRuntime,
            after_runtime: BeforeRuntime,
            speedup: 1.0,
            before_memory: BeforeMemory,
            after_memory: BeforeMemory,
            before_inferences: BeforeInferences,
            after_inferences: BeforeInferences,
            structural_reduction: 0
        },
        complexity: _{theoretical:Complexity},
        nn_reference: NNReference,
        reproducibility: _{seed:Seed, command:Command},
        reproduction: _{command:Command},
        last_trace: FinalTraceText,
        run_id: BenchmarkID
    },
    parallels:find_parallels(Partial, ParallelTerms),
    collect_counterexamples(ParallelTerms, CounterexampleTerms),
    stringify_terms(ParallelTerms, Parallels),
    stringify_terms(CounterexampleTerms, Counterexamples),
    Report0 = Partial.put(_{parallels:Parallels, counterexamples:Counterexamples}),
    retractall(stored_explanation(BenchmarkID, _)),
    asserta(stored_explanation(BenchmarkID, FinalExplanation)),
    reports:save_result(BenchmarkID, Report0, _JsonPath, _CsvPath),
    reports:write_graph_dot(BenchmarkID, Structural),
    reports:update_aggregates(Report0),
    ( option(publish(true), Options) ->
        publishing:publish_benchmark(BenchmarkID, Options)
    ; true ),
    Report = Report0.

explain_result(RunID, Explanation) :-
    stored_explanation(RunID, Explanation).

run_warmup(_Algorithm, _Dataset, _Test, Warmup) :-
    Warmup =< 0, !.
run_warmup(Algorithm, Dataset, Test, Warmup) :-
    forall(between(1, Warmup, _), run_once(Algorithm, Dataset, Test, _Stats, _Predicted, _Trace, _Explanation)).

run_trials(Algorithm, Dataset, Test, Runs, TrialStats, FinalOutputs, FinalTrace, FinalExplanation) :-
    findall(pack(Stats,Predicted,Trace,Explanation),
        (between(1, Runs, _), run_once(Algorithm, Dataset, Test, Stats, Predicted, Trace, Explanation)),
        Packed),
    maplist(pack_stats, Packed, TrialStats),
    last(Packed, pack(_,FinalOutputs,FinalTrace,FinalExplanation)).

pack_stats(pack(Stats,_,_,_), Stats).

run_once(Algorithm, Dataset, Test, Stats, Predicted, Trace, Explanation) :-
    reset_algorithm_state(Algorithm),
    statistics(inferences, I0),
    statistics(cputime, C0),
    statistics(globalused, M0),
    get_time(W0),
    run_examples(Algorithm, Dataset, Test, Predicted, Trace, Explanation),
    get_time(W1),
    statistics(globalused, M1),
    statistics(cputime, C1),
    statistics(inferences, I1),
    WallMs is (W1 - W0) * 1000,
    CpuMs is (C1 - C0) * 1000,
    Inferences is I1 - I0,
    MemoryBytes is max(0, M1 - M0),
    Stats = _{wall_ms:WallMs, cpu_ms:CpuMs, inferences:Inferences, memory_bytes:MemoryBytes}.

run_examples(Algorithm, Dataset, Examples, Predicted, LastTrace, LastExplanation) :-
    findall(Output,
        ( member(ex(Input, _Expected), Examples),
          call_algorithm_evaluate(Algorithm, Dataset, Input, Output, _Trace, _Explanation)
        ),
        Predicted),
    last(Examples, ex(LastInput, _)),
    call_algorithm_evaluate(Algorithm, Dataset, LastInput, _LastOutput, LastTrace, LastExplanation).

call_algorithm_evaluate(Algorithm, Dataset, Input, Output, Trace, Explanation) :-
    algorithm_module(Algorithm, Module),
    call(Module:evaluate(Dataset, Input, Output, Trace, Explanation)).

call_algorithm_structure(Algorithm, Structure) :-
    algorithm_module(Algorithm, Module),
    call(Module:structure(Structure)).

reset_algorithm_state(memoized_lookup_mnn) :-
    memoized_lookup:reset_cache.
reset_algorithm_state(_).

extract_metrics(TrialStats, Test, FinalOutputs, Performance, OutputMetrics) :-
    findall(W, (member(S, TrialStats), W = S.wall_ms), Wall),
    findall(C, (member(S, TrialStats), C = S.cpu_ms), Cpu),
    findall(I, (member(S, TrialStats), I = S.inferences), Inf),
    findall(M, (member(S, TrialStats), M = S.memory_bytes), Mem),
    summary(Wall, WallSummary),
    summary(Cpu, CpuSummary),
    summary(Inf, InfSummary),
    summary(Mem, MemSummary),
    length(Test, ExampleCount),
    throughput(ExampleCount, WallSummary.mean, Throughput),
    Performance = _{
        wall_clock_ms: WallSummary,
        cpu_ms: CpuSummary,
        inferences: InfSummary,
        memory_bytes: MemSummary,
        peak_memory_bytes: MemSummary.max,
        throughput: Throughput,
        latency_ms: WallSummary.mean,
        repeated_run_variance: WallSummary.stddev
    },
    evaluate_outputs(FinalOutputs, Test, OutputMetrics).

gather_env(Environment) :-
    current_prolog_flag(version_data, swi(Major, Minor, Patch, _)),
    current_prolog_flag(arch, Arch),
    os_name(OS),
    Environment = _{
        swi_prolog_version: [Major,Minor,Patch],
        operating_system: OS,
        architecture: Arch,
        cpu: unknown,
        memory: unknown
    }.

os_name(OS) :-
    process_create(path(uname), ['-s'], [stdout(pipe(Out))]),
    read_string(Out, _, S),
    close(Out),
    normalize_space(string(OS), S), !.
os_name(unknown).

git_commit(Commit) :-
    process_create(path(git), ['rev-parse','HEAD'], [stdout(pipe(Out))]),
    read_string(Out, _, S),
    close(Out),
    normalize_space(string(C), S),
    atom_string(Commit, C), !.
git_commit('unknown').

now_iso(Timestamp) :-
    get_time(Now),
    format_time(atom(Timestamp), '%FT%TZ', Now).

benchmark_id(Algorithm, Dataset, Commit, Timestamp, BenchmarkID) :-
    sub_atom(Commit, 0, 7, _, Short),
    split_string(Timestamp, "-:TZ", "", Parts),
    atomic_list_concat(Parts, '', Compact),
    format(atom(BenchmarkID), '~w-~w-~w-~w', [Algorithm, Dataset, Short, Compact]).

reproduction_command(Algorithm, Dataset, Runs, Command) :-
    format(atom(Command),
        'swipl -q -s benchmark.pl -g "run_benchmark(~w,~w,[runs(~w)])" -t halt',
        [Algorithm, Dataset, Runs]).

collect_counterexamples(Parallels, Counterexamples) :-
    findall(C,
        ( member(P, Parallels),
          counterexamples:find_counterexamples(P, List),
          member(C, List)
        ), Raw),
    sort(Raw, Counterexamples).

stringify_terms(Terms, Strings) :-
    maplist(term_string, Terms, Strings).
