:- module(publishing, [publish_benchmark/2]).

publish_benchmark(BenchmarkID, Options) :-
    ( member(pull_request_mode(true), Options) -> true ; true ),
    format('publish_benchmark(~w): generated benchmark artifacts for publication.~n', [BenchmarkID]).
