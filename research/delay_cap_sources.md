# Ordinary-delay cap: source, semantics, and certificate audit

Audit date: 2026-08-27  
Scope: the proposition

```lean
Collatz.RecordBounds.ColDelayCap 46499999999999999999 2480
```

## Result

**The proposition is not discharged by any public artifact located in this
audit.** Eric Roosendaal's current site supplies a semantically matching
definition of ordinary Collatz delay, a completed-range statement, a class
record table, a technical description, and downloadable workers. It does not
publish the completed workers' logs, the CUDA source, a block manifest, or a
proof-producing coverage certificate. The current worker archive contains
binaries, not source.

This is a sharply delimited evidence gap rather than a map-convention gap. If
both of the site's relevant claims are correct--the reported convergence sweep
through `2^71` and the exhaustive class-record sweep through the target
boundary--then its current tables imply the desired cap. What is absent is
independently checkable evidence that those computations really covered every
start in the claimed ranges and handled every sieve, cut-off, reuse link, and
overflow correctly. None of the present web pages or binaries is accepted by
Lean's kernel.

## Exact semantic match

The Lean definitions are:

```lean
def Col (n : Nat) : Nat :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

def ColDelayCap (upper delay : Nat) : Prop :=
  forall {n : Nat}, 0 < n -> n <= upper ->
    exists d <= delay, iterate Col d n = 1
```

Roosendaal's [main page](http://www.ericr.nl/wondrous/) defines, for a
positive integer `N`, `S_0 = N` and

```text
S_i = S_(i-1) / 2       if S_(i-1) is even,
S_i = 3*S_(i-1) + 1     if S_(i-1) is odd.
```

It defines `D(N)` as the least index `k` for which `S_k = 1`. Hence a direct
induction on `d` gives

```text
S_d = iterate Col d N.
```

For every positive start whose source delay exists,

```text
D(N) <= 2480
  iff exists d <= 2480, iterate Col d N = 1.
```

The forward direction takes `d = D(N)`. In the reverse direction the
well-ordering of the natural numbers gives the least visiting index, which is
at most the supplied witness. Thus the source's `Delay` is exactly the Lean
quantity: ordinary, unaccelerated total stopping time to an actual visit to
`1`. It is not accelerated delay and it is not the glide/stopping time to a
value below the start. This also agrees with Rozier--Terracol's definition of
`d_Col` in `Paradox.tex`.

The remaining edge conventions also match:

- Roosendaal explicitly restricts the page to positive integers. Lean excludes
  `0` with `0 < n`.
- `N = 1` has delay zero. Lean takes `d = 0`; the fact that the next ordinary
  state is `4` is irrelevant.
- A divergent orbit or a nontrivial cycle has no visit-to-`1` witness. A
  sound checker must reject such a case; it may not silently classify it as
  having no large delay.
- Reuse of a previously checked smaller trajectory is semantically valid only
  with an exact state equality and an accumulated step budget. Lean's
  proposition does not trust a label such as "already known."

Let

```text
B = 46,500,000 * 10^12
  = 46,500 * 10^15
  = 46,500,000,000,000,000,000.
```

The target range `n <= 46,499,999,999,999,999,999` is exactly `n < B` over
natural numbers. The progress page states that its full coordinates are in
units of `10^12`; the June 30, 2026 history line abbreviates the completed
coordinate as `46,500`, while the main page reports `46.5 * 10^18`. The class
table footer spells out `46,500000,000000,000000`. The target's strict endpoint
is conservative under either ordinary-language reading of "through B": both
an inclusive computation through `B` and a half-open computation ending at
`B` cover every `n < B`. The current .NET launcher additionally writes the two
coordinates `blockStart` and `blockStart + blockLength` to `start.txt`, and
parses progress in units of `10^15`; the native CUDA worker's loop condition is
not available as source.

The main page separately reports that every start through `2^71` was checked
for convergence. Since `B < 2^71`, that reported range includes every positive
start needed by the Lean predicate. Semantically this is the missing existence
premise required before assigning a finite delay class; evidentially it remains
only an external computation claim because no corresponding proof certificate
or complete replay log is public.

## How the class-record statement would imply the cap

First use the separately reported convergence coverage to give every positive
`n < B` a finite delay `k = D(n)`. Let `R_k` be the least positive start with
delay `k`. Then `R_k <= n`. Consequently, if all class records with start below
`B` were found and no such record has class greater than `2480`, every positive
`n < B` has `D(n) <= 2480`.

The current public evidence reports both premises of that implication:

- the main page says every start through `2^71` has been checked for
  convergence, and `B < 2^71`;
- the main page says all numbers through `46.5 * 10^18` have been checked for
  class records;
- the [progress page](http://www.ericr.nl/wondrous/progress.html), dated July
  29, 2026, says all blocks through coordinate `46,500` were completed on June
  30, 2026;
- the [class-record table](http://www.ericr.nl/wondrous/classrec.html) displays
  a grid through class `2480`, claims to contain all 2,425 class records whose
  starts are at most `B`, and has class `2456` as its highest populated class;
- the highest confirmed delay record displayed by the main page is class
  `2456` at `28,019,077,177,231,758,495`;
- the progress page reports a possible, not yet confirmed, delay-`2480` record
  on June 12, 2026. Allowing equality at `2480` is therefore conservative.

This deduction still presupposes the truth of both external computation
statements. A class table by itself is not a convergence certificate: if a
start never reaches `1`, it belongs to no finite delay class. Conversely, the
reported convergence range alone supplies no uniform bound of `2480`. Neither
reported sweep has public evidence that Lean can check.

## Official artifacts pinned in this repository

All Roosendaal URLs below were retrieved over HTTP on 2026-08-26. The site's
HTTPS endpoint presented a certificate-name failure in this environment.
Therefore the hashes pin the exact bytes examined but do not authenticate the
mutable site.

| Artifact | Exact URL or origin | SHA-256 |
|---|---|---|
| Main definitions/status page | <http://www.ericr.nl/wondrous/> | `4bf0c36bf4d779f4f09814d742c2d4d5b40c26c1120a066636d1449a28a567f5` |
| Progress page | <http://www.ericr.nl/wondrous/progress.html> | `64b42e1ad232e7748f5bfedd6e230b0233b47827e62e9428a40b403dc846dcd2` |
| Class-record table | <http://www.ericr.nl/wondrous/classrec.html> | `ff85440b5aff69831d691992fd2e992a457ab1bb53d3c4c4c992034ef56692da` |
| Delay-record page | <http://www.ericr.nl/wondrous/delrecs.html> | `59dd4ca4d14e5a90d9d881f90bef1782638b229fc233e8a0f051da3919436964` |
| Raw record-start column | <http://www.ericr.nl/wondrous/delays.txt> | `f168da1b973c5ab44fff60144cb8248f8732ccb9529fec5638e8c36251d01507` |
| Search instructions | <http://www.ericr.nl/wondrous/search.html> | `d113da436177a41e221c84290e0d4b5db17627b2d624d78b272bd2ad71f9dee3` |
| Technical description | <http://www.ericr.nl/wondrous/techpage.html> | `3bb4a5e25ffc9c17d7022458e8200ec003186335ecab85171c6b73a0c772323e` |
| Site map | <http://www.ericr.nl/wondrous/sitemap.html> | `665c1f4cb1066d4cafc65ab2a1a64f6106bf6964364c4172f098e88899996329` |
| GPU 6.41 archive | <http://www.ericr.nl/wondrous/searchgpu6_41.zip> | `4eff1acf99b7788602f93772fccb3032e05e1f75be496c68b03dc0de4e87375f` |
| CPU 6.0.2 archive | <http://www.ericr.nl/wondrous/search64_4.zip> | `074c35576c888b07361784881c56561b244b79fe479dd750e784ebfe458e0067` |

The raw `delays.txt` file is only the ordered record-start column; it is not a
coverage log. Its entries align with the delay-record HTML table.

Important extracted files are pinned as follows:

| File | SHA-256 |
|---|---|
| `cudawon641.exe` | `babfbdb07dd90e15497ac7731a9d886637118258fa57e7dc9d1d01783cd58502` |
| `WonGPU.exe` | `4d512593dc2767bc9de8c36a81e002bc6fe6b5235960b883d4ee31fff76c6165` |
| `WonGPU.exe.config` | `000ad827929709c3d3ebecd4d4bcdc87ebc8a564eced85336b22dc30153f75fc` |
| `won600.exe` | `dc37569377e9a46498b3830b0bff600e13ce52f3cc5dbbcba5549c523fe38d01` |
| `won600.exe.config` | `4707fd63d3337ed0f897012b948e42917c54d067e44c701330856bec58ad5c25` |
| local decompilation of `won600.exe` | `aaacefd4e0e8471f633c9bf1b71427835ba491ae91a6543f947bc8c5b1efe74b` |

The decompilation is a derivative audit aid, not original source. No explicit
software license or redistribution permission was found on the pages or in
either archive. The CPU executable carries an "Electric Eel Productions
2012-2018" copyright field and the launcher carries a 2026 copyright field;
those notices are not licenses.

## What the worker and log format establish

The official technical page describes the class-record algorithm as follows:

1. a `2^25` path-collision sieve eliminates about 89% of starts;
2. even starts, starts congruent to `2 mod 3`, and starts congruent to `4 mod
   9` are also skipped, bringing the stated reduction to about 93%;
3. trajectories are cut off using already known delay-record intervals when
   their accumulated steps plus the applicable earlier bound cannot reach the
   reporting threshold.

The search page assigns units of `10^15` starts and normally assigns 100 such
units per block. A worker logs a checkpoint every `2^42` starts, the start and
finish, every "interesting number," elapsed time, and an overflow count. The
page says the overflow count permits a reproducibility check. Contributors
email their logs to the record holder; a log is stated to be about 60 KB per
`10^15` interval. Complete logs to the target would therefore comprise about
46,500 interval logs and roughly 2.8 GB before compression.

The GPU archive contains a Windows .NET launcher, a native CUDA executable,
the CUDA runtime DLL, and configuration, but no CUDA/C++ source, test vectors,
block manifest, or certificates. Native strings identify

```text
Version 6.41 (2025.01.27), lookup depth %d
start.txt
gpu%s.log
current.log
Checked to %s, overflow %llu, %s
%s with delay %d
```

The download page calls it a slightly modified February 2026 build with a
completion estimate. The managed launcher has file version 1.0.5.0; the native
worker has no useful version/company metadata.

The historical CPU 6.0.2 executable is managed code and can be decompiled. It
does contain a `2^25` collision sieve, exact 96/128-bit trajectory routines,
the modulo filters, seven hard-coded cut-off records, an overflow fallback,
and log messages of the form `N Delay = d (Level L)`. Its default reporting
threshold is 1960. This is valuable evidence for the high-level algorithm, but
it is explicitly unmaintained, has stale cut-off data, and is not the native
GPU worker that produced the 2020-2026 coverage. Decompiled code is also not a
proof of the binary's complete historical execution.

An overflow total is a useful duplicate-run checksum, but it is not a
proof-producing certificate. It does not identify every skipped residue, bind
each cut-off to an exact prior delay proof, prove that the assigned intervals
form a complete non-overlapping cover, or give a visit-to-`1` witness for every
remaining start. Agreement between two unchecked runs would improve empirical
confidence but would still not make `ColDelayCap` a Lean theorem.

## Search for public logs, mirrors, and source

As of the audit date:

- the official search page and site map link the two binary archives but no
  source repository, raw-log directory, block manifest, or certificate;
- conventional official paths including `logs/`, `logs.zip`, `results.zip`,
  `source.zip`, `cudawon641.cu`, representative `gpu*.log` names, and
  `current.log` returned HTTP 404;
- exact-name web searches for `cudawon641.exe`, `searchgpu6_41.zip`,
  `search64_4.zip`, and distinctive log strings found no public copy of the
  completed logs or worker source;
- the old Chinese Equn forum mirror reproduces the old command-line
  instructions and again directs contributors to email logs privately. It
  contains no modern GPU logs, source, or complete result archive.

These are negative search results, not a proof that no unindexed private or
archived copy exists. An Internet Archive CDX query was not reachable from this
environment, so no claim is made about unindexed Wayback holdings.

## Related public implementations and why they do not fill the gap

### Roger Dahl, `cuda-collatz`

<https://github.com/rogerdahl/cuda-collatz> is MIT-licensed and is the closest
public source-level delay-record implementation found. It defines Delay as the
number of ordinary Collatz iterations until `1`, includes simple and optimized
CPU/CUDA implementations, a sieve generator, sieve files, a reference
implementation, and historical benchmark logs. Its README thanks Eric
Roosendaal for describing the high-level optimizations.

The downloaded `master` archive used in this audit has SHA-256
`fe2cdae17840ff6d1526042a461600b820218c662194cf65c740c6a0916d101f`.
It limits starting values to 64 bits (while allowing 128-bit intermediate
states). The target boundary is greater than `2^64`, its bundled logs are old
benchmarks rather than complete target coverage, and it has no proof-producing
coverage certificate. No source identity between this repository and
Roosendaal's current GPU 6.41 binary was established.

### David Barina, `collatz`

<https://github.com/xbarin02/collatz> is MIT-licensed (copyright 2019-2026
David Barina) and publishes both workers and server code. The downloaded
`master` archive used here has SHA-256
`3740f6f9c6d0644251782c73db0b3d2e74d8fb476cf1dcfca5115c6bb989c73e`.

Its exact deployed predicate is different. `doc/ALGORITHM.md` assigns work
units `[N*2^40, (N+1)*2^40)` and iterates until the current value is below its
own start. The returned checksum is the sum of the encountered alpha counts;
the server protocol also stores overflow and extremal offsets. This is
convergence/glide evidence, not an ordinary total-delay-to-`1` cap. The source
tree does not bundle the server's completed `checksums.dat` and related result
arrays. Even with those arrays, a checksum of work is not a Lean-verified proof
that every covered start reaches `1` within 2480 ordinary steps.

A live recheck on 2026-08-27 found that the project's generated status page
now reports convergence verification below `2075 * 2^60`, well beyond the
target start boundary, and links the same public source repository.  This does
not improve the semantic match: the result remains first descent below the
seed, with work-unit checksums and a server-side coverage assertion, rather
than a certificate of an ordinary visit to `1` within 2480 steps.  The mutable
status page is therefore current provenance only, not an input to any Lean
theorem; the hash-pinned source archive above is the preserved artifact.

## Smallest viable certification route

A useful certificate should follow the optimization structure instead of
naively listing 46.5 quintillion trajectories. One workable design is a tree
or DAG of residue cylinders. Each node covers the intersection of a numeric
interval with `n == r mod 2^k` and carries an exact affine Collatz prefix. A
node is accepted only if it does one of the following:

1. reaches `1` with accumulated ordinary length at most 2480;
2. reaches an exactly identified earlier certified state, with the two step
   budgets adding to at most 2480;
3. proves a path-collision domination/cut-off relation used by the class-record
   sieve, including the precise lower representative and delay inequality; or
4. splits into disjoint children whose union is exactly the parent.

A Lean-verified checker can prove that accepted roots are disjoint and cover
`[1,B)`, verify all affine arithmetic and parity preconditions, reject
overflows rather than truncate them, and topologically check every descent
link. The existing `2^25` sieve and cut-off records can be inputs, but the
checker must verify their mathematical meaning; it must not trust their bits.
The top-level manifest should bind the interval endpoints, format version,
generator revision, and hashes of all shards.

`Collatz/Certified/Finite/DelayCertificate.lean` now supplies the verified
terminal/reference layer of this design: a point-indexed strict-descent DAG
whose successful Boolean check implies `ColDelayCap`, with a pure-kernel demo
through `20`.  It does not yet supply the residue-cylinder refinement and
gap-free compressed coverage layer needed at the target scale, nor does the
public record project supply data in that richer format.

The public logs would be valuable provenance and independent replay
checkpoints for such a generator. Their current advertised format is not, by
itself, rich enough to act as this certificate. Source alone would also be
insufficient, but the actual CUDA source, exact build recipe, cut-off tables,
and complete raw logs would make an independent proof-producing replay
substantially more credible and would expose any unlogged overflow handling.

## Narrowest missing artifact

The one mathematical artifact needed to remove `DC-1` is:

> A complete, hash-pinned, proof-producing coverage certificate for the
> half-open interval `[1, 46,500,000,000,000,000,000)`, accepted by a
> Lean-proved checker, whose leaves establish an ordinary visit to `1` within
> 2480 steps (directly or through verified well-founded descent links).

The narrowest existing record-holder material that could seed creation of that
artifact, but is not public, is the complete per-unit log archive together
with the exact GPU 6.41 kernel source/build configuration and assignment
manifest. Obtaining only the logs would improve reproducibility but would not
remove the Lean assumption.

Until such a certificate is generated and accepted, the `4.65 * 10^19`
paradoxical-segment exclusion must remain labeled **conditional on
`ColDelayCap 46499999999999999999 2480`**.
