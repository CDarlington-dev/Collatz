import Collatz.Certified.Finite.OptimizedFirstExcursion

namespace Collatz.Certified.Finite

set_option maxHeartbeats 1000000

theorem optimizedFirstExcursionBlock010_true :
    optimizedFirstExcursionBlockCheck 10 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
