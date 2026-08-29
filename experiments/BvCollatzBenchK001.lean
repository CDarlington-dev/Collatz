import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem prefix_safe_k001 (input : Input) :
    prefixSafeBounds [0] 4615 1000000000 input = true := by
  simp only [prefixSafeBounds, inClosedInterval, runBounds, scanBounds, maxSafeOddInput]
  bv_bench "experiments/bv-collatz-k001.cnf"

#print axioms prefix_safe_k001
