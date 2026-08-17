:- module(benchmark,
    [ mnn_nn_benchmark/4,
      run_benchmark/3,
      research_benchmark/3,
      explain_result/2,
      publish_benchmark/2,
      find_parallels/2,
      find_counterexamples/2,
      verify_equivalence/4,
      benchmark_regression/3
    ]).

:- use_module(src/runner, [run_benchmark/4]).
:- use_module(src/parallels, [find_parallels/2]).
:- use_module(src/counterexamples, [find_counterexamples/2]).
:- use_module(src/publishing, [publish_benchmark/2]).
:- use_module(src/verification, [verify_equivalence/4]).
:- use_module(src/regression, [benchmark_regression/3]).

mnn_nn_benchmark(Algorithm, Dataset, Options, Report) :-
    runner:run_benchmark(Algorithm, Dataset, Options, Report).

run_benchmark(Algorithm, Dataset, Options) :-
    mnn_nn_benchmark(Algorithm, Dataset, Options, _).

research_benchmark(Dataset, Options, Report) :-
    member(mnn(Algorithm), Options),
    mnn_nn_benchmark(Algorithm, Dataset, Options, Report).

explain_result(RunID, Explanation) :-
    runner:explain_result(RunID, Explanation).
