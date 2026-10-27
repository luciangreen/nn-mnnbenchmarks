# nn-mnnbenchmarks

An SWI-Prolog research harness for measuring small Manual Neural Network (MNN)
implementations and comparing their structure and behavior with imported neural
network (NN) reference results. The included datasets and algorithms are
deterministic, hand-authored examples; this is not a neural-network training
framework.

## Requirements and setup

- SWI-Prolog 9.x (the GitHub Actions workflow currently uses the Ubuntu package).
- Run commands from the repository root; generated benchmark artifacts are
  written relative to the current working directory.

On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install swi-prolog-nox
```

## Run a benchmark

```bash
swipl -q -s benchmark.pl -g "run_benchmark(rule_network_mnn,xor,[runs(100),warmup(10),seed(12345)])" -t halt
```

The public report-producing predicate is `mnn_nn_benchmark/4`:

```prolog
?- mnn_nn_benchmark(decision_tree_mnn, xor,
                    [runs(1000), warmup(10), seed(12345)], Report).
```

It returns a report dict and writes JSON, CSV, Markdown, and DOT artifacts.
Options are `runs(N)` (default `100`), `warmup(N)` (default `10`), `seed(N)`
(default `12345`), and `publish(true)` to invoke the current publication hook.
For a reproducible invocation, the report includes a command preserving all
three run options.

## Test

Run the complete PlUnit suite:

```bash
swipl -q -s tests/test_benchmark.pl -g run_tests -t halt
```

Tests invoke benchmarks and therefore write generated files under `results/`,
`reports/`, and `graphs/`, and refresh aggregate reports in the repository root.
The GitHub Actions workflow runs this suite and a small seeded sample benchmark
on pushes and pull requests.

## Documentation

See [FEATURES.md](FEATURES.md) for the API, algorithms, metrics, generated
artifacts, and known limitations. [PROGRAM_REQUIREMENTS.md](PROGRAM_REQUIREMENTS.md)
tracks implemented and remaining work. Current benchmark samples are in
[BENCHMARKS.md](BENCHMARKS.md), with inferred comparisons in [PARALLELS.md](PARALLELS.md).
