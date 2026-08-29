import Collatz.Certified.Exclusion
import Mathlib.Tactic

/-!
Prototype for a pure-kernel classification of every start through `4614`.

The computational theorem at the end intentionally uses ordinary `decide`.
No VM evaluator, `native_decide`, file hash, or external assumption is involved.
This direct version recomputes each prefix; it is a compact baseline against
which an incremental production checker can be benchmarked.
-/

namespace Collatz.Certified.Finite.Base4614Direct

/-- Boolean membership in the exact `(n,j)` projection of the 593-row table. -/
def publishedPairCheck (n j : ℕ) : Bool :=
  decide (∃ w ∈ publishedWitnesses, w.n = n ∧ w.j = j)

theorem publishedPairCheck_iff {n j : ℕ} :
    publishedPairCheck n j = true ↔
      ∃ w ∈ publishedWitnesses, w.n = n ∧ w.j = j := by
  simp [publishedPairCheck]

/--
Check all prefixes `0,...,150`, and check that the endpoint at `150` has
entered the terminal set `{0,1,2}`.  Membership is evaluated only when the
prefix really is paradoxical, because Boolean `||` short-circuits.
-/
def startCheck (n : ℕ) : Bool :=
  decide (endpoint n 150 ≤ 2) &&
    (List.range 151).all fun j =>
      (!decide (Paradoxical n j)) || publishedPairCheck n j

/-- Check `count` starts beginning at `lo`. -/
def intervalCheck (lo count : ℕ) : Bool :=
  (List.range count).all fun i => startCheck (lo + i)

/-- A parameterized fixed-size block beginning at start `3`. -/
def blockCheck (blockSize block : ℕ) : Bool :=
  intervalCheck (3 + blockSize * block) blockSize

/- The first benchmark cell: 100 starts, ordinary kernel reduction. -/
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem block100_zero : blockCheck 100 0 = true := by
  decide

end Collatz.Certified.Finite.Base4614Direct
