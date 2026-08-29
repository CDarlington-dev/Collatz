import BvCollatzBenchCore

open BvCollatzBench

set_option maxHeartbeats 0
set_option maxRecDepth 100000

theorem chain_at_027_probe (input : Input) (x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 x21 x22 x23 x24 x25 x26 x27 : Value) :
    noParadoxChain { b0 := true, b4 := true } 4615 26017
      input [x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27] = true := by
  simp only [noParadoxChain, inClosedInterval, chain, transition, countChainInputs,
    incrementCounter, counterEq, chainEndpoint, maxSafeOddInput]
  bv_decide (timeout := 120)

