import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock022_true :
    baseClassificationBlockCheck 22 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
