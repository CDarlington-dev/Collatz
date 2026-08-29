# Kernel certificate: published classification through 4614

## Statement

`Collatz.Certified.Finite.finiteBaseClassification_4614` proves

```lean
RecordBounds.FiniteBaseClassification 4614
  Finite.PublishedClassificationUpTo4614
```

and `Collatz.Certified.finiteBaseClassification_4614_kernel` bridges this
definitionally identical predicate to the production
`Collatz.Certified.PublishedClassification`.

## Semantic match

The checker imports the project's authoritative definitions.  It therefore
uses the accelerated map

```text
T(n) = n / 2                 when n is even
T(n) = (3*n + 1) / 2         when n is odd
```

and the exact `Paradoxical n j` predicate: `n > 2`, `j > 0`, the odd inputs
among indices `0,...,j-1` satisfy `3^q < 2^j`, and `n <= T^j(n)`.

For each start the checker carries the endpoint, odd count, `2^j`, and `3^q`
incrementally.  Every prefix is either nonparadoxical or its `(n,j)` pair must
occur in the literal 593-row `publishedWitnesses` list.  The scan fails closed
if fuel is exhausted outside `{0,1,2}`.  A proved terminal-set lemma covers all
later lengths.  Separately, ordinary kernel reduction checks that every one of
the 593 listed rows has `n <= 4614`, `j <= 92`, its stated odd count, and the
authoritative `Paradoxical` property.

Starts are split into 47 blocks of 100:

```text
block b = [3 + 100*b, 3 + 100*b + 99],  0 <= b <= 46
```

Thus the checked superset is `3..4702`.  Starts `0..2` are impossible by the
definition of `Paradoxical`.  Fuel is 150; acceptance of every block proves
inside Lean that all checked starts enter the terminal set within that fuel.
The independently observed maximum is start 3711 at 150 accelerated steps,
but that observation is not an assumption of the theorem.

## Trust boundary

Every concrete block uses ordinary `decide`.  There is no `native_decide`,
external oracle, imported record claim, hash assumption, or unchecked program
output in the proof chain.  `BaseClassificationAxiomAudit.lean` prints the
axioms of the row checker, scanner soundness, a concrete block, the aggregate,
the dependency-light theorem, and the production bridge.

## Reproduction

```powershell
lake build +Collatz.Certified.Finite.BaseClassificationKernel
lake build +Collatz.Certified.Exclusion
lake env lean Collatz/Certified/Finite/BaseClassificationAxiomAudit.lean
```

The recorded environment was Lean 4.32.1, Lake 5.0.0, PowerShell 7.6.4, and an
AMD Ryzen 7 260 with 16 logical processors.  On a shared, concurrently loaded
machine, representative clean module times were 23 seconds for the common
checker, 18 seconds for block 000, 20 seconds for block 037 (which includes the
150-step maximum), and 53 seconds for the aggregate importer.  Three-at-a-time
block builds varied from 27 to 73 seconds per block because other Lean builds
were running concurrently; these are reproducibility notes, not performance
claims.

`SOURCE-SHA256SUMS` contains hashes of the common checker, all 47 block source
files, the aggregate, and the axiom audit.
