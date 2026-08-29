import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

set_option maxHeartbeats 500000

theorem firstExcursionBlock074_true :
    firstExcursionBlockCheck 74 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
