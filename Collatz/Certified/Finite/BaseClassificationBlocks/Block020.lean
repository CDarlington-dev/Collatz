import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock020_true :
    baseClassificationBlockCheck 20 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
