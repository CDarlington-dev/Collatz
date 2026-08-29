import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock015_true :
    firstExcursionBlockCheck 15 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
