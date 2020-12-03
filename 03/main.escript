%%  Neat:
%%  - Binary pattern matching
%%  - Partial patterns
%%
%%  Messy:
%%  - 1-indexed list access (0-indexed [nth_tail]) !?
%%  - No pipe operation / partial application

%% -----------------------------------------------------------------------------

parse_row(<<>>) -> {[], 0};
parse_row(<<H,T/binary>>) ->
    X = case H of $# -> 1; $. -> 0 end,
    {Xs, Count} = parse_row(T),
    {[X|Xs], Count + 1}.

read_input() ->
    {ok, Data} = file:read_file("./input.txt"),
    Lines = binary:split(Data, [<<"\n">>], [global]),
    Nonempty = lists:filter(fun (S) -> not (string:is_empty(S)) end, Lines),
    lists:map(fun parse_row/1, Nonempty).

%% -----------------------------------------------------------------------------

drop(0, L) -> L;
drop(_, []) -> [];
drop(N, [_|T]) -> drop(N-1, T).

count_hits(D, T) -> count_hits(D, T, 0).
count_hits(_, [], _) -> 0;
count_hits({Dx, Dy}, [{Trees,Count}|_] = Forest, X_pos) ->
    Hit = lists:nth(X_pos rem Count + 1, Trees),
    Hit + count_hits({Dx, Dy}, drop(Dy, Forest), X_pos + Dx).

product(L) -> lists:foldl(fun (A, B) -> A * B end, 1, L).

main(_) ->
    Forest = read_input(),

    Part1 = count_hits({3, 1}, Forest),
    io:fwrite("--- Part One ---\n~p\n\n", [Part1]),

    TreeCounts = lists:map(fun (D) -> count_hits(D, Forest) end, [ {1,1}, {3,1}, {5,1}, {7,1}, {1,2} ]),
    Part2 = product(TreeCounts),
    io:fwrite("--- Part Two ---\n~p\n\n", [Part2]).
