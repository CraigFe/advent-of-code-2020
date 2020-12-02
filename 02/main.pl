% -*- Mode: Prolog -*-
:- [library(dcg/basics)].
:- [library(pure_input)].
:- [library(clpfd)].

% ------------------------------------------------------------
%  Define the definite clause grammar (DCG) of the input file
% ------------------------------------------------------------

line(policy(C,N1-N2)/Pass) -->
    integer(N1), "-", integer(N2), " ", [C], ": ", string(Pass).

lines([])           --> call(eos), !.
lines([Line|Lines]) --> line(Line), "\n", lines(Lines).

% ------------------------------------------------------------

% count(P, L, N) holds iff there are exactly N elements satisfying P in L.
count(_, [], 0).
count(Pred, [H|T], N) :- call(Pred, H), !, count(Pred, T, N_1), N is N_1 + 1.
count(Pred, [_|T], N) :- count(Pred, T, N).

% Interpret `policy(C, L-U)` as "Require between L and U occurrences of C".
cardinal(policy(_, L-U), []    , N) :- N >= L, N =< U.
cardinal(policy(C, L-U), [C|CS], N) :- N < U, N_1 is N + 1, cardinal(policy(C, L-U), CS, N_1).
cardinal(policy(C, R), [C_|CS], N)  :- dif(C, C_), cardinal(policy(C, R), CS, N).
cardinal(T/S) :- cardinal(T, S, 0).

% Interpret `policy(C, I1-I2)` as "Exactly one char at position I1 or I2 is C".
positional(policy(C, I1-I2)/S) :-
    nth1(I1,S,N1),
    nth1(I2,S,N2),
    (N1 #= C) #\ (N2 #= C).

main :-
    phrase_from_file(lines(Data), 'input.txt'),
    count(cardinal, Data, N1),
    write(["Part 1", N1]), nl,
    count(positional, Data, N2),
    write(["Part 2", N2]), nl.
