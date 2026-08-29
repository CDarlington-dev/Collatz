import Collatz.Certified.Finite.NoParadoxicalRange

namespace Collatz.Certified.Finite

theorem noParadoxicalRangeBlock016_true :
    noParadoxicalRangeBlockCheck 16 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
