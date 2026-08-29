import Collatz.Certified.Finite.NoParadoxicalRange

namespace Collatz.Certified.Finite

theorem noParadoxicalRangeBlock021_true :
    noParadoxicalRangeBlockCheck 21 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
