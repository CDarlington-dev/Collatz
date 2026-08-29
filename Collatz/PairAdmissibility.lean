import Collatz.ProductBound

/-!
# Table-free length/odd-count exclusions

This file formalizes the integer necessary condition behind
Rozier--Terracol, Corollaries 4.3--4.4.  It uses no record table: the common
lower bound `3` for a paradoxical prefix is derived from the forward
invariance of the terminal set `{0, 1, 2}`.
-/

namespace Collatz

/-! ## Prefix lower bound -/

/-- The terminal set `{0, 1, 2}` is forward-invariant under `T`. -/
theorem T_le_two_of_le_two {x : ℕ} (hx : x ≤ 2) : T x ≤ 2 := by
  interval_cases x <;> decide

/-- Every future accelerated iterate of a value at most `2` is at most `2`. -/
theorem endpoint_le_two_of_le_two {x : ℕ} (hx : x ≤ 2) (r : ℕ) :
    endpoint x r ≤ 2 := by
  induction r with
  | zero => simpa using hx
  | succ r ih =>
      rw [endpoint_succ]
      exact T_le_two_of_le_two ih

namespace Paradoxical

/-- Every input term strictly before the endpoint of a paradoxical segment is at least `3`. -/
theorem prefix_ge_three {n j : ℕ} (h : Paradoxical n j) {k : ℕ} (hk : k < j) :
    3 ≤ endpoint n k := by
  by_contra hnot
  have hsmall : endpoint n k ≤ 2 := by omega
  have hkj : k ≤ j := Nat.le_of_lt hk
  have hend : endpoint n j ≤ 2 := by
    rw [← Nat.add_sub_of_le hkj, endpoint_add]
    exact endpoint_le_two_of_le_two hsmall (j - k)
  have hstart := h.start_gt_two
  have hreturn := h.start_le_endpoint
  omega

end Paradoxical

/-! ## The pair criterion -/

/-- The table-free integer necessary condition on a length and odd-step count. -/
def PairAdmissible (j q : ℕ) : Prop :=
  3 ^ q < 2 ^ j ∧ 2 ^ j * 3 ^ q ≤ 10 ^ q

instance instDecidablePairAdmissible (j q : ℕ) : Decidable (PairAdmissible j q) := by
  unfold PairAdmissible
  infer_instance

/-- Every paradoxical segment has an admissible `(length, odd-count)` pair. -/
theorem Paradoxical.pairAdmissible {n j : ℕ} (h : Paradoxical n j) :
    PairAdmissible j (oddCount n j) := by
  constructor
  · exact h.factor_lt_one
  · simpa using
      (paradoxical_power_necessary (m := 3) h
        (fun k hk => h.prefix_ge_three hk))

/-- If the product inequality fails, no paradoxical segment has the specified pair. -/
theorem no_paradoxical_of_ten_pow_lt {j q : ℕ}
    (hfail : 10 ^ q < 2 ^ j * 3 ^ q) :
    ¬ ∃ n, Paradoxical n j ∧ oddCount n j = q := by
  rintro ⟨n, hp, hq⟩
  have hadmissible := hp.pairAdmissible
  rw [hq] at hadmissible
  exact (Nat.not_le_of_lt hfail) hadmissible.2

/-- The pair criterion excludes a length exactly when no `q ≤ j` is admissible. -/
def PairCriterionExcludes (j : ℕ) : Prop :=
  ∀ q, q ≤ j → ¬ PairAdmissible j q

/-! ## Five-step propagation and finality -/

/-- Admissibility propagates under `(j, q) ↦ (j + 5, q + 3)`. -/
theorem pairAdmissible_add_five_add_three {j q : ℕ}
    (h : PairAdmissible j q) : PairAdmissible (j + 5) (q + 3) := by
  rcases h with ⟨hlower, hupper⟩
  have h27_32 : 3 ^ 3 < 2 ^ 5 := by decide
  have h864_1000 : 2 ^ 5 * 3 ^ 3 < 10 ^ 3 := by decide
  constructor
  · rw [pow_add, pow_add]
    calc
      3 ^ q * 3 ^ 3 < 2 ^ j * 3 ^ 3 :=
        Nat.mul_lt_mul_of_pos_right hlower (by positivity)
      _ < 2 ^ j * 2 ^ 5 :=
        Nat.mul_lt_mul_of_pos_left h27_32 (by positivity)
  · rw [pow_add, pow_add, pow_add]
    calc
      (2 ^ j * 2 ^ 5) * (3 ^ q * 3 ^ 3) =
          (2 ^ j * 3 ^ q) * (2 ^ 5 * 3 ^ 3) := by ac_rfl
      _ ≤ 10 ^ q * (2 ^ 5 * 3 ^ 3) := Nat.mul_le_mul_right _ hupper
      _ ≤ 10 ^ q * 10 ^ 3 :=
        Nat.mul_le_mul_left _ (Nat.le_of_lt h864_1000)

/-- First residue-class base pair. -/
theorem pairAdmissible_5_3 : PairAdmissible 5 3 := by decide

/-- Second residue-class base pair. -/
theorem pairAdmissible_16_10 : PairAdmissible 16 10 := by decide

/-- Third residue-class base pair. -/
theorem pairAdmissible_12_7 : PairAdmissible 12 7 := by decide

/-- Fourth residue-class base pair. -/
theorem pairAdmissible_8_5 : PairAdmissible 8 5 := by decide

/-- Fifth residue-class base pair. -/
theorem pairAdmissible_19_11 : PairAdmissible 19 11 := by decide

/-- Every length at least `15` has an admissible odd-step count. -/
theorem exists_pairAdmissible_of_fifteen_le (j : ℕ) (hj : 15 ≤ j) :
    ∃ q, q ≤ j ∧ PairAdmissible j q := by
  induction j using Nat.strong_induction_on with
  | h j ih =>
      by_cases h20 : 20 ≤ j
      · obtain ⟨q, hqle, hq⟩ := ih (j - 5) (by omega) (by omega)
        refine ⟨q + 3, by omega, ?_⟩
        have hprop := pairAdmissible_add_five_add_three hq
        convert hprop using 1
        all_goals omega
      · have hj19 : j ≤ 19 := by omega
        interval_cases j
        · exact ⟨9, by decide,
            pairAdmissible_add_five_add_three
              (pairAdmissible_add_five_add_three pairAdmissible_5_3)⟩
        · exact ⟨10, by decide, pairAdmissible_16_10⟩
        · exact ⟨10, by decide,
            pairAdmissible_add_five_add_three pairAdmissible_12_7⟩
        · exact ⟨11, by decide,
            pairAdmissible_add_five_add_three
              (pairAdmissible_add_five_add_three pairAdmissible_8_5)⟩
        · exact ⟨11, by decide, pairAdmissible_19_11⟩

/-- No length at least `15` is excludable by the pair criterion. -/
theorem not_pairCriterionExcludes_of_fifteen_le (j : ℕ) (hj : 15 ≤ j) :
    ¬ PairCriterionExcludes j := by
  rintro hexcludes
  obtain ⟨q, hqle, hq⟩ := exists_pairAdmissible_of_fifteen_le j hj
  exact hexcludes q hqle hq

/-! ## Complete classification of excluded lengths -/

/--
For `j ≥ 2`, the pair criterion excludes exactly these eight lengths.
The cases `11` and `14` strictly extend the list printed in Corollary 4.4.
-/
theorem pairCriterionExcludes_iff {j : ℕ} (hj : 2 ≤ j) :
    PairCriterionExcludes j ↔
      j = 2 ∨ j = 3 ∨ j = 4 ∨ j = 6 ∨ j = 7 ∨ j = 9 ∨ j = 11 ∨ j = 14 := by
  constructor
  · intro hexcludes
    by_cases h15 : 15 ≤ j
    · exact (not_pairCriterionExcludes_of_fifteen_le j h15 hexcludes).elim
    · have hj14 : j ≤ 14 := by omega
      interval_cases j <;>
        first
        | decide
        | exact (hexcludes 3 (by decide) pairAdmissible_5_3).elim
        | exact (hexcludes 5 (by decide) pairAdmissible_8_5).elim
        | exact (hexcludes 6 (by decide)
            (pairAdmissible_add_five_add_three pairAdmissible_5_3)).elim
        | exact (hexcludes 7 (by decide) pairAdmissible_12_7).elim
        | exact (hexcludes 8 (by decide)
            (pairAdmissible_add_five_add_three pairAdmissible_8_5)).elim
  · intro hjmem
    rcases hjmem with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
      intro q hqle <;> interval_cases q <;> decide

end Collatz
