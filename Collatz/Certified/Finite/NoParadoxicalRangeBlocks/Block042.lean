import Collatz.Certified.Finite.NoParadoxicalRange

namespace Collatz.Certified.Finite

theorem noParadoxicalRangeBlock042_true :
    noParadoxicalRangeBlockCheck 42 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
