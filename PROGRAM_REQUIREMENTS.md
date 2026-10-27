# Program requirements and implementation status

The project implements a basic SWI-Prolog MNN/NN benchmarking loop. "Implemented"
means the feature is present in the current repository; it does not imply
production-grade coverage or external NN training/integration.

| # | Requirement | Status | Notes |
|---|---|---|---|
| 1 | Benchmark and algorithm registries | Implemented | Fixed registry in `src/registry.pl`; datasets and algorithms are listed in [FEATURES.md](FEATURES.md). |
| 2 | Benchmark execution (`mnn_nn_benchmark/4`) | Implemented | Repeated deterministic evaluation with `runs/1`, `warmup/1`, and `seed/1` options. |
| 3 | Repeated timing and inference statistics | Implemented | Wall, CPU, inferences, and global-stack delta summaries; environment hardware fields remain unknown. |
| 4 | Structural measurements and execution traces | Implemented | Hand-authored per-algorithm structure and trace data. |
| 5 | NN reference adapter import | Implemented (static CSV) | `nn_reference_results.csv` is parsed at query time; there is no framework runner or live model import. |
| 6 | Parallel discovery (`find_parallels/2`) | Partial | Structural heuristics generate candidate parallels, not empirically validated equivalence claims. |
| 7 | Counterexample reporting (`find_counterexamples/2`) | Partial | Static limitation templates; no automatic search or dataset-derived counterexamples. |
| 8 | JSON/CSV/Markdown results and aggregate reports | Implemented | Individual and aggregate output files are produced per benchmark run. |
| 9 | Historical run preservation | Implemented | Individual files use algorithm/dataset/commit/timestamp IDs. |
| 10 | Publishing hook (`publish_benchmark/2`) | Stub | Prints a message only; no external publishing is performed. |
| 11 | Equivalence verification (`verify_equivalence/4`) | Partial | Compares registered algorithms over an exact registered test split. |
| 12 | Regression comparison (`benchmark_regression/3`) | Implemented (basic) | Fixed thresholds; no CI gate, baseline store, or statistical significance check. |

## Remaining work

1. Implement and test a real publishing backend, after selecting a destination
   and credential strategy.
2. Expand datasets and algorithms; algorithms currently contain fixed
   hand-authored behavior and are not trained from examples.
3. Replace heuristic parallel/counterexample templates with measured evidence
   and automated counterexample discovery.
4. Broaden equivalence verification to arbitrary example sets and add stronger
   coverage for failure, invalid input, and algorithm/dataset compatibility.
5. Add durable regression baselines, configurable thresholds, and CI failure
   policy; the current report comparison is descriptive only.
6. Improve hardware/environment capture and benchmark methodology before using
   performance values for cross-machine conclusions.

For feature details, API signatures, caveats, and runnable commands, see
[FEATURES.md](FEATURES.md) and [README.md](README.md).
