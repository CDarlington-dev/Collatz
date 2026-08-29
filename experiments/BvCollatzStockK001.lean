import BvCollatzBenchCore

open BvCollatzBench

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem prefix_safe_stock_k001 (input : Input) :
    prefixSafe 1 4615 1000000000 input = true := by
  simp only [prefixSafe, inClosedInterval, run, scan, qBound, qBoundNat, maxSafeOddInput]
  bv_decide (timeout := 120)
