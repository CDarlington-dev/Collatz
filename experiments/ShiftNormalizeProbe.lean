import Std.Tactic.BVDecide

theorem shift64_le_state (x : BitVec 64) : (x >>> 1) ≤ x := by
  bv_normalize
  trace_state
  sorry

