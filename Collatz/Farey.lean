import Mathlib

/-!
# An exact Farey barrier for paradoxical Collatz segments

This file contains the arithmetic core of the Rozier--Terracol lower bound.
There are no logarithms or floating-point numbers: the two endpoint
comparisons and the two necessary segment comparisons are inequalities in
`ℕ`.

If `a / b` and `c / d` are Farey neighbours, with
`b * c = a * d + 1`, every fraction strictly between them has numerator at
least `a + c` and denominator at least `b + d`.  The power inequalities below
put `j / q` strictly between these two endpoints.
-/

namespace Collatz

namespace Farey

/-- The integer form of the Farey-neighbour (mediant) barrier. -/
private theorem mediant_barrier_int
    {a b c d j q : ℤ}
    (ha : 0 ≤ a) (hb : 0 < b) (hc : 0 ≤ c) (hd : 0 < d)
    (hdet : b * c = a * d + 1)
    (hlower : a * q < b * j) (hupper : d * j < c * q) :
    a + c ≤ j ∧ b + d ≤ q := by
  let x : ℤ := b * j - a * q
  let y : ℤ := c * q - d * j
  have hx : 1 ≤ x := by
    dsimp [x]
    omega
  have hy : 1 ≤ y := by
    dsimp [y]
    omega
  have hdet' : b * c - a * d = 1 := by
    rw [hdet]
    ring
  have hq : q = d * x + b * y := by
    symm
    calc
      d * x + b * y = q * (b * c - a * d) := by
        dsimp [x, y]
        ring
      _ = q := by rw [hdet']; ring
  have hj : j = c * x + a * y := by
    symm
    calc
      c * x + a * y = j * (b * c - a * d) := by
        dsimp [x, y]
        ring
      _ = j := by rw [hdet']; ring
  have hdx : d ≤ d * x := by
    calc
      d = d * 1 := by ring
      _ ≤ d * x := mul_le_mul_of_nonneg_left hx (le_of_lt hd)
  have hby : b ≤ b * y := by
    calc
      b = b * 1 := by ring
      _ ≤ b * y := mul_le_mul_of_nonneg_left hy (le_of_lt hb)
  have hcx : c ≤ c * x := by
    calc
      c = c * 1 := by ring
      _ ≤ c * x := mul_le_mul_of_nonneg_left hx hc
  have hay : a ≤ a * y := by
    calc
      a = a * 1 := by ring
      _ ≤ a * y := mul_le_mul_of_nonneg_left hy ha
  constructor <;> omega

/--
The elementary Farey barrier in natural-number, cross-multiplied form.
No division is used, so there are no side conditions hidden in a field cast.
-/
theorem mediant_barrier
    {a b c d j q : ℕ}
    (hb : 0 < b) (hd : 0 < d)
    (hdet : b * c = a * d + 1)
    (hlower : a * q < b * j) (hupper : d * j < c * q) :
    a + c ≤ j ∧ b + d ≤ q := by
  have hz :
      (a : ℤ) + (c : ℤ) ≤ (j : ℤ) ∧
        (b : ℤ) + (d : ℤ) ≤ (q : ℤ) := by
    apply mediant_barrier_int
    · positivity
    · exact_mod_cast hb
    · positivity
    · exact_mod_cast hd
    · exact_mod_cast hdet
    · exact_mod_cast hlower
    · exact_mod_cast hupper
  exact_mod_cast hz

/--
The lower power comparisons imply the left cross-multiplied inequality.
This is the exact-arithmetic replacement for comparing logarithms.
-/
private theorem lower_cross
    {a b j q : ℕ} (hb : 0 < b)
    (hendpoint : 2 ^ a < 3 ^ b) (hsegment : 3 ^ q < 2 ^ j) :
    a * q < b * j := by
  by_cases hq : q = 0
  · subst q
    have hj : 0 < j := by
      by_contra hj
      have : j = 0 := by omega
      subst j
      norm_num at hsegment
    simp only [Nat.mul_zero]
    exact Nat.mul_pos hb hj
  · by_contra hcross
    have hbj_aq : b * j ≤ a * q := by omega
    have hendpoint_pow : (2 ^ a) ^ q < (3 ^ b) ^ q :=
      Nat.pow_lt_pow_left hendpoint hq
    have hsegment_pow : (3 ^ q) ^ b < (2 ^ j) ^ b :=
      Nat.pow_lt_pow_left hsegment (Nat.ne_of_gt hb)
    have himpossible : 2 ^ (b * j) < 2 ^ (b * j) := calc
      2 ^ (b * j) ≤ 2 ^ (a * q) :=
        Nat.pow_le_pow_right (by omega) hbj_aq
      _ < 3 ^ (b * q) := by simpa only [pow_mul] using hendpoint_pow
      _ = 3 ^ (q * b) := by rw [Nat.mul_comm b q]
      _ < 2 ^ (j * b) := by simpa only [pow_mul] using hsegment_pow
      _ = 2 ^ (b * j) := by rw [Nat.mul_comm j b]
    exact (Nat.lt_irrefl _ himpossible)

/--
The upper endpoint and segment comparisons imply the right
cross-multiplied inequality.  Again, this is entirely in `ℕ`.
-/
private theorem upper_cross
    {m c d j q : ℕ} (_hd : 0 < d) (hq : q ≠ 0)
    (hendpoint : (3 * m + 1) ^ d < 2 ^ c * m ^ d)
    (hsegment : 2 ^ j * m ^ q ≤ (3 * m + 1) ^ q) :
    d * j < c * q := by
  by_contra hcross
  have hcq_dj : c * q ≤ d * j := by omega
  have hendpoint_pow : ((3 * m + 1) ^ d) ^ q < (2 ^ c * m ^ d) ^ q :=
    Nat.pow_lt_pow_left hendpoint hq
  have hsegment_pow : (2 ^ j * m ^ q) ^ d ≤ ((3 * m + 1) ^ q) ^ d :=
    Nat.pow_le_pow_left hsegment d
  have hleft : (3 * m + 1) ^ (d * q) < 2 ^ (c * q) * m ^ (d * q) := by
    simpa only [pow_mul, mul_pow] using hendpoint_pow
  have hright : 2 ^ (j * d) * m ^ (q * d) ≤ (3 * m + 1) ^ (q * d) := by
    simpa only [pow_mul, mul_pow] using hsegment_pow
  have himpossible : (3 * m + 1) ^ (d * q) < (3 * m + 1) ^ (d * q) := calc
    (3 * m + 1) ^ (d * q) < 2 ^ (c * q) * m ^ (d * q) := hleft
    _ ≤ 2 ^ (d * j) * m ^ (d * q) :=
      Nat.mul_le_mul_right _ (Nat.pow_le_pow_right (by omega) hcq_dj)
    _ = 2 ^ (j * d) * m ^ (q * d) := by
      rw [Nat.mul_comm d j, Nat.mul_comm d q]
    _ ≤ (3 * m + 1) ^ (q * d) := hright
    _ = (3 * m + 1) ^ (d * q) := by rw [Nat.mul_comm q d]
  exact (Nat.lt_irrefl _ himpossible)

/--
**Exact Farey barrier.**  If the positive endpoint data bracket the necessary
power inequalities for a segment and have determinant one, then the segment
has at least the mediant numerator and denominator.

The hypotheses are deliberately the raw integer inequalities used by a
certificate checker.  In particular, this theorem has no analytic or
floating-point assumptions.
-/
theorem barrier
    {m a b c d j q : ℕ}
    (_hm : 0 < m) (_ha : 0 < a) (hb : 0 < b) (_hc : 0 < c) (hd : 0 < d)
    (hlowerEndpoint : 2 ^ a < 3 ^ b)
    (hupperEndpoint : (3 * m + 1) ^ d < 2 ^ c * m ^ d)
    (hdet : b * c = a * d + 1)
    (hcoefficientDecrease : 3 ^ q < 2 ^ j)
    (hnoDecreaseAtMinimum : 2 ^ j * m ^ q ≤ (3 * m + 1) ^ q) :
    a + c ≤ j ∧ b + d ≤ q := by
  have hq : q ≠ 0 := by
    intro hq
    subst q
    simp only [pow_zero, mul_one] at hcoefficientDecrease hnoDecreaseAtMinimum
    omega
  apply mediant_barrier hb hd hdet
  · exact lower_cross hb hlowerEndpoint hcoefficientDecrease
  · exact upper_cross hd hq hupperEndpoint hnoDecreaseAtMinimum

/-- A compact exact certificate for an instance of `barrier`. -/
structure Certificate where
  m : ℕ
  a : ℕ
  b : ℕ
  c : ℕ
  d : ℕ
  deriving DecidableEq, Repr

/-- All hypotheses on the fixed endpoint data, in executable form. -/
def Certificate.Valid (cert : Certificate) : Prop :=
  0 < cert.m ∧ 0 < cert.a ∧ 0 < cert.b ∧ 0 < cert.c ∧ 0 < cert.d ∧
  2 ^ cert.a < 3 ^ cert.b ∧
  (3 * cert.m + 1) ^ cert.d < 2 ^ cert.c * cert.m ^ cert.d ∧
  cert.b * cert.c = cert.a * cert.d + 1

/-- `Valid` is executable even when this module is imported from an olean. -/
instance (cert : Certificate) : Decidable cert.Valid := by
  unfold Certificate.Valid
  infer_instance

/--
Optional endpoint tightness: for each fixed denominator, the recorded lower
numerator is maximal and the upper numerator is minimal.  These conditions
are not needed by `barrier`, but make the numerical certificate auditable.
-/
def Certificate.Tight (cert : Certificate) : Prop :=
  3 ^ cert.b < 2 ^ (cert.a + 1) ∧
  2 ^ (cert.c - 1) * cert.m ^ cert.d ≤ (3 * cert.m + 1) ^ cert.d

/-- `Tight` is executable even when this module is imported from an olean. -/
instance (cert : Certificate) : Decidable cert.Tight := by
  unfold Certificate.Tight
  infer_instance

/-- Apply a valid certificate to arbitrary segment data. -/
theorem Certificate.apply {cert : Certificate} (hcert : cert.Valid)
    {j q : ℕ}
    (hcoefficientDecrease : 3 ^ q < 2 ^ j)
    (hnoDecreaseAtMinimum : 2 ^ j * cert.m ^ q ≤ (3 * cert.m + 1) ^ q) :
    cert.a + cert.c ≤ j ∧ cert.b + cert.d ≤ q := by
  rcases hcert with ⟨hm, ha, hb, hc, hd, hlower, hupper, hdet⟩
  exact barrier hm ha hb hc hd hlower hupper hdet
    hcoefficientDecrease hnoDecreaseAtMinimum

end Farey

end Collatz
