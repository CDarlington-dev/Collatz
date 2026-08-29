import Collatz.Farey

/-!
# A sharper first-feedback Farey seed

The same neighbouring fractions used by Rozier--Terracol already bracket the
necessary interval at `m = 99781`.  This is the smallest positive integer at
which their mediant lower bound has ordinary length `2510`; the minimality
claim is useful provenance but is not needed by the theorem below.
-/

namespace Collatz.Certified

open Farey

def optimizedFirstFarey : Farey.Certificate where
  m := 99781
  a := 1054
  b := 665
  c := 485
  d := 306

theorem optimizedFirstFarey_valid : optimizedFirstFarey.Valid := by
  set_option exponentiation.threshold 2000 in
    norm_num [Farey.Certificate.Valid, optimizedFirstFarey]

theorem optimizedFirstFarey_sums :
    optimizedFirstFarey.a + optimizedFirstFarey.c = 1539 ∧
      optimizedFirstFarey.b + optimizedFirstFarey.d = 971 ∧
      (optimizedFirstFarey.a + optimizedFirstFarey.c) +
        (optimizedFirstFarey.b + optimizedFirstFarey.d) = 2510 := by
  norm_num [optimizedFirstFarey]

end Collatz.Certified
