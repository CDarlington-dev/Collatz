import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock009_true :
    baseClassificationBlockCheck 9 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
