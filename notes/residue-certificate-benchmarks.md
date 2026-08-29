# Residue-certificate compression benchmarks

Evidence label: **exact design experiment, not a theorem in the exclusion
chain**.  These measurements explain why the completed `10^9` scalar scans
cannot yet be converted into a package-sized Lean certificate by a simple
residue tree.

## Sound leaf rules tested

For a prefix of accelerated length `k`, odd count `q`, original start `n`, and
current state `x = T^k(n)`, the strict-descent leaf

```text
x < n  and  2^k <= 3^q
```

is compatible with strong induction on the start.  If a later prefix became
globally contracting and then returned to at least `n`, its tail from the
smaller state `x` would itself be paradoxical.  On starts `26018..100000`,
however, this produced 4,425,641 nodes and exactly 73,983 singleton leaves:
no interval compression.

The stronger exact tail profile was

```text
F_x(k,q) = max { T^s(x) : 3^(q + oddCount(x,s)) < 2^(k+s) }.
```

After earlier prefixes are checked, `F_x(k,q) < n` is the exact tail-closing
condition.  A future Lean checker could recompute each queried profile from a
finite, fail-closed trace to `1`.

| Start range | Tree nodes | Leaves | Exact point-profile queries | Maximum depth |
|---|---:|---:|---:|---:|
| `26018..100000` | 233,084 | 22,975 | 73,511 | 154 |
| `26018..1000000` | 8,343,614 | 579,041 | 956,448 | 235 |
| `100000000..100999999` | 41,282,516 | 991,995 | 0 pointwise; 991,995 global leaves | 364 |

Allowing unrestricted point-profile queries lowered the first two leaf counts
only to 16,451 and 562,090, while still requiring 73,593 and 956,720 point
queries.  The proof workload remains essentially linear in the number of
starts.

An even smaller state summary records only monotone maximum-excursion changes.
There are 19 such changes below `113383`, ending at the exact maximum
`785412368`.  It compressed the tail data but not the coverage tree:

| Start range | Tree nodes | Leaves | Singleton leaves | Maximum depth |
|---|---:|---:|---:|---:|
| `26018..100000` | 1,416,330 | 65,114 | 62,803 | 197 |
| `26018..1000000` | 20,293,056 | 922,107 | 901,476 | 256 |
| `100000000..100999999` | 35,512,602 | 976,448 | 967,180 | 363 |

## Why fixed parity residues become singletons

The kernel-proved affine bound makes the first possible length `35` above
start `26017`, `40` above `100000`, `46` above `10^6`, and `65` above
`10^8`.  Since `2^35 > 10^9`, fixing the parity residue of any potentially
paradoxical prefix already identifies at most one start in the remaining
finite interval.  The affine filter removes short lengths but cannot itself
share the later proof work.  Through observed accelerated length `616`, it
leaves 104,702 admissible `(j,q)` pairs above start `26017`.

## Narrow missing invariant

A sublinear residue certificate needs a relational tail summary that preserves
the correlation between original and tail states, for example a verified
affine-cylinder inequality of the form

```text
forall t in [L,H],
  F_(A*t+B)(k,q) < 2^k*t + r.
```

State-only profiles, global excursion envelopes, bucket maxima, and first
descent discard this correlation and degenerate to nearly one leaf per start.
The alternatives are therefore a proof-producing relational-profile/DAG
certificate with a genuine domination rule, or a global non-residue proof such
as the kernel-verified CNF/LRAT route described in `notes/circuit-benchmarks.md`.

Exact prototype sources and SHA-256 values:

```text
prototypes/finite_base_certificate/analyze_inductive_residue_tree.py
  9b274eaba6be39b75fadce2fe54dde2d16c88a63744e9f09c19d897b56af1785
prototypes/finite_base_certificate/analyze_excursion_tail_tree.py
  43a6c665c5a7f413dd20638d07229892285d94300d822c9641b4158ea79204b0
prototypes/finite_base_certificate/analyze_filtered_tail_tree.py
  0ad8b9101d4efa7179165603b236d940e8fa494d1df09474b7673ed6e3269e09
```
