# Kernel certificate: paradoxical starts through 26017

This directory records the independently replayable Lean certificate for the
following inclusive, all-length statement:

```lean
theorem no_paradoxical_start_4615_through_26017
    {n j : ℕ} (hlower : 4614 < n) (hupper : n ≤ 26017) :
    ¬ Paradoxical n j
```

The aggregate also proves

```lean
RecordBounds.FiniteBaseClassification 26017
  PublishedClassificationUpTo4614
```

where `PublishedClassificationUpTo4614` is literal membership in the checked
593-row published table together with its exact start and length bounds.

## Certificate format

- `Collatz/Certified/Finite/NoParadoxicalRange26017.lean` defines the block
  checks and proves their generic soundness.
- `NoParadoxicalRange26017Blocks/Block000.lean` through `Block039.lean` each
  contain one ordinary Lean `decide` proof for 400 consecutive starts.
- `NoParadoxicalRange26017Blocks/Tail.lean` checks exactly the final three
  starts, 26015 through 26017.
- `NoParadoxicalRange26017Kernel.lean` assembles the blocks and combines them
  with the earlier kernel classification/exclusion.
- `NoParadoxicalRange26017AxiomAudit.lean` prints the kernel dependencies.

Each start is followed under the accelerated map `n/2` for even `n` and
`(3*n+1)/2` for odd `n`. Every positive prefix is tested for both
paradoxical inequalities. Acceptance also requires an exact visit to `1`
within fuel 178; exhaustion away from `1` returns `false`.

The design-time scalar scan in `scan-output.json` selected fuel 178. It is not
trusted by the proof. Lean reduces every concrete block proposition again,
and the source theorem explicitly demonstrates that fuel 177 rejects the
extremal start 23529 while fuel 178 accepts it.

## Trust status

This finite theorem has no external mathematical assumption and uses no
`native_decide`. The audit reports only Lean's standard `propext`,
`Classical.choice`, and `Quot.sound`; the concrete all-block Boolean theorem
uses only `propext` and `Quot.sound`.

This certificate does **not** make the requested 4.65e19 exclusion
unconditional. It discharges finite classification only through 26017; the
remaining range and the giant ordinary-delay cap remain separate obligations.

Use `generate_blocks.ps1` to check or regenerate the mechanical wrapper
sources and `build_paired.ps1` to replay the proof conservatively.
