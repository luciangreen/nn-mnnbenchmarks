:- module(regression, [benchmark_regression/3]).

benchmark_regression(Old, New, Regression) :-
    RuntimeOld = Old.performance.wall_clock_ms.mean,
    RuntimeNew = New.performance.wall_clock_ms.mean,
    MemoryOld = Old.performance.memory_bytes.mean,
    MemoryNew = New.performance.memory_bytes.mean,
    AccOld = Old.output.accuracy,
    AccNew = New.output.accuracy,
    runtime_percent(RuntimeOld, RuntimeNew, RuntimePct),
    runtime_percent(MemoryOld, MemoryNew, MemoryPct),
    AccuracyDrop is (AccOld - AccNew) * 100,
    ( RuntimePct > 10 -> RuntimeFlag = true ; RuntimeFlag = false ),
    ( MemoryPct > 10 -> MemoryFlag = true ; MemoryFlag = false ),
    ( AccuracyDrop > 1 -> AccuracyFlag = true ; AccuracyFlag = false ),
    Regression = _{
        runtime_regression_percent: RuntimePct,
        memory_regression_percent: MemoryPct,
        accuracy_regression_percent: AccuracyDrop,
        runtime_regression_flag: RuntimeFlag,
        memory_regression_flag: MemoryFlag,
        accuracy_regression_flag: AccuracyFlag
    }.

runtime_percent(0, _, 0) :- !.
runtime_percent(Old, New, Pct) :-
    Pct is ((New - Old) / Old) * 100.
