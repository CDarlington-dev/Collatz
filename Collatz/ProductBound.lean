import Collatz.Segment
import Mathlib.Algebra.Group.Nat.Even
import Mathlib.Tactic

/-!
# An exact replacement for the harmonic-mean estimate

If every input term of a `j`-step segment is at least `m`, multiplying the
one-step inequalities gives an integer inequality.  No logarithms or floating
point numbers occur.
-/

namespace Collatz

/-- The scaled product inequality for an arbitrary accelerated prefix. -/
theorem product_bound_aux (n j m : ℕ)
    (hmin : ∀ k < j, m ≤ endpoint n k) :
    2 ^ j * m ^ oddCount n j * endpoint n j ≤
      (3 * m + 1) ^ oddCount n j * n := by
  induction j generalizing n with
  | zero => simp
  | succ j ih =>
      have hmn : m ≤ n := by
        simpa using hmin 0 (Nat.zero_lt_succ j)
      have htail : ∀ k < j, m ≤ endpoint (T n) k := by
        intro k hk
        simpa [endpoint_succ_apply] using hmin (k + 1) (Nat.succ_lt_succ hk)
      have hih := ih (T n) htail
      by_cases heven : n % 2 = 0
      · have hnotodd : n % 2 ≠ 1 := by omega
        have hdouble : 2 * T n = n := by
          rw [T_of_even heven]
          exact Nat.two_mul_div_two_of_even (Nat.even_iff.mpr heven)
        rw [oddCount_succ_apply, if_neg hnotodd, zero_add, endpoint_succ_apply]
        calc
          2 ^ (j + 1) * m ^ oddCount (T n) j * endpoint (T n) j =
              2 * (2 ^ j * m ^ oddCount (T n) j * endpoint (T n) j) := by ring
          _ ≤ 2 * ((3 * m + 1) ^ oddCount (T n) j * T n) :=
              Nat.mul_le_mul_left 2 hih
          _ = (3 * m + 1) ^ oddCount (T n) j * n := by
              calc
                2 * ((3 * m + 1) ^ oddCount (T n) j * T n) =
                    (3 * m + 1) ^ oddCount (T n) j * (2 * T n) := by
                      ac_rfl
                _ = (3 * m + 1) ^ oddCount (T n) j * n := by rw [hdouble]
      · have hodd : n % 2 = 1 := by omega
        have hsum_even : Even (3 * n + 1) := Nat.even_iff.mpr (by omega)
        have hdouble : 2 * T n = 3 * n + 1 := by
          rw [T_of_odd hodd]
          exact Nat.two_mul_div_two_of_even hsum_even
        have hstep : m * (3 * n + 1) ≤ (3 * m + 1) * n := by
          nlinarith
        rw [oddCount_succ_apply, if_pos hodd, endpoint_succ_apply]
        calc
          2 ^ (j + 1) * m ^ (1 + oddCount (T n) j) * endpoint (T n) j =
              (2 * m) *
                (2 ^ j * m ^ oddCount (T n) j * endpoint (T n) j) := by ring
          _ ≤ (2 * m) * ((3 * m + 1) ^ oddCount (T n) j * T n) :=
              Nat.mul_le_mul_left (2 * m) hih
          _ = (3 * m + 1) ^ oddCount (T n) j * (m * (3 * n + 1)) := by
              calc
                (2 * m) * ((3 * m + 1) ^ oddCount (T n) j * T n) =
                    (3 * m + 1) ^ oddCount (T n) j * (m * (2 * T n)) := by
                      ac_rfl
                _ = (3 * m + 1) ^ oddCount (T n) j *
                    (m * (3 * n + 1)) := by rw [hdouble]
          _ ≤ (3 * m + 1) ^ oddCount (T n) j * ((3 * m + 1) * n) :=
              Nat.mul_le_mul_left _ hstep
          _ = (3 * m + 1) ^ (1 + oddCount (T n) j) * n := by ring

/--
Rozier--Terracol's necessary growth inequality with the harmonic mean weakened
to any common lower bound `m` for the input terms.
-/
theorem paradoxical_power_necessary {n j m : ℕ} (hp : Paradoxical n j)
    (hmin : ∀ k < j, m ≤ endpoint n k) :
    2 ^ j * m ^ oddCount n j ≤ (3 * m + 1) ^ oddCount n j := by
  have hscaled := product_bound_aux n j m hmin
  have hn : 0 < n := (hp.start_gt_two).trans' (by omega)
  have hmul :
      (2 ^ j * m ^ oddCount n j) * n ≤
        ((3 * m + 1) ^ oddCount n j) * n := by
    calc
      (2 ^ j * m ^ oddCount n j) * n ≤
          (2 ^ j * m ^ oddCount n j) * endpoint n j :=
        Nat.mul_le_mul_left _ hp.start_le_endpoint
      _ ≤ ((3 * m + 1) ^ oddCount n j) * n := by simpa [mul_assoc] using hscaled
  exact Nat.le_of_mul_le_mul_right hmul hn

end Collatz
