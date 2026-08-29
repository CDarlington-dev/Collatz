# Checkpoint log

The evidence labels used throughout this project are:

- **Lean theorem**: checked by the pinned Lean kernel.
- **Certificate computation**: exact finite computation accepted by a small checker.
- **External hypothesis**: a completeness/range assertion reported by a third-party record search, not silently promoted to a local proof.
- **Exploration**: evidence or a proposed route that has not been certified.

## Checkpoint 0 — workspace and environment audit (2026-08-26)

Verified:

- The supplied workspace was empty and was not a Git repository.
- No Lean, Lake, or Elan executable was installed or on `PATH`.
- Git 2.55.0, Node.js 24.19.0, and bundled Python 3.12.13 are available.
- Host: Windows 10 build 26200, AMD Ryzen 7 260 with Radeon 780M, 16 logical processors reported by the host registry.

Files produced:

- `.gitattributes`, `.gitignore`
- `lean-toolchain`, `lakefile.toml`
- this checkpoint log

Remaining assumptions:

- The pinned Lean/mathlib toolchain must still be downloaded and every theorem must be checked locally.

Next highest-value action:

- Bootstrap the workspace-local Lean toolchain and formalize the exact map, segment predicate, and Farey barrier.

## Checkpoint 1 — paper and record-chain reconstruction (2026-08-26)

Verified:

- Read arXiv:2502.00948v5 in full and reconstructed Definitions 1.1, 1.2,
  2.1, 4.1, 5.2; equations (1), (2), (9), (13), (14); and the theorem chain
  through Theorem 5.3 and Corollary 5.4.
- Reconstructed all seven published `(j,q,count)` groups and the exact
  feedback constants `113383`, `1539`, `971`, `2510`,
  `28019077177231758495`, `23035537407`, and `301994`.
- Located the current primary record pages and recorded the difference between
  accelerated `M_T` and the unaccelerated path values printed there.
- Identified a reciprocal typo in the v5 Table 1 caption.

Files produced:

- `research/rozier_terracol_v5.md`

Remaining assumptions:

- The published `n<=10^9` enumeration and record-table coverage claims are
  external computations, not proofs supplied by the paper.

Next highest-value action:

- Replace every logarithmic numerical cutoff with exact integer certificates,
  prove the generic barrier in Lean, and verify the published example list.

## Checkpoint 2 — exact arithmetic and published witnesses (2026-08-26)

Verified:

- Installed Lean 4.32.1 and mathlib v4.32.1 locally and checked the accelerated
  map, endpoint, odd-count, and paradoxical-segment definitions.
- Proved the exact product inequality and determinant-one Farey barrier.
- Checked the first two paper feedbacks exactly: `(j,q)>=(1539,971)` at
  `m=113383`, and `(j,q)>=(301994,190537)` at `m=23035537407`.
- Extracted and Lean-native-checked all 593 Appendix C witnesses; Node and
  Python independently reproduce all seven groups and 550 distinct starts.

Files produced:

- `Collatz/Map.lean`, `Collatz/Segment.lean`, `Collatz/ProductBound.lean`
- `Collatz/Farey.lean`, `Collatz/Certified/Farey.lean`
- `Collatz/Certified/Published.lean`
- `certificates/farey-v1.json`, `certificates/published-witnesses-v1.csv`
- `tools/verify_exact.mjs`, `verifier/reference.py`

Remaining assumptions:

- Positive witnesses do not establish the paper's exhaustive `n<=10^9`
  classification. Large fixed checks use Lean native decision and are also
  covered by the independent exact verifiers.

Next highest-value action:

- Build two algorithmically independent exhaustive finite scanners and a
  replayable record-bound certificate.

## Checkpoint 3 — finite certificates and local excursion replay (2026-08-26)

Verified:

- The odd-core/lattice generator and scalar per-start verifier agree on every
  start through `10^6`: exactly 593 hits, no start above 4614.
- Scalar replay covers 87,826,477 accelerated steps through `10^6`.
- A separate replay through 113382 proves exact maximum state 785412368 at
  start 77671, strictly below `10^9`; start 113383 exceeds `10^9`.

Files produced:

- `tools/odd_core_scan.py`, `verifier/scalar_scan.py`
- `certificates/finite-1000000/`, `certificates/finite-113382/`
- `certificates/record-bounds-v1.json`, `docs/certificate-format.md`

Remaining assumptions:

- Local exhaustive coverage stops at `10^6`, not `10^9`. The first excursion
  envelope is discharged by a certificate computation but not imported into
  Lean through a proof-producing bridge.

Next highest-value action:

- Formalize the deterministic conversion from finite classification,
  excursion envelopes, and delay caps to start and length exclusions.

## Checkpoint 4 — Lean exclusion theorem and paper reproduction (2026-08-26)

Verified:

- Proved the exact accelerated-prefix/ordinary-prefix relation `j+q`, the
  post-convergence cycle bound, and generic one- and two-feedback theorems.
- With four named paper inputs, Lean proves no paradoxical segment for
  `4614<n<=28019077177231758495` and none with `93<=j<=301993`.
- `lake build` succeeds; the symbolic axiom audit lists only Lean's standard
  `propext`, `Classical.choice`, and `Quot.sound` foundations.

Files produced:

- `Collatz/RecordBounds.lean`, `Collatz/Exclusion.lean`
- `Collatz/Certified/Exclusion.lean`, `audit/AxiomAudit.lean`

Remaining assumptions:

- The paper's `10^9` classification, large delay cap, and second excursion
  envelope are explicit theorem parameters.

Next highest-value action:

- Audit current record coverage and seek the smallest sound extension.

## Checkpoint 5 — July 2026 conditional extension (2026-08-26)

*Historical phase status: the three-input target described here was later
reduced to two inputs; see Checkpoint 6.*

Verified:

- Resolved the progress-page shorthand against its full grid and main status:
  the completed boundary is `46,500,000 * 10^12 = 4.65 * 10^19`.
- Conservatively allow the page's unconfirmed delay-2480 candidate. Since
  `2480 <= 2510`, the first feedback still excludes all starts below the
  reported boundary.
- Lean proves, from three explicitly named current inputs, no paradoxical
  segment for `4614<n<46500000000000000000`.
- With the additional current excursion envelope at seed 51739336447, Lean
  proves every hypothetical beyond the boundary has `j>=301994` and
  `q>=190537`.

Files produced:

- `certificates/external-claims-v1.json`
- `README.md`, `REPRODUCING.md`, `docs/results.md`, `notes/runtime.md`

Remaining assumptions:

- Current class-record/delay completeness and the current excursion envelope
  are third-party hypotheses; archived byte hashes identify retrieved HTTP
  pages, but the ignored raw snapshots are not bundled or authenticated.

Next highest-value action:

- Produce an independently replayable ordinary-delay cap of at most 492531 at
  or beyond `4.65 * 10^19`; convergence-only coverage is insufficient.

## Checkpoint 6 — crash recovery and finite certification upgrade (2026-08-27)

Verified:

- Completed a clean, `--no-resume` optimized odd-core/lattice scan through the
  inclusive bound `10^9`. Its manifest lists 4,096 shards covering
  1,000,000,000 represented starts and reports exactly 593 rows at 550 starts,
  with maximum start 4614. The timestamped launch-to-manifest interval was
  about 6,751 seconds (1 h 52 min 31 s).
- The canonical hashes are
  `9a4db72c9c5ab79eda689f42a15d92ed5100abceee566442b9579a0894d0a37a`
  for `hits.csv`,
  `1418ad38b73cc223d745477f6751e66d64ce5aec9d2b45c58a87da4cf813f505`
  for `manifest.json`, and
  `3483e9cc639d434536e9ef50b775674241c8d4c6168c5108b57c011567ceb1d7`
  for the certificate-local `SHA256SUMS`.
- Added a Lean-proved point-indexed ordinary-delay DAG checker and a
  Lean-proved odd-core/lattice leaf checker. Both discharge manageable examples
  but do not yet bridge the full external data to the two target predicates.
- Generated pure-kernel block-proof source for the complete first accelerated
  excursion envelope below seed 113383. Consequently the current target input
  structure no longer contains an excursion-envelope field. The aggregate of
  all 114 ordinary-`decide` blocks now builds successfully; its audit contains
  only `propext`, `Classical.choice`, and `Quot.sound`. Blocks 43, 46, and 48
  through 113 use explicit `maxHeartbeats 500000`; all others use the default.
  The legacy native-decision comparison theorem is not used.
- Generated and built a pure-kernel direct-check theorem proving no
  paradoxical start from 4615 through 10014. Its axiom audit lists only
  `propext`, `Classical.choice`, and `Quot.sound`, with no native-decision
  axiom. This is an unconditional finite theorem.
- Reduced the exact `4.65 * 10^19` target implication to two named predicates:
  the finite classification through `10^9` and the ordinary delay cap through
  `46499999999999999999`.

Build status at this checkpoint:

- The clean `10^9` computation is complete.
- A fresh, zero-reuse source-bound scalar replay through `10^9` is complete.
  It covered all 999,999,998 starts from 3 through `10^9`, reported `PASSED`,
  and reproduced all 593 rows and the canonical hit hash in 5,245.591715
  seconds after 135,705,965,843 accelerated steps.
- A second pass validated and reused 4,096/4,096 scalar checkpoints, reported
  `PASSED`, and completed in 1.013257 seconds. This identity/integrity pass did
  not recompute reused trajectories.
- The scalar source hash is
  `1127da520f9946c72e23818a90699df2ef369b5b913ed3ce9c7d50a9b9d455cf`.
  The preserved fresh manifest/sums hashes are
  `033501eed471312f83b589bd204a697c02a21f6101964ecb8103ad73aa2cd752`
  and `6d68fc3d99557262b41b3a133304246c016fc29ec2f5a3035dd90a1e5eb32a16`;
  after reuse validation, the live hashes are
  `69c4add41a1198ce3402ed0e8287cc2af4a53a0e8eb0d4c4be9d9927aed8a85c`
  and `99a8c9f79585ab8bbfb8bc45a331ce2ec92233027e6e30c4cf2fe395dd325c2`.
- The 4615-through-10014 aggregate build and axiom audit are complete.
- The first-excursion aggregate build and axiom audit are complete. Both
  generated finite results are unconditional pure-kernel Lean theorems.
- Corrected the fresh-checkout recipe after observing that Lake 5 ignored
  `-Kjobs=2` as a concurrency cap and spawned 16 reducers. The checked
  `scripts/build_kernel_blocks.ps1` recipe builds `Range` and `Excursion`
  separately and submits exactly two block targets per Lake invocation before
  their aggregates. A bare `lake build` follows both family scripts.

Files produced or updated:

- `certificates/finite-1000000000/`
- `certificates/scalar-1000000000/`
- `Collatz/Certified/Finite/ClassificationCertificate.lean`
- `Collatz/Certified/Finite/DelayCertificate.lean`
- `Collatz/Certified/Finite/FirstExcursionKernel.lean` and its block modules
- `Collatz/Certified/Finite/NoParadoxicalRangeKernel.lean` and its block modules
- `Collatz/Certified/Exclusion.lean`
- `docs/TRUST-BOUNDARY.md`, `docs/certificate-format.md`, and
  `docs/delay-certificate-format.md`

Remaining mathematical assumptions:

- `FiniteBaseClassification 1000000000 PublishedClassification` is not yet a
  Lean theorem. The optimized computation is exact evidence, but the global
  coverage/equality bridge remains missing. The completed independent scalar
  replay is also external computational evidence, not proof-producing input
  accepted by Lean.
- `ColDelayCap 46499999999999999999 2480` is not yet a Lean theorem. The one
  decisive missing public artifact is a proof-producing compressed coverage
  certificate, or equivalent raw coverage data, for the exact half-open range
  `[1,46500000000000000000)`.

Next highest-value action:

- Build the Lean global-coverage/equality bridge for the finite classifier. In
  parallel, seek or generate the compressed ordinary-delay coverage certificate
  required by the Lean-proved checker.

The target exclusion remains **conditional** at this checkpoint.

## Checkpoint 7 — affine preprocessing and optimized route (2026-08-27, proof-engine complete)

Verified:

- Built the 47-block ordinary-kernel classifier and its production bridge.
  It proves the exact 593-row `FiniteBaseClassification` through inclusive
  start `4614`, for every segment length.
- Proved the universal affine remainder bound. In particular, any paradoxical
  segment above start `26017` has accelerated length `j >= 35`.
- Built all forty 400-start `Range26017` blocks and the exact tail
  `26015..26017` with fuel 178. The paired loop took 1,697.504 seconds and the
  aggregate 17.870 seconds. Its audit reports only `propext`,
  `Classical.choice`, and `Quot.sound` for the arbitrary-length exclusion and
  complete classification through `26017`; there is no native bridge. The
  replay was sealed in `certificates/kernel-range-26017/`; its 162-entry
  source-manifest digest is
  `9ae3954aff8da49857bca68dba64b02b3bfc66374294fc8ae7a37d5a9ef5a1bb`.
- Built and audited the reducible circuit/CNF/LRAT demonstration on one genuine
  accelerated step for inputs 26 and 27. Its evidence label is
  **kernel-checked technology demonstration, not target-scale coverage**.
- Built the optimized Farey module and all 99 full 1,000-start envelope blocks
  plus exact tail `99000..99780`. The paired run took 1,004.896 seconds and
  proves `AcceleratedExcursionEnvelope 785412369 99781`; Lean also proves
  `endpoint 77671 39 = 785412368`. Fuel 134 fails closed and fuel 135 accepts
  the extremal first-descent start `35655`.
- The production envelope audits to only `propext`, `Classical.choice`, and
  `Quot.sound`; concrete reductions and the peak equality use no axioms. The
  optimized Farey theorem, classifier reconstruction, and target exclusion
  also audit to standard Lean/Mathlib axioms with no native bridge.
- The current 9,040-job root build and complete axiom-audit/circuit-audit sweep
  passed. The 106-entry optimized-envelope source manifest has digest
  `910dfa86fa2812b461bdfde2572db650e855699fc8ae430ff2d907f3e49779b9`;
  semantic-source hash
  `15d495cddf760905fad5d21fa50677be102b6ea9a2d9433e821e2755c6d31f51`;
  package-`SHA256SUMS` hash
  `9077033661a33d4df93a22eb049b5630c19f654ffc1d11d496e187be0c622ed7`.
- Measured the exact residue-certificate designs in
  [residue-certificate-benchmarks.md](residue-certificate-benchmarks.md).
  Fixed-parity, first-descent,
  state-only excursion, and point-tail summaries all remain essentially
  pointwise; the note isolates the missing relational affine-cylinder tail
  invariant.

The remaining optimized input predicate is exactly

```text
26017 < n <= 785412368,
35 <= j,
j + oddCount n j < 2480
  -> not Paradoxical n j.
```

The affine theorem supplies the length split. A generic Lean lemma derives the
ordinary-prefix split from `ColDelayCap 46499999999999999999 2480`, so the
built classifier reconstruction takes both fields of `OptimizedCurrentInputs`.
Starts at or above `785412369` use the strict optimized envelope/Farey route.

Remaining mathematical inputs on that route:

- The filtered finite gap above.
- `DC-1`, the ordinary delay cap through `46499999999999999999`.

Next highest-value action:

- Construct a proof-producing relational-profile/DAG or global circuit
  certificate for the filtered finite gap, while independently obtaining the
  `DC-1` coverage data.

The target exclusion remains **conditional** at this checkpoint.
