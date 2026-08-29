import Mathlib

namespace KernelBitVecScalarBench

abbrev Value := BitVec 64

def half (x : Value) : Value := 0#1 ++ BitVec.extractLsb' 1 63 x

def step (n : Value) : Value :=
  if n.getLsbD 0 then half (3 * n + 1) else half n

def reachesOneAux : Nat → Value → Bool
  | 0, n => n == 1
  | fuel + 1, n => if n == 1 then true else reachesOneAux fuel (step n)

def reachesOne (n : Value) : Bool := reachesOneAux 700 n

def intervalAux : Nat → Value → Bool
  | 0, _ => true
  | count + 1, n => reachesOne n && intervalAux count (n + 1)

def interval (lo count : Nat) : Bool := intervalAux count (BitVec.ofNat 64 lo)

theorem benchmark : interval 3 1 = true := by
  set_option maxRecDepth 1000000 in
    decide

#print axioms benchmark

end KernelBitVecScalarBench

