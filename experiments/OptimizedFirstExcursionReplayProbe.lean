import Collatz.Certified.Finite.FirstExcursion

/-!
Timing-only comparison module for the superseded replay-to-`1` design.  This
is not imported by the production theorem.  Block 77 contains both the exact
221-step stopping extremal and the exact excursion-peak start.
-/

namespace Collatz.Certified.Finite

def optimizedFirstExcursionReplayProbe : Bool :=
  (List.range 1000).all fun i => orbitCheck 785412369 221 (77000 + i)

set_option maxHeartbeats 1000000

theorem optimizedFirstExcursionReplayProbe_true :
    optimizedFirstExcursionReplayProbe = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
