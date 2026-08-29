# Kernel certificate: optimized first-excursion envelope

## Statement

`Collatz.Certified.Finite.optimizedFirstExcursionEnvelope_kernel` proves

```lean
RecordBounds.AcceleratedExcursionEnvelope 785412369 99781
```

That predicate means, with strict endpoints, that every natural-number start
`x < 99781` and every accelerated step count `r` satisfy
`endpoint x r < 785412369`.

`optimizedFirstExcursionThresholdExact_kernel` additionally proves the
concrete equality

```lean
endpoint 77671 39 = 785412368
```

so `785412369` is the least possible natural-number strict threshold for this
seed interval.

## Semantic match

The checker imports the project's authoritative accelerated map:

```text
T(n) = n / 2                 when n is even
T(n) = (3*n + 1) / 2         when n is odd.
```

For each start above `2`, the Boolean check requires a positive-index visit to
a state strictly below that start within 135 accelerated steps and checks every
state in that prefix against the strict threshold.  A symbolic strong-induction
proof composes those verified descents to cover every later iterate.  Starts
`0,1,2` are handled separately by the proved closure of that terminal set.
Thus the computation is accelerated, not ordinary; checks an all-time maximum
excursion, not a stopping-time record; includes `0`; and uses both strict
inequalities exactly as displayed in the target predicate.

The finite domain is exactly partitioned into 99 full blocks

```text
block b = [1000*b, 1000*b + 999],  0 <= b <= 98,
```

and one tail `[99000,99780]` of 781 starts.  Separate kernel reductions prove
that fuel 134 fails closed at start 35655 and fuel 135 accepts it.  Those facts
document the exact first-descent fuel calibration; soundness does not assume an
external delay table.

## Trust boundary

Every concrete first-descent equality is proved by ordinary `decide`, reduced
by Lean's kernel.  There is no `native_decide`, imported stopping-time or
maximum-excursion claim, external oracle, hash assumption, or unchecked program
output in the theorem's proof chain.  The axiom audit prints the dependencies
of the checker soundness, strong-induction composition, calibration facts,
representative reductions, aggregate, envelope, and sharpness theorem.

## Reproduction

From the repository root:

```powershell
& scripts/build_optimized_first_excursion.ps1
lake env lean Collatz/Certified/Finite/OptimizedFirstExcursionAxiomAudit.lean
```

The build script deliberately submits reductions in pairs; its last pair is
full block 098 together with the exact tail.  It then builds the aggregate and
audit.  Regenerate the mechanical wrappers and source manifest with:

```powershell
python scripts/generate_optimized_first_excursion.py
```

Use the bundled Python runtime if `python` is not on `PATH`.

`SOURCE-SHA256SUMS` binds the semantic checker, all 99 full blocks, the exact
tail, aggregate, axiom audit, generator, paired build script, and timing probe.
`AXIOM-AUDIT.txt` preserves the audit output, and `RUN.md` records the checked
run and environment.
