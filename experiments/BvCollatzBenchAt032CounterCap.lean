import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem safe_at_032_q20_capped (input : Input) :
    noParadoxAtCounter 32 { b2 := true, b4 := true }
      4615 17666 input = true := by
  simp (config := { zeta := false }) only [noParadoxAtCounter, inClosedInterval, runRawCounter, scanRawCounter,
    incrementCounter, counterEq, maxSafeOddInput]
  bv_dump "experiments/bv-collatz-at032-q20-capped.cnf"
  sorry
