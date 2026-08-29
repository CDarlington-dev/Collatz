# Exact paradoxical segments for the accelerated Collatz map

This repository reconstructs the finite-exclusion argument in Olivier Rozier
and Claude Terracol, *Paradoxical behavior in Collatz sequences* (Discrete
Mathematics 349 (2026), 115167; arXiv:2502.00948v5), while keeping formal
theorems, finite computations, and external record claims on separate trust
boundaries.

For

\[
T(n)=\begin{cases}n/2&n\text{ even},\\(3n+1)/2&n\text{ odd},\end{cases}
\]

a length-`j` segment from `n` is paradoxical when `n > 2`, `j > 0`, exactly
`q` of its first `j` inputs are odd, `3^q < 2^j`, and `T^j(n) >= n`.

## Current status

- The definitions, exact arithmetic lemmas, accelerated/ordinary-step
  conversion, Farey feedback, and deterministic record-to-exclusion argument
  are formalized in Lean.
- A built pure-kernel classifier checks every start through `4614` and every
  segment length against the literal 593-row table.  Its 47 ordinary-`decide`
  blocks fail closed outside the terminal set `{0,1,2}`.  This is an
  unconditional `FiniteBaseClassification 4614 PublishedClassification`
  theorem; it does not by itself certify the much larger range through
  `10^9`.
- A clean, non-resumed exact odd-core/lattice computation covers every start
  `1 <= n <= 1,000,000,000`. It found 593 paradoxical segments at 550 distinct
  starts, all at starts at most 4614. A fresh, zero-reuse scalar replay then
  independently iterated all 999,999,998 starts from 3 through `10^9` and every
  accelerated prefix through the first visit to 1; it reproduced the same 593
  rows and hit-list hash. These are exact computational results, not a Lean
  theorem: the remaining finite-side obligation is a Lean proof that verified
  external coverage implies `FiniteBaseClassification`.
- A built and audited pure-kernel Lean theorem proves the first accelerated
  excursion envelope `AcceleratedExcursionEnvelope 1000000000 113383`,
  eliminating that external input from the target theorem. It aggregates 114
  ordinary-`decide` blocks; blocks 43, 46, and 48 through 113 use explicit
  `maxHeartbeats 500000`, while the others use the default. Its audit lists
  only `propext`, `Classical.choice`, and `Quot.sound`, with no native axiom.
- Built and audited pure-kernel Lean theorems directly exclude every start from
  4615 through 26017. The extension from 10015 uses forty 400-start blocks and
  the exact three-start tail, all with fail-closed fuel 178. The aggregate also
  proves `FiniteBaseClassification 26017 PublishedClassification`; its audit
  lists only `propext`, `Classical.choice`, and `Quot.sound`, with no native
  bridge. The replay recipe, exact scan output, wrapper generator, and sealed
  162-entry source manifest are in
  [`certificates/kernel-range-26017/`](certificates/kernel-range-26017/README.md).
- A symbolic affine-remainder theorem, also on the kernel path, proves that a
  paradoxical segment above start `4614` has `j >= 27`, and one above `26017`
  has `j >= 35`.  A separate checked circuit/CNF/LRAT demonstration reconstructs
  a small accelerated-map refutation inside Lean.  The circuit result is a
  **technology demonstration, not target-scale coverage** and does not clear
  the finite-classification assumption.
- The exact Farey seed at `99781`, the sharper envelope
  `AcceleratedExcursionEnvelope 785412369 99781`, and the optimized exclusion
  target are now built and audited on the ordinary kernel path. The envelope
  uses 99 blocks of 1,000 starts plus the exact tail `99000..99780`; fuel 134
  fails closed and fuel 135 accepts the extremal first-descent start `35655`.
  Lean also proves the sharp equality `endpoint 77671 39 = 785412368`. The
  current 9,040-job root build and complete axiom-audit sweep passed without a
  native bridge. This verified proof-engine route leaves only the finite cases
  `26017 < n <= 785412368` with `j >= 35` and
  `j + oddCount n j < 2480`; the affine theorem discharges shorter lengths, the
  delay-cap lemma supplies the ordinary-prefix filter, and starts at or above
  `785412369` enter the strict envelope/Farey route. It remains **conditional**
  on this filtered finite-gap input and the independent ordinary-delay input.
  The sealed envelope replay package is
  [`certificates/optimized-first-excursion-99781/`](certificates/optimized-first-excursion-99781/README.md);
  its source-manifest, semantic-source, and package-`SHA256SUMS` digests are
  `910dfa86fa2812b461bdfde2572db650e855699fc8ae430ff2d907f3e49779b9`,
  `15d495cddf760905fad5d21fa50677be102b6ea9a2d9433e821e2755c6d31f51`,
  and `9077033661a33d4df93a22eb049b5630c19f654ffc1d11d496e187be0c622ed7`.
- The original record-based target implication

  ```text
  4614 < n < 46500000000000000000  ->  not Paradoxical n j
  ```

  has exactly two explicit inputs:

  ```text
  FiniteBaseClassification 1000000000 PublishedClassification
  ColDelayCap 46499999999999999999 2480
  ```

  The optimized target theorem described above replaces the first input with
  `OptimizedFiniteGap`; it retains the same delay-cap input. No input on either
  route is disguised as an axiom. The target exclusion is therefore
  **conditional, not unconditional** on both routes.

## Clean `10^9` finite computation

The committed optimized run used 4,096 manifest-listed shards and unique
factorization `n = 2^a u` with odd `u`. Its principal SHA-256 values are:

```text
hits.csv       9a4db72c9c5ab79eda689f42a15d92ed5100abceee566442b9579a0894d0a37a
manifest.json  1418ad38b73cc223d745477f6751e66d64ce5aec9d2b45c58a87da4cf813f505
SHA256SUMS     3483e9cc639d434536e9ef50b775674241c8d4c6168c5108b57c011567ceb1d7
generator      8e2e3c853fab300f7db8abf6ed2c8d5bc6d3df4a1243c6937feca3fbc084e296
```

The manifest records 500,000,000 odd cores, 34,969,255,812 odd blocks,
69,762,619,290 accelerated steps from odd cores, maximum accelerated delay 616
at start 670617279, and maximum state 707118223359971240 at start 319804831.
These statistics are exact outputs, not premises of a theorem.

The clean command ran from 20:02:54 EDT to its original final manifest at
21:55:25 EDT on 2026-08-26: about 6,751 seconds (1 h 52 min 31 s).

## Independent scalar replay through `10^9`

The scalar verifier source hash is
`1127da520f9946c72e23818a90699df2ef369b5b913ed3ce9c7d50a9b9d455cf`.
Its fresh empty-directory, `--no-resume` run completed in 5,245.591715 seconds
and reported:

```text
covered starts       999999998 (3 through 1000000000)
reused shards        0
paradoxical rows     593
hit-list SHA-256     9a4db72c9c5ab79eda689f42a15d92ed5100abceee566442b9579a0894d0a37a
accelerated steps    135705965843
max accelerated delay 616 at 670617279
max ordinary delay    986 at 670617279
max state              707118223359971240 at 319804831
fresh manifest       033501eed471312f83b589bd204a697c02a21f6101964ecb8103ad73aa2cd752
fresh SHA256SUMS     6d68fc3d99557262b41b3a133304246c016fc29ec2f5a3035dd90a1e5eb32a16
```

A second pass validated and reused all 4,096 checkpoints in 1.013257 seconds;
its live manifest and sums hashes are `69c4add41a1198ce3402ed0e8287cc2af4a53a0e8eb0d4c4be9d9927aed8a85c`
and `99a8c9f79585ab8bbfb8bc45a331ce2ec92233027e6e30c4cf2fe395dd325c2`.
Checkpoint validation does not recompute reused trajectories, and neither pass
is accepted by a Lean-proved checker. The exact run record is in
`certificates/scalar-1000000000/RUN.md`.

## Residue-compression experiments

Exact gap-relevant experiments explain why the remaining finite bridge is
narrow but not yet solved.  The sound strong-induction rule produced exactly
73,983 singleton leaves for `26018..100000`.  On `26018..1000000`, the richer
exact tail-profile tree still used 579,041 leaves and 956,448 point-profile
queries, while a compressed maximum-excursion summary used 922,107 leaves,
901,476 of them singletons.

These are design experiments, not Lean theorems or certificate coverage.  The
key obstruction is exact: since `2^35 > 10^9`, fixing a parity residue at any
potentially paradoxical length above `26017` already identifies at most one
start in the finite interval.  The missing invariant must instead preserve a
relation between original and tail states across an affine cylinder.  Detailed
tables, the candidate relational inequality, and source hashes are in
[notes/residue-certificate-benchmarks.md](notes/residue-certificate-benchmarks.md).
The independent `DC-1` ordinary-delay certificate remains a separate, larger
external bottleneck.

## Reproduction

The main commands and their trust meaning are in
[REPRODUCING.md](REPRODUCING.md). The authoritative assumption ledger is
[docs/TRUST-BOUNDARY.md](docs/TRUST-BOUNDARY.md); it must contain no
mathematical assumptions before the `4.65 * 10^19` exclusion can be called
unconditional.

On a fresh checkout, build the generated kernel blocks in bounded pairs before
the ordinary project build:

```powershell
& .\scripts\build_kernel_blocks.ps1 -Family Base
& .\scripts\build_kernel_blocks.ps1 -Family Range
& .\scripts\build_kernel_blocks.ps1 -Family Range26017
& .\scripts\build_kernel_blocks.ps1 -Family Excursion
& .\scripts\build_kernel_blocks.ps1 -Family OptimizedExcursion
```

All five generated families above have completed aggregates and audits. On a
fresh checkout, run a bare `lake build` only after all block families required
by the current public import have completed. A source file or partial block
build is not a checked aggregate theorem.

During each block-family loop, the script submits exactly two block targets per
Lake invocation; the base and family aggregate use separate single-target
invocations. Lake 5 did not interpret `-Kjobs=2` as a concurrency cap in this
project; that obsolete recipe spawned 16 reducers and must not be used.

See also [docs/results.md](docs/results.md) for theorem-level status,
[docs/certificate-format.md](docs/certificate-format.md) for certificate
semantics, [audit/RESULTS.md](audit/RESULTS.md) for the recorded build/axiom
audit, [notes/checkpoints.md](notes/checkpoints.md) for phase history, and
[notes/runtime.md](notes/runtime.md) for recorded timings.

## Evidence labels

1. **Lean theorem** — accepted by the pinned Lean toolchain. Pure-kernel
   numerical proofs are distinguished from `native_decide` results.
2. **Certificate computation** — exact finite output accepted by an exact
   checker, but not automatically a Lean theorem about complete coverage.
3. **External hypothesis** — a mathematical completeness claim not discharged
   by the repository.
4. **Exploration or pending computation** — source or evidence not yet
   promoted to a checked result.

Hashes identify exact bytes; they do not by themselves prove that a search was
complete or that a mutable web page is mathematically correct.
