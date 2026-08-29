import Collatz.Farey

/-!
# Checked Farey certificates

The first certificate reproduces the exact `j ≥ 1539`, `q ≥ 971` barrier
used in Rozier--Terracol.  The second uses the paper's second maximum-excursion
envelope seed.  The third uses the 2026 extension threshold's envelope seed.
Both later certificates yield `j ≥ 301994` and `q ≥ 190537`.
-/

namespace Collatz

namespace Certified

open Farey

/-- The Farey certificate at the paper's minimum `m = 113383`. -/
def publishedFarey : Farey.Certificate where
  m := 113383
  a := 1054
  b := 665
  c := 485
  d := 306

/--
Kernel-reduced structural part of the published certificate.  Keeping this
separate makes the determinant and positivity checks independent of native
evaluation.
-/
theorem publishedFarey_structural :
    0 < publishedFarey.m ∧ 0 < publishedFarey.a ∧
    0 < publishedFarey.b ∧ 0 < publishedFarey.c ∧
    0 < publishedFarey.d ∧
    publishedFarey.b * publishedFarey.c =
      publishedFarey.a * publishedFarey.d + 1 := by
  norm_num [publishedFarey]

/-- Kernel-reduced check of every published endpoint condition. -/
theorem publishedFarey_valid : publishedFarey.Valid := by
  set_option exponentiation.threshold 2000 in
    norm_num [Farey.Certificate.Valid, publishedFarey]

/-- The published endpoints are also tight for their fixed denominators. -/
theorem publishedFarey_tight : publishedFarey.Tight := by
  set_option exponentiation.threshold 2000 in
    norm_num [Farey.Certificate.Tight, publishedFarey]

/-- The exact Farey certificate at the paper's second-envelope seed. -/
def secondFarey : Farey.Certificate where
  m := 23035537407
  a := 176251
  b := 111202
  c := 125743
  d := 79335

/-- Kernel-reduced positivity, determinant, and claimed mediant sums. -/
theorem secondFarey_structural :
    0 < secondFarey.m ∧ 0 < secondFarey.a ∧
    0 < secondFarey.b ∧ 0 < secondFarey.c ∧
    0 < secondFarey.d ∧
    secondFarey.b * secondFarey.c =
      secondFarey.a * secondFarey.d + 1 ∧
    secondFarey.a + secondFarey.c = 301994 ∧
    secondFarey.b + secondFarey.d = 190537 := by
  norm_num [secondFarey]

/-- Exact executable check of every strengthened endpoint condition. -/
theorem secondFarey_valid : secondFarey.Valid := by
  native_decide

/-- The strengthened endpoints are tight for their fixed denominators. -/
theorem secondFarey_tight : secondFarey.Tight := by
  native_decide

/-- Exact Farey certificate at the 2026 class-record coverage envelope seed. -/
def currentFarey : Farey.Certificate where
  m := 51739336447
  a := 176251
  b := 111202
  c := 125743
  d := 79335

/-- Kernel-reduced positivity, determinant, and mediant sums for the extension. -/
theorem currentFarey_structural :
    0 < currentFarey.m ∧ 0 < currentFarey.a ∧
    0 < currentFarey.b ∧ 0 < currentFarey.c ∧
    0 < currentFarey.d ∧
    currentFarey.b * currentFarey.c =
      currentFarey.a * currentFarey.d + 1 ∧
    currentFarey.a + currentFarey.c = 301994 ∧
    currentFarey.b + currentFarey.d = 190537 := by
  norm_num [currentFarey]

/-- Exact executable endpoint check for the 2026 extension certificate. -/
theorem currentFarey_valid : currentFarey.Valid := by
  native_decide

/-- Reproduction of the paper's exact Farey consequence. -/
theorem published_barrier {j q : ℕ}
    (hcoefficientDecrease : 3 ^ q < 2 ^ j)
    (hnoDecreaseAtMinimum :
      2 ^ j * publishedFarey.m ^ q ≤ (3 * publishedFarey.m + 1) ^ q) :
    1539 ≤ j ∧ 971 ≤ q := by
  simpa [publishedFarey] using
    publishedFarey.apply publishedFarey_valid
      hcoefficientDecrease hnoDecreaseAtMinimum

/-- The exact second-envelope consequence, conditional on the segment inequalities. -/
theorem second_barrier {j q : ℕ}
    (hcoefficientDecrease : 3 ^ q < 2 ^ j)
    (hnoDecreaseAtMinimum :
      2 ^ j * secondFarey.m ^ q ≤ (3 * secondFarey.m + 1) ^ q) :
    301994 ≤ j ∧ 190537 ≤ q := by
  simpa [secondFarey] using
    secondFarey.apply secondFarey_valid
      hcoefficientDecrease hnoDecreaseAtMinimum

/-- The exact 2026 extension-envelope consequence. -/
theorem current_barrier {j q : ℕ}
    (hcoefficientDecrease : 3 ^ q < 2 ^ j)
    (hnoDecreaseAtMinimum :
      2 ^ j * currentFarey.m ^ q ≤ (3 * currentFarey.m + 1) ^ q) :
    301994 ≤ j ∧ 190537 ≤ q := by
  simpa [currentFarey] using
    currentFarey.apply currentFarey_valid
      hcoefficientDecrease hnoDecreaseAtMinimum

end Certified

end Collatz
