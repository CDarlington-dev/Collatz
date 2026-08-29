import Mathlib.Tactic.Sat.FromLRAT
import Mathlib.Tactic.Tauto
import Std.Tactic.BVDecide

/-!
Prototype for removing `bv_decide`'s compiler-evaluation axiom.  Mathlib's
`lrat_proof` elaborator converts LRAT steps into ordinary theorem applications;
the resulting proof is checked directly by Lean's kernel.
-/

namespace LratKernelPrototype

namespace Bridge

def literal : Std.Sat.Literal Nat -> Sat.Literal
  | (i, true) => .pos i
  | (i, false) => .neg i

def clause (c : Std.Sat.CNF.Clause Nat) : Sat.Clause := c.map literal

def fmla (f : Std.Sat.CNF Nat) : Sat.Fmla := f.clauses.toList.map clause

theorem clause_sound (assign : Nat -> Bool) : forall c,
    Std.Sat.CNF.Clause.eval assign c = true ->
      Sat.Valuation.satisfies (fun i => assign i = true) (clause c) := by
  intro c
  induction c with
  | nil => simp [Std.Sat.CNF.Clause.eval, clause, Sat.Valuation.satisfies]
  | cons l c ih =>
      rcases l with ⟨i, b⟩
      cases b with
      | false =>
          simp only [clause, List.map_cons, literal, Sat.Valuation.satisfies,
            Sat.Valuation.neg]
          intro h hneg
          rw [Std.Sat.CNF.Clause.eval_cons, Bool.or_eq_true] at h
          rcases h with hl | hr
          · simp only [beq_iff_eq] at hl
            simp [hneg] at hl
          · exact ih hr
      | true =>
          simp only [clause, List.map_cons, literal, Sat.Valuation.satisfies,
            Sat.Valuation.neg]
          intro h hneg
          rw [Std.Sat.CNF.Clause.eval_cons, Bool.or_eq_true] at h
          rcases h with hl | hr
          · simp only [beq_iff_eq] at hl
            exact (hneg hl).elim
          · exact ih hr

theorem std_unsat_of_fmla_proof (f : Std.Sat.CNF Nat)
    (hproof : (fmla f).proof []) : f.Unsat := by
  intro assign
  rw [Bool.eq_false_iff]
  intro heval
  apply hproof (fun i => assign i = true)
  constructor
  intro c hc
  simp only [fmla, List.mem_map] at hc
  obtain ⟨source, hsource, rfl⟩ := hc
  apply clause_sound
  have hall : ∀ source, source ∈ f.clauses ->
      Std.Sat.CNF.Clause.eval assign source = true := by
    simp only [Std.Sat.CNF.eval, Array.all_eq_true] at heval
    intro source hsource
    rw [Array.mem_iff_getElem] at hsource
    obtain ⟨i, hi, rfl⟩ := hsource
    exact heval i hi
  exact hall source (by simpa using hsource)

end Bridge

lrat_proof four_clause_unsat
  "p cnf 2 4
   1 2 0
   -1 2 0
   1 -2 0
   -1 -2 0"
  "5 -2 0 4 3 0
   5 d 3 4 0
   6 1 0 5 1 0
   6 d 1 0
   7 0 5 2 6 0"

#print axioms four_clause_unsat
#check four_clause_unsat

def fourClauseCNF : Std.Sat.CNF Nat where
  clauses := #[
    [(0, true), (1, true)],
    [(0, false), (1, true)],
    [(0, true), (1, false)],
    [(0, false), (1, false)]]

theorem fourClauseCNF_unsat : fourClauseCNF.Unsat := by
  intro assign
  have h := four_clause_unsat (assign 0 = true) (assign 1 = true)
  rw [Bool.eq_false_iff]
  intro heval
  simp [fourClauseCNF, Std.Sat.CNF.eval, Std.Sat.CNF.Clause.eval] at heval
  simp only [Bool.eq_false_iff] at heval
  tauto

#print axioms fourClauseCNF_unsat

theorem small_bv_stock (x y : BitVec 2) : x + y = y + x := by
  bv_decide

#print axioms small_bv_stock

theorem square_roots_stock (x : BitVec 4) :
    x * x = 0 -> x = 0 ∨ x = 4 ∨ x = 8 ∨ x = 12 := by
  bv_decide

#print axioms square_roots_stock

-- Running this once asks `bv_decide` to preserve its LRAT artifact.  It is
-- commented after capture because the generated stock proof is intentionally
-- not part of the kernel-only prototype.
-- theorem small_bv_trace (x y : BitVec 2) : x + y = y + x := by
--   bv_decide?

theorem square_roots_trace (x : BitVec 4) :
    x * x = 0 -> x = 0 ∨ x = 4 ∨ x = 8 ∨ x = 12 := by
  bv_decide?

end LratKernelPrototype
