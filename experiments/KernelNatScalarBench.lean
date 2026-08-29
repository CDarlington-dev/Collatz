import Mathlib

namespace KernelNatScalarBench

def step (n : Nat) : Nat :=
  if n % 2 = 0 then n / 2 else (3 * n + 1) / 2

def reachesOneAux : Nat → Nat → Bool
  | 0, n => n == 1
  | fuel + 1, n => if n == 1 then true else reachesOneAux fuel (step n)

def reachesOne (n : Nat) : Bool := reachesOneAux 700 n

def intervalAux : Nat → Nat → Bool
  | 0, _ => true
  | count + 1, n => reachesOne n && intervalAux count (n + 1)

def interval (lo count : Nat) : Bool := intervalAux count lo

theorem benchmark : interval 3 1 = true := by
  set_option maxRecDepth 1000000 in
    decide

#print axioms benchmark

end KernelNatScalarBench
