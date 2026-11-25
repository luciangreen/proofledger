% proofledger: an append-only, hash-chained record of proof results. Each entry holds its index,
% theorem, status (proved or failed), the previous entry's hash and its own hash, so changing any
% earlier entry breaks the chain from that point. status/3 gives a theorem's latest status.
%?- build([append_nil-proved, rev_rev-failed], L), verify(L).        % true
%?- build([t-proved], [entry(1, t, proved, P, H)]), first_bad([entry(1, t, failed, P, H)], I).   % I = 1
:- module(proofledger, [add/4, build/2, verify/1, first_bad/2, status/3, hash/2, head/2, verify/2]).
:- use_module(library(lists)).
:- use_module(library(apply)).

hash(T, H) :- term_to_atom(T, A), atom_codes(A, Cs), foldl([C, H0, H1]>>( H1 is (H0 * 131 + C) mod 1000000007 ), Cs, 7, H).

add(L, Thm, St, L2) :- length(L, N), I is N + 1, ( last(L, entry(_, _, _, _, P)) -> true ; P = 0 ), hash(e(I, Thm, St, P), H), append(L, [entry(I, Thm, St, P, H)], L2).
build(Items, L) :- foldl([T-S, L0, L1]>>add(L0, T, S, L1), Items, [], L).

% first_bad(+Ledger, -Index): the first entry whose index, link or hash is wrong.
first_bad(L, I) :- nth1(K, L, entry(I0, T, S, P, H)), ( K =:= 1 -> P0 = 0 ; K1 is K - 1, nth1(K1, L, entry(_, _, _, _, P0)) ), \+ ( I0 =:= K, P == P0, hash(e(K, T, S, P), H) ), !, I = K.
verify(L) :- \+ first_bad(L, _).

% A chain only shows tampering if its latest hash is kept where a forger cannot change it,
% because anyone can recompute every hash after an edit. head/2 gives the hash to publish
% (0 for an empty ledger); verify/2 checks the chain and that it ends at the published hash.
head(L, H) :- ( last(L, entry(_, _, _, _, H0)) -> H = H0 ; H = 0 ).
verify(L, Anchor) :- verify(L), head(L, Anchor).

status(L, Thm, St) :- reverse(L, R), memberchk(entry(_, Thm, St0, _, _), R), St = St0.
