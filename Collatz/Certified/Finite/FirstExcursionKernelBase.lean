import Collatz.Certified.Finite.FirstExcursion

/-!
# Pure-kernel block certificate infrastructure for the first excursion envelope

`FirstExcursion.lean` supplies the executable trajectory checker and its
ordinary soundness proof.  This file partitions the finite domain so that each
acceptance equality can be established by ordinary kernel reduction (`decide`)
rather than the native evaluator.
-/

namespace Collatz

namespace Certified

namespace Finite

/-- The exact Boolean proposition checked for one start. -/
def firstExcursionAt (x : ℕ) : Bool :=
  if x = 0 then true else orbitCheck 1000000000 223 x

/-- Check `count` consecutive starts beginning at `lo`. -/
def firstExcursionIntervalCheck (lo count : ℕ) : Bool :=
  (List.range count).all fun i => firstExcursionAt (lo + i)

/-- Sound extraction of one checked start from a checked consecutive block. -/
theorem firstExcursionIntervalCheck_sound
    {lo count x : ℕ}
    (hcheck : firstExcursionIntervalCheck lo count = true)
    (hlo : lo ≤ x) (hhi : x < lo + count) :
    firstExcursionAt x = true := by
  have hall : ∀ i, i ∈ List.range count →
      firstExcursionAt (lo + i) = true := by
    simpa [firstExcursionIntervalCheck] using hcheck
  let i := x - lo
  have hi : i < count := by
    dsimp [i]
    omega
  have himem : i ∈ List.range count := by simpa using hi
  have hsum : lo + i = x := by
    dsimp [i]
    omega
  simpa [hsum] using hall i himem

/-- Block `b` starts at `1000*b`; the final block has only 383 entries. -/
def firstExcursionBlockCheck (b : ℕ) : Bool :=
  firstExcursionIntervalCheck (1000 * b) (if b = 113 then 383 else 1000)

end Finite

end Certified

end Collatz
