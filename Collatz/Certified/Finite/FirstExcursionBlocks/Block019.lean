import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock019_true :
    firstExcursionBlockCheck 19 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
