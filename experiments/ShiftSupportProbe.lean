import Std.Tactic.BVDecide

set_option maxHeartbeats 0

theorem shift32_le (x : BitVec 32) : (x >>> 1) ≤ x := by
  bv_decide

theorem shift64_le (x : BitVec 64) : (x >>> 1) ≤ x := by
  bv_decide

theorem shift_zeroExtend_le (x : BitVec 30) :
    (x.zeroExtend 64 >>> 1) ≤ x.zeroExtend 64 := by
  bv_decide

theorem shift_concat_le (x : BitVec 30) :
    ((0#34 ++ x) >>> 1) ≤ (0#34 ++ x) := by
  bv_decide
