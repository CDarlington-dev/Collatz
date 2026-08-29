import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem prefix_safe_k032 (input : Input) :
    prefixSafeBounds [0, 1, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 8, 8, 9, 10, 10, 11, 11, 12, 13, 13, 14, 15, 15, 16, 17, 17, 18, 18, 19, 20] 4615 1000000000 input = true := by
  simp only [prefixSafeBounds, inClosedInterval, runBounds, scanBounds, maxSafeOddInput]
  bv_bench "experiments/bv-collatz-k032.cnf"

#print axioms prefix_safe_k032

