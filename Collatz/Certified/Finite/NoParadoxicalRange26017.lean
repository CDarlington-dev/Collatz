import Collatz.Certified.Finite.NoParadoxicalRange
import Mathlib.Tactic

/-!
# Pure-kernel finite exclusion from 10015 through 26017

This module specializes the generic fail-closed checker from
`NoParadoxicalRange`.  Forty full blocks contain 400 starts each, beginning at
`10015`; a final three-start tail covers `26015,26016,26017`.  Fuel `178` is
part of every Boolean proposition checked by Lean, not an assumed stopping
time bound.
-/

namespace Collatz.Certified.Finite

/-- One of the forty 400-start blocks beginning at `10015`. -/
def noParadoxicalRange26017BlockCheck (block : ℕ) : Bool :=
  noParadoxicalIntervalCheck 178 (10015 + 400 * block) 400

/-- The forty full blocks cover starts `10015,...,26014`. -/
def noParadoxicalRange26017AllBlocksCheck : Bool :=
  (List.range 40).all noParadoxicalRange26017BlockCheck

/-- The exact non-full tail `26015,26016,26017`. -/
def noParadoxicalRange26017TailCheck : Bool :=
  noParadoxicalIntervalCheck 178 26015 3

/-!
The next two reduction facts pin down the fuel calibration at its extremal
start.  In particular, reducing fuel by one makes the fail-closed checker
reject, while fuel 178 accepts the same complete trajectory.
-/

theorem noParadoxicalRange26017_fuel177_fails_closed :
    noParadoxicalStartCheck 177 23529 = false := by
  set_option maxRecDepth 1000000 in
    decide

theorem noParadoxicalRange26017_fuel178_accepts_extremal :
    noParadoxicalStartCheck 178 23529 = true := by
  set_option maxRecDepth 1000000 in
    decide

/-- Soundness of the forty full blocks together with the exact tail. -/
theorem noParadoxicalRange26017Checks_sound
    (hblocks : noParadoxicalRange26017AllBlocksCheck = true)
    (htail : noParadoxicalRange26017TailCheck = true)
    {n j : ℕ} (hnlo : 10015 ≤ n) (hnhi : n < 26018) :
    ¬ Paradoxical n j := by
  by_cases hfull : n < 26015
  · have hall : ∀ b, b ∈ List.range 40 →
        noParadoxicalRange26017BlockCheck b = true := by
      simpa only [noParadoxicalRange26017AllBlocksCheck, List.all_eq_true] using
        hblocks
    let x := n - 10015
    let b := x / 400
    let t := x % 400
    have hx : 10015 + x = n := by
      dsimp [x]
      omega
    have hxlt : x < 16000 := by
      dsimp [x]
      omega
    have hb : b < 40 := by
      dsimp [b]
      exact (Nat.div_lt_iff_lt_mul (by norm_num : 0 < 400)).2 (by omega)
    have ht : t < 400 := by
      dsimp [t]
      exact Nat.mod_lt _ (by norm_num)
    have hdecomp : t + 400 * b = x := by
      simpa only [t, b] using Nat.mod_add_div x 400
    have hbmem : b ∈ List.range 40 := by
      simpa only [List.mem_range] using hb
    have hbcheck := hall b hbmem
    have hblo : 10015 + 400 * b ≤ n := by omega
    have hbhi : n < (10015 + 400 * b) + 400 := by omega
    exact noParadoxicalIntervalCheck_sound
      (by simpa only [noParadoxicalRange26017BlockCheck] using hbcheck)
      hblo hbhi (by omega) j
  · exact noParadoxicalIntervalCheck_sound
      (by simpa only [noParadoxicalRange26017TailCheck] using htail)
      (by omega) (by omega) (by omega) j

end Collatz.Certified.Finite
