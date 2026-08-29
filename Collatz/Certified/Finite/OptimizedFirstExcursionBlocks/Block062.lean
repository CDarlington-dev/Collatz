import Collatz.Certified.Finite.OptimizedFirstExcursion

namespace Collatz.Certified.Finite

set_option maxHeartbeats 1000000

theorem optimizedFirstExcursionBlock062_true :
    optimizedFirstExcursionBlockCheck 62 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
