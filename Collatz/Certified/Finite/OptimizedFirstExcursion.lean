import Collatz.Certified.Finite.FirstExcursion
import Mathlib.Tactic

/-!
# Pure-kernel checker for the optimized first-feedback excursion envelope

For each start above the terminal set `{0,1,2}`, the checker follows the exact
accelerated orbit until it reaches a strictly smaller positive-index state,
checking every state in that prefix against the strict excursion threshold.
A strong-induction proof composes these checked descents and supplies the
all-time envelope.

The finite domain is split into 99 full 1000-start blocks and the exact tail
`99000,...,99780`.  Fuel `135` is part of every accepted Boolean proposition;
the checker fails closed if no strict descent is found within that fuel.
-/

namespace Collatz.Certified.Finite

open RecordBounds

/--
Check at most `fuel` accelerated steps from `current`, requiring every visited
state to be below `threshold` and accepting only after a positive-index state
strictly below `start` is reached.
-/
def firstDescentExcursionCheck (threshold start : ℕ) : ℕ → ℕ → Bool
  | 0, _ => false
  | fuel + 1, current =>
      decide (current < threshold) &&
        decide (T current < threshold) &&
          if T current < start then true
          else firstDescentExcursionCheck threshold start fuel (T current)

/--
An accepted descent check supplies a positive step bounded by the checked fuel,
a strict descent, and the strict threshold bound for its complete prefix.
-/
theorem firstDescentExcursionCheck_sound
    {threshold start fuel current : ℕ}
    (hcheck : firstDescentExcursionCheck threshold start fuel current = true) :
    ∃ d, 0 < d ∧ d ≤ fuel ∧ endpoint current d < start ∧
      ∀ r ≤ d, endpoint current r < threshold := by
  induction fuel generalizing current with
  | zero =>
      simp [firstDescentExcursionCheck] at hcheck
  | succ fuel ih =>
      have hparts :
          (current < threshold ∧ T current < threshold) ∧
            (T current < start ∨
              firstDescentExcursionCheck threshold start fuel (T current) = true) := by
        simpa [firstDescentExcursionCheck] using hcheck
      by_cases hdesc : T current < start
      · refine ⟨1, by omega, by omega, ?_, ?_⟩
        · simpa [endpoint] using hdesc
        · intro r hr
          interval_cases r
          · simpa [endpoint] using hparts.1.1
          · simpa [endpoint] using hparts.1.2
      · have htail :
            firstDescentExcursionCheck threshold start fuel (T current) = true := by
          rcases hparts.2 with hbad | htail
          · exact (hdesc hbad).elim
          · exact htail
        obtain ⟨d, hdpos, hdle, hdend, hprefix⟩ := ih htail
        refine ⟨d + 1, by omega, by omega, ?_, ?_⟩
        · simpa [endpoint_succ_apply] using hdend
        · intro r hr
          cases r with
          | zero => simpa [endpoint] using hparts.1.1
          | succ r =>
              have hrle : r ≤ d := by omega
              simpa [endpoint_succ_apply] using hprefix r hrle

/-- The exact Boolean proposition checked for one seed. -/
def optimizedFirstExcursionAt (x : ℕ) : Bool :=
  if x ≤ 2 then true else firstDescentExcursionCheck 785412369 x 135 x

/-- Check `count` consecutive starts beginning at `lo`. -/
def optimizedFirstExcursionIntervalCheck (lo count : ℕ) : Bool :=
  (List.range count).all fun i => optimizedFirstExcursionAt (lo + i)

/-- Extract one checked start from an accepted consecutive block. -/
theorem optimizedFirstExcursionIntervalCheck_sound
    {lo count x : ℕ}
    (hcheck : optimizedFirstExcursionIntervalCheck lo count = true)
    (hlo : lo ≤ x) (hhi : x < lo + count) :
    optimizedFirstExcursionAt x = true := by
  have hall : ∀ i, i ∈ List.range count →
      optimizedFirstExcursionAt (lo + i) = true := by
    simpa [optimizedFirstExcursionIntervalCheck] using hcheck
  let i := x - lo
  have hi : i < count := by
    dsimp [i]
    omega
  have himem : i ∈ List.range count := by simpa using hi
  have hsum : lo + i = x := by
    dsimp [i]
    omega
  simpa [hsum] using hall i himem

/-- Full block `b` covers `1000*b,...,1000*b+999`. -/
def optimizedFirstExcursionBlockCheck (b : ℕ) : Bool :=
  optimizedFirstExcursionIntervalCheck (1000 * b) 1000

/-- Blocks `0,...,98` cover exactly the starts below `99000`. -/
def optimizedFirstExcursionAllBlocksCheck : Bool :=
  (List.range 99).all optimizedFirstExcursionBlockCheck

/-- The exact non-full tail covers `99000,...,99780`. -/
def optimizedFirstExcursionTailCheck : Bool :=
  optimizedFirstExcursionIntervalCheck 99000 781

/-- Fuel 134 rejects at the exact longest first-descent trajectory. -/
theorem optimizedFirstExcursion_fuel134_fails_closed :
    firstDescentExcursionCheck 785412369 35655 134 35655 = false := by
  set_option maxRecDepth 1000000 in
    decide

/-- Fuel 135 accepts that same first-descent trajectory. -/
theorem optimizedFirstExcursion_fuel135_accepts_extremal :
    firstDescentExcursionCheck 785412369 35655 135 35655 = true := by
  set_option maxRecDepth 1000000 in
    decide

/-- A concrete orbit attains the largest state allowed by the strict bound. -/
theorem optimizedFirstExcursion_peak :
    endpoint 77671 39 = 785412368 := by
  set_option maxRecDepth 1000000 in
    decide

/-- Every accelerated endpoint from the terminal set `{0,1,2}` is at most 2. -/
theorem optimizedEndpoint_le_two_of_le_two
    {x : ℕ} (hx : x ≤ 2) (r : ℕ) : endpoint x r ≤ 2 := by
  interval_cases x
  · norm_num [endpoint_zero_all]
  · exact (endpoint_one_two_cycle_le_two r).1
  · exact (endpoint_one_two_cycle_le_two r).2

/-- Extract the checked Boolean proposition for any seed below `99781`. -/
theorem optimizedFirstExcursionAt_true_of_checks
    (hblocks : optimizedFirstExcursionAllBlocksCheck = true)
    (htail : optimizedFirstExcursionTailCheck = true)
    {x : ℕ} (hx : x < 99781) :
    optimizedFirstExcursionAt x = true := by
  by_cases hfull : x < 99000
  · have hall : ∀ b, b ∈ List.range 99 →
        optimizedFirstExcursionBlockCheck b = true := by
      simpa only [optimizedFirstExcursionAllBlocksCheck, List.all_eq_true]
        using hblocks
    let b := x / 1000
    have hb : b < 99 := by
      dsimp [b]
      exact (Nat.div_lt_iff_lt_mul (by norm_num : 0 < 1000)).2 (by omega)
    have hbmem : b ∈ List.range 99 := by simpa using hb
    have hbcheck := hall b hbmem
    have hlo : 1000 * b ≤ x := by
      have h := Nat.div_mul_le_self x 1000
      simpa [b, Nat.mul_comm] using h
    have hmod : x % 1000 < 1000 := Nat.mod_lt x (by norm_num)
    have hdecomp : x / 1000 * 1000 + x % 1000 = x :=
      by simpa [Nat.mul_comm] using Nat.div_add_mod x 1000
    exact optimizedFirstExcursionIntervalCheck_sound
      (by simpa only [optimizedFirstExcursionBlockCheck] using hbcheck)
      hlo (by dsimp [b]; omega)
  · exact optimizedFirstExcursionIntervalCheck_sound htail
      (by omega) (by omega)

/--
Accepted first-descent blocks imply the optimized all-time accelerated
excursion envelope by strong induction on the start.
-/
theorem optimizedFirstExcursionChecks_sound
    (hblocks : optimizedFirstExcursionAllBlocksCheck = true)
    (htail : optimizedFirstExcursionTailCheck = true) :
    AcceleratedExcursionEnvelope 785412369 99781 := by
  intro x
  induction x using Nat.strong_induction_on with
  | h x ih =>
      intro hx r
      by_cases hsmall : x ≤ 2
      · have hterminal := optimizedEndpoint_le_two_of_le_two hsmall r
        omega
      · have hxat := optimizedFirstExcursionAt_true_of_checks hblocks htail hx
        have hxcheck :
            firstDescentExcursionCheck 785412369 x 135 x = true := by
          simpa [optimizedFirstExcursionAt, hsmall] using hxat
        obtain ⟨d, hdpos, _hdle, hdesc, hprefix⟩ :=
          firstDescentExcursionCheck_sound hxcheck
        by_cases hrd : r ≤ d
        · exact hprefix r hrd
        · have hdr : d ≤ r := by omega
          calc
            endpoint x r = endpoint x (d + (r - d)) := by
              rw [Nat.add_sub_of_le hdr]
            _ = endpoint (endpoint x d) (r - d) := endpoint_add x d (r - d)
            _ < 785412369 := ih (endpoint x d) hdesc (by omega) (r - d)

end Collatz.Certified.Finite
