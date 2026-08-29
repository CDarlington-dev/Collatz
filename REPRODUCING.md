# Reproducing the checks

All commands below are PowerShell commands run from the repository root. All
certificate decisions use integer arithmetic.

## 1. Toolchain and bounded Lean build

The repository pins Lean `4.32.1` and mathlib `v4.32.1`.  The five generated
families whose completed results are already recorded are built as follows:

```powershell
& .\scripts\build_kernel_blocks.ps1 -Family Base
& .\scripts\build_kernel_blocks.ps1 -Family Range
& .\scripts\build_kernel_blocks.ps1 -Family Range26017
& .\scripts\build_kernel_blocks.ps1 -Family Excursion
& .\scripts\build_kernel_blocks.ps1 -Family OptimizedExcursion
lake build
```

`Base` proves the complete published classification through `4614`; `Range`
excludes `4615..10014`; `Range26017` extends the exclusion and complete
classification through `26017`; `Excursion` proves the original
first-excursion envelope; and `OptimizedExcursion` proves the sharp envelope
`AcceleratedExcursionEnvelope 785412369 99781`. The recorded current root build
then passed with 9,040 jobs. Because the public import surface references the
generated sources, a bare full-project build must follow all required
block-family builds rather than being used to launch many reducers at once.

The checked block script expects the development checkout's workspace-local
Elan installation at `.tooling\elan-home`. Its equivalent final project build
is:

```powershell
$env:ELAN_HOME = "$PWD\.tooling\elan-home"
& "$env:ELAN_HOME\bin\lake.exe" build
```

During each block-family loop, the script submits exactly two block targets to
each Lake invocation. The base and final aggregate are separate single-target
invocations. This is the checked concurrency control on the recorded
16-logical-processor host. Lake 5 ignored the former `-Kjobs=2` recipe as a
concurrency cap and spawned 16 reducers, so that option must not be used for
these generated proofs.

The verified generated pure-kernel aggregates are the classification through
`4614`, both first-excursion envelopes, and the direct
exclusion/classification through `26017`. Their audits disclose only standard
Lean/Mathlib logical axioms, with no native-decision axiom.

The first-excursion aggregate contains 114 ordinary-`decide` blocks. Blocks
43, 46, and 48 through 113 set `maxHeartbeats 500000`; all other blocks use the
default heartbeat setting. `FirstExcursion.lean` retains a legacy
native-decision comparison theorem, but neither
`firstExcursionEnvelope_kernel` nor the target exclusion uses it.

After a successful full build, list and run every committed axiom audit:

```powershell
rg --files -g '*AxiomAudit.lean'
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\Finite\AxiomAudit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\Finite\ClassificationCertificateAxiomAudit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\Finite\DelayCertificateAxiomAudit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\Finite\NoParadoxicalRangeAxiomAudit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\Finite\BaseClassificationAxiomAudit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\Finite\NoParadoxicalRange26017AxiomAudit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\AffineBoundAxiomAudit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\Circuit\Audit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\Finite\OptimizedFirstExcursionAxiomAudit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\OptimizedFareyAxiomAudit.lean
& "$env:ELAN_HOME\bin\lake.exe" env lean .\audit\AxiomAudit.lean
```

The recorded run passed every audit above, including the optimized target and
classifier reconstruction. Do not promote generated source, a partial block
set, or an unrecorded local object file to a verified aggregate.

Compare the list printed by `rg` with the commands before relying on the audit;
this avoids silently omitting a newly added audit.

## 2. Verified local kernel additions

The complete classifier through `26017`, the affine preprocessing lemmas, and
the small production-format LRAT demonstration can be rebuilt directly:

```powershell
& .\scripts\build_kernel_blocks.ps1 -Family Base
& .\scripts\build_kernel_blocks.ps1 -Family Range
& .\scripts\build_kernel_blocks.ps1 -Family Range26017
& "$env:ELAN_HOME\bin\lake.exe" build Collatz.AffineBound
& "$env:ELAN_HOME\bin\lake.exe" build Collatz.Certified.Circuit.Demo
& "$env:ELAN_HOME\bin\lake.exe" build Collatz.Certified.Circuit.Audit
```

The base aggregate proves
`FiniteBaseClassification 4614 PublishedClassification`; the two range
families extend it to `FiniteBaseClassification 26017 PublishedClassification`.
The affine theorem
proves `j >= 35` for a paradoxical segment with `n > 26017`.  The circuit demo
checks a static CNF/LRAT refutation for one real 8-bit accelerated step on the
two inputs 26 and 27.  Its evidence label is **kernel-checked technology
demonstration, not target-scale finite coverage**; it does not discharge
`FB-1`.

The sealed range replay package is documented in
[`certificates/kernel-range-26017/`](certificates/kernel-range-26017/README.md).
Its check-only wrapper generator, conservative paired replay, and detached
manifest check are:

```powershell
& .\certificates\kernel-range-26017\generate_blocks.ps1
& .\certificates\kernel-range-26017\build_paired.ps1
python .\verifier\verify_source_manifest.py `
  .\certificates\kernel-range-26017\source-manifest.sha256
```

The last command independently checks all 162 workspace-relative files and
must report
`9ae3954aff8da49857bca68dba64b02b3bfc66374294fc8ae7a37d5a9ef5a1bb`.

The optimized envelope has its own sealed replay package at
[`certificates/optimized-first-excursion-99781/`](certificates/optimized-first-excursion-99781/README.md).
Its production replay, audit, and independent 106-row source-manifest check are:

```powershell
& .\scripts\build_optimized_first_excursion.ps1
& "$env:ELAN_HOME\bin\lake.exe" env lean `
  .\Collatz\Certified\Finite\OptimizedFirstExcursionAxiomAudit.lean
python .\verifier\verify_source_manifest.py `
  .\certificates\optimized-first-excursion-99781\SOURCE-SHA256SUMS
```

The last command must report 106 unique files and manifest digest
`910dfa86fa2812b461bdfde2572db650e855699fc8ae430ff2d907f3e49779b9`.
The semantic checker source is
`15d495cddf760905fad5d21fa50677be102b6ea9a2d9433e821e2755c6d31f51`,
and the package `SHA256SUMS` hashes to
`9077033661a33d4df93a22eb049b5630c19f654ffc1d11d496e187be0c622ed7`.

## 3. Compact exact checks

```powershell
node .\tools\verify_exact.mjs
python .\verifier\reference.py
```

These programs recompute the fixed Farey data, trajectory fixtures, and 593
published positive witnesses. Positive-witness checking alone is not an
exhaustive classification.

The package manifest can be checked after it has been regenerated for the
final repository state:

```powershell
python .\verifier\package_hashes.py
```

## 4. Inspect the committed clean `10^9` computation

```powershell
Get-FileHash .\certificates\finite-1000000000\hits.csv -Algorithm SHA256
Get-FileHash .\certificates\finite-1000000000\manifest.json -Algorithm SHA256
Get-FileHash .\certificates\finite-1000000000\SHA256SUMS -Algorithm SHA256
Get-FileHash .\tools\odd_core_scan.py -Algorithm SHA256
```

Expected lowercase hashes are:

```text
hits.csv       9a4db72c9c5ab79eda689f42a15d92ed5100abceee566442b9579a0894d0a37a
manifest.json  1418ad38b73cc223d745477f6751e66d64ce5aec9d2b45c58a87da4cf813f505
SHA256SUMS     3483e9cc639d434536e9ef50b775674241c8d4c6168c5108b57c011567ceb1d7
generator      8e2e3c853fab300f7db8abf6ed2c8d5bc6d3df4a1243c6937feca3fbc084e296
```

The manifest must state limit `1000000000`, 4,096 shards, 1,000,000,000
represented starts, 593 rows, 550 distinct starts, and maximum start 4614.

## 5. Regenerate the optimized certificate from scratch

Generate into a separate directory so that the committed evidence remains
untouched:

```powershell
python .\tools\odd_core_scan.py --limit 1000000000 `
  --workers 8 --shards 4096 `
  --output-dir .\build\finite-1000000000 --no-resume
```

`--no-resume` is essential for reproducing the recorded clean run: every shard
must be recomputed by the hash-pinned generator. Compare the resulting hit
list and manifest with the hashes above. The recorded command launch was
20:02:54 EDT, the first and last shard timestamps were 20:02:59 and 21:54:33,
and the original final manifest was written at 21:55:25. The observed wall
interval was about 6,751 seconds (1 h 52 min 31 s). See
`certificates/finite-1000000000/RUN.md` for the complete run record.

The optimized algorithm follows each odd core and solves exact integer lattice
intervals. The 4,096 shard files and manifest make its work inspectable, but
the present Lean leaf checker does not yet prove that this external collection
covers every core and every relevant prefix.

## 6. Reproduce the completed independent scalar replay

The source-bound scalar verifier uses a different algorithm: it iterates every
start and every accelerated prefix directly. Its SHA-256 is
`1127da520f9946c72e23818a90699df2ef369b5b913ed3ce9c7d50a9b9d455cf`.

For a genuinely independent production replay, choose a checkpoint directory
that does not exist before launch and include `--no-resume`. The following
keeps the committed evidence untouched:

```powershell
python .\verifier\scalar_scan.py --limit 1000000000 `
  --hits .\certificates\finite-1000000000\hits.csv `
  --workers 8 --shards 4096 `
  --checkpoint-dir .\build\scalar-1000000000-fresh `
  --no-resume
```

The recorded zero-reuse run covered all 999,999,998 starts from 3 through
`10^9`, reported `PASSED`, found 593 rows with hit hash
`9a4db72c9c5ab79eda689f42a15d92ed5100abceee566442b9579a0894d0a37a`,
and took 5,245.591715 seconds. It traversed 135,705,965,843 accelerated steps;
the maximum accelerated delay was 616 at 670617279, the maximum ordinary delay
was 986 at the same start, and the maximum state was 707118223359971240 at
319804831.

The preserved fresh aggregate hashes are:

```text
manifest-fresh.json  033501eed471312f83b589bd204a697c02a21f6101964ecb8103ad73aa2cd752
SHA256SUMS-fresh     6d68fc3d99557262b41b3a133304246c016fc29ec2f5a3035dd90a1e5eb32a16
```

Run the same command without `--no-resume` to validate checkpoint identity and
reuse:

```powershell
python .\verifier\scalar_scan.py --limit 1000000000 `
  --hits .\certificates\finite-1000000000\hits.csv `
  --workers 8 --shards 4096 `
  --checkpoint-dir .\build\scalar-1000000000-fresh
```

The recorded reuse pass validated 4,096/4,096 shards, reported `PASSED`, and
took 1.013257 seconds. The resulting live hashes are:

```text
manifest.json  69c4add41a1198ce3402ed0e8287cc2af4a53a0e8eb0d4c4be9d9927aed8a85c
SHA256SUMS     99a8c9f79585ab8bbfb8bc45a331ce2ec92233027e6e30c4cf2fe395dd325c2
```

Version-2 checkpoints embed the verifier source hash and are checked for exact
parameters, assigned range, canonical encoding, payload hash, and coverage
count. Reuse validation does not recompute trajectories, and unkeyed hashes can
be forged. The fresh pass is strong independent exact computational evidence,
but neither pass constructs the Lean term required by
`FiniteBaseClassification`. See
`certificates/scalar-1000000000/RUN.md` for the full record and the exact
production command, which used the certificate directory before it existed.

## 7. Reproduce the residue-compression measurements

These are exact design measurements, not trusted certificates. Representative
gap-relevant commands are:

```powershell
python .\prototypes\finite_base_certificate\analyze_inductive_residue_tree.py `
  --lo 26018 --hi 100000
python .\prototypes\finite_base_certificate\analyze_filtered_tail_tree.py `
  --lo 26018 --hi 1000000
python .\prototypes\finite_base_certificate\analyze_excursion_tail_tree.py `
  --lo 26018 --hi 1000000
```

The first command produces one singleton leaf for each of its 73,983 starts.
On `26018..1000000`, the exact tail-profile route still uses 579,041 leaves and
956,448 point-profile queries, while the maximum-excursion summary uses 922,107
leaves, including 901,476 singletons. Since `2^35 > 10^9`, a fixed parity
residue at a remaining length already selects at most one start. The detailed
tables, exact missing relational invariant, and source hashes are in
[notes/residue-certificate-benchmarks.md](notes/residue-certificate-benchmarks.md).

## 8. Exact theorem boundary

The target Lean implication now consumes only:

```text
FiniteBaseClassification 1000000000 PublishedClassification
ColDelayCap 46499999999999999999 2480
```

The first accelerated excursion envelope is supplied internally by generated
pure-kernel proof source. The target is not unconditional until both remaining
predicates are discharged by Lean proofs or by data accepted through a
Lean-proved checker.

The finite-side missing bridge is a proof that the full shard coverage implies
the exact classifier, including every prefix and uniqueness of odd-core
coverage. The delay-side missing artifact is a proof-producing, hash-pinned
coverage certificate for every ordinary-Collatz start in
`[1,46500000000000000000)`, with an exact visit to 1 within 2480 ordinary
steps, accepted by a Lean-proved compressed checker. Naive enumeration is not
the intended route.

The optimized theorem route is now built and audited. Its exact conditional
input remains

```text
finiteGap : 26017 < n -> n <= 785412368 -> 35 <= j ->
            j + oddCount n j < 2480 -> not Paradoxical n j
delayCap  : ColDelayCap 46499999999999999999 2480
```

The internal range through `26017`, exact Farey seed `99781`, sharp envelope,
optimized exclusion target, classifier reconstruction, root build, and audits
are all verified. The one-unit distinction is exact: the finite gap ends at
`785412368`, while the strict envelope route starts at `785412369`. A generic
Lean lemma derives the displayed ordinary-prefix filter from `delayCap`; the
classifier-reconstruction theorem therefore takes the complete
`OptimizedCurrentInputs`, not `finiteGap` alone. This proof-engine promotion
does **not** prove either input: the optimized target remains conditional on
the displayed filtered finite gap (`FG-OPT`) and `DC-1`.

Consult [docs/TRUST-BOUNDARY.md](docs/TRUST-BOUNDARY.md) before describing any
result as unconditional.
