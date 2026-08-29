import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock029_true :
    baseClassificationBlockCheck 29 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
