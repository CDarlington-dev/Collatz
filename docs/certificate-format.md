# Paradoxical-segment finite certificate format

This package certifies an exhaustive finite statement for the accelerated map

\[
T(n)=\begin{cases}
n/2,&n\text{ even},\\
(3n+1)/2,&n\text{ odd}.
\end{cases}
\]

A row `(n,j,q,end)` in `hits.csv` means that `end = T^j(n)`, exactly `q` of
the first `j` iterates were odd, `3^q < 2^j`, and `end >= n`.  Starts 1 and 2
are outside the paradoxical-segment definition; the certificate covers them
only to make the arithmetic partition of `1..N` exact.

## Files

Running

```text
python tools/odd_core_scan.py --limit N --workers W --shards S --output-dir DIR
```

produces:

- `DIR/hits.csv`: the canonical complete hit list;
- `DIR/manifest.json`: global coverage, result, statistics, and shard metadata;
- `DIR/shards/shard-NNNNNN.json`: deterministic resumable computations;
- `DIR/SHA256SUMS`: SHA-256 hashes of the preceding files.

All JSON is ASCII, has lexicographically sorted keys, uses no insignificant
spaces, and ends in one LF byte.  `hits.csv` is ASCII, LF-terminated, sorted
lexicographically by `(n,j,q,end)`, and has the exact header:

```text
n,j,q,end
```

The output is deterministic for fixed source, `N`, and `S`; worker count and
completion order do not affect it.  A run reuses an existing shard only after
checking its format, exact assigned range, and payload hash.  `--no-resume`
forces recomputation without deleting unrelated files.

Version 1 shard payloads are self-hashed but do not embed the generator-source
hash.  Range/hash validation therefore detects interrupted or accidentally
corrupted shards, but it is not proof that a deliberately substituted shard was
computed by the recorded source.  A provenance-grade run should use
`--no-resume` from a known source revision and retain its console/runtime note;
the independent scalar replay below is still required to recompute the actual
classification.  Neither route turns the Python output into a Lean-kernel
theorem.

## Exact coverage semantics

Every positive integer has a unique factorization

\[
n=2^a u,\qquad u\text{ odd}.
\]

For an inclusive limit `N`, shard ranges partition the odd-core indices
`i = 0,...,(N+1)//2-1`, where `u=2*i+1`.  For each `u`, the scanner represents
exactly

\[
0\le a\le A(u)=\lfloor\log_2(N/u)\rfloor.
\]

Consequently, the sum of `represented_starts` across all shards must equal
`N`.  The combiner rejects the certificate if this identity or the contiguous
shard partition fails.

The initial `a` halvings from `2^a u` strictly decrease the value, so none can
end a paradoxical segment.  Starting at the odd core, define

\[
y_r=3x_r+1,\quad v_r=\nu_2(y_r),\quad
x_{r+1}=y_r/2^{v_r},\quad K_r=\sum_{i<r}v_i.
\]

The endpoints represented by odd block `r` are exactly

\[
y_r/2^s,\qquad 1\le s\le v_r.
\]

Thus every accelerated-`T` length after the initial halvings occurs in exactly
one checked block.  The scanner continues until `x_r=1`.  For a start greater
than 2, every later value in the trivial `(1,2)` cycle is below the start, so
there can be no omitted later hit.  If an orbit fails to reach 1, the scan does
not produce a completed shard and therefore cannot certify the range.

## Exact lattice test

Let `q=r+1` in the current odd block and define

```text
need(q) = bit_length(3^q).
```

This is computed with arbitrary-precision integers.  Since `3^q` is never a
power of two,

\[
3^q<2^J\quad\Longleftrightarrow\quad J\ge\operatorname{need}(q).
\]

For start `n=2^a u` and substep `s`, put `z=a+s`.  Its total length is
`J=K_r+z`.  With

\[
L=\lfloor\log_2(y_r/u)\rfloor,
\]

the endpoint condition is exact:

\[
y_r/2^s\ge 2^a u\quad\Longleftrightarrow\quad z\le L.
\]

Both paradoxical conditions and the bounds on `a,s` therefore reduce to the
following finite integer intervals:

```text
z_low  = max(1, need(q) - K_r)
z_high = min(L, A(u) + v_r)

for z in [z_low, z_high]:
    a_low  = max(0, z - v_r)
    a_high = min(A(u), z - 1)
    for a in [a_low, a_high]:
        s   = z - a
        n   = u * 2^a
        j   = K_r + z
        end = y_r / 2^s
```

There are no logarithmic floating-point evaluations: both `A` and `L` are
computed by integer bit lengths followed by an exact shifted comparison.

This proves that a successfully replayed empty portion of a shard establishes
absence there; the procedure is not merely a search that recognizes supplied
examples.

## Lean leaf checker

`Collatz/Certified/Finite/ClassificationCertificate.lean` proves the exact
kernel bridge used by a proof-producing form of the lattice scan.  An untrusted
`ScaledPrefixCell` supplies `(u,a,s,t,q,y)`.  Its Boolean checker independently
recomputes

```text
oddCount u (s+t) = q
y = 2^t * endpoint u (s+t)
```

and the theorem `ScaledPrefixCell.paradoxical_iff_lattice` then proves that the
authoritative Lean predicate at start `2^a*u` and length `a+s+t` is equivalent
to the four exact lattice inequalities.  `scannerCellBounds_iff` also proves
the scanner's `(z,a)` loop bounds enumerate exactly `0 <= a <= A`,
`1 <= t <= v`, and `z=a+t`.

This is a sound leaf checker, not a claim that the present shard hashes encode
all negative leaves.  To derive `FiniteBaseClassification 1000000000 ...`, a
future certificate must additionally give a kernel-checked trace to `1` for
every represented odd core, assign every relevant prefix to a checked cell,
and prove disjoint, gap-free odd-core/exponent coverage.  The package states
that missing layer explicitly rather than treating a digest as it.

## Shard payload

Each shard JSON has these semantic fields:

- identity: `format`, `map`, `limit`, `shard_count`, `shard_id`;
- coverage: `odd_index_start` (inclusive), `odd_index_stop` (exclusive),
  `first_odd`, `last_odd`, `odd_cores`, `represented_starts`;
- result: `hits`, a sorted list of objects with `n`, `j`, `q`, and `end`;
- exact run summaries: `odd_blocks`, `total_t_steps`, `max_delay`,
  `max_odd_steps`, and `max_state`;
- `core_summary_sha256`, the hash of canonical per-core summaries;
- `payload_sha256`, the hash of the canonical shard object before that field is
  added.

The hashes make interrupted and independently repeated runs comparable.  A
hash is not, by itself, a mathematical proof that a claimed empty range was
searched.  Absence is discharged by replaying all shards with the exact
scanner, or by the independent scalar verifier below.

## Independent verification

Run:

```text
python verifier/scalar_scan.py --limit N --hits DIR/hits.csv --workers W --shards S --checkpoint-dir REPLAY_DIR
```

The scalar verifier deliberately does **not** use odd-core factorization or the
lattice test.  For every integer `n=3,...,N`, it iterates `T` one step at a
time until 1 and tests the endpoint and exact `need(q)` condition at every
length.  It requires byte-for-byte canonical CSV and compares every computed
tuple with the supplied list.  Its `--max-steps` option is fail-closed: reaching
the cap rejects the run and can never turn an unverified orbit into an accepted
one.

When `--checkpoint-dir` is present, the scalar replay is crash-resumable.  Its
numeric partitions are independent of worker count.  Every completed shard is
written atomically as canonical ASCII JSON under
`REPLAY_DIR/shards/shard-NNNNNN.json`; an interrupted temporary file is never
accepted as a shard.  A saved shard binds all of the following into a
`payload_sha256` digest:

- the exact accelerated-map identifier and scalar-checker format version;
- SHA-256 of the exact scalar-verifier source that produced the shard;
- shard number, inclusive start, exclusive stop, and fail-closed step cap;
- the complete sorted hit list for that numeric interval;
- the exact number of represented starts and accelerated steps; and
- local maximum accelerated delay, ordinary delay, and state, each with its
  least attaining start.

On resume, the version-2 verifier reparses canonical JSON, recomputes the
payload digest, requires the embedded verifier-source hash to equal its own
source bytes, checks the assigned interval and all structural invariants, and
reuses only a valid shard.  An invalid or differently sourced saved shard is
reported and recomputed.  A successful
whole replay writes `REPLAY_DIR/manifest.json`, containing the hit-list and
verifier-source hashes plus every shard file and payload hash, and writes a
GNU-compatible `REPLAY_DIR/SHA256SUMS` over the manifest and all shards.
`--no-resume` forces every shard to be recalculated while preserving the same
deterministic partition.

Agreement between these two algorithmically different enumerations is strong
reproducibility evidence.  In a Lean development, the generic odd-block and
lattice equivalence lemmas can be kernel-checked, while the finite range result
should remain explicitly labelled a certificate computation unless the full
scan is evaluated by a trusted proof-producing mechanism.

## Record-bound certificate

`certificates/record-bounds-v1.json` records a finite domain, convergence
target, exact maximum state and least maximizing start, exact accelerated and
ordinary delays, and a strict excursion threshold.  Its manifest and hit-list
hashes bind the claim to one finite-scan certificate.  The standard-library
`verifier/reference.py` independently iterates every start in that domain to
`1`, checks every claimed extremum, and fails unless the maximum is strictly
below the stated threshold.  Thus a passing row with domain `0..seed-1`
discharges the finite proposition that every later accelerated iterate of
every start below `seed` stays below `threshold`; zero is fixed and the
post-convergence `(1,2)` cycle introduces no larger state.

This format can similarly carry an ordinary-delay cap, but the present package
does not pretend that a compact provenance row proves a huge external search.
An exhaustive Python replay is exact computational evidence, not by itself a
Lean-kernel proof of a universal proposition.  Large finite claims remain
explicit hypotheses until their coverage is accepted by a Lean-proved checker
whose successful decision is itself kernel-checked (or until direct proof terms
are supplied).

## Direct kernel interval certificates

For manageable domains, `Collatz/Certified/Finite/NoParadoxicalRange.lean`
uses a smaller proof-producing format with no external data parser.  A block
source fixes four integers—fuel, first start, number of starts, and the expected
Boolean value—and proves the value with ordinary `decide`.  The generic
soundness theorem checks, for every represented start, every accelerated prefix
through an exact visit to `1`; it rejects on fuel exhaustion.  Lean then proves
symbolically that later endpoints alternate between `1` and `2`, below every
allowed paradoxical start.  Aggregate modules prove that consecutive blocks
and any exact tail are gap-free and have the advertised inclusive endpoints.

The first-excursion format is analogous.  Its production optimized variant
checks a strict maximum bound only until a certified strict descent, then uses
strong induction on the start to cover all later iterates.  Starts in the
terminal set are proved separately.  The certificate includes reductions
showing that one less unit of fuel fails closed at the extremal start, the
chosen fuel succeeds, and a concrete orbit attains the claimed maximum.  Thus
neither stopping fuel nor maximum excursion is imported as a table claim.

For both formats, the mechanically generated Lean sources are the certificate
payload.  `SOURCE-SHA256SUMS` binds the generic checker, every block, exact
tail, aggregate, axiom audit, generator, and bounded-pair build driver.
`RUN.md` records the checked build and host.  A source hash establishes byte
identity; mathematical acceptance comes from the resulting proof terms being
checked by Lean's kernel and from an axiom audit that excludes the native
evaluation bridge.

## Circuit/LRAT certificate

`Collatz/Certified/Circuit/` provides a second proof-producing format for
symbolic finite claims:

1. a reducible, cache-free Boolean gate circuit;
2. the definitionally generated DIMACS CNF;
3. an LRAT refutation of that exact clause list; and
4. a Lean theorem connecting circuit evaluations to the mathematical
   accelerated map, with overflow exposed as a checked premise.

The `checked_lrat` elaborator reads the static DIMACS and LRAT files, rejects a
formula mismatch, and reconstructs Mathlib's explicit `Sat.Fmla.proof` term.
The resulting unsatisfiability theorem is checked by Lean's kernel; it does not
use `native_decide` or trust CaDiCaL's exit code.  The width-generic ripple
theorems prove exact natural-number addition and the exact accelerated
`T(n)`, not merely arithmetic modulo `2^w`; truncation is used only after a
proved false outgoing-overflow bit.

`certificates/circuit-demo/` is a complete small example over inputs 26 and
27.  Its CNF and LRAT hashes are recorded in its README.  The example proves
the checker pipeline and semantic bridge, but its tiny domain does **not**
discharge `FB-1`.  Scaling measurements and the precise proof-size bottleneck
are recorded in `notes/circuit-benchmarks.md`.
