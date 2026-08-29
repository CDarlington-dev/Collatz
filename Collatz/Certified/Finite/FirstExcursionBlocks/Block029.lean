import Collatz.Certified.Finite.FirstExcursionKernelBase

namespace Collatz.Certified.Finite

theorem firstExcursionBlock029_true :
    firstExcursionBlockCheck 29 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
