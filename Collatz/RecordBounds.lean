import Collatz.Segment

/-!
# Explicit interfaces for external Collatz record computations

The propositions in this file are interfaces, not axioms.  A theorem that uses
one of them remains visibly conditional until a finite certificate (or another
Lean proof) supplies the proposition.

The accelerated excursion envelope is stated for every later iterate.  This
incorporates both the finite maximum-excursion record and convergence of each
covered start.  `ColDelayCap` instead records convergence directly, by asking
for a witnessed visit to `1` no later than the stated cap.
-/

namespace Collatz

namespace RecordBounds

/--
Every accelerated orbit starting strictly below `seed` stays strictly below
`threshold`.  This is the exact implication used from a maximum-excursion
record table.
-/
def AcceleratedExcursionEnvelope (threshold seed : ℕ) : Prop :=
  ∀ {x : ℕ}, x < seed → ∀ r, endpoint x r < threshold

/--
Every positive start through `upper` reaches `1` in at most `delay` ordinary
(unaccelerated) Collatz steps.
-/
def ColDelayCap (upper delay : ℕ) : Prop :=
  ∀ {n : ℕ}, 0 < n → n ≤ upper → ∃ d ≤ delay, iterate Col d n = 1

/--
An exact finite classification of paradoxical segments with start at most
`upper`.  The predicate `classified n j` can be membership in a certificate
list, or a coarser consequence such as the published bounds on `n` and `j`.
-/
def FiniteBaseClassification
    (upper : ℕ) (classified : ℕ → ℕ → Prop) : Prop :=
  ∀ {n j : ℕ}, n ≤ upper → (Paradoxical n j ↔ classified n j)

namespace AcceleratedExcursionEnvelope

theorem apply {threshold seed : ℕ}
    (h : AcceleratedExcursionEnvelope threshold seed)
    {x : ℕ} (hx : x < seed) (r : ℕ) :
    endpoint x r < threshold :=
  h hx r

end AcceleratedExcursionEnvelope

namespace ColDelayCap

theorem apply {upper delay : ℕ} (h : ColDelayCap upper delay)
    {n : ℕ} (hn : 0 < n) (hnupper : n ≤ upper) :
    ∃ d ≤ delay, iterate Col d n = 1 :=
  h hn hnupper

end ColDelayCap

namespace FiniteBaseClassification

theorem paradoxical_iff {upper : ℕ} {classified : ℕ → ℕ → Prop}
    (h : FiniteBaseClassification upper classified)
    {n j : ℕ} (hn : n ≤ upper) :
    Paradoxical n j ↔ classified n j :=
  h hn

theorem classify {upper : ℕ} {classified : ℕ → ℕ → Prop}
    (h : FiniteBaseClassification upper classified)
    {n j : ℕ} (hn : n ≤ upper) (hp : Paradoxical n j) :
    classified n j :=
  (h hn).mp hp

end FiniteBaseClassification

end RecordBounds

end Collatz
