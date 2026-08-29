import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock033_true :
    baseClassificationBlockCheck 33 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
