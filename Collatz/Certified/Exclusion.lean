import Collatz.Exclusion
import Collatz.AffineBound
import Collatz.Certified.Farey
import Collatz.Certified.OptimizedFarey
import Collatz.Certified.Published
import Collatz.Certified.Finite.FirstExcursionKernel
import Collatz.Certified.Finite.OptimizedFirstExcursionKernel
import Collatz.Certified.Finite.BaseClassificationKernel
import Collatz.Certified.Finite.NoParadoxicalRangeKernel
import Collatz.Certified.Finite.NoParadoxicalRange26017Kernel

/-!
# Numeric Rozier--Terracol exclusion theorem

This file instantiates the axiom-free deterministic theorem with the exact
integers used in the paper.  The manageable first excursion envelope is
discharged by a kernel-reduced finite certificate.  The remaining large
finite-computation inputs stay explicit fields; Lean proves every implication
from those fields without silently postulating their completeness.
-/

namespace Collatz

namespace Certified

open RecordBounds

/-- Membership in the published finite classification, with its checked bounds exposed. -/
def PublishedClassification (n j : ℕ) : Prop :=
  n ≤ 4614 ∧ j ≤ 92 ∧
    ∃ w ∈ publishedWitnesses, w.n = n ∧ w.j = j

/--
Unconditional kernel-checked classification through the largest published
start.  This is the exact production predicate, not a renamed assumption.
-/
theorem finiteBaseClassification_4614_kernel :
    FiniteBaseClassification 4614 PublishedClassification := by
  intro n j hn
  simpa only [PublishedClassification, Finite.PublishedClassificationUpTo4614] using
    Finite.finiteBaseClassification_4614 hn

/--
The earlier kernel-checked complete classification through start `10014`.
Starts `4615,...,10014` are ruled out by the independent all-prefix,
trace-to-`1` checker; the stronger theorem through `26017` appears below.
-/
theorem finiteBaseClassification_10014_kernel :
    FiniteBaseClassification 10014 PublishedClassification := by
  intro n j hn
  by_cases hsmall : n ≤ 4614
  · exact finiteBaseClassification_4614_kernel hsmall
  · have hnot : ¬ Paradoxical n j :=
      Finite.no_paradoxical_start_4615_through_10014 (by omega) hn
    constructor
    · exact fun hp => (hnot hp).elim
    · rintro ⟨hn4614, _hj, _hw⟩
      omega

/--
Kernel-checked complete classification through `26017`.  The positive side is
still exactly the 593 published pairs; ordinary reduction excludes every
additional start `4615,...,26017` and every segment length.
-/
theorem finiteBaseClassification_26017_kernel :
    FiniteBaseClassification 26017 PublishedClassification := by
  intro n j hn
  simpa only [PublishedClassification, Finite.PublishedClassificationUpTo4614] using
    Finite.finiteBaseClassification_26017 hn

/-- Strongest current unconditional target-shaped start exclusion. -/
theorem no_paradoxical_start_above_4614_below_26018
    {n j : ℕ} (hlower : 4614 < n) (hupper : n < 26018) :
    ¬ Paradoxical n j :=
  Finite.no_paradoxical_start_4615_through_26017 hlower (by omega)

/--
Exactly the remaining external completeness inputs needed for the paper's
numeric theorem.  The first envelope is supplied internally by
`Finite.firstExcursionEnvelope_kernel`.
-/
structure RozierTerracolInputs : Prop where
  finiteBase : FiniteBaseClassification 1000000000 PublishedClassification
  delayCap : ColDelayCap 28019077177231758495 2456
  secondEnvelope :
    AcceleratedExcursionEnvelope 28019077177231758495 secondFarey.m

/--
The separately named 2026 record inputs.  Their range is larger than the
paper's, and their completeness is deliberately still a theorem hypothesis.
-/
structure CurrentDelayInputs : Prop where
  finiteBase : FiniteBaseClassification 1000000000 PublishedClassification
  delayCap : ColDelayCap 46499999999999999999 2480

/--
The strictly smaller assumptions needed after combining the exact optimized
first-feedback envelope with the kernel classification through `26017`.
The affine bound discharges all lengths below `35`, so the gap predicate asks
only about the remaining lengths; the delay cap further restricts it to
ordinary prefix length `j + oddCount n j < 2480`.
-/
def OptimizedFiniteGap : Prop :=
  ∀ {n j : ℕ},
    26017 < n → n ≤ 785412368 → 35 ≤ j →
      j + oddCount n j < 2480 → ¬ Paradoxical n j

structure OptimizedCurrentInputs : Prop where
  finiteGap : OptimizedFiniteGap
  delayCap : ColDelayCap 46499999999999999999 2480

/-- The optimized premises are exactly enough to recover a complete classifier
through the finite endpoint; no positive-row assumption is added. -/
theorem finiteBaseClassification_785412368_of_optimized_inputs
    (h : OptimizedCurrentInputs) :
    FiniteBaseClassification 785412368 PublishedClassification := by
  intro n j hn
  by_cases hsmall : n ≤ 26017
  · exact finiteBaseClassification_26017_kernel hsmall
  · have hnot : ¬ Paradoxical n j := by
      intro hp
      exact h.finiteGap (by omega) hn
        (AffineBound.paradoxical_length_at_least_35 (by omega) hp)
        (Exclusion.paradoxical_ordinary_length_lt_delay_cap
          (upper := 46499999999999999999) (delay := 2480)
          (by omega) (by omega) h.delayCap hp) hp
    constructor
    · exact fun hp => (hnot hp).elim
    · rintro ⟨hn4614, _hj, _hw⟩
      omega

/-- The additional excursion input needed for beyond-bound length estimates. -/
structure CurrentExtensionInputs : Prop extends CurrentDelayInputs where
  currentEnvelope :
    AcceleratedExcursionEnvelope 46499999999999999999 currentFarey.m

/--
The exact two-feedback dichotomy.  Besides reproducing `j ≥ 301994`, it
exposes the strengthened exact consequence `q ≥ 190537`.
-/
theorem rozier_terracol_dichotomy
    (h : RozierTerracolInputs) {n j : ℕ} (hp : Paradoxical n j) :
    PublishedClassification n j ∨
      (28019077177231758495 < n ∧
        301994 ≤ j ∧ 190537 ≤ oddCount n j) := by
  simpa [publishedFarey, secondFarey] using
    (Exclusion.two_feedback
      (base := 1000000000)
      (delayUpper := 28019077177231758495)
      (delay := 2456)
      (classified := PublishedClassification)
      (first := publishedFarey)
      (second := secondFarey)
      (by norm_num : 4 ≤ 1000000000)
      h.finiteBase
      publishedFarey_valid
      (by
        intro x hx r
        exact Finite.firstExcursionEnvelope_kernel
          (x := x) (by simpa [publishedFarey] using hx) r)
      h.delayCap
      (by norm_num [publishedFarey] :
        2456 ≤
          (publishedFarey.a + publishedFarey.c) +
            (publishedFarey.b + publishedFarey.d))
      secondFarey_valid
      h.secondEnvelope
      hp)

/--
Conditional exact-endpoint sharpening of the paper's rounded `2.8 * 10^19`
statement.  The endpoint is the exact start of the delay-2456 record used by
the paper.
-/
theorem no_paradoxical_start_through_delay_record
    (h : RozierTerracolInputs) {n j : ℕ}
    (hlower : 4614 < n) (hupper : n ≤ 28019077177231758495) :
    ¬ Paradoxical n j := by
  intro hp
  rcases rozier_terracol_dichotomy h hp with hbase | hbeyond
  · exact (Nat.not_lt_of_ge hbase.1) hlower
  · exact (Nat.not_lt_of_ge hupper) hbeyond.1

/-- Reproduction of the paper's excluded length interval. -/
theorem no_paradoxical_length_from_93_through_301993
    (h : RozierTerracolInputs) {n j : ℕ}
    (hlower : 93 ≤ j) (hupper : j ≤ 301993) :
    ¬ Paradoxical n j := by
  intro hp
  rcases rozier_terracol_dichotomy h hp with hbase | hbeyond
  · rcases hbase with ⟨_, hj, _⟩
    omega
  · omega

/-- The paper's displayed rounded start interval follows immediately. -/
theorem no_paradoxical_start_through_28e19
    (h : RozierTerracolInputs) {n j : ℕ}
    (hlower : 4614 < n) (hupper : n ≤ 28000000000000000000) :
    ¬ Paradoxical n j := by
  exact no_paradoxical_start_through_delay_record h hlower (by omega)

/-! ## Conditional extension from the July 2026 record status -/

/--
The current conditional dichotomy.  Every segment is either in the published
finite classification or begins beyond `4.65 * 10^19` and satisfies both
strengthened size bounds.
-/
theorem current_extension_dichotomy
    (h : CurrentExtensionInputs) {n j : ℕ} (hp : Paradoxical n j) :
    PublishedClassification n j ∨
      (46499999999999999999 < n ∧
        301994 ≤ j ∧ 190537 ≤ oddCount n j) := by
  simpa [publishedFarey, currentFarey] using
    (Exclusion.two_feedback
      (base := 1000000000)
      (delayUpper := 46499999999999999999)
      (delay := 2480)
      (classified := PublishedClassification)
      (first := publishedFarey)
      (second := currentFarey)
      (by norm_num : 4 ≤ 1000000000)
      h.finiteBase
      publishedFarey_valid
      (by
        intro x hx r
        exact Finite.firstExcursionEnvelope_kernel
          (x := x) (by simpa [publishedFarey] using hx) r)
      h.delayCap
      (by norm_num [publishedFarey] :
        2480 ≤
          (publishedFarey.a + publishedFarey.c) +
            (publishedFarey.b + publishedFarey.d))
      currentFarey_valid
      h.currentEnvelope
      hp)

/--
Conditional extension of Rozier--Terracol's start exclusion below the reported
2026 class-record coverage boundary.
-/
theorem no_paradoxical_start_through_current_coverage
    (h : CurrentDelayInputs) {n j : ℕ}
    (hlower : 4614 < n) (hupper : n ≤ 46499999999999999999) :
    ¬ Paradoxical n j := by
  intro hp
  by_cases hnbase : n ≤ 1000000000
  · have hclassified :=
      RecordBounds.FiniteBaseClassification.classify h.finiteBase hnbase hp
    exact (Nat.not_lt_of_ge hclassified.1) hlower
  · have hbeyond : 46499999999999999999 < n :=
      Exclusion.above_delay_coverage
        (base := 1000000000)
        (upper := 46499999999999999999)
        (delay := 2480)
        (cert := publishedFarey)
        (by norm_num : 4 ≤ 1000000000)
        publishedFarey_valid
        (by
          intro x hx r
          exact Finite.firstExcursionEnvelope_kernel
            (x := x) (by simpa [publishedFarey] using hx) r)
        h.delayCap
        (by norm_num [publishedFarey] :
          2480 ≤
            (publishedFarey.a + publishedFarey.c) +
              (publishedFarey.b + publishedFarey.d))
        (by omega)
        hp
    exact (Nat.not_lt_of_ge hupper) hbeyond

/--
The user's strict-endpoint target, conditional only on the two mathematical
inputs that remain in `CurrentDelayInputs`.  In particular, the first
accelerated excursion envelope is no longer a hypothesis.
-/
theorem target_exclusion_of_remaining_inputs
    (h : CurrentDelayInputs) {n j : ℕ}
    (hlower : 4614 < n) (hupper : n < 46500000000000000000) :
    ¬ Paradoxical n j := by
  exact no_paradoxical_start_through_current_coverage h hlower (by omega)

/-! ## Sharper first-feedback reduction -/

/--
The exact optimized envelope lowers the finite boundary needed by the current
delay argument from `10^9` to `785412368`.  The already checked prefix through
`26017` is supplied internally, so the only finite premise is the open-closed
gap `26017 < n ≤ 785412368` at lengths `j ≥ 35`.
The same delay premise restricts those cases to `j + oddCount n j < 2480`.
-/
theorem target_exclusion_of_optimized_inputs
    (h : OptimizedCurrentInputs) {n j : ℕ}
    (hlower : 4614 < n) (hupper : n < 46500000000000000000) :
    ¬ Paradoxical n j := by
  by_cases hnsmall : n ≤ 26017
  · exact Finite.no_paradoxical_start_4615_through_26017 hlower hnsmall
  by_cases hnbase : n ≤ 785412368
  · intro hp
    exact h.finiteGap (by omega) hnbase
      (AffineBound.paradoxical_length_at_least_35 (by omega) hp)
      (Exclusion.paradoxical_ordinary_length_lt_delay_cap
        (upper := 46499999999999999999) (delay := 2480)
        (by omega) (by omega) h.delayCap hp) hp
  · intro hp
    have hbeyond : 46499999999999999999 < n :=
      Exclusion.above_delay_coverage_of_at_least_threshold
        (threshold := 785412369)
        (upper := 46499999999999999999)
        (delay := 2480)
        (cert := optimizedFirstFarey)
        (by norm_num : 5 ≤ 785412369)
        optimizedFirstFarey_valid
        Finite.optimizedFirstExcursionEnvelope_kernel
        h.delayCap
        (by norm_num [optimizedFirstFarey] :
          2480 ≤
            (optimizedFirstFarey.a + optimizedFirstFarey.c) +
              (optimizedFirstFarey.b + optimizedFirstFarey.d))
        (by omega : 785412369 ≤ n)
        hp
    omega

end Certified

end Collatz
