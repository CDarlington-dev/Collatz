import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block000
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block001
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block002
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block003
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block004
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block005
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block006
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block007
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block008
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block009
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block010
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block011
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block012
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block013
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block014
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block015
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block016
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block017
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block018
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block019
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block020
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block021
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block022
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block023
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block024
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block025
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block026
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block027
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block028
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block029
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block030
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block031
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block032
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block033
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block034
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block035
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block036
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block037
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block038
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block039
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block040
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block041
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block042
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block043
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block044
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block045
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block046
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block047
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block048
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block049
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block050
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block051
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block052
import Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block053
import Mathlib.Tactic

/-!
# Pure-kernel exclusion of starts 4615 through 10014

The 5,400 starts are partitioned into 54 independent blocks of 100.  Each
block is reduced by ordinary `decide`; this aggregate contains no
`native_decide` step.
-/

namespace Collatz

namespace Certified

namespace Finite

/-- Every one of the 54 ordinary-kernel blocks was accepted. -/
theorem noParadoxicalRangeAllBlocks_true (b : ℕ) (hb : b ≤ 53) :
    noParadoxicalRangeBlockCheck b = true := by
  interval_cases b <;>
    simp only [
      noParadoxicalRangeBlock000_true,
      noParadoxicalRangeBlock001_true,
      noParadoxicalRangeBlock002_true,
      noParadoxicalRangeBlock003_true,
      noParadoxicalRangeBlock004_true,
      noParadoxicalRangeBlock005_true,
      noParadoxicalRangeBlock006_true,
      noParadoxicalRangeBlock007_true,
      noParadoxicalRangeBlock008_true,
      noParadoxicalRangeBlock009_true,
      noParadoxicalRangeBlock010_true,
      noParadoxicalRangeBlock011_true,
      noParadoxicalRangeBlock012_true,
      noParadoxicalRangeBlock013_true,
      noParadoxicalRangeBlock014_true,
      noParadoxicalRangeBlock015_true,
      noParadoxicalRangeBlock016_true,
      noParadoxicalRangeBlock017_true,
      noParadoxicalRangeBlock018_true,
      noParadoxicalRangeBlock019_true,
      noParadoxicalRangeBlock020_true,
      noParadoxicalRangeBlock021_true,
      noParadoxicalRangeBlock022_true,
      noParadoxicalRangeBlock023_true,
      noParadoxicalRangeBlock024_true,
      noParadoxicalRangeBlock025_true,
      noParadoxicalRangeBlock026_true,
      noParadoxicalRangeBlock027_true,
      noParadoxicalRangeBlock028_true,
      noParadoxicalRangeBlock029_true,
      noParadoxicalRangeBlock030_true,
      noParadoxicalRangeBlock031_true,
      noParadoxicalRangeBlock032_true,
      noParadoxicalRangeBlock033_true,
      noParadoxicalRangeBlock034_true,
      noParadoxicalRangeBlock035_true,
      noParadoxicalRangeBlock036_true,
      noParadoxicalRangeBlock037_true,
      noParadoxicalRangeBlock038_true,
      noParadoxicalRangeBlock039_true,
      noParadoxicalRangeBlock040_true,
      noParadoxicalRangeBlock041_true,
      noParadoxicalRangeBlock042_true,
      noParadoxicalRangeBlock043_true,
      noParadoxicalRangeBlock044_true,
      noParadoxicalRangeBlock045_true,
      noParadoxicalRangeBlock046_true,
      noParadoxicalRangeBlock047_true,
      noParadoxicalRangeBlock048_true,
      noParadoxicalRangeBlock049_true,
      noParadoxicalRangeBlock050_true,
      noParadoxicalRangeBlock051_true,
      noParadoxicalRangeBlock052_true,
      noParadoxicalRangeBlock053_true]

/-- The complete block-list Boolean is accepted without recomputation. -/
theorem noParadoxicalAllBlocksCheck_true :
    noParadoxicalAllBlocksCheck = true := by
  simp only [noParadoxicalAllBlocksCheck, List.all_eq_true]
  intro b hb
  have hblt : b < 54 := by simpa using hb
  exact noParadoxicalRangeAllBlocks_true b (by omega)

/--
Unconditional finite exclusion for every start from 4615 through 10014,
inclusive, and every segment length.
-/
theorem no_paradoxical_start_4615_through_10014
    {n j : ℕ} (hlower : 4614 < n) (hupper : n ≤ 10014) :
    ¬ Paradoxical n j :=
  noParadoxicalAllBlocksCheck_sound noParadoxicalAllBlocksCheck_true
    (by omega) (by omega)

/-- The requested conservative endpoint at 10000. -/
theorem no_paradoxical_start_4615_through_10000
    {n j : ℕ} (hlower : 4614 < n) (hupper : n ≤ 10000) :
    ¬ Paradoxical n j :=
  no_paradoxical_start_4615_through_10014 hlower (by omega)

end Finite

end Certified

end Collatz
