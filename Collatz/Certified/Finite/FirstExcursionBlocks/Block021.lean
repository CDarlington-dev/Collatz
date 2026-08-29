import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock021_true :
    firstExcursionBlockCheck 21 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
