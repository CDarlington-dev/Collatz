import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem safe_at_029_q18_capped (input : Input) :
    noParadoxAtCounter 29 { b1 := true, b4 := true }
      4615 5305 input = true := by
  simp (config := { zeta := false }) only [noParadoxAtCounter, inClosedInterval, runRawCounter, scanRawCounter,
    incrementCounter, counterEq, maxSafeOddInput]
  bv_dump "experiments/bv-collatz-at029-q18-capped.cnf"
  sorry
