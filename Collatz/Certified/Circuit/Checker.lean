import Collatz.Certified.Circuit.CNF

/-!
# Static DIMACS/LRAT certificate reconstruction

`checked_lrat` reads two string expressions (normally `include_str` artifacts), asks Mathlib's
proof-producing LRAT reconstructor for a proof, and accepts that proof only when the DIMACS
formula is definitionally equal to the expected `Sat.Fmla` in the Lean goal.  The elaborator is
not part of the trusted result: the generated proof term is checked by Lean's kernel.

Unlike `bv_decide`, this term elaborator neither uses `ofReduceBool` nor calls a SAT solver.
-/

open Lean Meta Elab Term Tactic

/--
Reconstruct a kernel proof of an expected `Sat.Fmla.proof f []` from static DIMACS and LRAT
strings.  A mismatch between the supplied DIMACS and `f` is rejected during elaboration.
-/
syntax (name := checkedLrat) "checked_lrat " term:max ppSpace term:max : tactic

elab_rules : tactic
  | `(tactic| checked_lrat $cnfSyntax:term $lratSyntax:term) => do
      let cnf ← unsafe evalTerm String (mkConst ``String) cnfSyntax
      let lrat ← unsafe evalTerm String (mkConst ``String) lratSyntax
      liftMetaFinishingTactic fun goal => do
        let expected ← instantiateMVars (← goal.getType)
        let_expr Sat.Fmla.proof expectedFmla expectedClause := expected
          | throwError "checked_lrat expects type Sat.Fmla.proof f []"
        unless expectedClause.isAppOfArity ``List.nil 1 do
          throwError "checked_lrat currently proves only the empty derived clause"
        let name ← mkAuxDeclName `checked_lrat
        let (_, parsedFmla, _, proof) ←
          Mathlib.Tactic.Sat.fromLRATAux cnf lrat name
        unless ← withTransparency .all <| isDefEq parsedFmla expectedFmla do
          throwError
            "checked_lrat: DIMACS formula does not definitionally match the expected formula"
        goal.assign proof
