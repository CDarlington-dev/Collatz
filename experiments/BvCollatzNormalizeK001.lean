import BvCollatzBenchCore

open BvCollatzBench

set_option pp.all false
set_option maxRecDepth 100000

theorem prefix_safe_normalize_k001 (input : Input) :
    prefixSafe 1 4615 1000000000 input = true := by
  simp only [prefixSafe, inClosedInterval, run, scan, qBound, qBoundNat, maxSafeOddInput]
  bv_normalize
  trace_state
  sorry
