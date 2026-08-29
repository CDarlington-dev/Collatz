# Trust boundary for the finite exclusion

Last updated: 2026-08-27 (phase 4 proof-engine reduction complete)

## Claim under construction

The target is a theorem with no hypotheses asserting that, for every `n j : ℕ`,

```lean
4614 < n → n < 46500000000000000000 → ¬ Collatz.Paradoxical n j
```

The previously audited theorem `target_exclusion_of_remaining_inputs` has those
exact strict endpoints.  It is conditional on a value of
`Collatz.Certified.CurrentDelayInputs`, whose two fields are exactly
`FiniteBaseClassification 1000000000 PublishedClassification` and
`ColDelayCap 46499999999999999999 2480`.  The auxiliary theorem uses the
equivalent inclusive upper endpoint `n ≤ 46499999999999999999`.

The current source also defines a sharper built route. Its finite premise
is the named proposition

```lean
OptimizedFiniteGap :=
  ∀ {n j : ℕ},
    26017 < n → n ≤ 785412368 → 35 ≤ j →
      j + oddCount n j < 2480 → ¬ Paradoxical n j
```

and its other premise is the same ordinary delay cap. The direct range through
`26017`, optimized Farey module, strict envelope below seed `99781`, optimized
target, classifier reconstruction, 9,040-job root build, and full audit sweep
are now verified. The symbolic affine theorem supplies the `j ≥ 35` split, and a
generic lemma derives `j + oddCount n j < 2480` from `DC-1` for a paradoxical
start below the delay boundary. Consequently the built classifier
reconstruction takes the full `OptimizedCurrentInputs`, not the gap alone. The
endpoint distinction is deliberate: the finite premise ends at `785412368`,
and the strict-envelope/Farey argument begins at `785412369`.

This promotes the proof-engine reduction, not the requested unconditional
theorem: `FG-OPT` and `DC-1` remain explicit mathematical assumptions.

This document uses **kernel-accepted** to mean that Lean elaborates a proof term
whose type is checked by Lean's kernel.  A hash, a web page, a successful Python,
Node, C, or GPU run, and an unchecked program's printed answer are reproducibility
evidence, not kernel-accepted proofs.  A finite data file removes a mathematical
assumption only when a checker with a Lean proof of its soundness accepts that
data and the resulting proposition has a Lean proof.

## Exact semantic predicates

The definitions below are in `Collatz/RecordBounds.lean`.

### A. Finite paradoxical-segment classification

```lean
FiniteBaseClassification 1000000000 PublishedClassification
```

means, with an inclusive endpoint,

```lean
∀ {n j : ℕ}, n ≤ 1000000000 →
  (Paradoxical n j ↔ PublishedClassification n j).
```

`Paradoxical n j` is defined in `Collatz/Segment.lean` and requires all four
conditions: `2 < n`, `0 < j`, `3 ^ oddCount n j < 2 ^ j`, and
`n ≤ endpoint n j`.  `oddCount` counts odd inputs at indices `0,...,j-1`;
`endpoint n j = T^[j](n)`.  `PublishedClassification` is membership in the
bundled list of 593 published witnesses, with the explicit consequences
`n ≤ 4614` and `j ≤ 92`.  Thus the missing direction is not merely validation
of the 593 rows: it is exhaustive absence of every other length for every start
through `10^9`.

Semantic match required of any source: the accelerated map is exactly
`T(n)=n/2` for even `n` and `(3*n+1)/2` for odd `n`; lengths count accelerated
steps; the upper endpoint `10^9` is included; and the computation continues far
enough to exclude all later lengths (normally by a certified visit to `1`, after
which the `(1,2)` cycle is below every allowed paradoxical start).  Starts `0,1,2`
cannot be paradoxical by definition but remain covered by the universal Lean
predicate.

A separate built kernel theorem now establishes the definitionally matching
predicate through the published maximum:

```lean
FiniteBaseClassification 4614 PublishedClassification
```

It uses 47 ordinary-`decide` blocks, checks every prefix until a proved terminal
tail, and kernel-checks the 593 literal positive rows. Two built direct-range
families then exclude every additional start through `26017`, yielding

```lean
FiniteBaseClassification 26017 PublishedClassification.
```

Thus the classification is unconditional through `26017`; `FB-1` below still
names only the unproved extension of this predicate through `10^9`.

### B. First accelerated maximum-excursion envelope

```lean
AcceleratedExcursionEnvelope 1000000000 113383
```

means

```lean
∀ {x : ℕ}, x < 113383 → ∀ r : ℕ, endpoint x r < 1000000000.
```

The seed endpoint is strict: starts are exactly `0,...,113382`.  The state
threshold is also strict.  The map is accelerated `T`, not ordinary `Col`.
The quantifier covers every future iterate, so a finite trajectory table must
also certify convergence to `1` (or otherwise certify the infinite tail).
Here `T 0 = 0`, while positive convergent trajectories enter the `(1,2)` cycle;
both tails stay below the threshold.

The theorem `firstExcursionEnvelope_kernel` now proves this proposition by 114
ordinary-`decide` blocks.  Its proof handles `0`, verifies an exact visit to `1`
within 223 accelerated steps for every positive covered start, and proves the
entire `(1,2)` tail.  Its axiom audit lists only `propext`, `Classical.choice`,
and `Quot.sound`, not Lean's native-evaluation axiom.  The separate local replay
reports exact maximum state `785412368`, first attained from `77671`; that JSON
is reproducibility cross-check evidence, not an input to the Lean proof.

The sharper strict envelope theorem

```lean
AcceleratedExcursionEnvelope 785412369 99781,
```

is built from 99 ordinary-`decide` blocks of 1,000 starts and the exact tail
`99000..99780`. Lean also proves the sharpness equality
`endpoint 77671 39 = 785412368`; fuel 134 fails closed and fuel 135 accepts the
extremal first-descent start `35655`. The production envelope audits to only
`propext`, `Classical.choice`, and `Quot.sound`; concrete reductions and the
peak equality use no axioms. There is no native bridge or external data input.
The strict state threshold is exactly what lets the optimized feedback route
begin at start `785412369`.

The sealed 106-source replay package is
[`certificates/optimized-first-excursion-99781/`](../certificates/optimized-first-excursion-99781/README.md).
Its source-manifest digest, semantic-source hash, and package-`SHA256SUMS` hash
are, respectively,
`910dfa86fa2812b461bdfde2572db650e855699fc8ae430ff2d907f3e49779b9`,
`15d495cddf760905fad5d21fa50677be102b6ea9a2d9433e821e2755c6d31f51`,
and `9077033661a33d4df93a22eb049b5630c19f654ffc1d11d496e187be0c622ed7`.

### C. Ordinary Collatz delay cap

```lean
ColDelayCap 46499999999999999999 2480
```

means

```lean
∀ {n : ℕ}, 0 < n → n ≤ 46499999999999999999 →
  ∃ d ≤ 2480, iterate Col d n = 1.
```

`Col` is the ordinary map: an even input takes one step to `n/2`, while an odd
input takes one step to `3*n+1` with no division folded into that step.  The
quantity is total stopping time (an actual visit to `1`), not stopping time below
the start and not accelerated delay.  Zero is excluded; `n=1` is included with
witness `d=0`.  The upper endpoint is inclusive and is exactly one less than the
target theorem's strict bound.  Reuse of already-certified smaller trajectories
is sound only if the certificate records a well-founded descent/coverage link and
the Lean checker proves that link reaches `1` within the accumulated step budget.

## Current assumption ledger

| ID | Mathematical proposition still assumed? | Present artifact and provenance | SHA-256 | What removes the assumption | Kernel accepts the proposition now? |
|---|---:|---|---|---|---:|
| FB-1 | **Yes** | Direct ordinary-kernel theorems now give the complete classification through `26017`. `research/finite_base_sources.md` audits the two larger local computations: the clean odd-core/lattice run represented every `1 ≤ n ≤ 10^9`, and the independent scalar replay directly checked every `3 ≤ n ≤ 10^9`. Both returned exactly the 593 published rows, but neither output is accepted by a Lean global-coverage checker. | Audit `a24f22769c6f7d295893159207e9067102d0431df0626aec7085d005697c17c3`; RT archive `9951c89da83b3e226e277585642b8bfc28d3410e9964904c51abdbd384663ab6`; checker `737b131b637ee4f191493f92e621209812fe84011e20c08ab7481ec44ce9ad5d`; witnesses/hits `c2255baa57392ef8ebc7da783c03b9797067776cc9cfe1904037ca426b5efa33` / `9a4db72c9c5ab79eda689f42a15d92ed5100abceee566442b9579a0894d0a37a`; optimized manifest/sums/run `1418ad38b73cc223d745477f6751e66d64ce5aec9d2b45c58a87da4cf813f505` / `3483e9cc639d434536e9ef50b775674241c8d4c6168c5108b57c011567ceb1d7` / `fc018b786b6736fce32b225ec7190e167941da909336a9ab84a67632751c59a3`; scalar source/fresh manifest/fresh sums/run `1127da520f9946c72e23818a90699df2ef369b5b913ed3ce9c7d50a9b9d455cf` / `033501eed471312f83b589bd204a697c02a21f6101964ecb8103ad73aa2cd752` / `6d68fc3d99557262b41b3a133304246c016fc29ec2f5a3035dd90a1e5eb32a16` / `7555d1cb54aae33cdc28d9b006238b5b91ab18b0935c0a95f85983b28a06eed4`. These hashes do not prove completeness. | A kernel-accepted all-prefix classification for the remaining starts `26018..10^9`, or an equivalent proof-producing coverage certificate combined with the verified prefix. | **No** |
| AE-1 | **No** | `firstExcursionEnvelope_kernel` is a completed direct Lean proof built from 114 ordinary-`decide` blocks. It is used internally by `Exclusion.lean`; the legacy `native_decide` comparison theorem is not on this proof path. | Aggregate `bd9a1dfd21ffc8a79790e5952768209cb72788fce26565d8d818dc289f99d403`; base `a48362b5689edf0af35e4781fb68414864d73c99f1ad3677e3232f10c1168a43`; record JSON cross-check `57ec514cee4ecc3fc96901b1f06ed64ebeb2545cdf3294d1b0ec93d737930b10`; all 114 block sources are bound by the final repository `SHA256SUMS`. | Already discharged by kernel reduction; rebuild the aggregate and run its axiom audit to reproduce it. | **Yes** |
| FG-OPT | **Yes, on the optimized route** | `OptimizedFiniteGap` asks only about `26017 < n ≤ 785412368`, `35 ≤ j`, and `j + oddCount n j < 2480`. The built classification through `26017` and affine theorem supply the internal start/length splits; the delay premise supplies the ordinary-prefix split. The two exact `10^9` scans are computational evidence for this smaller claim, but their retained files are still not proof-producing. | Shares the exact hit-list and run hashes recorded under `FB-1`; exploratory residue summaries are not trust inputs. | A kernel-accepted compositional cover of precisely the filtered gap, or a direct proof. The verified optimized Farey/envelope path reduces the required domain but does not itself prove this field. | **No** |
| DC-1 | **Yes** | `research/delay_cap_sources.md` and `provenance/delay_cap/` pin the official convergence/class-record pages, tables, GPU 6.41 and CPU 6.0.2 binaries, and a derived CPU decompilation. The public project collects per-unit logs by private email; it publishes neither those logs nor a manifest, CUDA source, or proof-producing coverage data. `DelayCertificate.lean` kernel-proves a point-indexed descent-DAG checker and `ColDelayCap 20 20`; no target-scale data is present. | Delay-source audit `89703576a01ca18d323c4813f0bc36aa9316ff493d5cdbd2563d09041ae8de84`; delay checker `38bee14a507d9207f5e7c13460991718c6212ce4149878cc8f23564d333734bd`; main convergence/status page `4bf0c36bf4d779f4f09814d742c2d4d5b40c26c1120a066636d1449a28a567f5`; progress page `64b42e1ad232e7748f5bfedd6e230b0233b47827e62e9428a40b403dc846dcd2`; class table `ff85440b5aff69831d691992fd2e992a457ab1bb53d3c4c4c992034ef56692da`; GPU archive `4eff1acf99b7788602f93772fccb3032e05e1f75be496c68b03dc0de4e87375f`; CPU archive `074c35576c888b07361784881c56561b244b79fe479dd750e784ebfe458e0067`. | A complete proof-producing coverage certificate for every `1 ≤ n ≤ 46499999999999999999`, with leaves establishing an ordinary visit to `1` within 2480 steps, accepted by a Lean-proved compressed checker. Raw project logs plus exact GPU source/build and assignment manifest are the narrowest unavailable record-holder inputs from which to construct it; no hashes are available because those artifacts are not public. | **No** |

On the original record-based route, because `FB-1` and `DC-1` remain
mathematical assumptions, the `4.65×10^19` exclusion is **conditional**, not
unconditional. No external maximum-excursion assumption remains.

The verified optimized theorem route replaces `FB-1` with `FG-OPT`, but it
still depends on `DC-1`. The internal range, Farey module, envelope, target,
classifier reconstruction, root build, and audits are all kernel-accepted.
Only the two mathematical fields `FG-OPT` and `DC-1` prevent an unconditional
result on this route.

## Non-mathematical proof-engine boundary

The project may use ordinary Mathlib axioms such as quotient soundness,
propositional extensionality, and choice; these are not hidden record claims.
Of the three original finite inputs, `AE-1` is now discharged by ordinary kernel
reduction.  The intended path for `FB-1` and `DC-1` remains kernel reduction or
kernel-checked proof terms produced from explicit data.  Use of `native_decide`
is disclosed separately because it relies on Lean's native-code evaluation
bridge; it is not used to clear this ledger.

The reducible circuit/CNF/LRAT checker is a legitimate kernel-proof path: it
checks that a static DIMACS formula matches the Lean-generated circuit and
reconstructs the LRAT refutation as an explicit proposition proof. Its current
26/27 one-step certificate is nevertheless labeled **technology demonstration,
not target-scale coverage**. The separate stock `bv_check` benchmarks use a
native-reflection axiom and likewise do not clear any ledger item.

## Phase log

### Phase 0 — predicate and semantic audit (complete)

- Verified the three original external predicates and the strict/inclusive
  conversion used by the target theorem.  The current `CurrentDelayInputs`
  structure has exactly two fields because the excursion predicate was later
  discharged internally.
- Verified accelerated versus ordinary map conventions, odd-step counting,
  total stopping time semantics, and handling of `0`, `1`, `2`, and the trivial
  `(1,2)` accelerated cycle.
- Produced this trust ledger before treating any newly located external number
  as evidence.
- Remaining assumptions: `FB-1`, `AE-1`, and `DC-1`.
- Next highest-value action: locate authentic raw/code artifacts for `FB-1` and
  `DC-1` while implementing a Lean certificate for manageable `AE-1`.

### Phase 1 — public artifact and algorithm audit (complete)

- Verified that the Rozier--Terracol v5 source archive contains no finite-search
  code or negative-coverage artifact; Appendix C is a positive list only.
- Audited the nearest public fixed-parity and reproduction programs and recorded
  why neither establishes the inclusive `10^9` universal predicate.
- Preserved and hashed Roosendaal's official definitions, progress grid,
  class/delay tables, search instructions, technical page, and downloadable
  workers. Decompiled the historical managed CPU worker as a derived audit aid.
- Verified the exact source-to-Lean match for ordinary total delay, positivity,
  the half-open record boundary, and the class-record implication.
- Located no public raw work-unit logs, coverage manifest, current CUDA source,
  or proof-producing certificate. The official instructions say logs are emailed
  to the record holder.
- Files produced: `research/finite_base_sources.md`,
  `research/delay_cap_sources.md`, and `provenance/delay_cap/`.
- Remaining mathematical assumptions: `FB-1`, `AE-1`, and `DC-1`.
- Next highest-value action: complete kernel reduction for `AE-1` and finish the
  independently replayable `10^9` computation without confusing it with a
  kernel certificate.

### Phase 2 — local certificate construction (complete)

- Kernel-proved reference checkers were built for finite-classification lattice
  leaves and ordinary-delay descent DAGs. Their pure-kernel demonstrations
  establish, respectively, the sharp empty classification through `6` and
  `ColDelayCap 20 20`; neither demo is substituted for a target-scale claim.
- After the crash-resumed exploratory scan, a clean reuse-disabled odd-core run
  recomputed all 4,096 shards through inclusive `10^9` in about 6,751 seconds.
  It returned exactly 593 rows (550 starts), maximum start 4614, and hit-list
  SHA-256
  `9a4db72c9c5ab79eda689f42a15d92ed5100abceee566442b9579a0894d0a37a`.
- All 114 first-excursion blocks were reduced with ordinary `decide` and the
  aggregate theorem `firstExcursionEnvelope_kernel` was built. Its axiom audit
  lists only `propext`, `Classical.choice`, and `Quot.sound`; `AE-1` is therefore
  discharged without the legacy native-evaluation theorem.
- A separate incremental checker reduced 54 ordinary-`decide` blocks and built
  the unconditional theorem `no_paradoxical_start_4615_through_10014` for every
  segment length. Its aggregate/generic source hashes are
  `ac18bda22ea372e6a51acc9d8cd75a658484c1e15be4cfece74421b650f4b8d3`
  and `fb1ef82a009ff8b9901e035fb8fee27828259e3d4a6f908081b14b2c7122c5da`.
- Remaining mathematical assumptions at phase close: `FB-1` and `DC-1`.
- Next highest-value action: independently replay the complete scalar scan and
  then re-audit the exact final theorem path.

### Phase 3 — independent replay and final trust audit (complete)

- From an empty checkpoint directory, the source-bound scalar verifier followed
  every start `3..10^9` and every positive accelerated prefix through its first
  exact visit to `1`. It covered 999,999,998 starts in 5,245.591715 seconds,
  reproduced exactly 593 rows and the same hit-list hash, and recorded
  135,705,965,843 accelerated steps. Its maximum accelerated delay was 616 and
  maximum ordinary delay 986, both first at 670,617,279; its maximum accelerated
  state was 707,118,223,359,971,240, first at 319,804,831.
- A second pass validated and reused all 4,096 scalar shards in 1.013257 seconds.
  This is labelled an integrity/identity validation, not another trajectory
  computation. The fresh manifest, sums, and run-record hashes are in `FB-1`.
- The full Lean project and standalone axiom audits built successfully. The
  strict-endpoint theorem `target_exclusion_of_remaining_inputs`, phase-3-built
  source SHA-256
  `ac0a7d7f4e5a5e3afaea597438216163562ae7d18ea413e53462268c91a69946`,
  has only standard Mathlib axioms and is conditional on exactly the two fields
  `FB-1` and `DC-1`. The same file now also contains the verified optimized
  reduction and has current SHA-256
  `041ee224ad1721f7202b6abe7729dd6b4cd86c1aa686a3083d3cc3e416af6971`;
  the subsequent 9,040-job root build and full axiom-audit sweep passed.
- Strongest unconditional target-shaped result at phase-3 close: no
  paradoxical segment of any length starts at an `n` with
  `4614 < n ≤ 10014`.
- Final mathematical assumptions: `FB-1` and `DC-1`. Therefore the requested
  `4.65×10^19` theorem is not called unconditional.
- Next exact work: generate a Lean-accepted trace/coverage certificate for
  inclusive `10^9`; independently, obtain or reconstruct a proof-producing
  residue-coverage certificate for `[1,46500000000000000000)` with ordinary
  visit-to-`1` budgets at most 2480. The latter is the dominant public-artifact
  bottleneck.

### Phase 4 — affine and optimized finite reduction (proof-engine complete)

Verified:

- Built the 47-block ordinary-kernel classifier and its production bridge,
  proving the complete 593-row classification through inclusive start `4614`
  for every length.
- Proved the symbolic affine endpoint bound and the exact consequence that a
  paradoxical segment above `26017` must have `j ≥ 35`.
- Built the forty 400-start `Range26017` blocks, exact three-start tail, and
  aggregate. The arbitrary-length exclusion and complete classification
  through `26017` audit to only `propext`, `Classical.choice`, and `Quot.sound`;
  the all-block Boolean uses only `propext` and `Quot.sound`. The sealed
  162-entry source manifest under `certificates/kernel-range-26017/` has
  detached digest
  `9ae3954aff8da49857bca68dba64b02b3bfc66374294fc8ae7a37d5a9ef5a1bb`.
- Built and audited the small reducible circuit/CNF/LRAT demonstration. It
  checks a genuine accelerated step but is not target-scale coverage.
- Built the exact Farey seed `99781`, all 99 optimized 1,000-start envelope
  blocks, and tail `99000..99780`. The 1,004.896-second paired replay proves
  `AcceleratedExcursionEnvelope 785412369 99781` and the sharp equality
  `endpoint 77671 39 = 785412368`. Fuel 134 fails closed and fuel 135 accepts
  the extremal first-descent start `35655`. The envelope audit lists only
  `propext`, `Classical.choice`, and `Quot.sound`; concrete reductions and the
  peak equality use no axioms.
- Built and audited `finiteBaseClassification_785412368_of_optimized_inputs`
  and `target_exclusion_of_optimized_inputs`. Together with
  `optimizedFirstFarey_valid`, they audit to only `propext`,
  `Classical.choice`, and `Quot.sound`. The current root build passed with
  9,040 jobs, followed by the complete axiom-audit and circuit-audit sweep.
  These theorems have no native bridge and remain conditional on the fields of
  `OptimizedCurrentInputs`.
- Sealed and independently verified the 106-source envelope package. Its
  source-manifest digest is
  `910dfa86fa2812b461bdfde2572db650e855699fc8ae430ff2d907f3e49779b9`;
  semantic-source hash
  `15d495cddf760905fad5d21fa50677be102b6ea9a2d9433e821e2755c6d31f51`;
  package-`SHA256SUMS` hash
  `9077033661a33d4df93a22eb049b5630c19f654ffc1d11d496e187be0c622ed7`.
- Recorded exact negative compression measurements. The sound induction rule
  gives 73,983 singleton leaves on `26018..100000`; on
  `26018..1000000`, the richer exact tail profile still makes 956,448 point
  queries, and the maximum-excursion summary has 901,476 singleton leaves.
  Detailed tables and hashes are in
  [notes/residue-certificate-benchmarks.md](../notes/residue-certificate-benchmarks.md).

Remaining mathematical assumptions, not pending proof-engine builds:

- The optimized reduction has exact remaining fields `FG-OPT` and `DC-1`.
  `FG-OPT` is restricted to `26017 < n ≤ 785412368`, `35 ≤ j`, and
  `j + oddCount n j < 2480`; the generic delay lemma derives the last filter
  from `DC-1` when reconstructing the finite classifier.

The narrow finite bottleneck is the relational affine-cylinder tail invariant
spelled out in
[notes/residue-certificate-benchmarks.md](../notes/residue-certificate-benchmarks.md);
state-only or
fixed-parity summaries lose the needed original/tail correlation. The
independent and larger external bottleneck remains `DC-1`.
