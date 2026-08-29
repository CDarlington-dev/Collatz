import Mathlib.Tactic.Sat.FromLRAT

/-!
# A reducible Boolean-circuit to CNF layer

This file deliberately avoids `Std.Sat.AIG` and its irreducible caches.  The CNF for a
`Circuit` is an ordinary recursive Lean value over lists, so the formula reconstructed from a
DIMACS/LRAT certificate can be compared directly with `Circuit.toFmla` by the elaborator and
the resulting proof is checked by Lean's kernel.

Wire identifiers are natural numbers.  A circuit's gates receive consecutive output wires,
starting at `firstGate`; inputs and constants are expressed by unit clauses.
-/

set_option maxRecDepth 100000

namespace Collatz.Certified.Circuit

/-- Boolean operations supported by the certificate circuit language. -/
inductive Op where
  | not
  | and
  | xor
  | maj
  | mux
deriving DecidableEq, Repr

def Op.eval : Op → Bool → Bool → Bool → Bool
  | .not, x, _, _ => !x
  | .and, x, y, _ => x && y
  | .xor, x, y, _ => x ^^ y
  | .maj, x, y, z => (x && y) || (x && z) || (y && z)
  | .mux, x, y, z => if x then y else z

/-- A gate refers to existing input wires; its output wire is supplied by its list position. -/
structure Gate where
  op : Op
  x : Nat
  y : Nat := 0
  z : Nat := 0
deriving DecidableEq, Repr

def Gate.Holds (g : Gate) (out : Nat) (a : Nat → Bool) : Prop :=
  a out = g.op.eval (a g.x) (a g.y) (a g.z)

/-- Compact Tseitin clauses defining one gate output. -/
def Gate.toFmla (out : Nat) (g : Gate) : Sat.Fmla :=
  match g.op with
  | .not => [
      [.pos out, .pos g.x],
      [.neg out, .neg g.x]]
  | .and => [
      [.neg out, .pos g.x],
      [.neg out, .pos g.y],
      [.pos out, .neg g.x, .neg g.y]]
  | .xor => [
      [.pos out, .pos g.x, .neg g.y],
      [.pos out, .neg g.x, .pos g.y],
      [.neg out, .pos g.x, .pos g.y],
      [.neg out, .neg g.x, .neg g.y]]
  | .maj => [
      [.neg out, .pos g.x, .pos g.y, .pos g.z],
      [.neg out, .pos g.x, .pos g.y, .neg g.z],
      [.neg out, .pos g.x, .neg g.y, .pos g.z],
      [.neg out, .neg g.x, .pos g.y, .pos g.z],
      [.pos out, .pos g.x, .neg g.y, .neg g.z],
      [.pos out, .neg g.x, .pos g.y, .neg g.z],
      [.pos out, .neg g.x, .neg g.y, .pos g.z],
      [.pos out, .neg g.x, .neg g.y, .neg g.z]]
  | .mux => [
      [.pos g.x, .neg out, .pos g.z],
      [.pos g.x, .pos out, .neg g.z],
      [.neg g.x, .neg out, .pos g.y],
      [.neg g.x, .pos out, .neg g.y]]

def boolValuation (a : Nat → Bool) : Sat.Valuation := fun i => a i = true

@[simp] theorem satisfies_fmla_nil (v : Sat.Valuation) :
    Sat.Valuation.satisfies_fmla v [] := ⟨fun c hc => nomatch hc⟩

theorem satisfies_fmla_cons_iff (v : Sat.Valuation) (c : Sat.Clause) (f : Sat.Fmla) :
    Sat.Valuation.satisfies_fmla v (c :: f) ↔
      Sat.Valuation.satisfies v c ∧ Sat.Valuation.satisfies_fmla v f := by
  constructor
  · intro h
    constructor
    · exact h.prop c (by simp)
    · exact ⟨fun q hq => h.prop q (by simp [hq])⟩
  · rintro ⟨hc, hf⟩
    exact ⟨fun q hq => by
      simp only [List.mem_cons] at hq
      rcases hq with rfl | hq
      · exact hc
      · exact hf.prop q hq⟩

/-- The Tseitin clauses for one gate are equivalent to its Boolean semantics. -/
theorem satisfies_gate_toFmla_iff (a : Nat → Bool) (out : Nat) (g : Gate) :
    Sat.Valuation.satisfies_fmla (boolValuation a) (g.toFmla out) ↔ g.Holds out a := by
  rcases g with ⟨op, x, y, z⟩
  cases op <;> cases ho : a out <;> cases hx : a x <;> cases hy : a y <;> cases hz : a z <;>
    simp [Gate.toFmla, Gate.Holds, Op.eval, satisfies_fmla_cons_iff,
      boolValuation, Sat.Valuation.satisfies, Sat.Valuation.neg, ho, hx, hy, hz]

def Gates.HoldsFrom : Nat → List Gate → (Nat → Bool) → Prop
  | _, [], _ => True
  | out, g :: gs, a => g.Holds out a ∧ HoldsFrom (out + 1) gs a

def Gates.toFmlaFrom : Nat → List Gate → Sat.Fmla
  | _, [] => []
  | out, g :: gs => g.toFmla out ++ toFmlaFrom (out + 1) gs

theorem satisfies_gates_toFmlaFrom_iff (a : Nat → Bool) (out : Nat) (gs : List Gate) :
    Sat.Valuation.satisfies_fmla (boolValuation a) (Gates.toFmlaFrom out gs) ↔
      Gates.HoldsFrom out gs a := by
  induction gs generalizing out with
  | nil =>
      constructor
      · intro _; trivial
      · intro _; exact ⟨fun c hc => nomatch hc⟩
  | cons g gs ih =>
      rw [Gates.toFmlaFrom, Gates.HoldsFrom]
      constructor
      · intro h
        constructor
        · apply (satisfies_gate_toFmla_iff a out g).1
          exact ⟨fun c hc => h.prop c (List.mem_append_left _ hc)⟩
        · apply (ih (out + 1)).1
          exact ⟨fun c hc => h.prop c (List.mem_append_right _ hc)⟩
      · rintro ⟨hg, hgs⟩
        constructor
        intro c hc
        rw [List.mem_append] at hc
        rcases hc with hc | hc
        · exact ((satisfies_gate_toFmla_iff a out g).2 hg).prop c hc
        · exact ((ih (out + 1)).2 hgs).prop c hc

private def lit (positive : Bool) (i : Nat) : Sat.Literal :=
  if positive then .pos i else .neg i

private def unit (positive : Bool) (i : Nat) : Sat.Clause := [lit positive i]

def Units.Holds (us : List (Bool × Nat)) (a : Nat → Bool) : Prop :=
  ∀ u ∈ us, a u.2 = u.1

def Units.toFmla (us : List (Bool × Nat)) : Sat.Fmla :=
  us.map fun (b, i) => unit b i

theorem satisfies_unit_iff (a : Nat → Bool) (b : Bool) (i : Nat) :
    Sat.Valuation.satisfies (boolValuation a) (unit b i) ↔ a i = b := by
  cases b <;> cases h : a i <;>
    simp [unit, lit, boolValuation, Sat.Valuation.satisfies, Sat.Valuation.neg, h]

theorem satisfies_units_toFmla_iff (a : Nat → Bool) (us : List (Bool × Nat)) :
    Sat.Valuation.satisfies_fmla (boolValuation a) (Units.toFmla us) ↔ Units.Holds us a := by
  constructor
  · intro h u hu
    rcases u with ⟨b, i⟩
    apply (satisfies_unit_iff a b i).1
    exact h.prop _ (List.mem_map.2 ⟨(b, i), hu, rfl⟩)
  · intro h
    constructor
    intro c hc
    rw [Units.toFmla, List.mem_map] at hc
    obtain ⟨⟨b, i⟩, hu, rfl⟩ := hc
    exact (satisfies_unit_iff a b i).2 (h (b, i) hu)

/-- A combinational circuit together with unit assumptions/assertions. -/
structure Circuit where
  firstGate : Nat
  gates : List Gate
  units : List (Bool × Nat)
deriving DecidableEq, Repr

def Circuit.Holds (c : Circuit) (a : Nat → Bool) : Prop :=
  Gates.HoldsFrom c.firstGate c.gates a ∧ Units.Holds c.units a

def Circuit.toFmla (c : Circuit) : Sat.Fmla :=
  Gates.toFmlaFrom c.firstGate c.gates ++ Units.toFmla c.units

/-- The generated CNF has exactly the circuit semantics. -/
theorem satisfies_circuit_toFmla_iff (a : Nat → Bool) (c : Circuit) :
    Sat.Valuation.satisfies_fmla (boolValuation a) c.toFmla ↔ c.Holds a := by
  constructor
  · intro h
    constructor
    · apply (satisfies_gates_toFmlaFrom_iff a c.firstGate c.gates).1
      exact ⟨fun q hq => h.prop q (List.mem_append_left _ hq)⟩
    · apply (satisfies_units_toFmla_iff a c.units).1
      exact ⟨fun q hq => h.prop q (List.mem_append_right _ hq)⟩
  · rintro ⟨hg, hu⟩
    constructor
    intro q hq
    unfold Circuit.toFmla at hq
    rw [List.mem_append] at hq
    rcases hq with hq | hq
    · exact ((satisfies_gates_toFmlaFrom_iff a c.firstGate c.gates).2 hg).prop q hq
    · exact ((satisfies_units_toFmla_iff a c.units).2 hu).prop q hq

/-- A kernel-checked LRAT refutation of the generated formula rules out every wire assignment. -/
theorem no_model_of_lrat (c : Circuit) (h : Sat.Fmla.proof c.toFmla []) :
    ¬ ∃ a, c.Holds a := by
  rintro ⟨a, ha⟩
  have hs := (satisfies_circuit_toFmla_iff a c).2 ha
  exact h (boolValuation a) hs

end Collatz.Certified.Circuit
