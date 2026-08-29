import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem safe_at_027_q17_capped (input : Input) :
    noParadoxAtCounter 27 { b0 := true, b4 := true }
      4615 26017 input = true := by
  simp only [noParadoxAtCounter, inClosedInterval, runRawCounter, scanRawCounter,
    incrementCounter, counterEq, maxSafeOddInput]
  bv_bench "experiments/bv-collatz-at027-q17-capped.cnf"

#print axioms safe_at_027_q17_capped

