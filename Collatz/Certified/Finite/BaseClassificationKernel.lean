import Collatz.Certified.Finite.BaseClassificationBlocks.Block000
import Collatz.Certified.Finite.BaseClassificationBlocks.Block001
import Collatz.Certified.Finite.BaseClassificationBlocks.Block002
import Collatz.Certified.Finite.BaseClassificationBlocks.Block003
import Collatz.Certified.Finite.BaseClassificationBlocks.Block004
import Collatz.Certified.Finite.BaseClassificationBlocks.Block005
import Collatz.Certified.Finite.BaseClassificationBlocks.Block006
import Collatz.Certified.Finite.BaseClassificationBlocks.Block007
import Collatz.Certified.Finite.BaseClassificationBlocks.Block008
import Collatz.Certified.Finite.BaseClassificationBlocks.Block009
import Collatz.Certified.Finite.BaseClassificationBlocks.Block010
import Collatz.Certified.Finite.BaseClassificationBlocks.Block011
import Collatz.Certified.Finite.BaseClassificationBlocks.Block012
import Collatz.Certified.Finite.BaseClassificationBlocks.Block013
import Collatz.Certified.Finite.BaseClassificationBlocks.Block014
import Collatz.Certified.Finite.BaseClassificationBlocks.Block015
import Collatz.Certified.Finite.BaseClassificationBlocks.Block016
import Collatz.Certified.Finite.BaseClassificationBlocks.Block017
import Collatz.Certified.Finite.BaseClassificationBlocks.Block018
import Collatz.Certified.Finite.BaseClassificationBlocks.Block019
import Collatz.Certified.Finite.BaseClassificationBlocks.Block020
import Collatz.Certified.Finite.BaseClassificationBlocks.Block021
import Collatz.Certified.Finite.BaseClassificationBlocks.Block022
import Collatz.Certified.Finite.BaseClassificationBlocks.Block023
import Collatz.Certified.Finite.BaseClassificationBlocks.Block024
import Collatz.Certified.Finite.BaseClassificationBlocks.Block025
import Collatz.Certified.Finite.BaseClassificationBlocks.Block026
import Collatz.Certified.Finite.BaseClassificationBlocks.Block027
import Collatz.Certified.Finite.BaseClassificationBlocks.Block028
import Collatz.Certified.Finite.BaseClassificationBlocks.Block029
import Collatz.Certified.Finite.BaseClassificationBlocks.Block030
import Collatz.Certified.Finite.BaseClassificationBlocks.Block031
import Collatz.Certified.Finite.BaseClassificationBlocks.Block032
import Collatz.Certified.Finite.BaseClassificationBlocks.Block033
import Collatz.Certified.Finite.BaseClassificationBlocks.Block034
import Collatz.Certified.Finite.BaseClassificationBlocks.Block035
import Collatz.Certified.Finite.BaseClassificationBlocks.Block036
import Collatz.Certified.Finite.BaseClassificationBlocks.Block037
import Collatz.Certified.Finite.BaseClassificationBlocks.Block038
import Collatz.Certified.Finite.BaseClassificationBlocks.Block039
import Collatz.Certified.Finite.BaseClassificationBlocks.Block040
import Collatz.Certified.Finite.BaseClassificationBlocks.Block041
import Collatz.Certified.Finite.BaseClassificationBlocks.Block042
import Collatz.Certified.Finite.BaseClassificationBlocks.Block043
import Collatz.Certified.Finite.BaseClassificationBlocks.Block044
import Collatz.Certified.Finite.BaseClassificationBlocks.Block045
import Collatz.Certified.Finite.BaseClassificationBlocks.Block046

/-!
# Kernel-checked finite classification through start 4614

The 4,700 starts are partitioned into 47 independent blocks of 100.  Every
block is reduced by ordinary `decide`; no `native_decide`, external table
claim, or unchecked executable result occurs in the theorem below.
-/

namespace Collatz.Certified.Finite

/-- Every one of the 47 ordinary-kernel blocks was accepted. -/
theorem baseClassificationEveryBlock_true (b : ℕ) (hb : b ≤ 46) :
    baseClassificationBlockCheck b = true := by
  interval_cases b <;>
    simp only [
      baseClassificationBlock000_true,
      baseClassificationBlock001_true,
      baseClassificationBlock002_true,
      baseClassificationBlock003_true,
      baseClassificationBlock004_true,
      baseClassificationBlock005_true,
      baseClassificationBlock006_true,
      baseClassificationBlock007_true,
      baseClassificationBlock008_true,
      baseClassificationBlock009_true,
      baseClassificationBlock010_true,
      baseClassificationBlock011_true,
      baseClassificationBlock012_true,
      baseClassificationBlock013_true,
      baseClassificationBlock014_true,
      baseClassificationBlock015_true,
      baseClassificationBlock016_true,
      baseClassificationBlock017_true,
      baseClassificationBlock018_true,
      baseClassificationBlock019_true,
      baseClassificationBlock020_true,
      baseClassificationBlock021_true,
      baseClassificationBlock022_true,
      baseClassificationBlock023_true,
      baseClassificationBlock024_true,
      baseClassificationBlock025_true,
      baseClassificationBlock026_true,
      baseClassificationBlock027_true,
      baseClassificationBlock028_true,
      baseClassificationBlock029_true,
      baseClassificationBlock030_true,
      baseClassificationBlock031_true,
      baseClassificationBlock032_true,
      baseClassificationBlock033_true,
      baseClassificationBlock034_true,
      baseClassificationBlock035_true,
      baseClassificationBlock036_true,
      baseClassificationBlock037_true,
      baseClassificationBlock038_true,
      baseClassificationBlock039_true,
      baseClassificationBlock040_true,
      baseClassificationBlock041_true,
      baseClassificationBlock042_true,
      baseClassificationBlock043_true,
      baseClassificationBlock044_true,
      baseClassificationBlock045_true,
      baseClassificationBlock046_true
    ]

/-- The complete block-list Boolean is accepted without recomputation. -/
theorem baseClassificationAllBlocksCheck_true :
    baseClassificationAllBlocksCheck = true := by
  simp only [baseClassificationAllBlocksCheck, List.all_eq_true]
  intro b hb
  have hblt : b < 47 := by simpa using hb
  exact baseClassificationEveryBlock_true b (by omega)

/--
Unconditional finite classification through start `4614`, for all lengths,
against the exact 593-row published predicate.
-/
theorem finiteBaseClassification_4614 :
    RecordBounds.FiniteBaseClassification 4614 PublishedClassificationUpTo4614 :=
  finiteBaseClassification_4614_of_check baseClassificationAllBlocksCheck_true

end Collatz.Certified.Finite

