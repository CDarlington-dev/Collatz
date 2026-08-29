import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem prefix_safe_k008_hi (input : Input) :
    prefixSafeBounds [0, 1, 1, 2, 3, 3, 4, 5] 536870912 1000000000 input = true := by
  simp only [prefixSafeBounds, inClosedInterval, runBounds, scanBounds, maxSafeOddInput]
  bv_bench "experiments/bv-collatz-k008-hi.cnf"

#print axioms prefix_safe_k008_hi

