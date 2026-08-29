import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock020_true :
    firstExcursionBlockCheck 20 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
