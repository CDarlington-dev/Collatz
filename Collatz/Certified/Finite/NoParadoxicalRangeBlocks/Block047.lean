import Collatz.Certified.Finite.NoParadoxicalRange

namespace Collatz.Certified.Finite

theorem noParadoxicalRangeBlock047_true :
    noParadoxicalRangeBlockCheck 47 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
