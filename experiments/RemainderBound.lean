import Collatz.Segment
import Mathlib.Tactic

namespace Collatz.RemainderBound

def maxRemainder (j q : ℕ) : ℕ :=
  2 ^ (j - q) * (3 ^ q - 2 ^ q)

theorem maxRemainder_even {j q : ℕ} (hq : q ≤ j) :
    maxRemainder (j + 1) q = 2 * maxRemainder j q := by
  have he : j + 1 - q = (j - q) + 1 := by omega
  simp [maxRemainder, he, pow_succ]
  ring

theorem maxRemainder_odd {j q : ℕ} (hq : q ≤ j) :
    3 ^ q + 2 * maxRemainder j q ≤ maxRemainder (j + 1) (q + 1) := by
  have he : j + 1 - (q + 1) = j - q := by omega
  have hp0 : 0 < 2 ^ (j - q) := Nat.pow_pos (by omega)
  have hp : 1 ≤ 2 ^ (j - q) := by omega
  have hpow : 2 ^ q ≤ 3 ^ q := Nat.pow_le_pow_left (by omega) q
  have hinside :
      3 ^ q + 2 * (3 ^ q - 2 ^ q) =
        3 ^ q * 3 - 2 ^ q * 2 := by
    omega
  have hxscale : 3 ^ q ≤ 2 ^ (j - q) * 3 ^ q := by
    calc
      3 ^ q = 1 * 3 ^ q := by simp
      _ ≤ 2 ^ (j - q) * 3 ^ q := Nat.mul_le_mul_right (3 ^ q) hp
  simp only [maxRemainder, he, pow_succ]
  calc
    3 ^ q + 2 * (2 ^ (j - q) * (3 ^ q - 2 ^ q))
        ≤ 2 ^ (j - q) * 3 ^ q +
            2 * (2 ^ (j - q) * (3 ^ q - 2 ^ q)) := by
          exact Nat.add_le_add_right hxscale _
    _ = 2 ^ (j - q) *
          (3 ^ q + 2 * (3 ^ q - 2 ^ q)) := by ring
    _ = 2 ^ (j - q) * (3 ^ q * 3 - 2 ^ q * 2) := by rw [hinside]

theorem scaled_endpoint_upper (n j : ℕ) :
    2 ^ j * endpoint n j ≤
      3 ^ oddCount n j * n + maxRemainder j (oddCount n j) := by
  induction j generalizing n with
  | zero => simp [maxRemainder]
  | succ j ih =>
      have hq := oddCount_le (T n) j
      by_cases hodd : n % 2 = 1
      · have ht : T n = (3 * n + 1) / 2 := by simp [T, hodd]
        have heven : (3 * n + 1) % 2 = 0 := by omega
        have htwice : 2 * T n = 3 * n + 1 := by
          rw [ht]
          exact Nat.mul_div_cancel' (by omega : 2 ∣ 3 * n + 1)
        have hi := ih (T n)
        have hmul := Nat.mul_le_mul_left 2 hi
        have hr := maxRemainder_odd hq
        rw [oddCount_succ_apply, if_pos hodd, endpoint_succ_apply]
        let q := oddCount (T n) j
        change 2 ^ (j + 1) * endpoint (T n) j ≤
          3 ^ (1 + q) * n + maxRemainder (j + 1) (1 + q)
        calc
          2 ^ (j + 1) * endpoint (T n) j =
              2 * (2 ^ j * endpoint (T n) j) := by rw [pow_succ]; ring
          _ ≤ 2 * (3 ^ q * T n + maxRemainder j q) := hmul
          _ = 3 ^ q * (2 * T n) + 2 * maxRemainder j q := by ring
          _ = 3 ^ q * (3 * n + 1) + 2 * maxRemainder j q := by rw [htwice]
          _ = 3 ^ (q + 1) * n +
              (3 ^ q + 2 * maxRemainder j q) := by
                rw [pow_succ]
                ring
          _ ≤ 3 ^ (q + 1) * n + maxRemainder (j + 1) (q + 1) :=
                Nat.add_le_add_left hr _
          _ = 3 ^ (1 + q) * n + maxRemainder (j + 1) (1 + q) := by
                rw [Nat.add_comm 1 q]
      · have heven : n % 2 = 0 := by omega
        have ht : T n = n / 2 := by simp [T, heven]
        have htwice : 2 * T n = n := by
          rw [ht]
          exact Nat.mul_div_cancel' (Nat.dvd_of_mod_eq_zero heven)
        have hi := ih (T n)
        have hmul := Nat.mul_le_mul_left 2 hi
        have hr := maxRemainder_even hq
        rw [oddCount_succ_apply, if_neg hodd, zero_add, endpoint_succ_apply]
        let q := oddCount (T n) j
        change 2 ^ (j + 1) * endpoint (T n) j ≤
          3 ^ q * n + maxRemainder (j + 1) q
        calc
          2 ^ (j + 1) * endpoint (T n) j =
              2 * (2 ^ j * endpoint (T n) j) := by rw [pow_succ]; ring
          _ ≤ 2 * (3 ^ q * T n + maxRemainder j q) := hmul
          _ = 3 ^ q * (2 * T n) + 2 * maxRemainder j q := by ring
          _ = 3 ^ q * n + 2 * maxRemainder j q := by rw [htwice]
          _ = 3 ^ q * n + maxRemainder (j + 1) q := by rw [hr]

theorem start_bound_of_paradoxical {n j : ℕ} (h : Paradoxical n j) :
    (2 ^ j - 3 ^ oddCount n j) * n ≤
      maxRemainder j (oddCount n j) := by
  have hs := scaled_endpoint_upper n j
  have hm := Nat.mul_le_mul_left (2 ^ j) h.start_le_endpoint
  have hpow := h.factor_lt_one
  have hdecomp :
      (2 ^ j - 3 ^ oddCount n j) * n + 3 ^ oddCount n j * n =
        2 ^ j * n := by
    rw [← Nat.add_mul, Nat.sub_add_cancel (Nat.le_of_lt hpow)]
  omega

def shortBoundCheck : Bool :=
  (List.range 27).all fun j =>
    (List.range (j + 1)).all fun q =>
      decide (3 ^ q < 2 ^ j →
        maxRemainder j q < (2 ^ j - 3 ^ q) * 4615)

theorem shortBoundCheck_true : shortBoundCheck = true := by
  decide

theorem short_numeric_bound {j q : ℕ} (hj : j ≤ 26) (hq : q ≤ j)
    (hfactor : 3 ^ q < 2 ^ j) :
    maxRemainder j q < (2 ^ j - 3 ^ q) * 4615 := by
  have hallj : ∀ x, x ∈ List.range 27 →
      (List.range (x + 1)).all fun y =>
        decide (3 ^ y < 2 ^ x →
          maxRemainder x y < (2 ^ x - 3 ^ y) * 4615) = true := by
    simpa [shortBoundCheck] using shortBoundCheck_true
  have hjmem : j ∈ List.range 27 := by
    simp only [List.mem_range]
    omega
  have hallq := hallj j hjmem
  have hqmem : q ∈ List.range (j + 1) := by simpa using hq
  have hcheck : decide (3 ^ q < 2 ^ j →
      maxRemainder j q < (2 ^ j - 3 ^ q) * 4615) = true := by
    simpa using (List.all_eq_true.mp hallq q hqmem)
  exact (of_decide_eq_true hcheck) hfactor

theorem no_paradoxical_short_above_4614 {n j : ℕ}
    (hn : 4614 < n) (hj : j ≤ 26) : ¬ Paradoxical n j := by
  intro hp
  have hq := oddCount_le n j
  have hupper := start_bound_of_paradoxical hp
  have hlower := short_numeric_bound hj hq hp.factor_lt_one
  have hn4615 : 4615 ≤ n := by omega
  have hmul := Nat.mul_le_mul_left (2 ^ j - 3 ^ oddCount n j) hn4615
  omega

#print axioms scaled_endpoint_upper
#print axioms no_paradoxical_short_above_4614

end Collatz.RemainderBound
