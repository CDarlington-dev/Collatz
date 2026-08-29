import Collatz.RecordBounds
import Mathlib.Tactic

/-!
# Certified first accelerated-excursion envelope

This module discharges the manageable first excursion input used by the
Rozier--Terracol feedback.  The executable check follows every positive start
strictly below `113383` until it reaches `1`, using the independently observed
uniform bound of `223` accelerated steps, and checks every visited value is
strictly below `10^9`.  A symbolic soundness proof extends the finite prefix
through the terminal accelerated cycle `1, 2, 1, 2, ...`.

The certificate theorem uses `native_decide`; the conversion from its Boolean
result to `AcceleratedExcursionEnvelope` is an ordinary Lean proof.
-/

namespace Collatz

namespace Certified

namespace Finite

open RecordBounds

/--
Check that `x` reaches `1` within `fuel` accelerated steps and that every state
through that first witnessed visit is strictly below `threshold`.
-/
def orbitCheck (threshold : ℕ) : ℕ → ℕ → Bool
  | 0, x => decide (x = 1 ∧ x < threshold)
  | fuel + 1, x =>
      decide (x < threshold) &&
        if x = 1 then true else orbitCheck threshold fuel (T x)

/-- The finite Boolean certificate for all positive starts below `113383`. -/
def firstExcursionCheck : Bool :=
  (List.range 113383).all fun x =>
    if x = 0 then true else orbitCheck 1000000000 223 x

/-- A successful trajectory check supplies an exact visit to `1` and its prefix bound. -/
theorem orbitCheck_sound {threshold fuel x : ℕ}
    (hcheck : orbitCheck threshold fuel x = true) :
    ∃ d ≤ fuel, endpoint x d = 1 ∧
      ∀ r ≤ d, endpoint x r < threshold := by
  induction fuel generalizing x with
  | zero =>
      have h : x = 1 ∧ x < threshold := by
        simpa [orbitCheck] using hcheck
      refine ⟨0, Nat.le_refl 0, ?_, ?_⟩
      · simpa using h.1
      · intro r hr
        have hrzero : r = 0 := by omega
        subst r
        simpa using h.2
  | succ fuel ih =>
      have h : x < threshold ∧
          (if x = 1 then true else orbitCheck threshold fuel (T x)) = true := by
        simpa [orbitCheck] using hcheck
      by_cases hxone : x = 1
      · refine ⟨0, Nat.zero_le _, ?_, ?_⟩
        · simpa using hxone
        · intro r hr
          have hrzero : r = 0 := by omega
          subst r
          simpa using h.1
      · have htail : orbitCheck threshold fuel (T x) = true := by
          simpa [hxone] using h.2
        obtain ⟨d, hd, hend, hprefix⟩ := ih htail
        refine ⟨d + 1, by omega, ?_, ?_⟩
        · simpa [endpoint_succ_apply] using hend
        · intro r hr
          cases r with
          | zero => simpa using h.1
          | succ r =>
              have hrle : r ≤ d := by omega
              simpa [endpoint_succ_apply] using hprefix r hrle

/-- The accelerated zero orbit is fixed. -/
theorem endpoint_zero_all (r : ℕ) : endpoint 0 r = 0 := by
  induction r with
  | zero => rfl
  | succ r ih =>
      rw [endpoint_succ, ih, T_zero]

/-- Every continuation after reaching `1` stays in the accelerated `1,2` cycle. -/
theorem endpoint_one_two_cycle_le_two (r : ℕ) :
    endpoint 1 r ≤ 2 ∧ endpoint 2 r ≤ 2 := by
  induction r with
  | zero => norm_num [endpoint]
  | succ r ih =>
      rw [endpoint_succ_apply, endpoint_succ_apply]
      norm_num [T]
      exact ⟨ih.2, ih.1⟩

/-- Native evaluation of all `113382` positive trajectories. -/
theorem firstExcursionCheck_true : firstExcursionCheck = true := by
  native_decide

/--
Lean-verified first inverse-excursion envelope: every accelerated orbit with
start strictly below `113383` stays strictly below `10^9` for all time.
-/
theorem firstExcursionEnvelope :
    AcceleratedExcursionEnvelope 1000000000 113383 := by
  intro x hx r
  by_cases hxzero : x = 0
  · subst x
    rw [endpoint_zero_all]
    norm_num
  · have hxmem : x ∈ List.range 113383 := by simpa using hx
    have hall : ∀ y, y ∈ List.range 113383 →
        (if y = 0 then true else orbitCheck 1000000000 223 y) = true := by
      simpa [firstExcursionCheck] using firstExcursionCheck_true
    have hxcheck : orbitCheck 1000000000 223 x = true := by
      simpa [hxzero] using hall x hxmem
    obtain ⟨d, hd, hone, hprefix⟩ := orbitCheck_sound hxcheck
    by_cases hrd : r ≤ d
    · exact hprefix r hrd
    · have hdr : d ≤ r := by omega
      calc
        endpoint x r = endpoint x (d + (r - d)) := by rw [Nat.add_sub_of_le hdr]
        _ = endpoint (endpoint x d) (r - d) := endpoint_add x d (r - d)
        _ = endpoint 1 (r - d) := by rw [hone]
        _ ≤ 2 := (endpoint_one_two_cycle_le_two (r - d)).1
        _ < 1000000000 := by norm_num

/-- The next start actually crosses the threshold, at accelerated step `69`. -/
theorem endpoint_113383_69 : endpoint 113383 69 = 1241055674 := by
  set_option maxRecDepth 100000 in decide

/-- `113383` is therefore the exact first seed whose orbit reaches `10^9`. -/
theorem firstExcursionSeedExact :
    AcceleratedExcursionEnvelope 1000000000 113383 ∧
      1000000000 ≤ endpoint 113383 69 := by
  exact ⟨firstExcursionEnvelope, by rw [endpoint_113383_69]; norm_num⟩

end Finite

end Certified

end Collatz
