import Collatz.Certified.Finite.NoParadoxicalRange

namespace Collatz.Certified.Finite

theorem noParadoxicalRangeBlock048_true :
    noParadoxicalRangeBlockCheck 48 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
