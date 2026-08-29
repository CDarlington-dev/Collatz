import Collatz.Certified.Circuit.Arithmetic
import Collatz.Certified.Circuit.Checker

/-!
# Small end-to-end LRAT certificate demonstration

This module checks one real accelerated-Collatz step on the two inputs `26` and `27`.  It is a
technology demonstration for the reducible circuit/CNF/LRAT path.  In particular, it does **not**
discharge `FiniteBaseClassification 1000000000 PublishedClassification` (trust-ledger item FB-1).

Input wires `0..7` and output wires `40..47` are little-endian bytes.  The circuit computes the
accelerated map; the units restrict the input to `26` or `27` and assert falsely that output bit
zero is clear.  The checked LRAT certificate refutes that assertion in one shard.
-/

set_option maxRecDepth 100000
set_option maxHeartbeats 2000000

namespace Collatz.Certified.Circuit.Demo

open Collatz.Certified.Circuit

/-- An eight-bit ripple circuit for one accelerated Collatz step. -/
def acceleratedStep8 : Circuit where
  firstGate := 8
  gates := [
    { op := .xor, x := 0, y := 0 },
    { op := .not, x := 8 },
    { op := .xor, x := 0, y := 8 },
    { op := .xor, x := 10, y := 9 },
    { op := .maj, x := 0, y := 8, z := 9 },
    { op := .xor, x := 1, y := 0 },
    { op := .xor, x := 13, y := 12 },
    { op := .maj, x := 1, y := 0, z := 12 },
    { op := .xor, x := 2, y := 1 },
    { op := .xor, x := 16, y := 15 },
    { op := .maj, x := 2, y := 1, z := 15 },
    { op := .xor, x := 3, y := 2 },
    { op := .xor, x := 19, y := 18 },
    { op := .maj, x := 3, y := 2, z := 18 },
    { op := .xor, x := 4, y := 3 },
    { op := .xor, x := 22, y := 21 },
    { op := .maj, x := 4, y := 3, z := 21 },
    { op := .xor, x := 5, y := 4 },
    { op := .xor, x := 25, y := 24 },
    { op := .maj, x := 5, y := 4, z := 24 },
    { op := .xor, x := 6, y := 5 },
    { op := .xor, x := 28, y := 27 },
    { op := .maj, x := 6, y := 5, z := 27 },
    { op := .xor, x := 7, y := 6 },
    { op := .xor, x := 31, y := 30 },
    { op := .maj, x := 7, y := 6, z := 30 },
    { op := .xor, x := 8, y := 7 },
    { op := .xor, x := 34, y := 33 },
    { op := .maj, x := 8, y := 7, z := 33 },
    { op := .xor, x := 8, y := 8 },
    { op := .xor, x := 37, y := 36 },
    { op := .maj, x := 8, y := 8, z := 36 },
    { op := .mux, x := 0, y := 14, z := 1 },
    { op := .mux, x := 0, y := 17, z := 2 },
    { op := .mux, x := 0, y := 20, z := 3 },
    { op := .mux, x := 0, y := 23, z := 4 },
    { op := .mux, x := 0, y := 26, z := 5 },
    { op := .mux, x := 0, y := 29, z := 6 },
    { op := .mux, x := 0, y := 32, z := 7 },
    { op := .mux, x := 0, y := 35, z := 8 }
  ]
  units := []

def input8 (a : Nat → Bool) : Nat :=
  (if a 0 then 1 else 0) + (if a 1 then 2 else 0) +
  (if a 2 then 4 else 0) + (if a 3 then 8 else 0) +
  (if a 4 then 16 else 0) + (if a 5 then 32 else 0) +
  (if a 6 then 64 else 0) + (if a 7 then 128 else 0)

def output8 (a : Nat → Bool) : Nat :=
  (if a 40 then 1 else 0) + (if a 41 then 2 else 0) +
  (if a 42 then 4 else 0) + (if a 43 then 8 else 0) +
  (if a 44 then 16 else 0) + (if a 45 then 32 else 0) +
  (if a 46 then 64 else 0) + (if a 47 then 128 else 0)

/-!
This 8-bit demo lemma enumerates only its 256 inputs.  Production-width semantics do not use
this argument: `Bits.fixedWidthAcceleratedBits_value_of_no_overflow` is width-generic and proved
structurally in `Arithmetic.lean`.
-/
theorem acceleratedStep8_semantic (a : Nat → Bool) (h : acceleratedStep8.Holds a)
    (hfit : Collatz.T (input8 a) < 256) : output8 a = Collatz.T (input8 a) := by
  rcases h with ⟨hg, _⟩
  simp only [acceleratedStep8, Gates.HoldsFrom, Gate.Holds, Op.eval] at hg
  cases h0 : a 0 <;> cases h1 : a 1 <;> cases h2 : a 2 <;> cases h3 : a 3 <;>
    cases h4 : a 4 <;> cases h5 : a 5 <;> cases h6 : a 6 <;> cases h7 : a 7 <;>
    simp_all [input8, output8, Collatz.T]

/-- Inputs are exactly 26 or 27; both successors, 13 and 41, have low bit one. -/
def interval26to27OneStepBad : Circuit where
  firstGate := 8
  gates := acceleratedStep8.gates
  units := [
    (true, 1), (false, 2), (true, 3), (true, 4),
    (false, 5), (false, 6), (false, 7),
    (false, 40)
  ]

/-- Static LRAT reconstruction; no solver runs while this theorem is checked. -/
theorem interval26to27OneStep_lrat :
    Sat.Fmla.proof interval26to27OneStepBad.toFmla [] := by
  checked_lrat
    (include_str "../../../certificates/circuit-demo/interval26to27-one-step.cnf")
    (include_str "../../../certificates/circuit-demo/interval26to27-one-step.lrat")

theorem interval26to27OneStep_no_model :
    ¬ ∃ a, interval26to27OneStepBad.Holds a :=
  no_model_of_lrat interval26to27OneStepBad interval26to27OneStep_lrat

end Collatz.Certified.Circuit.Demo
