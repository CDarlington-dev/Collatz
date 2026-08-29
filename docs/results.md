# Results and evidence boundary

## Definition and semantic match

For the accelerated map

\[
T(n)=n/2\quad(n\text{ even}),\qquad
T(n)=(3n+1)/2\quad(n\text{ odd}),
\]

let `q` count the odd inputs among
`n,T(n),...,T^(j-1)(n)`. The Lean predicate is

```text
Paradoxical n j :=
  2 < n /\ 0 < j /\ 3^(oddCount n j) < 2^j /\ n <= endpoint n j
```

Thus the endpoint inequality is non-strict, while both proposed exclusion
endpoints are strict. Ordinary delay means an exact visit to 1 under the
ordinary map `C(n)=n/2` for even `n` and `C(n)=3n+1` for odd `n`; it is not an
accelerated-step count or merely a first descent below the start.

## Status summary

| Statement | Current status | Qualification |
|---|---|---|
| Map, odd count, endpoint, paradoxical predicate | Lean definition/theorem | Exact accelerated convention above |
| Generic arithmetic, Farey barrier, and exclusion reduction | Lean theorem | External finite claims remain explicit parameters |
| Complete published classification through start `4614` | **Unconditional pure-kernel Lean theorem** | 47 ordinary-`decide` blocks check every prefix and every listed row; stronger than positive-witness validation |
| Exactly 593 rows, 550 starts, maximum start 4614 for `n <= 10^9` | Two completed exact computations | Clean optimized scan and fresh zero-reuse scalar replay agree; Lean coverage bridge still missing |
| Every accelerated orbit starting below 113383 stays below `10^9` | **Unconditional pure-kernel Lean theorem** | Built from 114 ordinary-`decide` blocks; audit has only `propext`, `Classical.choice`, and `Quot.sound` |
| Complete published classification through start `26017` | **Unconditional pure-kernel Lean theorem** | The verified base and two direct-range families exclude every additional start; arbitrary segment length, no native axiom |
| A paradoxical segment with `n > 26017` has `j >= 35` | Lean theorem | Exact symbolic affine bound; not a range classification |
| Circuit/CNF/LRAT checker and 26/27 one-step demo | **Kernel-checked technology demonstration** | Static 48-variable, 206-clause formula; no native axiom, but no target-scale coverage |
| No paradoxical start from 10015 through 26017 | **Unconditional pure-kernel Lean theorem** | Forty 400-start blocks plus a three-start tail, fuel 178; aggregate and audit passed |
| `AcceleratedExcursionEnvelope 785412369 99781` and exact Farey seed 99781 | **Unconditional pure-kernel Lean theorems** | 99 ordinary-`decide` blocks plus exact tail; aggregate, sharpness theorem, and audits passed |
| Optimized classifier through `785412368` and target exclusion | Lean theorems conditional on `OptimizedCurrentInputs` | Proof-engine path built and audited; `FG-OPT` and `DC-1` remain mathematical inputs |
| `4614 < n < 46500000000000000000` contains no paradoxical start | Lean implication conditional on two predicates | **Not unconditional** |
| Full ordinary delay cap through `46499999999999999999` | External mathematical assumption | No public proof-producing coverage artifact located |

No theorem structure postulates a record page as an axiom. The current target
input structure contains exactly:

```text
finiteBase : FiniteBaseClassification 1000000000 PublishedClassification
delayCap   : ColDelayCap 46499999999999999999 2480
```

The first-excursion envelope is no longer a field of that structure.

The verified optimized theorem takes the structure

```text
finiteGap : 26017 < n -> n <= 785412368 -> 35 <= j ->
            j + oddCount n j < 2480 -> not Paradoxical n j
delayCap  : ColDelayCap 46499999999999999999 2480
```

Its internal range through `26017`, Farey module, envelope aggregate, target,
classifier reconstruction, root build, and audits are verified. The two
displayed fields remain mathematical inputs. A generic Lean lemma derives the
ordinary-prefix filter from `delayCap`, so the classifier reconstruction
consumes the complete optimized input structure, not the gap field alone. The
one-unit boundary is exact: the finite gap ends at
`785412368`, while the strict envelope/Farey route applies from `785412369`
upward.

## Clean finite computation through `10^9`

The clean run recomputed all 4,096 manifest-listed odd-core shards with
`--no-resume`. The canonical results are:

| Quantity | Value |
|---|---:|
| Represented starts | 1,000,000,000 |
| Odd cores | 500,000,000 |
| Hit rows | 593 |
| Distinct hit starts | 550 |
| Minimum/maximum hit start | 7 / 4614 |
| Odd blocks | 34,969,255,812 |
| Accelerated steps from odd cores | 69,762,619,290 |
| Maximum accelerated delay | 616 at start 670617279 |
| Maximum state | 707118223359971240 at start 319804831 |

The seven `(j,q)` group counts are 5, 50, 231, 2, 244, 56, and 5 for
`(8,5)`, `(27,17)`, `(46,29)`, `(54,34)`, `(65,41)`, `(73,46)`, and
`(92,58)` respectively.

Principal hashes:

```text
hits.csv       9a4db72c9c5ab79eda689f42a15d92ed5100abceee566442b9579a0894d0a37a
manifest.json  1418ad38b73cc223d745477f6751e66d64ce5aec9d2b45c58a87da4cf813f505
SHA256SUMS     3483e9cc639d434536e9ef50b775674241c8d4c6168c5108b57c011567ceb1d7
generator      8e2e3c853fab300f7db8abf6ed2c8d5bc6d3df4a1243c6937feca3fbc084e296
```

The independent scalar replay started from an empty checkpoint directory with
`--no-resume`, iterated all 999,999,998 starts from 3 through `10^9`, and
reported `PASSED` with the same 593 rows and hit-list hash. It completed in
5,245.591715 seconds after 135,705,965,843 accelerated steps. Its maximum
accelerated delay was 616 at 670617279, maximum ordinary delay was 986 at the
same start, and maximum state was 707118223359971240 at 319804831.

Scalar evidence hashes:

```text
verifier source       1127da520f9946c72e23818a90699df2ef369b5b913ed3ce9c7d50a9b9d455cf
fresh manifest        033501eed471312f83b589bd204a697c02a21f6101964ecb8103ad73aa2cd752
fresh SHA256SUMS      6d68fc3d99557262b41b3a133304246c016fc29ec2f5a3035dd90a1e5eb32a16
reuse-pass manifest   69c4add41a1198ce3402ed0e8287cc2af4a53a0e8eb0d4c4be9d9927aed8a85c
reuse-pass SHA256SUMS 99a8c9f79585ab8bbfb8bc45a331ce2ec92233027e6e30c4cf2fe395dd325c2
```

The reuse pass validated 4,096/4,096 checkpoints in 1.013257 seconds. It did
not recompute their trajectories. The clean optimized scan and fresh scalar
replay are strong independent exact computational evidence, but their external
files are not accepted by a Lean-proved global-coverage checker and therefore
do not yet construct the exact Lean finite-classification predicate.

## Pure-kernel finite source

`BaseClassificationKernel.lean` assembles 47 ordinary-`decide` blocks and
proves the built theorem

```text
FiniteBaseClassification 4614 PublishedClassification.
```

Unlike the billion-scale external scans, this theorem checks the negative
classification as well as every one of the 593 literal positive rows.  It
fails closed if a trajectory does not enter `{0,1,2}` within its checked fuel.

`FirstExcursionKernel.lean` assembles 114 generated ordinary-`decide` block
proofs into the built theorem

```text
AcceleratedExcursionEnvelope 1000000000 113383.
```

`NoParadoxicalRangeKernel.lean` assembles direct prefix checks for every start
from 4615 through 10014 and derives the built theorem

```text
4614 < n /\ n <= 10014  ->  not Paradoxical n j.
```

For the excursion build, blocks 43, 46, and 48 through 113 use explicit
`maxHeartbeats 500000`; the remaining blocks use the default. Both finite
routes use ordinary `decide`, not `native_decide`. Their soundness theorems
fail closed on exhausted fuel and prove that the checked Boolean result implies
the mathematical predicate. Both aggregate builds succeeded, and both audits
list only `propext`, `Classical.choice`, and `Quot.sound`. They are therefore
unconditional finite Lean theorems with no native-decision trust boundary.

`NoParadoxicalRange26017Kernel.lean` adds forty 400-start blocks and the exact
tail `26015..26017`, all with fail-closed fuel 178. The paired replay completed
in 1,697.504 seconds; the aggregate built in 17.870 seconds. Its audit reports
`propext` and `Quot.sound` for the all-block Boolean, and only `propext`,
`Classical.choice`, and `Quot.sound` for the arbitrary-length exclusion and
complete classification through `26017`. No native evaluator axiom occurs.
The sealed replay package and 162-entry source manifest are documented in
[`certificates/kernel-range-26017/`](../certificates/kernel-range-26017/README.md);
the detached manifest digest is
`9ae3954aff8da49857bca68dba64b02b3bfc66374294fc8ae7a37d5a9ef5a1bb`.

`AffineBound.lean` independently proves the universal scaled endpoint bound
and its exact numerical consequences:

```text
4614 < n  and Paradoxical n j  ->  27 <= j
26017 < n and Paradoxical n j  ->  35 <= j.
```

The production-format circuit path reconstructs a static CNF/LRAT proof term
and proves that the corresponding circuit has no model.  Its committed demo
uses one genuine 8-bit accelerated step on inputs 26 and 27.  This validates
the checker and trust path only; it is deliberately not evidence for `FB-1`.

`FirstExcursion.lean` retains a legacy native-decision theorem for comparison.
It is not imported as evidence by `firstExcursionEnvelope_kernel` and is not
used in the target exclusion.

For reproducible builds, `scripts/build_kernel_blocks.ps1` submits exactly two
block targets per Lake invocation during each block-family loop; its base and
aggregate builds are separate single-target invocations. The verified `Base`,
`Range`, `Range26017`, `Excursion`, and `OptimizedExcursion` families use this
bounded-pair design. Lake 5 did not treat
`-Kjobs=2` as a concurrency
limit here and instead spawned 16 reducers; no result relies on that obsolete
command.

## Conditional target theorem

The deterministic chain is:

1. The finite classifier handles starts through `10^9`.
2. The internally proved first excursion envelope forces any larger
   paradoxical segment to remain at or above 113383.
3. Exact Farey feedback forces `j >= 1539` and `q >= 971`.
4. Its corresponding ordinary prefix has length `j+q >= 2510`.
5. A visit to 1 within 2480 ordinary steps puts the later accelerated endpoint
   in the `1,4,2` tail, contradicting a paradoxical endpoint for `n > 4614`.

Lean formalizes this implication for the strict interval

```text
4614 < n < 46500000000000000000.
```

The formal implication is not an unconditional theorem because its
`finiteBase` and `delayCap` arguments have not been constructed.

## Verified optimized reduction (conditional inputs remain)

The built exact Farey certificate at seed `99781` has feedback sums
`j >= 1539`, `q >= 971`, and `j+q >= 2510`. The sharp first-excursion theorem
uses the strict state threshold `785412369`, and Lean proves
`endpoint 77671 39 = 785412368`. Together with the built direct range through
`26017`, the optimized theorem reduces the finite input to

```text
26017 < n <= 785412368,
35 <= j,
j + oddCount n j < 2480.
```

All 99 full 1,000-start blocks and the exact 781-start tail `99000..99780`
passed ordinary kernel reduction. The paired replay took 1,004.896 seconds;
fuel 134 fails closed and fuel 135 accepts the extremal first-descent start
`35655`. The envelope audit lists only `propext`, `Classical.choice`, and
`Quot.sound`; concrete reductions and the peak equality use no axioms. The
optimized Farey theorem, target, classifier reconstruction, 9,040-job root
build, and full audit sweep also passed with no native bridge.

The sealed package is
[`certificates/optimized-first-excursion-99781/`](../certificates/optimized-first-excursion-99781/README.md).
Its 106-entry source-manifest digest is
`910dfa86fa2812b461bdfde2572db650e855699fc8ae430ff2d907f3e49779b9`;
the semantic source is
`15d495cddf760905fad5d21fa50677be102b6ea9a2d9433e821e2755c6d31f51`,
and the package `SHA256SUMS` hashes to
`9077033661a33d4df93a22eb049b5630c19f654ffc1d11d496e187be0c622ed7`.

The strict envelope route begins at `785412369`, but proof-engine completion
does not make the target unconditional. It still requires an exact proof of
the displayed filtered finite gap (`FG-OPT`) and the unchanged ordinary-delay
predicate `DC-1`; the classifier-reconstruction theorem consumes both.

## Narrow remaining bottlenecks

The kernel classifier has removed the finite uncertainty through `26017`. For the original `10^9`
route, the missing layer must still prove exact trajectory-to-1 handling,
every-prefix checking, unique odd-core/scaling coverage, complete shard-range
coverage, and equality with the published classification over the rest of the
domain. The committed external shards discarded the negative trajectory data
needed to construct that proof after the fact.

Exact residue-tree measurements also reject the simplest proposed compression.
The sound induction rule gives 73,983 singleton leaves on
`26018..100000`. On `26018..1000000`, the exact tail-profile tree still uses
579,041 leaves and 956,448 point-profile queries, while the state-only
maximum-excursion summary uses 922,107 leaves, including 901,476 singletons.
Because `2^35 > 10^9`, a fixed parity residue at any remaining length already
identifies at most one finite start. These are exact design experiments, not
trusted proofs. The narrow missing invariant is a relational tail bound that
preserves the correlation between original and tail states across an affine
cylinder. See
[notes/residue-certificate-benchmarks.md](../notes/residue-certificate-benchmarks.md)
for the full tables, exact invariant, and source hashes.

For the delay cap, the missing artifact is the record-holder's compressed
coverage evidence—or an independently generated equivalent—for the exact
half-open domain `[1,46500000000000000000)`, plus exact leaves showing a visit
to 1 within 2480 ordinary steps. Public pages and binary executables report the
record but do not provide a proof-producing coverage manifest. A Lean-proved
point-DAG checker exists for manageable data; the giant range needs a compact
coverage certificate rather than naive enumeration.

The authoritative, phase-updated ledger is
[TRUST-BOUNDARY.md](TRUST-BOUNDARY.md). The target may be called unconditional
only when that ledger contains no mathematical assumption.
