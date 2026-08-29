import Std.Tactic.BVDecide

theorem square_roots_probe (x : BitVec 4) :
    x * x = 0 -> x = 0 ∨ x = 4 ∨ x = 8 ∨ x = 12 := by
  bv_normalize
  trace_state
  bv_decide
