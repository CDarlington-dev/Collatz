import BvCollatzBenchCore

open BvCollatzBench
open BvCollatzBench.Tactic

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem chain_at_032_q20_capped (input : Input) (x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 x21 x22 x23 x24 x25 x26 x27 x28 x29 x30 x31 x32 : Value) :
    noParadoxChain { b2 := true, b4 := true } 4615 17666
      input [x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32] = true := by
  simp only [noParadoxChain, inClosedInterval, chain, transition, countChainInputs,
    incrementCounter, counterEq, chainEndpoint, maxSafeOddInput]
  bv_dump "experiments/bv-collatz-chain-at032-q20-capped.cnf"
  sorry

