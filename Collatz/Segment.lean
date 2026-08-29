import Collatz.Map

/-!
# Finite accelerated Collatz segments

For a segment with `j` steps starting at `n`, `oddCount n j` counts the odd
inputs to those steps (the terms with indices `0, ..., j - 1`), and
`endpoint n j` is the term at index `j`.
-/

namespace Collatz

/-- The endpoint `T^[j](n)` of the accelerated segment starting at `n`. -/
def endpoint (n j : ℕ) : ℕ := iterate T j n

/-- The number of odd steps among the first `j` accelerated Collatz steps. -/
def oddCount : ℕ → ℕ → ℕ
  | _, 0 => 0
  | n, j + 1 => (if n % 2 = 1 then 1 else 0) + oddCount (T n) j

@[simp] theorem endpoint_zero (n : ℕ) : endpoint n 0 = n := rfl

@[simp] theorem endpoint_succ_apply (n j : ℕ) :
    endpoint n (j + 1) = endpoint (T n) j := rfl

theorem endpoint_succ (n j : ℕ) : endpoint n (j + 1) = T (endpoint n j) := by
  exact iterate_succ j n

theorem endpoint_add (n i j : ℕ) :
    endpoint n (i + j) = endpoint (endpoint n i) j := by
  exact iterate_add i j n

theorem endpoint_eq_function_iterate (n j : ℕ) : endpoint n j = (T^[j]) n := by
  exact iterate_eq_function_iterate j n

@[simp] theorem oddCount_zero (n : ℕ) : oddCount n 0 = 0 := rfl

@[simp] theorem oddCount_succ_apply (n j : ℕ) :
    oddCount n (j + 1) =
      (if n % 2 = 1 then 1 else 0) + oddCount (T n) j := rfl

theorem oddCount_succ (n j : ℕ) :
    oddCount n (j + 1) =
      oddCount n j + (if endpoint n j % 2 = 1 then 1 else 0) := by
  induction j generalizing n with
  | zero => simp [oddCount, endpoint]
  | succ j ih =>
      rw [oddCount_succ_apply, ih (T n), oddCount_succ_apply]
      rw [endpoint_succ_apply]
      omega

theorem oddCount_add (n i j : ℕ) :
    oddCount n (i + j) = oddCount n i + oddCount (endpoint n i) j := by
  induction i generalizing n with
  | zero => simp
  | succ i ih =>
      rw [Nat.succ_add, oddCount_succ_apply, ih (T n), oddCount_succ_apply]
      rw [endpoint_succ_apply]
      omega

theorem oddCount_le (n j : ℕ) : oddCount n j ≤ j := by
  induction j generalizing n with
  | zero => simp
  | succ j ih =>
      rw [oddCount_succ_apply]
      have hle := ih (T n)
      split_ifs <;> omega

theorem oddCount_succ_of_even {n : ℕ} (h : n % 2 = 0) (j : ℕ) :
    oddCount n (j + 1) = oddCount (T n) j := by
  rw [oddCount_succ_apply]
  have hne : n % 2 ≠ 1 := by omega
  simp [hne]

theorem oddCount_succ_of_odd {n : ℕ} (h : n % 2 = 1) (j : ℕ) :
    oddCount n (j + 1) = 1 + oddCount (T n) j := by
  simp [h]

/--
An accelerated Collatz segment is paradoxical exactly when it has a starting
value greater than `2`, has positive length, has multiplicative factor below
one (`3^q < 2^j`), but nevertheless ends no lower than it started.
-/
def Paradoxical (n j : ℕ) : Prop :=
  2 < n ∧ 0 < j ∧ 3 ^ oddCount n j < 2 ^ j ∧ n ≤ endpoint n j

instance instDecidableParadoxical (n j : ℕ) : Decidable (Paradoxical n j) := by
  unfold Paradoxical
  infer_instance

theorem paradoxical_iff {n j : ℕ} :
    Paradoxical n j ↔
      2 < n ∧ 0 < j ∧ 3 ^ oddCount n j < 2 ^ j ∧ n ≤ endpoint n j :=
  Iff.rfl

namespace Paradoxical

theorem start_gt_two {n j : ℕ} (h : Paradoxical n j) : 2 < n := h.1

theorem length_pos {n j : ℕ} (h : Paradoxical n j) : 0 < j := h.2.1

theorem factor_lt_one {n j : ℕ} (h : Paradoxical n j) :
    3 ^ oddCount n j < 2 ^ j := h.2.2.1

theorem start_le_endpoint {n j : ℕ} (h : Paradoxical n j) :
    n ≤ endpoint n j := h.2.2.2

end Paradoxical

/-! ## Published paradoxical segments

The following kernel-checked computations reproduce the examples requested
from Rozier--Terracol.  The separate count and endpoint statements expose all
the data used by each `Paradoxical` proof.
-/

theorem oddCount_7_8 : oddCount 7 8 = 5 := by decide
theorem endpoint_7_8 : endpoint 7 8 = 8 := by decide
theorem paradoxical_7_8 : Paradoxical 7 8 := by decide

theorem oddCount_18_8 : oddCount 18 8 = 5 := by decide
theorem endpoint_18_8 : endpoint 18 8 = 20 := by decide
theorem paradoxical_18_8 : Paradoxical 18 8 := by decide

theorem oddCount_859_46 : oddCount 859 46 = 29 := by decide
theorem endpoint_859_46 : endpoint 859 46 = 890 := by
  set_option maxRecDepth 100000 in decide
theorem paradoxical_859_46 : Paradoxical 859 46 := by decide

theorem oddCount_859_65 : oddCount 859 65 = 41 := by decide
theorem endpoint_859_65 : endpoint 859 65 = 911 := by
  set_option maxRecDepth 100000 in decide
theorem paradoxical_859_65 : Paradoxical 859 65 := by decide

theorem oddCount_859_73 : oddCount 859 73 = 46 := by decide
theorem endpoint_859_73 : endpoint 859 73 = 866 := by
  set_option maxRecDepth 100000 in decide
theorem paradoxical_859_73 : Paradoxical 859 73 := by decide

end Collatz
