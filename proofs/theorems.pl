% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/proofledger').

% Domain: every ledger of 1..4 results over theorems t1, t2 with status proved or failed.
items(Is) :- between(1, 4, N), length(Is, N), maplist([T-S]>>( member(T, [t1, t2]), member(S, [proved, failed]) ), Is).

% 1. A built ledger verifies.
theorem(built_verifies) :- forall(items(Is), ( build(Is, L), verify(L) )).

% 2. Changing any entry's theorem or status is caught at that entry.
theorem(tamper_detected) :- forall(( items(Is), build(Is, L), nth1(K, L, entry(I, T, S, P, H)), member(T2-S2, [t1-proved, t1-failed, t2-proved, t2-failed]), T2-S2 \== T-S ), ( nth1(K, L, _, Rest), nth1(K, L2, entry(I, T2, S2, P, H), Rest), first_bad(L2, K) )).

% 3. Adding keeps the earlier entries as they were.
theorem(append_only) :- forall(( items(Is), build(Is, L), member(T-S, [t1-proved, t2-failed]) ), ( add(L, T, S, L2), append(L, [_], L2), verify(L2) )).

% 4. A theorem's status is the one most recently recorded.
theorem(latest_status) :- forall(( items(Is), build(Is, L), member(T, [t1, t2]) ), ( reverse(Is, R), ( memberchk(T-S, R) -> status(L, T, S) ; \+ status(L, T, _) ) )).
