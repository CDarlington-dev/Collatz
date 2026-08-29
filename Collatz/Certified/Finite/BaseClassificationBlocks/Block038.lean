import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock038_true :
    baseClassificationBlockCheck 38 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
