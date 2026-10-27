:- module(imported_csv, [nn_adapter/2, nn_reference_result/3]).

:- use_module(library(csv)).
:- use_module(library(filesex)).

nn_adapter(imported_csv, _{
    source: Source,
    note: "Reference NN metrics loaded from the CSV file"
}) :-
    reference_csv_path(Source).

nn_reference_result(Dataset, Model, Result) :-
    reference_csv_path(Path),
    csv_read_file(Path, [_Header|Rows], [functor(row), convert(true)]),
    member(row(Dataset, Model, TrainingTime, InferenceTime, Accuracy, Precision, Recall), Rows),
    Result = _{
        training_time_ms: TrainingTime,
        inference_time_ms: InferenceTime,
        accuracy: Accuracy,
        precision: Precision,
        recall: Recall,
        notes: "Imported from adapters/nn_reference_results.csv"
    }.

reference_csv_path(Path) :-
    source_file(imported_csv:nn_adapter(_,_), SourceFile),
    file_directory_name(SourceFile, AdapterDirectory),
    directory_file_path(AdapterDirectory, 'nn_reference_results.csv', Path).
