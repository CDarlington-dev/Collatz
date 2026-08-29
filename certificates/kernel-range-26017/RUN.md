# Recorded replay

## Environment

- CPU: AMD Ryzen 7 260 with Radeon 780M, 16 logical processors
- RAM: 16,438,382,592 bytes (about 15.31 GiB)
- OS: Windows build 26200, x64
- Lean: `leanprover/lean4:v4.32.1`
- mathlib revision: `520045ab14e26149ee970e2e617ca04b09bde5d6`
- workspace storage: OneDrive-backed NTFS path

## Exact scan

`scripts/scan_range26017_fuel.ps1` completed in 4.238 seconds and reported:

- inclusive starts: 10015 through 26017 (16003 starts)
- maximum accelerated steps to the first visit to 1: 178, at start 23529
- maximum encountered state: 25071632, from start 20895
- paradoxical prefixes found: 0

This scan is design evidence only. It is not accepted as a premise by Lean.

## Kernel replay

The production replay built the forty full blocks using exactly two Lake
targets per invocation. The paired loop completed successfully in 1697.504
seconds. The exact tail target then completed successfully. The aggregate
module built successfully in 17.870 seconds, and the axiom audit completed in
15.109 seconds.

An earlier attempt to build all missing blocks at once caused transient
OneDrive/filesystem read errors for mathlib `.olean` files. That process tree
was terminated. It made no mathematical rejection and supplied no accepted
artifact. Every block was subsequently replayed successfully under the
two-target schedule recorded by `build_paired.ps1`.

The audit output was:

```text
noParadoxicalRange26017Checks_sound:
  [propext, Classical.choice, Quot.sound]
noParadoxicalRange26017AllBlocksCheck_true:
  [propext, Quot.sound]
no_paradoxical_start_10015_through_26017:
  [propext, Classical.choice, Quot.sound]
no_paradoxical_start_4615_through_26017:
  [propext, Classical.choice, Quot.sound]
finiteBaseClassification_26017:
  [propext, Classical.choice, Quot.sound]
```
