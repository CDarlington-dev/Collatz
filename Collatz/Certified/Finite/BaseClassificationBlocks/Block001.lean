import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock001_true :
    baseClassificationBlockCheck 1 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
