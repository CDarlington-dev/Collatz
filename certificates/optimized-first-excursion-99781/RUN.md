# Reproduction run: optimized first-excursion envelope

## Result

Successful.  On 2026-08-27, every source in the production proof family was
accepted with ordinary kernel reduction:

- generic first-descent checker and strong-induction soundness proof;
- full blocks `000` through `098` (1000 starts each);
- exact tail `99000,...,99780` (781 starts);
- aggregate theorem and sharp threshold witness; and
- standalone axiom audit.

The run established

```lean
Collatz.Certified.Finite.optimizedFirstExcursionEnvelope_kernel :
  AcceleratedExcursionEnvelope 785412369 99781
```

and

```lean
Collatz.Certified.Finite.optimizedFirstExcursionThresholdExact_kernel :
  AcceleratedExcursionEnvelope 785412369 99781 ∧
    endpoint 77671 39 = 785412368
```

The audit reported no axioms for each concrete reduction, the fuel calibration
facts, or the peak equality.  The final envelope depends only on
`propext`, `Classical.choice`, and `Quot.sound`; in particular it does not
depend on `Lean.ofReduceBool`, `native_decide`, or a mathematical assumption.

## Commands and timing

The generic module first passed in 19.753 seconds after correction of a
proof-only Boolean association mismatch.  The hard representative pair
`076,077` then passed in 22.620 seconds (Lean reported 16 and 17 seconds for
the individual modules).  A timing-only replay-to-`1` version of block 077
took 69.959 seconds, motivating the sound first-descent/strong-induction route
used in production.

The production build was then run with:

```powershell
& scripts/build_optimized_first_excursion.ps1
```

It completed successfully in 1004.896 seconds.  Blocks 076 and 077 were warm
from the representative comparison; every other block and the tail were built
during that command.  This is therefore a checked run record, not a clean-build
performance claim.

Complete paired wall times printed by the build script follow (seconds):

```text
000-001 29.940   002-003 20.499   004-005 20.122   006-007 21.655
008-009 20.979   010-011 21.345   012-013 20.024   014-015 19.443
016-017 18.625   018-019 18.821   020-021 19.005   022-023 19.215
024-025 19.235   026-027 19.099   028-029 19.263   030-031 20.233
032-033 22.901   034-035 19.043   036-037 19.097   038-039 20.448
040-041 20.043   042-043 20.579   044-045 19.705   046-047 19.496
048-049 18.532   050-051 19.217   052-053 18.164   054-055 18.046
056-057 18.403   058-059 18.377   060-061 17.556   062-063 17.519
064-065 18.229   066-067 18.077   068-069 17.451   070-071 17.370
072-073 18.438   074-075 17.151   076-077  4.179*  078-079 16.848
080-081 16.885   082-083 16.483   084-085 16.560   086-087 16.302
088-089 16.456   090-091 16.561   092-093 17.285   094-095 16.466
096-097 16.386   098-tail 16.479  aggregate 17.508

* cached from the immediately preceding 22.620-second representative build
```

## Environment

- Lean `4.32.1` (pinned by `lean-toolchain`)
- Lake `5.0.0`
- Mathlib revision `v4.32.1` (pinned by `lakefile.toml` / manifest)
- PowerShell `7.6.4`
- Windows NT `10.0.26200.0`
- AMD Ryzen 7 260 with Radeon 780M, 16 logical processors
- workspace on a OneDrive-backed local volume

The machine was shared with repository inspection and documentation work, so
the timings are reproducibility notes rather than benchmark claims.
