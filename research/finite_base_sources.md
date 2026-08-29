# Finite-base classification source and certificate audit

Audit date: 2026-08-27  
Scope: the proposition

```lean
Collatz.RecordBounds.FiniteBaseClassification
  1000000000 Collatz.Certified.PublishedClassification
```

This note concerns only the finite paradoxical-segment classification. It does
not treat the large ordinary-delay computation except where a delay bound would
be needed to terminate an alternative finite classifier.

## Result of the source search

**No public artifact located in this audit establishes exhaustive coverage
through `n <= 10^9`.** The Rozier--Terracol source contains the 593 positive
rows but no search code, raw negative-coverage table, log, certificate, runtime,
or hardware description. Tong Niu's withdrawn 2026 source contains a useful
fixed-length formula and two Python scripts, but its complete enumerator is
exponential in the length and is explicitly used only through length 18. For
lengths 27--92, its second script only rechecks the already supplied positive
rows. The input table and the trajectory enumerator claimed to have searched
through `10^7` are absent from the source archive.

The repository now contains two completed, exhaustive, exact-arithmetic
computations through inclusive `10^9`: an odd-core/lattice scan and an
algorithmically independent scalar replay of every start and every prefix up to
the first exact visit to `1`.  Both return exactly the 593 published rows.  This
is strong independently replayable computational evidence, but it is not yet a
kernel-replayed proof: neither output supplies the complete trace and gap-free
coverage data accepted by the Lean classification checker.

## Exact Lean semantics

The definition in `Collatz/RecordBounds.lean` expands to

```lean
∀ {n j : ℕ}, n ≤ 1000000000 →
  (Collatz.Paradoxical n j ↔
    Collatz.Certified.PublishedClassification n j)
```

where `PublishedClassification n j` means

```lean
n ≤ 4614 ∧ j ≤ 92 ∧
  ∃ w ∈ publishedWitnesses, w.n = n ∧ w.j = j.
```

The underlying predicate is

```lean
2 < n ∧ 0 < j ∧
3 ^ oddCount n j < 2 ^ j ∧
n ≤ endpoint n j
```

with

```text
T(n) = n/2          when n is even
T(n) = (3*n+1)/2    when n is odd.
```

`oddCount n j` counts the odd **inputs** at indices `0,...,j-1`, and
`endpoint n j = T^j(n)`. Both inequalities in paradoxicality have the same
strictness as Rozier--Terracol: `3^q < 2^j` and `T^j(n) >= n`. The bound
`n <= 10^9` is inclusive.

The universal Lean proposition also mentions `n=0,1,2`. These starts are
immediately non-paradoxical because of `2 < n`, and none occurs in the
published list. For `n>2`, a finite scan may stop at the first visit to `1`:
all later accelerated iterates are in the cycle `(1,2)`, hence are strictly
below `n`. A purported exhaustive table which merely imposes a length cutoff,
without a certified visit to `1` or another proof about the tail, does not
establish the Lean proposition.

Lean does not assume convergence and does not silently discard hypothetical
nontrivial cycles. A segment with `n>2` and `T^j(n)=n` is covered by the
non-strict endpoint test and must be found or ruled out. Accordingly, an
exhaustive checker must be fail-closed: if a covered start does not reach `1`
within its certified computation, that shard is rejected rather than treated
as having no further hits. Zero is separately harmless because `T(0)=0` and
the definition requires `n>2`.

A complete exact scan producing precisely the bundled 593 `(n,j)` pairs has
the required semantic consequence:

1. every reported row satisfies the four decidable Lean conditions;
2. every `Paradoxical n j` with `3 <= n <= 10^9` occurs before the certified
   first visit to `1`, so an exhaustive per-step or proved-equivalent lattice
   scan must report it;
3. starts `0,1,2` discharge separately.

This is an equivalence claim, not merely validation of Appendix C.

## Rozier--Terracol artifacts

Primary references:

- [arXiv:2502.00948v5](https://arxiv.org/abs/2502.00948v5), revised
  2026-05-17;
- [version-pinned TeX source](https://arxiv.org/src/2502.00948v5);
- [journal DOI](https://doi.org/10.1016/j.disc.2026.115167).

The version-pinned source archive was downloaded without modification. Its
SHA-256 is

```text
2502.00948v5.tar.gz
9951C89DA83B3E226E277585642B8BFC28D3410E9964904C51ABDBD384663AB6
```

Its complete payload is only:

```text
00README.json       216 bytes
four_posets.pdf   10132 bytes
Paradox.tex       63644 bytes
```

Relevant extracted-file hashes are

```text
Paradox.tex
C3AA692D3E2C4CA0F55AC6A3F433FD23170ACC7BBB6841B5BE9C42B9D76B05FA

four_posets.pdf
658108FA21460CE4A18F26F8B76806F21230B910CD1A56EE51C777A33A055E24
```

The paper states that the authors "conducted a computational search for all"
paradoxical sequences starting at most `10^9` and reports exactly 593. Appendix
C supplies their complete **positive list**. Neither the prose nor the source
archive specifies the program, algorithm, search termination criterion,
machine, runtime, compiler, raw output, domain partition, or a negative
coverage certificate. Thus Appendix C permits exact witness checking but does
not independently establish that no row was omitted.

The semantic match of the stated claim is otherwise exact:

- the paper's `T` is the same accelerated map as Lean's `T`;
- its `q` counts odd terms among `n,T(n),...,T^(j-1)(n)`;
- its coefficient and endpoint tests are strict `<` and non-strict `>=`;
- the searched start bound is inclusive.

One typesetting hazard should not be propagated into a checker: the Table 1
caption prints the reciprocal expression `2^j/3^q`, while Definition 1.1, the
affine formula, the surrounding prose, and the numerical decimals use the
intended coefficient `3^q/2^j`.

The [author's publication page](https://www.ipgp.fr/~rozier/publi.html) links
the article but, as of the audit date, lists no associated Collatz dataset.
Crossref metadata retrieved from
`https://api.crossref.org/works/10.1016/j.disc.2026.115167` has an empty
`relation` object and no dataset or supplement link. The retrieved metadata is
9239 bytes with SHA-256

```text
27F05CC78DEDF5C0BBE5A69C5FD244CD5B0E71F109A1B57965DBF84CA10FA8AC
```

These negative metadata observations do not prove that private or
not-yet-indexed author files do not exist; they establish only that no such
public artifact was found at the primary locations searched.

The arXiv v5 license is CC BY-NC-ND 4.0. The archive was used from an ignored
research cache; no copy was added to this repository.

## Tong Niu's fixed-length enumerator

Primary references:

- [arXiv:2605.13886v1](https://arxiv.org/abs/2605.13886v1), submitted
  2026-05-11;
- [version-pinned v1 source](https://arxiv.org/src/2605.13886v1);
- [withdrawal notice in v2](https://arxiv.org/abs/2605.13886v2).

Version 2 says the paper was withdrawn because the Rozier--Terracol v4
enumeration already contained the numerical observation. The v1 source remains
valuable for its parity-residue formula, but it is not a `10^9` certificate.

The v1 source archive has SHA-256

```text
2605.13886v1.tar.gz
C6CF7FDF13516848295DE264FD89BE93622EFB8971A2BE1E355F6E97EBCF45BD
```

and its complete payload is

```text
00README.json             220 bytes
length_k_paradox.py      9788 bytes
paper_arxiv.tex         22774 bytes
verify_affine.py         3427 bytes
```

File hashes are

```text
length_k_paradox.py
64FB12FB6960253182FF76E38A426F7A2A63A9AE0B67809F65D52E07BCA70D01

verify_affine.py
506D1C668E3C4E908C9C81687531D037807F1858FE3049D181050A8498927842

paper_arxiv.tex
41518DCE0E743746634077CF77019A5606A56053A6517E9BA3C6B5A112EE0B65
```

### What the code proves when exhaustively run

For a fixed length `k`, the parity map gives one residue class modulo `2^k`
for every word `w`. On that class,

```text
T^k(n) = (3^q / 2^k) * n + r_w.
```

When `3^q < 2^k`, the endpoint test is therefore the exact rational inequality

```text
n <= r_w * 2^k / (2^k - 3^q).
```

This formula is a sound basis for a fixed-parity certificate, and it matches
Lean's accelerated map, odd-input count, strict coefficient test, and
non-strict endpoint test. The script uses Python arbitrary-precision integers
and `Fraction`, not floating point, for the decisive tests.

There are small representation differences which a formal importer must make
explicit:

- the theorem text chooses the residue representative in `[1,2^k]`, while the
  script simulates representatives in `[0,2^k)`;
- the script starts its requested interval at `n_min=2` and explicitly removes
  the trivial representatives, whereas Lean uses `n>2`;
- Niu phrases the definition as acyclic and as not revisiting the trivial
  cycle, while Lean and Rozier--Terracol retain hypothetical nontrivial cyclic
  segments; the Python code keeps endpoint equality except for its special
  handling of representatives `1` and `2`;
- the script's opening docstring writes `(3^q*n+r_w)/2^k`, although its code
  and theorem correctly use `(3^q/2^k)*n+r_w` (equivalently the numerator is
  `3^q*n + 2^k*r_w`).

These differences do not invalidate its five length-8 rows, but they must not
be copied informally into a verified checker.

### Why it is not the needed certificate

`all_parity_class_representatives(k)` explicitly simulates all `2^k` residues
and stores a dictionary of all parity words. The paper says this is feasible
through `k=18` and explicitly says direct word enumeration for
`k in {27,46,54,65,73,92}` is infeasible. It then verifies the affine identity
only for the 593 pairs found by a separate simulation. Positive-row checking
cannot prove negative coverage.

An exact replay on this host was:

```text
python length_k_paradox.py --k-max 18 --n-max 1000000000 --out-dir niu-run
```

It completed in 4.05 seconds and found five pairs at length 8 and zero at all
other lengths through 18. Output SHA-256 values were

```text
length_k_paradox_bound_kmax18.csv
211E7C331EE38FEF69FED966E60C8F2C0BA12BD234C346851121C57BD037EC7D

length_k_paradox_breakdown_kmax18.csv
42E60502603E4E28F13259ECFD7D7F86C3695A0F8C473F2ABA907B6F39984963
```

The archive omits both the `compute_table.py` program referenced in the
docstring and the claimed input `data/paradoxical_le10000000.csv`.
Consequently, `verify_affine.py` fails immediately with `FileNotFoundError` on
a clean extraction. The claimed complete simulation through `10^7` is not
replayable from the archived source.

The v1 arXiv record uses arXiv's non-exclusive distribution license, which
grants distribution rights to arXiv rather than a clear general software
license. No copy of these scripts was committed here; the hashes and retrieval
commands identify the public originals.

## Other public reproduction located

[Riku-Tono/reproduction_paradoxical-sequence](https://github.com/Riku-Tono/reproduction_paradoxical-sequence)
was inspected at commit
[`00212bef0169e0a0fae42e355950f3ba25034013`](https://github.com/Riku-Tono/reproduction_paradoxical-sequence/commit/00212bef0169e0a0fae42e355950f3ba25034013).
Its `rt_pure_reproduction.py` has SHA-256

```text
5E7610872AD776EFBDCC5F5910DDB6DBBBDBD816E766CA32152748A4FD492F27
```

The script iterates only the Appendix C input rows and confirms that all 593
are witnesses. Its own README describes the work as finite-sample and not a
proof. It supplies no scan of the remaining starts through `10^9` and therefore
does not address the missing direction of `FiniteBaseClassification`. The
repository has no license file at the pinned commit, so no source was copied
into this project.

## Completed local computations through `10^9`

### Optimized odd-core/lattice scan

`tools/odd_core_scan.py`, SHA-256
`8E2E3C853FAB300F7DB8ABF6ED2C8D5BC6D3DF4A1243C6937FECA3FBC084E296`,
factors each start uniquely as `n=2^a*u`, follows each odd core's odd-to-odd
orbit, and uses exact integer lattice inequalities for every intermediate
accelerated endpoint.  A clean `--no-resume` run covered all 500,000,000 odd
cores representing every start `1 <= n <= 10^9`.  It completed in approximately
6,751 seconds and produced:

```text
paradoxical rows                    593
distinct paradoxical starts        550
maximum paradoxical start           4614
odd-core blocks              34,969,255,812
accelerated steps             69,762,619,290

hits.csv
9A4DB72C9C5AB79EDA689F42A15D92ED5100ABCEEE566442B9579A0894D0A37A

manifest.json
1418AD38B73CC223D745477F6751E66D64CE5AEC9D2B45C58A87DA4CF813F505

SHA256SUMS
3483E9CC639D434536E9EF50B775674241C8D4C6168C5108B57C011567CEB1D7

RUN.md
FC018B786B6736FCE32B225EC7190E167941DA909336A9AB84A67632751C59A3
```

The clean run used no prior shard.  A later replay parsed all 4,096 shards,
validated their payload hashes, parameters, and exact assigned intervals, and
regenerated byte-identical aggregate files.  Version-1 per-shard files do not
individually bind the generator source, so the clean invocation and source hash
are part of the provenance record rather than a property inferred from reused
shards.

### Independent scalar replay

`verifier/scalar_scan.py`, SHA-256
`1127DA520F9946C72E23818A90699DF2EF369B5B913ED3CE9C7D50A9B9D455CF`,
does not use odd-core factorization or the lattice reduction.  From an empty
checkpoint directory with `--no-resume`, it followed every integer start from
`3` through `10^9`, tested every positive accelerated prefix through the first
exact visit to `1`, and compared the complete canonical `(n,j,q,end)` list with
the optimized scan.  The fresh run covered 999,999,998 starts in
5,245.591715 seconds and passed with:

```text
paradoxical rows                         593
hit-list SHA-256       9A4DB72C9C5AB79EDA689F42A15D92ED5100ABCEEE566442B9579A0894D0A37A
total accelerated steps       135,705,965,843
maximum accelerated delay                 616  (least start 670,617,279)
maximum ordinary Collatz delay             986  (least start 670,617,279)
maximum accelerated state 707,118,223,359,971,240
least start attaining it           319,804,831

manifest-fresh.json
033501EED471312F83B589BD204A697C02A21F6101964ECB8103AD73AA2CD752

SHA256SUMS-fresh
6D68FC3D99557262B41B3A133304246C016FC29EC2F5A3035DD90A1E5EB32A16

RUN.md
7555D1CB54AAE33CDC28D9B006238B5B91AB18B0935C0A95F85983B28A06EED4
```

A second pass validated and reused all 4,096 source-bound scalar checkpoints in
1.013257 seconds.  That is an integrity and identity test, not a second
trajectory computation; the zero-reuse pass is the independent replay.

### Exact evidence label and remaining Lean gap

The two runs are genuine exhaustive finite computations, not sampling,
floating-point tests, or reliance on Rozier--Terracol's positive table.  They
provide two exact implementations with different iteration structure and
identical complete output.  They nevertheless do **not** establish
`FiniteBaseClassification 1000000000 PublishedClassification` in Lean:

- the optimized shards retain hits and digests, not all negative core traces;
- the scalar checkpoints are accepted by a Python checker, not by Lean;
- `ClassificationCertificate.lean` proves the odd-core/lattice leaf semantics
  and a sharp kernel example through `6`, but the `10^9` artifacts do not supply
  its missing trace-to-`1`, all-prefix, unique-core, and gap-free coverage layer;
- accepting either program's successful output as an axiom would merely move
  the trust boundary, and `native_decide` would add Lean's native-evaluation
  bridge rather than kernel-reduce the billion-start proposition.

Accordingly these computations strongly reproduce the published finite result,
but `FB-1` remains an explicit mathematical assumption in the large exclusion
theorem.

## Certification routes, ranked

### 1. Completed reproducibility route: full exact replay

The optimized scan and independent scalar replay described above complete this
route.  Their shard files, canonical hit CSV, source hashes, exact command
lines, interpreter version, wall times, and hardware notes are preserved in
their two `RUN.md` files.  The production commands were:

```text
python tools/odd_core_scan.py --limit 1000000000 --workers 8 --shards 4096 --output-dir certificates/finite-1000000000 --no-resume
python verifier/scalar_scan.py --limit 1000000000 --hits certificates/finite-1000000000/hits.csv --workers 8 --shards 4096 --checkpoint-dir certificates/scalar-1000000000 --no-resume
```

This completed route does **not alone** meet the requested kernel-only trust
boundary. A digest of a negative computation is not a proof that Lean's kernel
can inspect.

### 2. Smallest plausible kernel route: proof-producing coverage tree

Replace per-start output with a symbolic coverage certificate over disjoint
residue classes. Each accepted node should contain enough exact data for Lean
to prove:

1. its interval/residue domain and disjoint coverage;
2. the parity word and affine iterate formula for the represented starts;
3. every prefix endpoint and odd-count condition relevant to paradoxicality;
4. either a terminal visit to `1`, or a well-founded link to an already
   certified tail together with a sound composition summary.

The checker soundness theorem can then derive the universal quantifier in
`FiniteBaseClassification`; externally generated nodes are untrusted input.
The difficult part is tail composition: merely proving that an orbit falls
below its start is insufficient, because it can later rise above the original
start with a different accumulated coefficient. A valid node must preserve
enough `(length, odd-count, endpoint-bound)` information to rule out those
later prefixes.

No such compact public certificate was found. Its size and construction time
must be benchmarked before calling it viable, but it is the narrowest design
located that can satisfy the kernel requirement without a billion explicit
proofs.

### 3. Niu fixed-parity formula as a checker lemma, not an enumerator

Formalizing the residue bijection and affine threshold is worthwhile. It can
make each leaf of route 2 small and exact. By itself it does not compress the
`2^k` words at the published lengths and therefore cannot discharge the finite
classification.

### 4. Direct Lean enumeration

A Boolean checker over all starts with a proved soundness theorem is simple.
Kernel evaluation with `decide` over roughly a billion starts is not a
credible build step. `native_decide` is much faster, but this project has
correctly chosen to disclose its native-code bridge rather than label it a
kernel-replayed certificate. This is not the requested final route.

## Narrow missing artifact

For historical reproduction, the missing author artifact is the exact
Rozier--Terracol `n <= 10^9` search implementation plus its complete run
record: versioned source, build command, domain partition, termination/visit-to-
`1` rule, raw shard outputs or logs, hashes, and runtime/hardware metadata.
That would permit an authentic independent replay, but would still require a
Lean-verified importer or a proof-producing conversion to cross the project's
strict kernel boundary.

For the final formal theorem, the single missing artifact is stronger and more
precise: **a complete `1..10^9` residue/trajectory coverage certificate in a
format accepted by a Lean-proved sound checker, with checker acceptance itself
kernel-reduced or represented by kernel-checkable proof terms.** No public
artifact located in this audit has that property.

## Retrieval and replay commands

PowerShell commands used for the primary archives:

```powershell
Invoke-WebRequest `
  -Uri 'https://arxiv.org/src/2502.00948v5' `
  -OutFile '2502.00948v5.tar.gz'
Invoke-WebRequest `
  -Uri 'https://arxiv.org/src/2605.13886v1' `
  -OutFile '2605.13886v1.tar.gz'

Get-FileHash .\2502.00948v5.tar.gz -Algorithm SHA256
Get-FileHash .\2605.13886v1.tar.gz -Algorithm SHA256

tar -tzf .\2502.00948v5.tar.gz
tar -tzf .\2605.13886v1.tar.gz
```

Clean-source Niu boundary check:

```powershell
python .\length_k_paradox.py `
  --k-max 18 `
  --n-max 1000000000 `
  --out-dir .\niu-run

# Expected to fail because the v1 archive omits the input CSV:
python .\verify_affine.py
```

No mathematical assumption is discharged merely by the hashes or commands in
this note.
