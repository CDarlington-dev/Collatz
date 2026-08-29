import Mathlib

/-!
Pure-kernel throughput microbenchmark for a prospective binary finite-base
checker.  This file is intentionally outside the `Collatz` library and proves
no project theorem.  It tests whether `UInt64` primitives materially change
the cost of replaying scalar trajectories with ordinary `decide`.
-/

namespace KernelUInt64Bench

def step (n : UInt64) : UInt64 :=
  if n % 2 = 0 then n / 2 else (3 * n + 1) / 2

def reachesOneAux : Nat -> UInt64 -> Bool
  | 0, n => n == 1
  | fuel + 1, n => if n == 1 then true else reachesOneAux fuel (step n)

def reachesOne (n : UInt64) : Bool := reachesOneAux 700 n

def intervalAux : Nat -> UInt64 -> Bool
  | 0, _ => true
  | count + 1, n => reachesOne n && intervalAux count (n + 1)

def interval (lo count : Nat) : Bool := intervalAux count lo.toUInt64

-- Change only this numeral when collecting a benchmark point.
theorem benchmark : interval 3 1 = true := by
  set_option maxRecDepth 1000000 in
    decide

#print axioms benchmark

end KernelUInt64Bench
