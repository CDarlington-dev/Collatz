import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem safe_at_029 (input : Input) :
    noParadoxAtExactOdds 29 18 4615 1000000000 input = true := by
  simp only [noParadoxAtExactOdds, inClosedInterval, runRaw, scanRaw, maxSafeOddInput]
  bv_bench "experiments/bv-collatz-at029.cnf"

#print axioms safe_at_029
