import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem safe_at_027 (input : Input) :
    noParadoxAtExactOdds 27 17 4615 1000000000 input = true := by
  simp only [noParadoxAtExactOdds, inClosedInterval, runRaw, scanRaw, maxSafeOddInput]
  bv_bench "experiments/bv-collatz-at027.cnf"

#print axioms safe_at_027
