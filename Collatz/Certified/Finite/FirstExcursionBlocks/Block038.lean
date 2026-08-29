import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock038_true :
    firstExcursionBlockCheck 38 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
