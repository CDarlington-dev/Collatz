import Collatz.Certified.Finite.NoParadoxicalRange26017

namespace Collatz.Certified.Finite

theorem noParadoxicalRange26017Tail_true :
    noParadoxicalRange26017TailCheck = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
