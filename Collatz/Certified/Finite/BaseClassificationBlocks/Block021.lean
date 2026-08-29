import Collatz.Certified.Finite.BaseClassification

namespace Collatz.Certified.Finite

theorem baseClassificationBlock021_true :
    baseClassificationBlockCheck 21 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
