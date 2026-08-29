import Collatz.Certified.Finite.NoParadoxicalRange

namespace Collatz.Certified.Finite

theorem noParadoxicalRangeBlock020_true :
    noParadoxicalRangeBlockCheck 20 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
