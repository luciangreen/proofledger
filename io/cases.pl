:- module(cases, [title/1, case/3]).
:- use_module('../prolog/proofledger').
:- use_module(engine).
title('proofledger').
items_g(Is) :- rnd_int(1, 6, N), length(Is, N), maplist([T-S]>>( rnd_pick([append_nil, rev_rev, sort_idem], T), rnd_pick([proved, proved, failed], S) ), Is).
case(build, [Is], build) :- items_g(Is).
case(status, [L, T], status) :- items_g(Is), build(Is, L), rnd_pick([append_nil, rev_rev, sort_idem], T).
case(first_bad, [L2], first_bad) :- items_g(Is), build(Is, L), length(L, N), rnd_int(1, N, K), nth1(K, L, entry(I, T, _, P, H), Rest), rnd_pick([proved, failed], S2), nth1(K, L2, entry(I, T, S2, P, H), Rest).
