import Collatz.Certified.Finite.NoParadoxicalRange

namespace Collatz.Certified.Finite

theorem range26017Bench400_true :
    noParadoxicalIntervalCheck 178 10015 400 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
