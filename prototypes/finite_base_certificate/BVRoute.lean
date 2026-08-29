import Std.Tactic.BVDecide

/-!
Small feasibility probe for a proof-producing bounded-model certificate.

`bv_decide` bit-blasts the universally quantified `BitVec` proposition, asks
CaDiCaL for an LRAT refutation, and checks the refutation using Lean's verified
LRAT checker.  The production finite-base theorem would use a wider no-overflow
model and would preserve the generated LRAT file with `bv_check`.
-/

namespace CollatzPrototype

def acceleratedBV (x : BitVec 32) : BitVec 32 :=
  if x.getLsbD 0 then (3 * x + 1) >>> 1 else x >>> 1

attribute [bv_normalize] acceleratedBV

def reachesOneWithinBV : Nat → BitVec 32 → Bool
  | 0, x => x == 1
  | fuel + 1, x => (x == 1) || reachesOneWithinBV fuel (acceleratedBV x)

set_option maxHeartbeats 0 in
theorem reachesOneThrough20 :
    ∀ x : BitVec 32,
      (1 : BitVec 32) ≤ x → x ≤ (20 : BitVec 32) →
        reachesOneWithinBV 30 x = true := by
  set_option maxRecDepth 10000 in
  simp only [reachesOneWithinBV]
  bv_decide (timeout := 120)

end CollatzPrototype
