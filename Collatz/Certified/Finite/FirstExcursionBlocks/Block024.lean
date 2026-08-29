import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock024_true :
    firstExcursionBlockCheck 24 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
