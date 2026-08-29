import Mathlib.Tactic.Sat.FromLRAT
import Mathlib.Data.Nat.Pairing
import Mathlib.Lean.Meta.Simp
import Std.Tactic.BVDecide
import Lean.Meta.Tactic.BVDecide.Main

namespace LRATStdBridge

open Std

instance : DecidableEq (Std.Sat.CNF Nat) := fun ⟨a⟩ ⟨b⟩ =>
  match decEq a b with
  | isTrue h => isTrue (by cases h; rfl)
  | isFalse h => isFalse (by intro h'; cases h'; exact h rfl)

def clauseOfStd (c : Std.Sat.CNF.Clause Nat) : _root_.Sat.Clause :=
  c.map fun lit => if lit.2 then .pos lit.1 else .neg lit.1

@[simp] theorem clauseOfStd_cons (i : Nat) (b : Bool) (c : Std.Sat.CNF.Clause Nat) :
    clauseOfStd ((i, b) :: c) =
      (if b then _root_.Sat.Literal.pos i else _root_.Sat.Literal.neg i) :: clauseOfStd c := rfl

def fmlaOfStd (f : Std.Sat.CNF Nat) : _root_.Sat.Fmla :=
  f.clauses.toList.map clauseOfStd

theorem satisfies_clauseOfStd_iff (a : Nat → Bool) (c : Std.Sat.CNF.Clause Nat) :
    _root_.Sat.Valuation.satisfies (fun i => a i = true) (clauseOfStd c) ↔
      Std.Sat.CNF.Clause.eval a c = true := by
  induction c with
  | nil =>
      change False ↔ false = true
      simp
  | cons lit c ih =>
      rcases lit with ⟨i, b⟩
      cases b <;> cases h : a i <;>
        simpa [clauseOfStd_cons, _root_.Sat.Valuation.satisfies,
          _root_.Sat.Valuation.neg, h] using ih

theorem satisfies_fmlaOfStd_of_eval_true (a : Nat → Bool) (f : Std.Sat.CNF Nat)
    (h : Std.Sat.CNF.eval a f = true) :
    _root_.Sat.Valuation.satisfies_fmla (fun i => a i = true) (fmlaOfStd f) := by
  constructor
  intro c hc
  rw [fmlaOfStd, List.mem_map] at hc
  obtain ⟨c', hc', rfl⟩ := hc
  apply (satisfies_clauseOfStd_iff a c').2
  rw [Std.Sat.CNF.eval, Array.all_eq_true] at h
  rw [Array.mem_toList_iff] at hc'
  rw [Array.mem_iff_getElem] at hc'
  obtain ⟨i, hi, hci⟩ := hc'
  simpa [hci] using h i hi

theorem std_unsat_of_fmla_proof (f : Std.Sat.CNF Nat)
    (h : _root_.Sat.Fmla.proof (fmlaOfStd f) []) : f.Unsat := by
  intro a
  cases he : Std.Sat.CNF.eval a f with
  | false => rfl
  | true =>
      exact False.elim (h (fun i => a i = true) (satisfies_fmlaOfStd_of_eval_true a f he))

#print axioms std_unsat_of_fmla_proof

open Std.Sat
open Std.Tactic.BVDecide

theorem bv_unsat_of_cnf_unsat (bv : BVLogicalExpr)
    (h : (AIG.toCNF bv.bitblast.relabelNat).Unsat) : bv.Unsat := by
  apply BVLogicalExpr.unsat_of_bitblast
  rw [← AIG.Entrypoint.relabelNat_unsat_iff]
  rw [← AIG.toCNF_equisat]
  exact h

#print axioms bv_unsat_of_cnf_unsat

theorem transfer_cnf_unsat {f g : Std.Sat.CNF Nat} (h : f = g) (hf : f.Unsat) : g.Unsat := by
  simpa [h] using hf

def encodeBVBit (b : BVBit) : Nat :=
  Nat.pair b.var (Nat.pair b.w b.idx.val)

theorem encodeBVBit_injective : Function.Injective encodeBVBit := by
  intro x y h
  cases x with
  | @mk xv xw xi =>
    cases y with
    | @mk yv yw yi =>
      have h₁ := congrArg Nat.unpair h
      simp only [encodeBVBit, Nat.unpair_pair] at h₁
      have hvar : xv = yv := congrArg Prod.fst h₁
      have hp : Nat.pair xw xi.val = Nat.pair yw yi.val := congrArg Prod.snd h₁
      have h₂ := congrArg Nat.unpair hp
      simp only [Nat.unpair_pair] at h₂
      have hw : xw = yw := congrArg Prod.fst h₂
      rw [BVBit.mk.injEq]
      refine ⟨hvar, hw, ?_⟩
      subst yw
      exact heq_of_eq (Fin.ext (congrArg Prod.snd h₂))

theorem bv_unsat_of_encoded_cnf (bv : BVLogicalExpr)
    (h : (AIG.toCNF (bv.bitblast.relabel encodeBVBit)).Unsat) : bv.Unsat := by
  apply BVLogicalExpr.unsat_of_bitblast
  have hinj : ∀ x y, x ∈ bv.bitblast.aig → y ∈ bv.bitblast.aig →
      encodeBVBit x = encodeBVBit y → x = y := fun x y _ _ hxy => encodeBVBit_injective hxy
  rw [← AIG.Entrypoint.relabel_unsat_iff hinj]
  rw [← AIG.toCNF_equisat]
  exact h

#print axioms bv_unsat_of_encoded_cnf

open Lean Elab Tactic Meta
open Lean.Meta.Tactic.BVDecide

private def addSafeDef (name : Name) (type value : Expr) : CoreM Unit :=
  addDecl <| Declaration.defnDecl {
    name, levelParams := [], type, value,
    hints := .abbrev, safety := .safe
  }

private def proveCnfEqBySimp (eqType : Expr) : MetaM Expr := do
  let m ← mkFreshExprMVar eqType MetavarKind.syntheticOpaque
  let names := [
    ``Std.Tactic.BVDecide.BVLogicalExpr.bitblast,
    ``Std.Tactic.BVDecide.BVLogicalExpr.bitblast.go,
    ``Std.Tactic.BVDecide.BVExpr.Cache.empty,
    ``Std.Sat.AIG.Entrypoint.relabel,
    ``Std.Sat.AIG.relabel,
    ``Std.Sat.AIG.toCNF,
    "_private.Std.Sat.AIG.CNF.0.Std.Sat.AIG.toCNF.go".toName,
    "_private.Std.Sat.AIG.CNF.0.Std.Sat.AIG.toCNF.State.empty".toName,
    ``Std.Sat.AIG.Cache.empty,
    ``Std.Sat.AIG.Cache.noUpdate,
    ``Std.Sat.AIG.Cache.insert,
    ``Std.Sat.AIG.Cache.get?,
    ``Std.DHashMap.Internal.mkIdx
  ]
  let simpThms ← names.foldlM (fun s n => s.addDeclToUnfold n) (← getSimpTheorems)
  let simpCtx ← Simp.mkContext { maxSteps := 10000000 }
    (simpTheorems := #[simpThms]) (congrTheorems := ← getSimpCongrTheorems)
  let (goal?, _) ← simpGoal m.mvarId! simpCtx
  match goal? with
  | none => instantiateMVars m
  | some (_, g) => throwError m!"cache-unfolding simp did not close CNF equality: {← g.getType}"

private def kernelLratProver (ctx : TacticContext) : UnsatProver Unit :=
  fun _goal reflectionResult _atomsAssignment => do
    let bvExpr := reflectionResult.bvExpr
    let entry := bvExpr.bitblast.relabelNat
    let cnf := AIG.toCNF entry
    let res ← runExternal cnf ctx.solver ctx.lratPath ctx.config.trimProofs
      ctx.config.timeout ctx.config.binaryProofs ctx.config.solverMode
    match res with
    | .error _ => throwError "kernel LRAT probe unexpectedly found SAT"
    | .ok cert =>
      addSafeDef ctx.exprDef (mkConst ``BVLogicalExpr) reflectionResult.expr
      let reflectedExpr := mkConst ctx.exprDef
      let bitblastExpr := mkApp (mkConst ``BVLogicalExpr.bitblast) reflectedExpr
      let relabeledExpr ← mkAppM ``AIG.Entrypoint.relabelNat #[bitblastExpr]
      let expectedCnf ← mkAppM ``AIG.toCNF #[relabeledExpr]
      let cnfName ← mkAuxDeclName (ctx.exprDef ++ `_kernel_cnf)
      let cnfType := mkApp (mkConst ``Std.Sat.CNF [.zero]) (mkConst ``Nat)
      let cnfValue := mkApp2 (mkConst ``Std.Sat.CNF.mk [.zero]) (mkConst ``Nat) (toExpr cnf.clauses)
      addSafeDef cnfName cnfType cnfValue
      let cnfExpr := mkConst cnfName
      let proofName ← mkAuxDeclName (ctx.exprDef ++ `_kernel_lrat)
      let (_nvars, fmlaCtx, fmlaCtxValue, fmlaProof) ←
        Mathlib.Tactic.Sat.fromLRATAux cnf.dimacs cert proofName
      let expectedFmla := mkApp (mkConst ``fmlaOfStd) cnfExpr
      unless ← withTransparency .all <| isDefEq fmlaCtx expectedFmla do
        throwError m!"parsed DIMACS formula does not definitionally match materialized fmlaOfStd:\nCNF={cnf.dimacs}\nctx={← reduceAll fmlaCtxValue}\nexpected={← reduceAll expectedFmla}"
      let cnfUnsat := mkApp2 (mkConst ``std_unsat_of_fmla_proof) cnfExpr fmlaProof
      let eqName ← mkAuxDeclName (ctx.exprDef ++ `_kernel_cnf_eq)
      let eqType ← mkEq cnfExpr expectedCnf
      let eqValue ← mkDecideProof eqType
      addDecl <| Declaration.thmDecl {
        name := eqName, levelParams := [], type := eqType, value := eqValue
      }
      let expectedCnfUnsat :=
        mkApp4 (mkConst ``transfer_cnf_unsat) cnfExpr expectedCnf (mkConst eqName) cnfUnsat
      let bvUnsat := mkApp2 (mkConst ``bv_unsat_of_cnf_unsat) reflectedExpr expectedCnfUnsat
      return .ok ⟨bvUnsat, ()⟩

private def kernelBvDecide (g : MVarId) (ctx : TacticContext) : MetaM Unit := do
  let g? ← Normalize.bvNormalize g ctx.config
  let some g := g? | return
  match ← closeWithBVReflection g (kernelLratProver ctx) with
  | .ok _ => return
  | .error _ => throwError "kernel_bv_decide found a counterexample"

elab "kernel_bv_decide" : tactic => do
  IO.FS.withTempFile fun _ lratFile => do
    let ctx ← TacticContext.new lratFile {}
    liftMetaFinishingTactic fun g => kernelBvDecide g ctx

private def kernelReflectProver (ctx : TacticContext) : UnsatProver Unit :=
  fun _goal reflectionResult _atomsAssignment => do
    let bvExpr := reflectionResult.bvExpr
    let entry := bvExpr.bitblast.relabelNat
    let cnf := AIG.toCNF entry
    let res ← runExternal cnf ctx.solver ctx.lratPath ctx.config.trimProofs
      ctx.config.timeout ctx.config.binaryProofs ctx.config.solverMode
    match res with
    | .error _ => throwError "kernel reflection probe unexpectedly found SAT"
    | .ok cert =>
      addSafeDef ctx.exprDef (mkConst ``BVLogicalExpr) reflectionResult.expr
      addSafeDef ctx.certDef (mkConst ``String) (toExpr cert)
      let reflectedExpr := mkConst ctx.exprDef
      let certExpr := mkConst ctx.certDef
      let reflectionTerm :=
        mkApp2 (mkConst ``Std.Tactic.BVDecide.Reflect.verifyBVExpr) reflectedExpr certExpr
      let checkProof ← mkEqRefl reflectionTerm
      let bvUnsat :=
        mkApp3 (mkConst ``Std.Tactic.BVDecide.Reflect.unsat_of_verifyBVExpr_eq_true)
          reflectedExpr certExpr checkProof
      return .ok ⟨bvUnsat, ()⟩

private def kernelReflectDecide (g : MVarId) (ctx : TacticContext) : MetaM Unit := do
  let g? ← Normalize.bvNormalize g ctx.config
  let some g := g? | return
  match ← closeWithBVReflection g (kernelReflectProver ctx) with
  | .ok _ => return
  | .error _ => throwError "kernel_bv_reflect found a counterexample"

elab "kernel_bv_reflect" : tactic => do
  IO.FS.withTempFile fun _ lratFile => do
    let ctx ← TacticContext.new lratFile {}
    liftMetaFinishingTactic fun g => kernelReflectDecide g ctx

private def encodedKernelLratProver (ctx : TacticContext) : UnsatProver Unit :=
  fun _goal reflectionResult _atomsAssignment => do
    let bvExpr := reflectionResult.bvExpr
    let entry := bvExpr.bitblast.relabel encodeBVBit
    let cnf := AIG.toCNF entry
    let res ← runExternal cnf ctx.solver ctx.lratPath ctx.config.trimProofs
      ctx.config.timeout ctx.config.binaryProofs ctx.config.solverMode
    match res with
    | .error _ => throwError "encoded kernel LRAT probe unexpectedly found SAT"
    | .ok cert =>
      addSafeDef ctx.exprDef (mkConst ``BVLogicalExpr) reflectionResult.expr
      let reflectedExpr := mkConst ctx.exprDef
      let bitblastExpr := mkApp (mkConst ``BVLogicalExpr.bitblast) reflectedExpr
      let relabeledExpr ← mkAppM ``AIG.Entrypoint.relabel #[mkConst ``encodeBVBit, bitblastExpr]
      let expectedCnf ← mkAppM ``AIG.toCNF #[relabeledExpr]
      let cnfName ← mkAuxDeclName (ctx.exprDef ++ `_encoded_kernel_cnf)
      let cnfType := mkApp (mkConst ``Std.Sat.CNF [.zero]) (mkConst ``Nat)
      let cnfValue := mkApp2 (mkConst ``Std.Sat.CNF.mk [.zero]) (mkConst ``Nat) (toExpr cnf.clauses)
      addSafeDef cnfName cnfType cnfValue
      let cnfExpr := mkConst cnfName
      let proofName ← mkAuxDeclName (ctx.exprDef ++ `_encoded_kernel_lrat)
      let (_nvars, fmlaCtx, _fmlaCtxValue, fmlaProof) ←
        Mathlib.Tactic.Sat.fromLRATAux cnf.dimacs cert proofName
      let expectedFmla := mkApp (mkConst ``fmlaOfStd) cnfExpr
      unless ← withTransparency .all <| isDefEq fmlaCtx expectedFmla do
        throwError "parsed DIMACS formula does not match the materialized encoded CNF"
      let cnfUnsat := mkApp2 (mkConst ``std_unsat_of_fmla_proof) cnfExpr fmlaProof
      let eqName ← mkAuxDeclName (ctx.exprDef ++ `_encoded_kernel_cnf_eq)
      let eqType ← mkEq cnfExpr expectedCnf
      let eqValue ← proveCnfEqBySimp eqType
      addDecl <| Declaration.thmDecl {
        name := eqName, levelParams := [], type := eqType, value := eqValue
      }
      let expectedCnfUnsat :=
        mkApp4 (mkConst ``transfer_cnf_unsat) cnfExpr expectedCnf (mkConst eqName) cnfUnsat
      let bvUnsat := mkApp2 (mkConst ``bv_unsat_of_encoded_cnf) reflectedExpr expectedCnfUnsat
      return .ok ⟨bvUnsat, ()⟩

private def encodedKernelBvDecide (g : MVarId) (ctx : TacticContext) : MetaM Unit := do
  let g? ← Normalize.bvNormalize g ctx.config
  let some g := g? | return
  match ← closeWithBVReflection g (encodedKernelLratProver ctx) with
  | .ok _ => return
  | .error _ => throwError "kernel_bv_encoded found a counterexample"

elab "kernel_bv_encoded" : tactic => do
  IO.FS.withTempFile fun _ lratFile => do
    let ctx ← TacticContext.new lratFile {}
    liftMetaFinishingTactic fun g => encodedKernelBvDecide g ctx

theorem kernel_bv_small (x : BitVec 8) (h : x ≤ 10) : x + 1 ≤ 11 := by
  kernel_bv_encoded

#print axioms kernel_bv_small

end LRATStdBridge
