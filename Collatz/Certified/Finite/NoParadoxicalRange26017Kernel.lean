import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block000
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block001
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block002
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block003
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block004
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block005
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block006
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block007
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block008
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block009
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block010
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block011
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block012
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block013
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block014
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block015
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block016
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block017
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block018
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block019
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block020
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block021
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block022
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block023
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block024
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block025
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block026
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block027
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block028
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block029
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block030
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block031
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block032
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block033
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block034
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block035
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block036
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block037
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block038
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block039
import Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Tail
import Collatz.Certified.Finite.NoParadoxicalRangeKernel
import Collatz.Certified.Finite.BaseClassificationKernel
import Mathlib.Tactic

/-!
# Kernel aggregate for the finite exclusion through 26017

Every concrete trajectory proposition in this module's dependency graph is
proved by ordinary kernel reduction.  The aggregate combines the published
classification through 4614, the prior exclusion through 10014, and the new
exact interval 10015 through 26017.
-/

namespace Collatz.Certified.Finite

/-- Every one of the forty full ordinary-kernel blocks was accepted. -/
theorem noParadoxicalRange26017EveryBlock_true (b : ℕ) (hb : b ≤ 39) :
    noParadoxicalRange26017BlockCheck b = true := by
  interval_cases b <;>
    simp only [
      noParadoxicalRange26017Block000_true,
      noParadoxicalRange26017Block001_true,
      noParadoxicalRange26017Block002_true,
      noParadoxicalRange26017Block003_true,
      noParadoxicalRange26017Block004_true,
      noParadoxicalRange26017Block005_true,
      noParadoxicalRange26017Block006_true,
      noParadoxicalRange26017Block007_true,
      noParadoxicalRange26017Block008_true,
      noParadoxicalRange26017Block009_true,
      noParadoxicalRange26017Block010_true,
      noParadoxicalRange26017Block011_true,
      noParadoxicalRange26017Block012_true,
      noParadoxicalRange26017Block013_true,
      noParadoxicalRange26017Block014_true,
      noParadoxicalRange26017Block015_true,
      noParadoxicalRange26017Block016_true,
      noParadoxicalRange26017Block017_true,
      noParadoxicalRange26017Block018_true,
      noParadoxicalRange26017Block019_true,
      noParadoxicalRange26017Block020_true,
      noParadoxicalRange26017Block021_true,
      noParadoxicalRange26017Block022_true,
      noParadoxicalRange26017Block023_true,
      noParadoxicalRange26017Block024_true,
      noParadoxicalRange26017Block025_true,
      noParadoxicalRange26017Block026_true,
      noParadoxicalRange26017Block027_true,
      noParadoxicalRange26017Block028_true,
      noParadoxicalRange26017Block029_true,
      noParadoxicalRange26017Block030_true,
      noParadoxicalRange26017Block031_true,
      noParadoxicalRange26017Block032_true,
      noParadoxicalRange26017Block033_true,
      noParadoxicalRange26017Block034_true,
      noParadoxicalRange26017Block035_true,
      noParadoxicalRange26017Block036_true,
      noParadoxicalRange26017Block037_true,
      noParadoxicalRange26017Block038_true,
      noParadoxicalRange26017Block039_true
    ]

/-- The complete forty-block Boolean is accepted without recomputation. -/
theorem noParadoxicalRange26017AllBlocksCheck_true :
    noParadoxicalRange26017AllBlocksCheck = true := by
  simp only [noParadoxicalRange26017AllBlocksCheck, List.all_eq_true]
  intro b hb
  have hblt : b < 40 := by simpa using hb
  exact noParadoxicalRange26017EveryBlock_true b (by omega)

/--
Unconditional exclusion for every start from 10015 through 26017, inclusive,
and every segment length.
-/
theorem no_paradoxical_start_10015_through_26017
    {n j : ℕ} (hlower : 10014 < n) (hupper : n ≤ 26017) :
    ¬ Paradoxical n j :=
  noParadoxicalRange26017Checks_sound
    noParadoxicalRange26017AllBlocksCheck_true
    noParadoxicalRange26017Tail_true
    (by omega) (by omega)

/--
The old and new ordinary-kernel blocks combine to exclude every start above
the published maximum and through 26017.
-/
theorem no_paradoxical_start_4615_through_26017
    {n j : ℕ} (hlower : 4614 < n) (hupper : n ≤ 26017) :
    ¬ Paradoxical n j := by
  by_cases hmid : n ≤ 10014
  · exact no_paradoxical_start_4615_through_10014 hlower hmid
  · exact no_paradoxical_start_10015_through_26017 (by omega) hupper

/--
Unconditional finite classification through 26017 against the exact
593-pair published predicate.
-/
theorem finiteBaseClassification_26017 :
    RecordBounds.FiniteBaseClassification 26017
      PublishedClassificationUpTo4614 := by
  intro n j hn
  by_cases hsmall : n ≤ 4614
  · exact finiteBaseClassification_4614 hsmall
  · have hnot : ¬ Paradoxical n j :=
      no_paradoxical_start_4615_through_26017 (by omega) hn
    constructor
    · exact fun hp => (hnot hp).elim
    · rintro ⟨hn4614, _hj, _hw⟩
      omega

end Collatz.Certified.Finite
