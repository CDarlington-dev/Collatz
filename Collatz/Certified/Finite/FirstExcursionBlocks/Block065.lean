import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

set_option maxHeartbeats 500000

theorem firstExcursionBlock065_true :
    firstExcursionBlockCheck 65 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
