# nn-mnnbenchmarks

SWI-Prolog research and benchmarking system for exploring measurable parallels between Manual Neural Networks (MNNs) and neural-network (NN) reference models.

## Quick start

```bash
swipl -q -s benchmark.pl -g "run_benchmark(rule_network_mnn,xor,[runs(100),warmup(10),seed(12345)])" -t halt
```

## Main predicate

```prolog
mnn_nn_benchmark(+Algorithm, +Dataset, +Options, -Report).
```

Example:

```prolog
?- mnn_nn_benchmark(decision_tree_mnn, xor, [runs(1000)], Report).
```

## Included BASIC benchmarks

Algorithms:
- `rule_network_mnn`
- `decision_tree_mnn`
- `memoized_lookup_mnn`
- `dependency_routing_mnn`

Datasets:
- `xor`
- `and_gate`
- `route_simple`

Outputs are generated in:
- `results/<benchmark-id>.json`
- `results/<benchmark-id>.csv`
- `reports/<benchmark-id>.md`
- `graphs/<benchmark-id>.dot`
- aggregate files: `BENCHMARKS.md`, `PARALLELS.md`, `results/all_results.csv`, `results/all_results.json`

## Tests

```bash
swipl -q -s tests/test_benchmark.pl -g run_tests -t halt
```
