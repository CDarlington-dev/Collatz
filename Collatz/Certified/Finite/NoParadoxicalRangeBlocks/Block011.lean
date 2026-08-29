import Collatz.Certified.Finite.NoParadoxicalRange

namespace Collatz.Certified.Finite

theorem noParadoxicalRangeBlock011_true :
    noParadoxicalRangeBlockCheck 11 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
