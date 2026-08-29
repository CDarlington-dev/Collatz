# Lean build and axiom-audit results

Run date: 2026-08-27 (America/New_York)

Toolchain: Lean 4.32.1, Lake 5.0.0, Mathlib v4.32.1.

## Build result

The next paragraph records the completed phase-3 build. Later additions are
listed separately so an in-progress aggregate is never mistaken for a checked
theorem.

The resource-bounded block driver compiled all 54 direct-range blocks and all
114 first-excursion blocks with ordinary `decide`.  Their aggregate modules,
`Collatz.Certified.Finite.NoParadoxicalRangeKernel` and
`Collatz.Certified.Finite.FirstExcursionKernel`, compiled successfully.  A
subsequent bare `lake build` completed successfully with 8,840 jobs in the
loaded build graph.

The first-excursion blocks 43, 46, and 48 through 113 use a file-level
`maxHeartbeats 500000`; all others use Lean's default.  This changes only the
deterministic elaboration budget, not the proof method or trust boundary.

The source scan taken with that phase-3 build found no `sorry`, `admit`, or
declared `axiom`.

## Later verified additions

- The 47 ordinary-`decide` base-classification blocks and their aggregate were
  built. `finiteBaseClassification_4614` and its production bridge prove the
  complete published classification through inclusive start `4614`, for every
  length. The dedicated audit reports no native-evaluation axiom.
- All forty 400-start `Range26017` blocks and the exact three-start tail built
  with fuel 178. The paired loop took 1,697.504 seconds and the aggregate
  17.870 seconds. Its axiom audit passed with no native bridge. The replay
  package is sealed under `certificates/kernel-range-26017/`. Principal SHA-256
  values are:

  ```text
  base source              6f4cd2380e16edfef877a8e6390bd0e9f9f42cbd732b485e0d48d1800d17e3e0
  aggregate source         f9e5778b2cc8888efef12fe41f33079df5448b9dca84883f27556fe4c8d864f7
  audit source             1480a1a5e85007540f79b2c549ac8a63db18d3df00e914703eb7f066acee258b
  block+tail concatenation 71e1519a172d98deeb11b17f96d64cc67e9bda93f9af4ae500331ba24a6ef323
  162-entry manifest       9ae3954aff8da49857bca68dba64b02b3bfc66374294fc8ae7a37d5a9ef5a1bb
  ```

  The independent standard-library verifier passed all 162 manifest rows and
  reproduced the detached digest.
- `Collatz.AffineBound` and its audit were built. In particular,
  `paradoxical_length_at_least_35` proves `j ≥ 35` for a paradoxical segment
  above `26017`, with no external finite input.
- The reducible circuit/CNF/LRAT demo and its audit were built. The static LRAT
  theorem reports `[propext]`, and the semantic no-model theorem reports
  `[propext, Quot.sound]`; neither uses native evaluation. This is a
  **technology demonstration, not target-scale coverage**.
- All 99 optimized first-excursion blocks and exact tail `99000..99780` built
  with ordinary `decide`. The paired replay took 1,004.896 seconds. It proves
  `optimizedFirstExcursionEnvelope_kernel` with type
  `AcceleratedExcursionEnvelope 785412369 99781` and the sharp equality
  `endpoint 77671 39 = 785412368`. Fuel 134 fails closed and fuel 135 accepts
  the extremal first-descent start `35655`. The production envelope reports
  `[propext, Classical.choice, Quot.sound]`; concrete reductions, calibration
  facts, and the peak equality report no axioms. No native bridge or external
  data occurs.
- The optimized Farey module, `target_exclusion_of_optimized_inputs`, and
  `finiteBaseClassification_785412368_of_optimized_inputs` built and audit to
  `[propext, Classical.choice, Quot.sound]`. The root build of
  `Collatz.Certified.Exclusion Collatz` passed with 9,040 jobs after correction
  of one omitted hypothesis. The complete `audit/AxiomAudit.lean` and circuit
  audit sweep passed.
- The optimized envelope package under
  `certificates/optimized-first-excursion-99781/` is sealed and independently
  verified:

  ```text
  106-entry source manifest 910dfa86fa2812b461bdfde2572db650e855699fc8ae430ff2d907f3e49779b9
  semantic checker source   15d495cddf760905fad5d21fa50677be102b6ea9a2d9433e821e2755c6d31f51
  package SHA256SUMS         9077033661a33d4df93a22eb049b5630c19f654ffc1d11d496e187be0c622ed7
  ```

## Remaining mathematical inputs

No proof-engine build is pending for the optimized reduction. Its verified
target theorem is nevertheless conditional on `OptimizedCurrentInputs`: the
filtered finite gap
`26017 < n ≤ 785412368`, `35 ≤ j`,
`j + oddCount n j < 2480`, plus `DC-1`.

## Claimed kernel paths

`#print axioms` reported:

| Theorem | Reported dependencies |
|---|---|
| `Finite.firstExcursionAllBlocks_true` | `propext` |
| `Finite.firstExcursionEnvelope_kernel` | `propext`, `Classical.choice`, `Quot.sound` |
| `Finite.noParadoxicalAllBlocksCheck_true` | `propext`, `Quot.sound` |
| `Finite.no_paradoxical_start_4615_through_10014` | `propext`, `Classical.choice`, `Quot.sound` |
| `Finite.noParadoxicalRange26017AllBlocksCheck_true` | `propext`, `Quot.sound` |
| `Finite.no_paradoxical_start_4615_through_26017` | `propext`, `Classical.choice`, `Quot.sound` |
| `Finite.finiteBaseClassification_26017` | `propext`, `Classical.choice`, `Quot.sound` |
| `Finite.optimizedFirstExcursion_fuel134_fails_closed` | none |
| `Finite.optimizedFirstExcursion_fuel135_accepts_extremal` | none |
| `Finite.optimizedFirstExcursion_peak` | none |
| `Finite.optimizedFirstExcursionAllBlocksCheck_true` | `propext`, `Quot.sound` |
| `Finite.optimizedFirstExcursionEnvelope_kernel` | `propext`, `Classical.choice`, `Quot.sound` |
| `Finite.optimizedFirstExcursionThresholdExact_kernel` | `propext`, `Classical.choice`, `Quot.sound` |
| `Certified.optimizedFirstFarey_valid` | `propext`, `Classical.choice`, `Quot.sound` |
| `Certified.finiteBaseClassification_785412368_of_optimized_inputs` | `propext`, `Classical.choice`, `Quot.sound` |
| `Certified.target_exclusion_of_optimized_inputs` | `propext`, `Classical.choice`, `Quot.sound` |
| `Finite.ScaledPrefixCell.paradoxical_iff_lattice` | `propext`, `Quot.sound` |
| `Finite.finiteBaseClassification_six` | `propext`, `Classical.choice`, `Quot.sound` |
| `Finite.delayDAGCheck_sound` | `propext`, `Classical.choice`, `Quot.sound` |
| `Finite.colDelayCap20` | `propext`, `Classical.choice`, `Quot.sound` |
| `Certified.target_exclusion_of_remaining_inputs` | `propext`, `Classical.choice`, `Quot.sound` |

These are Lean/Mathlib's disclosed standard logical axioms.  None of the
claimed kernel paths above depends on a native evaluator axiom or on an
external record-table axiom.  The target theorem nevertheless takes
`CurrentDelayInputs`, whose two fields are mathematical hypotheses; an axiom
audit cannot turn hypotheses into proofs.

The separately verified base-classification, affine, circuit, and optimized
proof-engine additions do not change that rule. The optimized theorem takes a
smaller but still mathematical finite-gap field together with the same
delay-cap field.

## Deliberately retained comparison paths

The audit also reports native evaluator axioms for the legacy/comparison
theorems `Finite.firstExcursionCheck_true`,
`Certified.every_published_witness_checks`, `Certified.secondFarey_valid`, and
`Certified.currentFarey_valid`.  They remain useful exact cross-checks but are
not dependencies of `target_exclusion_of_remaining_inputs`,
`firstExcursionEnvelope_kernel`, or the direct 4615-through-10014 theorem.

The stock `bv_check` scaling benchmarks likewise disclose a generated native
reflection axiom. They are engineering measurements only and are not the
reducible static-LRAT demo described above.

## Reproduction commands

```powershell
& .\scripts\build_kernel_blocks.ps1 -Family Base
& .\scripts\build_kernel_blocks.ps1 -Family Range
& .\scripts\build_kernel_blocks.ps1 -Family Range26017
& .\scripts\build_kernel_blocks.ps1 -Family Excursion
& .\scripts\build_optimized_first_excursion.ps1
& .\.tooling\elan-home\bin\lake.exe env lean Collatz\Certified\Finite\ClassificationCertificateAxiomAudit.lean
& .\.tooling\elan-home\bin\lake.exe env lean Collatz\Certified\Finite\DelayCertificateAxiomAudit.lean
& .\.tooling\elan-home\bin\lake.exe env lean Collatz\Certified\Finite\NoParadoxicalRangeAxiomAudit.lean
& .\.tooling\elan-home\bin\lake.exe env lean Collatz\Certified\Finite\AxiomAudit.lean
& .\.tooling\elan-home\bin\lake.exe env lean Collatz\Certified\Finite\BaseClassificationAxiomAudit.lean
& .\.tooling\elan-home\bin\lake.exe env lean Collatz\Certified\Finite\NoParadoxicalRange26017AxiomAudit.lean
& .\.tooling\elan-home\bin\lake.exe env lean Collatz\AffineBoundAxiomAudit.lean
& .\.tooling\elan-home\bin\lake.exe build Collatz.Certified.Circuit.Demo
& .\.tooling\elan-home\bin\lake.exe build Collatz.Certified.Circuit.Audit
& .\.tooling\elan-home\bin\lake.exe env lean Collatz\Certified\Finite\OptimizedFirstExcursionAxiomAudit.lean
& .\.tooling\elan-home\bin\lake.exe env lean Collatz\Certified\OptimizedFareyAxiomAudit.lean
& .\.tooling\elan-home\bin\lake.exe build Collatz.Certified.Exclusion Collatz
& .\.tooling\elan-home\bin\lake.exe env lean audit\AxiomAudit.lean
```

The recorded run completed this optimized block family, root build, and full
audit sequence successfully. Reproduction does not construct either
mathematical field of `OptimizedCurrentInputs`.

Set `ELAN_HOME` to the workspace `.tooling/elan-home` directory first when the
bundled toolchain is used.
