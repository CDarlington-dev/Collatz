import Collatz.RecordBounds
import Mathlib.Tactic

/-!
# Kernel-verified certificates for finite ordinary-Collatz delay bounds

This module defines a small, deliberately untrusted-data-friendly certificate
format.  A certificate contains, for every covered positive integer `n`,

* the length `steps[n]` of an ordinary-Collatz prefix that Lean recomputes;
* an implicit link from its recomputed endpoint to a strictly smaller positive
  integer; and
* an additive certified visit-time bound `budget[n]`.

The Boolean checker recomputes every trajectory prefix with `Collatz.Col`,
checks the well-founded link and the additive budget equation, and checks the
claimed global cap.  The soundness theorem is an ordinary Lean proof by strong
induction.  Consequently malformed or fabricated external tables cannot prove
`ColDelayCap`: they merely make `delayDAGCheck` evaluate to `false`.

This point-indexed format is useful as a reference checker and as the terminal
layer of a future compressed residue-cylinder certificate.  It is not a claim
that a point table through `4.65 * 10^19` is a viable representation.
-/

namespace Collatz

namespace Certified

namespace Finite

open RecordBounds

/--
An exact well-founded descent DAG, represented by two point-indexed tables.
Index `0` is unused.  Missing entries read as `0`, which can never make a
positive non-base node pass the checker.
-/
structure DelayDAGCertificate where
  steps : Array ℕ
  budgets : Array ℕ
  deriving Repr

namespace DelayDAGCertificate

/-- Total lookup used by the executable checker. -/
def tableAt (xs : Array ℕ) (n : ℕ) : ℕ :=
  (xs[n]?).getD 0

/-- Length of the exact trajectory prefix attached to `n`. -/
def stepAt (cert : DelayDAGCertificate) (n : ℕ) : ℕ :=
  tableAt cert.steps n

/-- Claimed upper bound for a certified ordinary visit to `1` from `n`. -/
def budgetAt (cert : DelayDAGCertificate) (n : ℕ) : ℕ :=
  tableAt cert.budgets n

end DelayDAGCertificate

open DelayDAGCertificate

/--
Check one node.  The base node `1` has budget zero.  Every other positive node
must take a nonempty, exactly recomputed prefix to a positive smaller node;
its certified visit-time bound must be the prefix length plus the linked
node's bound.  The bound need not be the least visit time.
-/
def delayDAGNodeCheck (cap : ℕ) (cert : DelayDAGCertificate) (n : ℕ) : Bool :=
  if n = 0 then true
  else if n = 1 then decide (budgetAt cert 1 = 0)
  else
    let s := stepAt cert n
    let target := iterate Col s n
    decide
      (0 < s ∧ 0 < target ∧ target < n ∧
        budgetAt cert n = s + budgetAt cert target ∧
        budgetAt cert n ≤ cap)

/--
Check table integrity and every node in the inclusive interval `0 .. upper`.
The result is a plain `Bool`, so certificate data remains computational input.
-/
def delayDAGCheck (upper cap : ℕ) (cert : DelayDAGCertificate) : Bool :=
  decide (upper < cert.steps.size ∧ upper < cert.budgets.size) &&
    (List.range (upper + 1)).all (delayDAGNodeCheck cap cert)

theorem delayDAGNodeCheck_sound
    {cap n : ℕ} {cert : DelayDAGCertificate}
    (hnzero : n ≠ 0) (hnone : n ≠ 1)
    (hcheck : delayDAGNodeCheck cap cert n = true) :
    let s := stepAt cert n
    let target := iterate Col s n
    0 < s ∧ 0 < target ∧ target < n ∧
      budgetAt cert n = s + budgetAt cert target ∧
      budgetAt cert n ≤ cap := by
  simpa [delayDAGNodeCheck, hnzero, hnone] using hcheck

/--
Soundness of the descent-DAG checker.  This is the proof-producing boundary:
only a successful exact check can create the record-bound predicate consumed
by the exclusion theorem.
-/
theorem delayDAGCheck_sound
    {upper cap : ℕ} {cert : DelayDAGCertificate}
    (hcheck : delayDAGCheck upper cap cert = true) :
    ColDelayCap upper cap := by
  have hparts :
      decide (upper < cert.steps.size ∧ upper < cert.budgets.size) = true ∧
        (List.range (upper + 1)).all (delayDAGNodeCheck cap cert) = true := by
    simpa [delayDAGCheck] using hcheck
  have hall : ∀ n, n ∈ List.range (upper + 1) →
      delayDAGNodeCheck cap cert n = true := by
    simpa using hparts.2
  have hreach : ∀ n : ℕ, 0 < n → n ≤ upper →
      ∃ d ≤ budgetAt cert n, iterate Col d n = 1 := by
    intro n
    induction n using Nat.strong_induction_on with
    | h n ih =>
        intro hnpos hnupper
        have hnmem : n ∈ List.range (upper + 1) := by
          simpa using (show n < upper + 1 by omega)
        have hnode := hall n hnmem
        by_cases hnone : n = 1
        · subst n
          have hbudget : budgetAt cert 1 = 0 := by
            simpa [delayDAGNodeCheck] using hnode
          refine ⟨0, ?_, ?_⟩
          · omega
          · rfl
        · have hnzero : n ≠ 0 := by omega
          have hdata := delayDAGNodeCheck_sound hnzero hnone hnode
          let s := stepAt cert n
          let target := iterate Col s n
          have hs : 0 < s := hdata.1
          have htargetpos : 0 < target := hdata.2.1
          have htargetlt : target < n := hdata.2.2.1
          have hbudget : budgetAt cert n = s + budgetAt cert target :=
            hdata.2.2.2.1
          have htargetupper : target ≤ upper := by omega
          obtain ⟨d, hd, hend⟩ := ih target htargetlt htargetpos htargetupper
          refine ⟨s + d, ?_, ?_⟩
          · omega
          · calc
              iterate Col (s + d) n = iterate Col d (iterate Col s n) :=
                iterate_add s d n
              _ = iterate Col d target := by rfl
              _ = 1 := hend
  intro n hnpos hnupper
  obtain ⟨d, hd, hend⟩ := hreach n hnpos hnupper
  refine ⟨d, ?_, hend⟩
  have hnmem : n ∈ List.range (upper + 1) := by
    simpa using (show n < upper + 1 by omega)
  have hnode := hall n hnmem
  by_cases hnone : n = 1
  · subst n
    have hbudget : budgetAt cert 1 = 0 := by
      simpa [delayDAGNodeCheck] using hnode
    omega
  · have hnzero : n ≠ 0 := by omega
    have hdata := delayDAGNodeCheck_sound hnzero hnone hnode
    exact le_trans hd hdata.2.2.2.2

/-! ## Small pure-kernel demonstrator -/

/-- Search an exact prefix ending strictly below the original start. -/
def firstDescentAux (start : ℕ) : ℕ → ℕ → ℕ → ℕ
  | 0, _, _ => 0
  | fuel + 1, current, elapsed =>
      let next := Col current
      let elapsed' := elapsed + 1
      if next < start then elapsed'
      else firstDescentAux start fuel next elapsed'

def firstDescentWithin (fuel n : ℕ) : ℕ :=
  firstDescentAux n fuel n 0

/-- Search the exact ordinary total stopping time to the first visit to `1`. -/
def stoppingTimeAux : ℕ → ℕ → ℕ → ℕ
  | 0, current, elapsed => if current = 1 then elapsed else 0
  | fuel + 1, current, elapsed =>
      if current = 1 then elapsed
      else stoppingTimeAux fuel (Col current) (elapsed + 1)

def stoppingTimeWithin (fuel n : ℕ) : ℕ :=
  stoppingTimeAux fuel n 0

/--
Materialized certificate data for `1 <= n <= 20`.  The generators are not
trusted: the checker independently recomputes every prefix and every link.
-/
def delayCertificate20 : DelayDAGCertificate where
  steps := ((List.range 21).map (firstDescentWithin 20)).toArray
  budgets := ((List.range 21).map (stoppingTimeWithin 20)).toArray

/-- Ordinary kernel reduction (not `native_decide`) accepts the demonstrator. -/
theorem delayCertificate20_checked :
    delayDAGCheck 20 20 delayCertificate20 = true := by
  set_option maxRecDepth 1000000 in
    decide

/-- Unconditional, kernel-checked ordinary Collatz delay cap through `20`. -/
theorem colDelayCap20 : ColDelayCap 20 20 :=
  delayDAGCheck_sound delayCertificate20_checked

end Finite

end Certified

end Collatz
