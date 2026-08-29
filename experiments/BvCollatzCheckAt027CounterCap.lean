import BvCollatzBenchCore

open BvCollatzBench

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem safe_at_027_q17_capped_check (input : Input) :
    noParadoxAtCounter 27 { b0 := true, b4 := true }
      4615 26017 input = true := by
  simp only [noParadoxAtCounter, inClosedInterval, runRawCounter, scanRawCounter,
    incrementCounter, counterEq, maxSafeOddInput]
  bv_check "bv-collatz-at027-q17-capped-external.lrat"

#print axioms safe_at_027_q17_capped_check
