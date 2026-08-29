import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock045_true :
    firstExcursionBlockCheck 45 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
