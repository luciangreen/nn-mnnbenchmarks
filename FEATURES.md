# Features and usage

## Benchmark entry points

`benchmark.pl` exports these predicates:

| Predicate | Purpose |
|---|---|
| `mnn_nn_benchmark(+Algorithm, +Dataset, +Options, -Report)` | Run repeated trials, calculate metrics, save artifacts, and return a report dict. |
| `run_benchmark(+Algorithm, +Dataset, +Options)` | Run a benchmark and discard the returned report. |
| `research_benchmark(+Dataset, +Options, -Report)` | Run the algorithm named by an `mnn(Algorithm)` option. |
| `explain_result(+RunID, -Explanation)` | Retrieve the final-example explanation for a run in the current Prolog process. |
| `find_parallels(+Report, -Parallels)` | Infer structural/behavioral MNN-to-NN comparisons from a report. |
| `find_counterexamples(+Parallel, -Counterexamples)` | Return known limitations for an inferred comparison. |
| `verify_equivalence(+Original, +Candidate, +Examples, -Result)` | Compare two registered algorithms on examples from a registered test split. |
| `benchmark_regression(+OldReport, +NewReport, -Regression)` | Compare runtime, memory, and accuracy in two report dicts. |
| `publish_benchmark(+RunID, +Options)` | Invoke the current publication hook; see limitations below. |

Typical interactive use:

```prolog
?- mnn_nn_benchmark(rule_network_mnn, xor,
                    [runs(100), warmup(10), seed(12345)], Report).
?- explain_result(Report.run_id, Explanation).
?- benchmark_regression(Report, AnotherReport, Regression).
```

`research_benchmark/3` takes the algorithm from options, for example:

```prolog
?- research_benchmark(xor, [mnn(rule_network_mnn), runs(20)], Report).
```

## Registry

The registry is in `src/registry.pl`. It currently contains:

| Dataset | Inputs | Outputs |
|---|---|---|
| `xor` | Two-element binary vector | `0` or `1` |
| `and_gate` | Two-element binary vector | `0` or `1` |
| `route_simple` | Two-element binary vector | `left` or `right` |

| Algorithm ID | Module | Current implementation |
|---|---|---|
| `rule_network_mnn` | `algorithms/rule_network.pl` | XOR rule |
| `decision_tree_mnn` | `algorithms/decision_tree.pl` | XOR decision tree |
| `memoized_lookup_mnn` | `algorithms/memoized_lookup.pl` | Cached XOR lookup |
| `dependency_routing_mnn` | `algorithms/dependency_routing.pl` | Dependency-based route selection |

The examples are fixed in the registry and each listed dataset currently uses
the same examples for training and testing. The algorithms are hand-coded; the
harness does not train them from the registry examples. Only the XOR-specific
algorithms are intended to match `xor`; `dependency_routing_mnn` is intended
for `route_simple`. Results from other algorithm/dataset combinations are not
validated for meaningful accuracy.

## Trial and report contents

For each trial, the runner resets memoized state when applicable, evaluates all
test examples, and measures wall-clock time, CPU time, Prolog inferences, and
change in global-stack usage. Warmup trials are excluded from the reported
statistics. The report includes min/max/mean/median/population standard
deviation for these measurements, throughput, latency, output accuracy,
environment and run metadata, algorithm structure, final trace, explanation,
and imported NN reference metrics.

The report dict also contains `benchmark_id`, `algorithm_id`, `dataset`,
`implementation_version`, `git_commit`, `benchmark_metadata`,
`algorithm_metadata`, `options`, `timestamp`, `performance`, `structural`,
`output`, `optimization`, `complexity`, `nn_reference`, `parallels`,
`counterexamples`, `reproducibility`, `reproduction`, `last_trace`, and
`run_id`. `explain_result/2` stores the final example's detailed explanation
in process memory; it is not included as a separate report key.

Output metrics currently include accuracy, exact-match accuracy, correct/total
counts, error count, and deterministic consistency fields. `structure/1` for
each algorithm supplies counts such as predicates, branches, dependencies,
decision depth, and memoization entries. The environment records the SWI-Prolog
version, operating system, and architecture; CPU and machine memory are
currently reported as `unknown`.

The `optimization` report section is currently a baseline placeholder: its
before/after values are identical and it does not represent an optimization
experiment. Likewise, throughput and memory are measurements from this
Prolog process, not hardware-independent comparisons.

## Reference results

`adapters/nn_reference_results.csv` is loaded by `adapters/imported_csv.pl`.
`nn_adapter/2` describes the source and `nn_reference_result/3` returns the
training time, inference time, accuracy, precision, and recall for a dataset
and model. The checked-in values are static offline reference measurements;
this feature does not train or invoke an NN framework.

## Parallel discovery and counterexamples

`src/parallels.pl` infers three comparisons from structural fields:

- Memoization/cache behavior when `memoisation_entries` is positive.
- Conditional routing when `branch_count` is greater than one.
- Computation/dependency-graph structure when `dependency_count` is positive.

Each result includes a class, confidence, evidence source and list, benchmark
IDs, counterexamples, and limitations. The rules are heuristic templates, not
proofs of neural-network equivalence. `src/counterexamples.pl` supplies static
limitations for these comparison types.

## Verification and regression

`verify_equivalence/4` evaluates both registered algorithms for every input in
the provided `ex(Input, Expected)` list and returns `equivalent` or
`not_equivalent(Pairs)`. The example list must exactly match a registered
dataset's test split; arbitrary or partial example lists are not currently
accepted.

`benchmark_regression/3` returns percentage changes and boolean flags. Runtime
and memory flags trigger above 10%; the accuracy flag triggers for an accuracy
drop above one percentage point. A zero baseline runtime or memory reports a
zero percentage change.

## Output files

Each run gets an ID composed from algorithm, dataset, short Git commit, and
timestamp. The runner writes:

- `results/<run-id>.json` and `results/<run-id>.csv`
- `reports/<run-id>.md`
- `graphs/<run-id>.dot`

It also refreshes `results/all_results.json`, `results/all_results.csv`,
`BENCHMARKS.md`, and `PARALLELS.md`. Historical individual run files are
preserved; aggregate files carry forward the prior aggregate JSON entries and
append the current report.

The reproduction command in the JSON/Markdown report preserves runs, warmup,
and seed. Git commit identity and timestamps necessarily differ when it is
executed again.

## Publishing

`publish(true)` calls `publish_benchmark/2`, which currently prints a
confirmation-style message only. It does not publish to GitHub, create an
artifact, or use `pull_request_mode(true)` for any action. A real destination,
authentication model, and publication behavior remain to be implemented.

## Test command

```bash
swipl -q -s tests/test_benchmark.pl -g run_tests -t halt
```

The suite covers registry access, a report-producing run, parallel discovery,
XOR equivalence, CSV-backed reference metrics, and preservation of run options
in the reproduction command.
