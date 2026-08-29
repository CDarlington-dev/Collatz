import Collatz.Certified.Finite.OptimizedFirstExcursion

namespace Collatz.Certified.Finite

set_option maxHeartbeats 1000000

theorem optimizedFirstExcursionBlock046_true :
    optimizedFirstExcursionBlockCheck 46 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
