# Circuit-certificate feasibility benchmarks

Evidence label: **engineering benchmark, not a theorem used by the exclusion**.

These runs were made on 2026-08-27 on the Windows/Ryzen 7 260 host described
in `notes/runtime.md`, using Lean 4.32.1, Mathlib's bit-vector circuit
generator, CaDiCaL 2.1.2, and LRAT output.  They measure whether a SAT proof is
a credible replacement for `FB-1`; no number below is imported as a
mathematical assumption.

## Aggregate-prefix encoding

The formula has a symbolic 30-bit start, a 64-bit exact accelerated state,
an explicit odd counter, range checks, and no-wrap checks.  It asks for a
paradoxical prefix among the first `k` steps.

| Domain / fuel | Variables / clauses | CNF bytes | LRAT bytes | Result |
|---|---:|---:|---:|---|
| `4615..10^9`, 1 | 1,153 / 2,955 | 36,355 | 8,732 | UNSAT; Lean 8.301 s |
| `4615..10^9`, 8 | 17,385 / 47,675 | 738,570 | 25,831,181 | UNSAT; Lean 18.265 s |
| `2^29..10^9`, 8 | 17,332 / 47,516 | 735,663 | 4,268,688 | UNSAT; Lean 11.794 s |
| `2^29..10^9`, 16 | 36,081 / 99,273 | 1,624,451 | 23,679,353 | UNSAT; Lean 23.377 s |

The full-domain 16-step run was stopped after 176 solver seconds with a
429,109,248-byte incomplete LRAT file.  A 32-step high-half run and an aligned
`2^20`-wide 32-step shard were stopped after about two minutes with incomplete
proofs above 400 MB.  Those incomplete files were deleted.  Consequently an
all-prefix unroll to the observed 616-step finite delay is not a viable
certificate design.

## Affine-capped exact pair

`Collatz.AffineBound.start_bound_of_paradoxical` reduces the first remaining
case to exactly

```text
j = 27, q = 17, 4615 <= n <= 26017.
```

With equality `q=17` implemented by a Boolean ripple counter, the exact case
had 59,282 variables, 163,748 clauses, and a 2,742,847-byte CNF.  CaDiCaL
proved UNSAT in 23.647 seconds and emitted a 53,833,627-byte raw LRAT proof;
the stock `bv_check` replay took 103.660 seconds.

This stock theorem is **not kernel-pure**: its axiom audit contains the
generated BVDecide native-reflection axiom.  It is deliberately absent from
the production theorem chain.  The production checker in
`Collatz/Certified/Circuit/` demonstrates an axiom-clean LRAT route on a small
exact accelerated-map circuit, but the 27-step stock formula has not been
transported through that checker.

Principal benchmark hashes:

```text
bv-collatz-k001.cnf                         57ee600bedf0186396cf9309d82b0682f2930d1bb2e91eaa0972028a16ddcd72
bv-collatz-k001.lrat                        1cd9862079c2e459169a42cfc9ed81d160d40ff2d94c15fcde7e1a3fd620fd33
bv-collatz-k008.cnf                         4a0c97e42feb92717182232ece8937413ffa0ce66dd7c3de7ad8a0934863e06e
bv-collatz-k008.lrat                        30941d238a706a99b5f073c035c51c44fdb7f9abf21717b87c46e67847e66c5e
bv-collatz-k008-hi.cnf                      ab92e7a9d782f58a50e2c98b5dcd887b1ace9d4927414c61d6b632bb1fc5c92e
bv-collatz-k008-hi.lrat                     c0eeec76a053c540967f0e30ba7663dc25c47a89e5d76f7b18e5aec1df391bab
bv-collatz-k016-hi.cnf                      2630c7ad6ddafaf31c00003e8f3a58ccc0591d2a532e81c2a8e74eb9c481ad89
bv-collatz-k016-hi.lrat                     2a15195a2a252ce9dd934e0552c3cf573164929ab73489cf6d3b8cd8fe5bfa31
bv-collatz-at027-q17-capped.cnf             69bc9c9a4536e3d9b0602c893336588ca95eacb17ad135c8f956a31959add33e
bv-collatz-at027-q17-capped-external.lrat   026b0d5e78696984e3ecccc616d9ffe797c0c696f79faca7e3f08e08502bc894
```

## Viability conclusion

The only credible SAT direction is affine preprocessing into exact `(j,q)`
cases with their exact start caps, followed by stronger residue splitting.
Even the first measured case uses 53.8 MB of raw proof.  Through length 616,
the universal affine filter leaves 107,599 pairs above start 4614 (90,260 at
the `10^9` threshold), so uncompressed per-pair LRAT is not package-credible.
The missing ingredient is a stronger arithmetic/residue cover that shares
work across those pairs; a verified LRAT checker alone does not supply that
compression.
