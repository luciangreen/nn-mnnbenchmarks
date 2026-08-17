# Benchmark memoized_lookup_mnn-xor-c4b7099-20260817212446

- Algorithm: `memoized_lookup_mnn`
- Dataset: `xor`
- Accuracy: 1.00
- Wall clock mean (ms): 0.008424
- CPU mean (ms): 0.009092
- Inferences mean: 61.000000
- Reproduction command:
```bash
swipl -q -s benchmark.pl -g "run_benchmark(memoized_lookup_mnn,xor,[runs(3)])" -t halt
```
## Parallels
- `"parallel(computation_graph,dependency_graph,[class(structural_parallel),confidence(0.7),evidence_source(conjecture),evidence([dependency_count]),benchmark_ids(['memoized_lookup_mnn-xor-c4b7099-20260817212446']),counterexamples([]),limitations([no_differentiable_weights])])"`
- `"parallel(memoisation,activation_cache,[class(memory_parallel),confidence(0.82),evidence_source(empirical),evidence([runtime_reduction,repeated_subproblem]),benchmark_ids(['memoized_lookup_mnn-xor-c4b7099-20260817212446']),counterexamples([]),limitations([cache_warmup_cost])])"`
- `"parallel(routing,conditional_activation,[class(routing_parallel),confidence(0.75),evidence_source(empirical),evidence([branch_selection,selective_execution]),benchmark_ids(['memoized_lookup_mnn-xor-c4b7099-20260817212446']),counterexamples([]),limitations([symbolic_conditions_not_gradient_based])])"`
## Counterexamples
- `"counterexample(no_cache_benefit_on_unique_inputs)"`
- `"counterexample(symbolic_branching_not_soft_attention)"`
- `"counterexample(unification_and_backtracking_have_no_direct_nn_equivalent)"`
