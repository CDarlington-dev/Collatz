import Collatz.Certified.Finite.NoParadoxicalRange26017

namespace Collatz.Certified.Finite

theorem noParadoxicalRange26017Block032_true :
    noParadoxicalRange26017BlockCheck 32 = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
