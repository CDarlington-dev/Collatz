import Collatz.RecordBounds
import Mathlib.Tactic

/-!
# Pure-kernel finite exclusion by incremental trajectory checking

This module defines a proof-producing Boolean checker for a whole interval of
accelerated-Collatz starts.  For each start it carries the current endpoint,
segment length, and odd-input count incrementally.  Every positive prefix is
checked until an exact visit to `1`; an ordinary Lean proof then excludes all
later prefixes using the accelerated terminal cycle `1,2,1,2,...`.

The generic soundness theorems contain no finite-range assumption.  Concrete
range modules may prove Boolean acceptance with ordinary `decide`; no use of
`native_decide` is needed or intended.
-/

namespace Collatz

namespace Certified

namespace Finite

/-- The contribution of one accelerated input to `oddCount`. -/
def oddIncrement (n : ℕ) : ℕ :=
  if n % 2 = 1 then 1 else 0

/-- Multiplicative update of `3^oddCount` for one input. -/
def oddPowerMultiplier (n : ℕ) : ℕ :=
  if n % 2 = 1 then 3 else 1

/--
Incremental exact scan from an accumulated state.

The state `(current, length, odds, powTwo, powThree)` is intended to mean
`current = endpoint start length`, `odds = oddCount start length`,
`powTwo = 2^length`, and `powThree = 3^odds`.  Carrying both powers avoids
recomputing them from scratch at every prefix.  A step first computes the next
endpoint and counters, checks that this new prefix is not paradoxical, and
only then recurses.  Fuel exhaustion away from `1` fails closed.
-/
def noParadoxicalScanAux (start : ℕ) :
    ℕ → ℕ → ℕ → ℕ → ℕ → ℕ → Bool
  | 0, current, _, _, _, _ => decide (current = 1)
  | fuel + 1, current, length, odds, powTwo, powThree =>
      if current = 1 then true
      else
        decide (¬ (
          powThree * oddPowerMultiplier current < 2 * powTwo ∧
            start ≤ T current)) &&
          noParadoxicalScanAux start fuel (T current) (length + 1)
            (odds + oddIncrement current) (2 * powTwo)
            (powThree * oddPowerMultiplier current)

/-- Check one start, beginning with its exact length-zero state. -/
def noParadoxicalStartCheck (fuel start : ℕ) : Bool :=
  noParadoxicalScanAux start fuel start 0 0 1 1

/--
Soundness of an accumulated scan.  Besides the exact visit to `1`, the result
records the absence of both decisive paradoxical inequalities at every newly
checked global prefix.
-/
theorem noParadoxicalScanAux_sound
    {start fuel current length odds powTwo powThree : ℕ}
    (hcurrent : current = endpoint start length)
    (hodds : odds = oddCount start length)
    (hpowTwo : powTwo = 2 ^ length)
    (hpowThree : powThree = 3 ^ odds)
    (hcheck :
      noParadoxicalScanAux start fuel current length odds powTwo powThree = true) :
    ∃ d, length ≤ d ∧ d ≤ length + fuel ∧ endpoint start d = 1 ∧
      ∀ r, length < r → r ≤ d →
        ¬ (3 ^ oddCount start r < 2 ^ r ∧ start ≤ endpoint start r) := by
  induction fuel generalizing current length odds powTwo powThree with
  | zero =>
      have hone : current = 1 := by
        simpa [noParadoxicalScanAux] using hcheck
      refine ⟨length, Nat.le_refl _, by omega, hcurrent.symm.trans hone, ?_⟩
      intro r hlr hrd
      omega
  | succ fuel ih =>
      by_cases hone : current = 1
      · refine ⟨length, Nat.le_refl _, by omega, hcurrent.symm.trans hone, ?_⟩
        intro r hlr hrd
        omega
      · have hparts :
            (2 * powTwo ≤ powThree * oddPowerMultiplier current ∨
                T current < start) ∧
              noParadoxicalScanAux start fuel (T current) (length + 1)
                (odds + oddIncrement current) (2 * powTwo)
                (powThree * oddPowerMultiplier current) = true := by
          simpa [noParadoxicalScanAux, hone] using hcheck
        have hcurrent' : T current = endpoint start (length + 1) := by
          calc
            T current = T (endpoint start length) := by rw [← hcurrent]
            _ = endpoint start (length + 1) := (endpoint_succ start length).symm
        have hodds' :
            odds + oddIncrement current = oddCount start (length + 1) := by
          calc
            odds + oddIncrement current =
                oddCount start length +
                  (if endpoint start length % 2 = 1 then 1 else 0) := by
              simp [oddIncrement, hodds, hcurrent]
            _ = oddCount start (length + 1) :=
              (oddCount_succ start length).symm
        have hpowTwo' : 2 * powTwo = 2 ^ (length + 1) := by
          rw [hpowTwo, pow_succ]
          ring
        have hpowThree' :
            powThree * oddPowerMultiplier current =
              3 ^ (odds + oddIncrement current) := by
          by_cases hodd : current % 2 = 1
          · simp [oddPowerMultiplier, oddIncrement, hodd, hpowThree, pow_succ,
              Nat.mul_comm]
          · simp [oddPowerMultiplier, oddIncrement, hodd, hpowThree]
        have hfirst :
            ¬ (3 ^ oddCount start (length + 1) < 2 ^ (length + 1) ∧
              start ≤ endpoint start (length + 1)) := by
          intro hbad
          have hbad' :
              powThree * oddPowerMultiplier current < 2 * powTwo ∧
                start ≤ T current := by
            simpa [hpowThree', hpowTwo', hodds', hcurrent'] using hbad
          rcases hparts.1 with hfactor | hendpoint <;> omega
        obtain ⟨d, hlength, hdfuel, hend, hsafe⟩ :=
          ih hcurrent' hodds' hpowTwo' hpowThree' hparts.2
        refine ⟨d, by omega, by omega, hend, ?_⟩
        intro r hlr hrd
        by_cases hr : r = length + 1
        · simpa [hr] using hfirst
        · exact hsafe r (by omega) hrd

/-- Both accelerated terminal-cycle states stay at most `2`. -/
theorem endpoint_one_two_cycle_le_two_for_range (r : ℕ) :
    endpoint 1 r ≤ 2 ∧ endpoint 2 r ≤ 2 := by
  induction r with
  | zero => norm_num [endpoint]
  | succ r ih =>
      rw [endpoint_succ_apply, endpoint_succ_apply]
      norm_num [T]
      exact ⟨ih.2, ih.1⟩

/--
An accepted start greater than `2` has no paradoxical segment of any length.
-/
theorem noParadoxicalStartCheck_sound
    {fuel start : ℕ} (hstart : 2 < start)
    (hcheck : noParadoxicalStartCheck fuel start = true) :
    ∀ j, ¬ Paradoxical start j := by
  obtain ⟨d, _hdnonneg, hdfuel, hone, hsafe⟩ :=
    noParadoxicalScanAux_sound
      (start := start) (fuel := fuel) (current := start) (length := 0) (odds := 0)
      (powTwo := 1) (powThree := 1)
      (by simp [endpoint]) (by simp) (by norm_num) (by norm_num) hcheck
  intro j hp
  by_cases hjd : j ≤ d
  · have hjpos : 0 < j := hp.length_pos
    exact (hsafe j hjpos hjd) ⟨hp.factor_lt_one, hp.start_le_endpoint⟩
  · have hdj : d ≤ j := by omega
    have hjadd : d + (j - d) = j := Nat.add_sub_of_le hdj
    have hend : endpoint start j = endpoint 1 (j - d) := by
      calc
        endpoint start j = endpoint start (d + (j - d)) := by rw [hjadd]
        _ = endpoint (endpoint start d) (j - d) := endpoint_add start d (j - d)
        _ = endpoint 1 (j - d) := by rw [hone]
    have hcycle : endpoint 1 (j - d) ≤ 2 :=
      (endpoint_one_two_cycle_le_two_for_range (j - d)).1
    have hnend := hp.start_le_endpoint
    rw [hend] at hnend
    omega

/-! ## Consecutive intervals and fixed-size blocks -/

/-- Check `count` consecutive starts beginning at `lo`. -/
def noParadoxicalIntervalCheck (fuel lo count : ℕ) : Bool :=
  (List.range count).all fun i => noParadoxicalStartCheck fuel (lo + i)

/-- Sound extraction of one start from a checked consecutive interval. -/
theorem noParadoxicalIntervalCheck_sound
    {fuel lo count n : ℕ}
    (hcheck : noParadoxicalIntervalCheck fuel lo count = true)
    (hnlo : lo ≤ n) (hnhi : n < lo + count) (hnstart : 2 < n) :
    ∀ j, ¬ Paradoxical n j := by
  have hall : ∀ i, i ∈ List.range count →
      noParadoxicalStartCheck fuel (lo + i) = true := by
    simpa [noParadoxicalIntervalCheck] using hcheck
  let i := n - lo
  have hi : i < count := by
    dsimp [i]
    omega
  have himem : i ∈ List.range count := by simpa using hi
  have hsum : lo + i = n := by
    dsimp [i]
    omega
  apply noParadoxicalStartCheck_sound hnstart
  simpa [hsum] using hall i himem

/--
Block `b` contains the 100 starts beginning at `4615 + 100*b`.  Fuel `223`
is deliberately checked rather than assumed.
-/
def noParadoxicalRangeBlockCheck (b : ℕ) : Bool :=
  noParadoxicalIntervalCheck 223 (4615 + 100 * b) 100

/-- All 54 blocks together cover starts `4615,...,10014`. -/
def noParadoxicalAllBlocksCheck : Bool :=
  (List.range 54).all noParadoxicalRangeBlockCheck

/--
Soundness of the 54-block aggregate.  This theorem contains the only quotient
arithmetic needed to route an arbitrary start to its checked block.
-/
theorem noParadoxicalAllBlocksCheck_sound
    (hcheck : noParadoxicalAllBlocksCheck = true)
    {n j : ℕ} (hnlo : 4615 ≤ n) (hnhi : n < 10015) :
    ¬ Paradoxical n j := by
  have hall : ∀ b, b ∈ List.range 54 →
      noParadoxicalRangeBlockCheck b = true := by
    simpa [noParadoxicalAllBlocksCheck] using hcheck
  let x := n - 4615
  let b := x / 100
  let t := x % 100
  have hx : 4615 + x = n := by
    dsimp [x]
    omega
  have hxlt : x < 5400 := by
    dsimp [x]
    omega
  have hb : b < 54 := by
    dsimp [b]
    exact (Nat.div_lt_iff_lt_mul (by norm_num : 0 < 100)).2 (by omega)
  have ht : t < 100 := by
    dsimp [t]
    exact Nat.mod_lt _ (by norm_num)
  have hdecomp : t + 100 * b = x := by
    simpa [t, b] using Nat.mod_add_div x 100
  have hbmem : b ∈ List.range 54 := by simpa using hb
  have hbcheck := hall b hbmem
  have hblo : 4615 + 100 * b ≤ n := by omega
  have hbhi : n < (4615 + 100 * b) + 100 := by omega
  exact noParadoxicalIntervalCheck_sound
    (by simpa [noParadoxicalRangeBlockCheck] using hbcheck)
    hblo hbhi (by omega) j

end Finite

end Certified

end Collatz
