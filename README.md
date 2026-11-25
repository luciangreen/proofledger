# proofledger

an append-only, hash-chained record of proof results. Each entry holds its index, theorem, status (proved or failed), the previous entry's hash and its own hash, so changing any earlier entry breaks the chain from that point. status/3 gives a theorem's latest status.

## Use

```prolog
?- use_module(prolog/proofledger).
?- build([append_nil-proved, rev_rev-failed], L), verify(L).        % true
?- build([append_nil-proved], L), head(L, A).    % A is the hash to publish; later, verify(L, A) checks against it
?- build([t-proved], [entry(1, t, proved, P, H)]), first_bad([entry(1, t, failed, P, H)], I).   % I = 1
```

## Proofs

`proofs/theorems.pl` proves 5 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every ledger of 1..4 results over theorems t1, t2 with status proved or failed.

1. A built ledger verifies.
2. Changing any entry's theorem or status is caught at that entry.
3. Adding keeps the earlier entries as they were.
4. A theorem's status is the one most recently recorded.
5. With the latest hash published, a forger who changes an entry and rebuilds the whole chain is still caught by verify/2.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.

The hash is a short polynomial hash, which catches accidents and, with a published head hash, a rebuilt chain. It is not a cryptographic hash: for protection against deliberate collisions, use a hash such as SHA-256 from SWI-Prolog's library(crypto).
