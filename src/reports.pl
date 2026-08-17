:- module(reports,
    [ save_result/4,
      update_aggregates/1,
      write_graph_dot/2
    ]).

:- use_module(library(http/json)).
:- use_module(library(csv)).
:- use_module(library(filesex)).

save_result(BenchmarkID, Result, JsonPath, CsvPath) :-
    ensure_dirs,
    format(atom(JsonPath), 'results/~w.json', [BenchmarkID]),
    format(atom(CsvPath), 'results/~w.csv', [BenchmarkID]),
    format(atom(MdPath), 'reports/~w.md', [BenchmarkID]),
    atom_json_dict(JsonAtom, Result, []),
    setup_call_cleanup(open(JsonPath, write, JOut), write(JOut, JsonAtom), close(JOut)),
    write_single_csv(CsvPath, Result),
    write_markdown_report(MdPath, Result).

update_aggregates(NewResult) :-
    ensure_dirs,
    all_result_dicts(Dicts),
    append(Dicts, [NewResult], Combined),
    sort(Combined, Unique),
    atom_json_dict(JsonAtom, Unique, []),
    setup_call_cleanup(open('results/all_results.json', write, JOut), write(JOut, JsonAtom), close(JOut)),
    write_all_results_csv('results/all_results.csv', Unique),
    write_benchmarks_md('BENCHMARKS.md', Unique),
    write_parallels_md('PARALLELS.md', Unique).

write_graph_dot(BenchmarkID, Structural) :-
    ensure_dirs,
    format(atom(Path), 'graphs/~w.dot', [BenchmarkID]),
    Branches = Structural.branch_count,
    setup_call_cleanup(open(Path, write, Out),
        ( format(Out, 'digraph mnn {~n', []),
          format(Out, '  input -> predicate_stage_1;~n', []),
          forall(between(1, Branches, I), format(Out, '  predicate_stage_1 -> branch_~w;~n', [I])),
          format(Out, '  predicate_stage_1 -> output;~n', []),
          format(Out, '}~n', [])
        ),
        close(Out)).

ensure_dirs :-
    make_directory_path('results'),
    make_directory_path('reports'),
    make_directory_path('graphs').

all_result_dicts(Dicts) :-
    ( exists_file('results/all_results.json') ->
        setup_call_cleanup(open('results/all_results.json', read, In),
            json_read_dict(In, Dicts0),
            close(In)),
        ( is_list(Dicts0) -> Dicts = Dicts0 ; Dicts = [] )
    ;
        Dicts = []
    ).

write_single_csv(Path, Result) :-
    BenchmarkID = Result.benchmark_id,
    AlgorithmID = Result.algorithm_id,
    Dataset = Result.dataset,
    WallMean = Result.performance.wall_clock_ms.mean,
    Accuracy = Result.output.accuracy,
    Row = row(BenchmarkID, AlgorithmID, Dataset, WallMean, Accuracy),
    csv_write_file(Path, [row(benchmark_id, algorithm_id, dataset, wall_clock_mean_ms, accuracy), Row], []).

write_all_results_csv(Path, Results) :-
    findall(row(BenchmarkID, AlgorithmID, Dataset, WallMean, Accuracy),
        ( member(R, Results),
          BenchmarkID = R.benchmark_id,
          AlgorithmID = R.algorithm_id,
          Dataset = R.dataset,
          WallMean = R.performance.wall_clock_ms.mean,
          Accuracy = R.output.accuracy
        ), Rows),
    csv_write_file(Path, [row(benchmark_id, algorithm_id, dataset, wall_clock_mean_ms, accuracy)|Rows], []).

write_markdown_report(Path, Result) :-
    Algorithm = Result.algorithm_id,
    Dataset = Result.dataset,
    Accuracy = Result.output.accuracy,
    WallMean = Result.performance.wall_clock_ms.mean,
    CpuMean = Result.performance.cpu_ms.mean,
    InfMean = Result.performance.inferences.mean,
    ReproCommand = Result.reproduction.command,
    setup_call_cleanup(open(Path, write, Out),
        ( format(Out, '# Benchmark ~w~n~n', [Result.benchmark_id]),
          format(Out, '- Algorithm: `~w`~n', [Algorithm]),
          format(Out, '- Dataset: `~w`~n', [Dataset]),
          format(Out, '- Accuracy: ~2f~n', [Accuracy]),
          format(Out, '- Wall clock mean (ms): ~6f~n', [WallMean]),
          format(Out, '- CPU mean (ms): ~6f~n', [CpuMean]),
          format(Out, '- Inferences mean: ~6f~n', [InfMean]),
          format(Out, '- Reproduction command:~n', []),
          format(Out, '```bash~n~w~n```~n', [ReproCommand]),
          format(Out, '## Parallels~n', []),
          forall(member(P, Result.parallels), format(Out, '- `~q`~n', [P])),
          format(Out, '## Counterexamples~n', []),
          forall(member(C, Result.counterexamples), format(Out, '- `~q`~n', [C]))
        ),
        close(Out)).

write_benchmarks_md(Path, Results) :-
    setup_call_cleanup(open(Path, write, Out),
        ( format(Out, '# BENCHMARKS~n~n', []),
          format(Out, '| Benchmark ID | Algorithm | Dataset | Wall mean (ms) | Accuracy |~n', []),
          format(Out, '|---|---|---:|---:|---:|~n', []),
          forall(member(R, Results),
            ( BenchmarkID = R.benchmark_id,
              AlgorithmID = R.algorithm_id,
              Dataset = R.dataset,
              WallMean = R.performance.wall_clock_ms.mean,
              Accuracy = R.output.accuracy,
              format(Out, '| ~w | ~w | ~w | ~6f | ~2f |~n',
                [BenchmarkID, AlgorithmID, Dataset, WallMean, Accuracy])
            ))
        ),
        close(Out)).

write_parallels_md(Path, Results) :-
    setup_call_cleanup(open(Path, write, Out),
        ( format(Out, '# PARALLELS~n~n', []),
          forall(member(R, Results),
            ( format(Out, '## ~w~n', [R.benchmark_id]),
              forall(member(P, R.parallels), format(Out, '- `~q`~n', [P])) ))
        ),
        close(Out)).
