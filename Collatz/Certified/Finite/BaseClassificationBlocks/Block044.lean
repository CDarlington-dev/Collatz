import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock044_true :
    baseClassificationBlockCheck 44 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
