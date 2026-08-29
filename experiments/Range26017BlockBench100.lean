import Collatz.Certified.Finite.NoParadoxicalRange

namespace Collatz.Certified.Finite

theorem range26017Bench100_true :
    noParadoxicalIntervalCheck 178 10015 100 = true := by
  set_option maxRecDepth 1000000 in
    decide

theorem range26017Fuel177_fails_closed :
    noParadoxicalStartCheck 177 23529 = false := by
  set_option maxRecDepth 1000000 in
    decide

theorem range26017Fuel178_accepts_extremal :
    noParadoxicalStartCheck 178 23529 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
