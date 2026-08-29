import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock030_true :
    baseClassificationBlockCheck 30 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
