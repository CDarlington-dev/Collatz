import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock025_true :
    firstExcursionBlockCheck 25 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
