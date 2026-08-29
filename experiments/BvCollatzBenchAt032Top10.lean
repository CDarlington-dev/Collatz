import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem safe_at_032_top10 (input : Input) :
    noParadoxAtExactOdds 32 20 998244352 999292927 input = true := by
  simp only [noParadoxAtExactOdds, inClosedInterval, runRaw, scanRaw, maxSafeOddInput]
  bv_bench "experiments/bv-collatz-at032-top10.cnf"

#print axioms safe_at_032_top10
