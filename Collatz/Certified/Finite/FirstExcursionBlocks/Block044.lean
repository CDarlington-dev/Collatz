import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock044_true :
    firstExcursionBlockCheck 44 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
