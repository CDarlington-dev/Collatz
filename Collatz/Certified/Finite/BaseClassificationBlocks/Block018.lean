import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock018_true :
    baseClassificationBlockCheck 18 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
