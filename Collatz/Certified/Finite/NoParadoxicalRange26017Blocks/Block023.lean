import Collatz.Certified.Finite.NoParadoxicalRange26017

namespace Collatz.Certified.Finite

theorem noParadoxicalRange26017Block023_true :
    noParadoxicalRange26017BlockCheck 23 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
