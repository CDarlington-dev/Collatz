import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem prefix_safe_k064_hi (input : Input) :
    prefixSafeBounds [0, 1, 1, 2, 3, 3, 4, 5, 5, 6, 6, 7, 8, 8, 9, 10, 10, 11, 11, 12, 13, 13, 14, 15, 15, 16, 17, 17, 18, 18, 19, 20, 20, 21, 22, 22, 23, 23, 24, 25, 25, 26, 27, 27, 28, 29, 29, 30, 30, 31, 32, 32, 33, 34, 34, 35, 35, 36, 37, 37, 38, 39, 39, 40] 536870912 1000000000 input = true := by
  simp only [prefixSafeBounds, inClosedInterval, runBounds, scanBounds, maxSafeOddInput]
  bv_bench "experiments/bv-collatz-k064-hi.cnf"

#print axioms prefix_safe_k064_hi

