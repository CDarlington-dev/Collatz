import Collatz.RecordBounds
import Collatz.ProductBound
import Collatz.Farey
import Mathlib.Tactic

/-!
# Deterministic record-bound feedback for paradoxical segments

This file isolates the mathematical implication behind the
Rozier--Terracol finite exclusion.  All record-table and finite-search inputs
occur as explicit propositions from `Collatz.RecordBounds`.  The remainder,
including the conversion of an accelerated prefix to an ordinary Collatz
prefix, is proved in Lean.
-/

namespace Collatz

namespace Exclusion

open RecordBounds

/-! ## Relating accelerated and ordinary prefixes -/

theorem iterate_Col_two_of_odd {n : ℕ} (hodd : n % 2 = 1) :
    iterate Col 2 n = T n := by
  have heven : (3 * n + 1) % 2 = 0 := by omega
  simp [iterate, Col, T, hodd, heven]

theorem iterate_Col_one_of_even {n : ℕ} (heven : n % 2 = 0) :
    iterate Col 1 n = T n := by
  simp [iterate, Col, T, heven]

/--
An accelerated prefix with `j` steps and `q` odd inputs is exactly an
ordinary Collatz prefix with `j + q` steps.
-/
theorem iterate_Col_add_oddCount (n j : ℕ) :
    iterate Col (j + oddCount n j) n = endpoint n j := by
  induction j generalizing n with
  | zero => simp
  | succ j ih =>
      by_cases heven : n % 2 = 0
      · have hnotodd : n % 2 ≠ 1 := by omega
        rw [oddCount_succ_apply, if_neg hnotodd, zero_add]
        rw [show j + 1 + oddCount (T n) j = 1 + (j + oddCount (T n) j) by omega]
        rw [iterate_add, iterate_Col_one_of_even heven, ih]
        rfl
      · have hodd : n % 2 = 1 := by omega
        rw [oddCount_succ_apply, if_pos hodd]
        rw [show j + 1 + (1 + oddCount (T n) j) =
            2 + (j + oddCount (T n) j) by omega]
        rw [iterate_add, iterate_Col_two_of_odd hodd, ih]
        rfl

/-- The ordinary orbit of each member of the `1,4,2` cycle stays at most `4`. -/
theorem iterate_Col_cycle_le_four (r : ℕ) :
    iterate Col r 1 ≤ 4 ∧
      iterate Col r 4 ≤ 4 ∧ iterate Col r 2 ≤ 4 := by
  induction r with
  | zero => simp
  | succ r ih =>
      rw [iterate_succ_apply, iterate_succ_apply, iterate_succ_apply]
      norm_num [Col]
      exact ⟨ih.2.1, ih.2.2, ih.1⟩

theorem iterate_Col_one_le_four (r : ℕ) : iterate Col r 1 ≤ 4 :=
  (iterate_Col_cycle_le_four r).1

/-- Once an ordinary Collatz prefix reaches `1`, every later endpoint is at most `4`. -/
theorem iterate_Col_le_four_of_reaches_one
    {n d L : ℕ} (hreach : iterate Col d n = 1) (hdL : d ≤ L) :
    iterate Col L n ≤ 4 := by
  calc
    iterate Col L n = iterate Col (d + (L - d)) n := by
      rw [Nat.add_sub_of_le hdL]
    _ = iterate Col (L - d) (iterate Col d n) := iterate_add d (L - d) n
    _ = iterate Col (L - d) 1 := by rw [hreach]
    _ ≤ 4 := iterate_Col_one_le_four (L - d)

/--
Below a verified ordinary-delay boundary, a paradoxical accelerated prefix
from a start above the terminal `1,4,2` cycle must use strictly fewer ordinary
steps than the delay cap.
-/
theorem paradoxical_ordinary_length_lt_delay_cap
    {upper delay n j : ℕ}
    (hnFive : 5 ≤ n) (hnUpper : n ≤ upper)
    (hdelay : ColDelayCap upper delay) (hp : Paradoxical n j) :
    j + oddCount n j < delay := by
  by_contra hnot
  have hdelayLength : delay ≤ j + oddCount n j := by omega
  obtain ⟨d, hd, hreach⟩ := hdelay (by omega) hnUpper
  have hdLength : d ≤ j + oddCount n j := hd.trans hdelayLength
  have hsmall : iterate Col (j + oddCount n j) n ≤ 4 :=
    iterate_Col_le_four_of_reaches_one hreach hdLength
  rw [iterate_Col_add_oddCount] at hsmall
  have hend : n ≤ endpoint n j := hp.start_le_endpoint
  omega

/-! ## Endpoint continuation and the exact Farey feedback -/

/--
If a segment starts above an excursion threshold and finishes no lower, every
input term of the segment is at least the envelope's first uncovered seed.
-/
theorem prefix_ge_seed_of_excursion_envelope
    {threshold seed n j : ℕ}
    (henvelope : AcceleratedExcursionEnvelope threshold seed)
    (hn : threshold < n) (hend : n ≤ endpoint n j) :
    ∀ k < j, seed ≤ endpoint n k := by
  intro k hk
  by_contra hseed
  have hkseed : endpoint n k < seed := by omega
  have hbelow : endpoint (endpoint n k) (j - k) < threshold :=
    henvelope hkseed (j - k)
  have hcontinue : endpoint (endpoint n k) (j - k) = endpoint n j := by
    rw [← endpoint_add, Nat.add_sub_of_le (Nat.le_of_lt hk)]
  rw [hcontinue] at hbelow
  omega

/--
Endpoint-sharp form of `prefix_ge_seed_of_excursion_envelope`: because the
envelope bound itself is strict, it is enough for the segment start to be at
least the threshold.
-/
theorem prefix_ge_seed_of_excursion_envelope_of_le
    {threshold seed n j : ℕ}
    (henvelope : AcceleratedExcursionEnvelope threshold seed)
    (hn : threshold ≤ n) (hend : n ≤ endpoint n j) :
    ∀ k < j, seed ≤ endpoint n k := by
  intro k hk
  by_contra hseed
  have hkseed : endpoint n k < seed := by omega
  have hbelow : endpoint (endpoint n k) (j - k) < threshold :=
    henvelope hkseed (j - k)
  have hcontinue : endpoint (endpoint n k) (j - k) = endpoint n j := by
    rw [← endpoint_add, Nat.add_sub_of_le (Nat.le_of_lt hk)]
  rw [hcontinue] at hbelow
  omega

/--
One excursion envelope and one valid exact Farey certificate force the
certificate's mediant lower bounds on both segment length and odd count.
-/
theorem farey_lower_bounds_of_above_threshold
    {threshold n j : ℕ} {cert : Farey.Certificate}
    (hcert : cert.Valid)
    (henvelope : AcceleratedExcursionEnvelope threshold cert.m)
    (hn : threshold < n) (hp : Paradoxical n j) :
    cert.a + cert.c ≤ j ∧ cert.b + cert.d ≤ oddCount n j := by
  apply cert.apply hcert hp.factor_lt_one
  exact paradoxical_power_necessary hp
    (prefix_ge_seed_of_excursion_envelope henvelope hn hp.start_le_endpoint)

/-- Farey lower bounds using the endpoint-sharp non-strict start boundary. -/
theorem farey_lower_bounds_of_at_least_threshold
    {threshold n j : ℕ} {cert : Farey.Certificate}
    (hcert : cert.Valid)
    (henvelope : AcceleratedExcursionEnvelope threshold cert.m)
    (hn : threshold ≤ n) (hp : Paradoxical n j) :
    cert.a + cert.c ≤ j ∧ cert.b + cert.d ≤ oddCount n j := by
  apply cert.apply hcert hp.factor_lt_one
  exact paradoxical_power_necessary hp
    (prefix_ge_seed_of_excursion_envelope_of_le
      henvelope hn hp.start_le_endpoint)

/-! ## The first feedback through an ordinary delay table -/

/--
The first excursion/Farey feedback makes the corresponding ordinary prefix at
least as long as the external delay cap.  Since the cap witnesses a visit to
`1` no later than that prefix, its endpoint is in the trivial cycle.
Consequently its start lies beyond the delay table's covered range.
-/
theorem above_delay_coverage
    {base upper delay n j : ℕ} {cert : Farey.Certificate}
    (hbaseFour : 4 ≤ base)
    (hcert : cert.Valid)
    (henvelope : AcceleratedExcursionEnvelope base cert.m)
    (hdelay : ColDelayCap upper delay)
    (hgap : delay ≤ (cert.a + cert.c) + (cert.b + cert.d))
    (hn : base < n) (hp : Paradoxical n j) :
    upper < n := by
  have hfarey := farey_lower_bounds_of_above_threshold
    hcert henvelope hn hp
  by_contra hnupper
  have hnupper' : n ≤ upper := by omega
  obtain ⟨d, hd, hreach⟩ := hdelay (by omega) hnupper'
  let L := j + oddCount n j
  have hminimumLength :
      (cert.a + cert.c) + (cert.b + cert.d) ≤ L := by
    dsimp [L]
    exact Nat.add_le_add hfarey.1 hfarey.2
  have hdelayL : delay ≤ L := hgap.trans hminimumLength
  have hdL : d ≤ L := le_trans hd hdelayL
  have hsmall : iterate Col L n ≤ 4 :=
    iterate_Col_le_four_of_reaches_one hreach hdL
  have hsame : iterate Col L n = endpoint n j := by
    dsimp [L]
    exact iterate_Col_add_oddCount n j
  rw [hsame] at hsmall
  have hend : n ≤ endpoint n j := hp.start_le_endpoint
  omega

/--
Endpoint-sharp delay feedback.  Here the finite side need cover only starts
strictly below `threshold`; a start equal to the threshold is already handled
by the strict excursion inequality.
-/
theorem above_delay_coverage_of_at_least_threshold
    {threshold upper delay n j : ℕ} {cert : Farey.Certificate}
    (hthresholdFive : 5 ≤ threshold)
    (hcert : cert.Valid)
    (henvelope : AcceleratedExcursionEnvelope threshold cert.m)
    (hdelay : ColDelayCap upper delay)
    (hgap : delay ≤ (cert.a + cert.c) + (cert.b + cert.d))
    (hn : threshold ≤ n) (hp : Paradoxical n j) :
    upper < n := by
  have hfarey := farey_lower_bounds_of_at_least_threshold
    hcert henvelope hn hp
  by_contra hnupper
  have hnupper' : n ≤ upper := by omega
  obtain ⟨d, hd, hreach⟩ := hdelay (by omega) hnupper'
  let L := j + oddCount n j
  have hminimumLength :
      (cert.a + cert.c) + (cert.b + cert.d) ≤ L := by
    dsimp [L]
    exact Nat.add_le_add hfarey.1 hfarey.2
  have hdelayL : delay ≤ L := hgap.trans hminimumLength
  have hdL : d ≤ L := le_trans hd hdelayL
  have hsmall : iterate Col L n ≤ 4 :=
    iterate_Col_le_four_of_reaches_one hreach hdL
  have hsame : iterate Col L n = endpoint n j := by
    dsimp [L]
    exact iterate_Col_add_oddCount n j
  rw [hsame] at hsmall
  have hend : n ≤ endpoint n j := hp.start_le_endpoint
  omega

/-! ## Complete two-feedback implication -/

/--
The deterministic two-feedback theorem.

For any paradoxical segment, either the exact finite classifier handles its
start, or the first excursion/Farey barrier plus the ordinary delay cap place
the start above `delayUpper`; at that point the second excursion/Farey barrier
gives its sharper lower bounds.  No record claim is built into the theorem:
all three external inputs are named hypotheses.
-/
theorem two_feedback
    {base delayUpper delay n j : ℕ}
    {classified : ℕ → ℕ → Prop}
    {first second : Farey.Certificate}
    (hbaseFour : 4 ≤ base)
    (hfinite : FiniteBaseClassification base classified)
    (hfirstValid : first.Valid)
    (hfirstEnvelope : AcceleratedExcursionEnvelope base first.m)
    (hdelay : ColDelayCap delayUpper delay)
    (hfirstGap : delay ≤
      (first.a + first.c) + (first.b + first.d))
    (hsecondValid : second.Valid)
    (hsecondEnvelope :
      AcceleratedExcursionEnvelope delayUpper second.m)
    (hp : Paradoxical n j) :
    classified n j ∨
      (delayUpper < n ∧
        second.a + second.c ≤ j ∧
        second.b + second.d ≤ oddCount n j) := by
  by_cases hnbase : n ≤ base
  · exact Or.inl (hfinite.classify hnbase hp)
  · have hnbase' : base < n := by omega
    have hnupper : delayUpper < n := above_delay_coverage
      hbaseFour hfirstValid hfirstEnvelope hdelay hfirstGap hnbase' hp
    have hsecond := farey_lower_bounds_of_above_threshold
      hsecondValid hsecondEnvelope hnupper hp
    exact Or.inr ⟨hnupper, hsecond.1, hsecond.2⟩

end Exclusion

end Collatz
