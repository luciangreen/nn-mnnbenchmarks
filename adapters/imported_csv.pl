:- module(imported_csv, [nn_adapter/2, nn_reference_result/3]).

nn_adapter(imported_csv, _{
    source: 'adapters/nn_reference_results.csv',
    note: "Reference NN metrics imported from static dataset"
}).

nn_reference_result(xor, reference_model, _{
    training_time_ms: 1.1,
    inference_time_ms: 0.02,
    accuracy: 1.0,
    precision: 1.0,
    recall: 1.0,
    notes: "Tiny MLP reference trained offline"
}).

nn_reference_result(and_gate, reference_model, _{
    training_time_ms: 1.0,
    inference_time_ms: 0.02,
    accuracy: 1.0,
    precision: 1.0,
    recall: 1.0,
    notes: "Tiny MLP reference trained offline"
}).

nn_reference_result(route_simple, reference_model, _{
    training_time_ms: 0.8,
    inference_time_ms: 0.02,
    accuracy: 1.0,
    precision: 1.0,
    recall: 1.0,
    notes: "Reference routing classifier"
}).
