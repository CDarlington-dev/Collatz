import Collatz.Certified.Published
import Collatz.Certified.Finite.NoParadoxicalRange
import Mathlib.Tactic

/-!
Pure-kernel checker for the complete classification through start `4614`.

The checker walks each trajectory once.  A prefix is accepted if it is not
paradoxical, or if its `(start,length)` pair occurs in the literal 593-row
published table.  Fuel exhaustion fails closed unless the orbit has entered
`{0,1,2}`.  All concrete acceptance theorems use ordinary `decide`.
-/

namespace Collatz.Certified.Finite

open Collatz.Certified

/-- Boolean membership in the exact `(n,j)` projection of the published table. -/
def publishedPairCheck (n j : ℕ) : Bool :=
  decide (∃ w ∈ publishedWitnesses, w.n = n ∧ w.j = j)

theorem publishedPairCheck_iff {n j : ℕ} :
    publishedPairCheck n j = true ↔
      ∃ w ∈ publishedWitnesses, w.n = n ∧ w.j = j := by
  simp only [publishedPairCheck, decide_eq_true_eq]

/-- All semantic facts expected of a literal published row. -/
def publishedWitnessKernelCheck (w : PublishedWitness) : Bool :=
  decide (
    w.n ≤ 4614 ∧ w.j ≤ 92 ∧
      oddCount w.n w.j = w.q ∧ Paradoxical w.n w.j)

theorem publishedWitnessKernelCheck_sound {w : PublishedWitness}
    (h : publishedWitnessKernelCheck w = true) :
    w.n ≤ 4614 ∧ w.j ≤ 92 ∧
      oddCount w.n w.j = w.q ∧ Paradoxical w.n w.j := by
  simpa only [publishedWitnessKernelCheck, decide_eq_true_eq] using h

/- This replaces the existing `native_decide` row check with kernel reduction. -/
set_option maxRecDepth 100000 in
set_option maxHeartbeats 0 in
theorem every_published_witness_checks_kernel :
    publishedWitnesses.all publishedWitnessKernelCheck = true := by
  decide

theorem publishedPairCheck_paradoxical {n j : ℕ}
    (hpair : publishedPairCheck n j = true) : Paradoxical n j := by
  obtain ⟨w, hwmem, hwn, hwj⟩ := publishedPairCheck_iff.mp hpair
  have hall : ∀ x, x ∈ publishedWitnesses →
      publishedWitnessKernelCheck x = true := by
    simpa only [List.all_eq_true] using every_published_witness_checks_kernel
  have hw := (publishedWitnessKernelCheck_sound (hall w hwmem)).2.2.2
  simpa only [hwn, hwj] using hw

theorem publishedPairCheck_bounds {n j : ℕ}
    (hpair : publishedPairCheck n j = true) : n ≤ 4614 ∧ j ≤ 92 := by
  obtain ⟨w, hwmem, hwn, hwj⟩ := publishedPairCheck_iff.mp hpair
  have hall : ∀ x, x ∈ publishedWitnesses →
      publishedWitnessKernelCheck x = true := by
    simpa only [List.all_eq_true] using every_published_witness_checks_kernel
  have hw := publishedWitnessKernelCheck_sound (hall w hwmem)
  constructor
  · simpa only [hwn] using hw.1
  · simpa only [hwj] using hw.2.1

/-- Dependency-light spelling of the production `PublishedClassification` predicate. -/
def PublishedClassificationUpTo4614 (n j : ℕ) : Prop :=
  n ≤ 4614 ∧ j ≤ 92 ∧
    ∃ w ∈ publishedWitnesses, w.n = n ∧ w.j = j

/--
Incremental classification scan.  The accumulated state has the same meaning
as `NoParadoxicalRange.noParadoxicalScanAux`.  The table lookup is behind a
short-circuiting `||`, so it is evaluated only at genuinely paradoxical
prefixes.
-/
def classificationScanAux (start : ℕ) :
    ℕ → ℕ → ℕ → ℕ → ℕ → ℕ → Bool
  | 0, current, _, _, _, _ => decide (current ≤ 2)
  | fuel + 1, current, length, odds, powTwo, powThree =>
      if current ≤ 2 then true
      else
        (decide (¬ (
          powThree * oddPowerMultiplier current < 2 * powTwo ∧
            start ≤ T current)) || publishedPairCheck start (length + 1)) &&
          classificationScanAux start fuel (T current) (length + 1)
            (odds + oddIncrement current) (2 * powTwo)
            (powThree * oddPowerMultiplier current)

def classificationStartCheck (fuel start : ℕ) : Bool :=
  classificationScanAux start fuel start 0 0 1 1

/-- The terminal set `{0,1,2}` is closed under one accelerated step. -/
theorem T_le_two_of_le_two {x : ℕ} (hx : x ≤ 2) : T x ≤ 2 := by
  interval_cases x <;> decide

/-- Every future endpoint from a state at most `2` is still at most `2`. -/
theorem endpoint_le_two_of_le_two {x : ℕ} (hx : x ≤ 2) (r : ℕ) :
    endpoint x r ≤ 2 := by
  induction r with
  | zero => simpa using hx
  | succ r ih =>
      rw [endpoint_succ]
      exact T_le_two_of_le_two ih

/-- Soundness of an accepted accumulated scan. -/
theorem classificationScanAux_sound
    {start fuel current length odds powTwo powThree : ℕ}
    (hcurrent : current = endpoint start length)
    (hodds : odds = oddCount start length)
    (hpowTwo : powTwo = 2 ^ length)
    (hpowThree : powThree = 3 ^ odds)
    (hcheck :
      classificationScanAux start fuel current length odds powTwo powThree = true) :
    ∃ d, length ≤ d ∧ d ≤ length + fuel ∧ endpoint start d ≤ 2 ∧
      ∀ r, length < r → r ≤ d →
        (3 ^ oddCount start r < 2 ^ r ∧ start ≤ endpoint start r) →
          publishedPairCheck start r = true := by
  induction fuel generalizing current length odds powTwo powThree with
  | zero =>
      have hterminal : current ≤ 2 := by
        change decide (current ≤ 2) = true at hcheck
        exact of_decide_eq_true hcheck
      refine ⟨length, Nat.le_refl _, by omega, ?_, ?_⟩
      · simpa [← hcurrent] using hterminal
      · intro r hlr hrd
        omega
  | succ fuel ih =>
      by_cases hterminal : current ≤ 2
      · refine ⟨length, Nat.le_refl _, by omega, ?_, ?_⟩
        · simpa [← hcurrent] using hterminal
        · intro r hlr hrd
          omega
      · have hparts :
            ((2 * powTwo ≤ powThree * oddPowerMultiplier current ∨
                T current < start) ∨
              publishedPairCheck start (length + 1) = true) ∧
              classificationScanAux start fuel (T current) (length + 1)
                (odds + oddIncrement current) (2 * powTwo)
                (powThree * oddPowerMultiplier current) = true := by
          rw [classificationScanAux, if_neg hterminal] at hcheck
          have hand := Bool.and_eq_true_iff.mp hcheck
          have hcover := Bool.or_eq_true_iff.mp hand.1
          refine ⟨?_, hand.2⟩
          rcases hcover with hsafe | hmember
          · left
            have hsafe' : ¬ (
                powThree * oddPowerMultiplier current < 2 * powTwo ∧
                  start ≤ T current) := of_decide_eq_true hsafe
            omega
          · exact Or.inr hmember
        have hcurrent' : T current = endpoint start (length + 1) := by
          calc
            T current = T (endpoint start length) := by rw [← hcurrent]
            _ = endpoint start (length + 1) := (endpoint_succ start length).symm
        have hodds' :
            odds + oddIncrement current = oddCount start (length + 1) := by
          calc
            odds + oddIncrement current =
                oddCount start length +
                  (if endpoint start length % 2 = 1 then 1 else 0) := by
              simp [oddIncrement, hodds, hcurrent]
            _ = oddCount start (length + 1) :=
              (oddCount_succ start length).symm
        have hpowTwo' : 2 * powTwo = 2 ^ (length + 1) := by
          rw [hpowTwo, pow_succ]
          ring
        have hpowThree' :
            powThree * oddPowerMultiplier current =
              3 ^ (odds + oddIncrement current) := by
          by_cases hodd : current % 2 = 1
          · simp [oddPowerMultiplier, oddIncrement, hodd, hpowThree, pow_succ,
              Nat.mul_comm]
          · simp [oddPowerMultiplier, oddIncrement, hodd, hpowThree]
        have hfirst :
            (3 ^ oddCount start (length + 1) < 2 ^ (length + 1) ∧
              start ≤ endpoint start (length + 1)) →
              publishedPairCheck start (length + 1) = true := by
          intro hbad
          have hbad' :
              powThree * oddPowerMultiplier current < 2 * powTwo ∧
                start ≤ T current := by
            simpa [hpowThree', hpowTwo', hodds', hcurrent'] using hbad
          rcases hparts.1 with (hsafe | hmember)
          · rcases hsafe with hfactor | hendpoint <;> omega
          · exact hmember
        obtain ⟨d, hlength, hdfuel, hend, hcovered⟩ :=
          ih hcurrent' hodds' hpowTwo' hpowThree' hparts.2
        refine ⟨d, by omega, by omega, hend, ?_⟩
        intro r hlr hrd hbad
        by_cases hr : r = length + 1
        · rw [hr] at hbad ⊢
          exact hfirst hbad
        · exact hcovered r (by omega) hrd hbad

/-- Any paradoxical prefix of an accepted start occurs in the literal table. -/
theorem classificationStartCheck_sound
    {fuel start : ℕ} (hstart : 2 < start)
    (hcheck : classificationStartCheck fuel start = true)
    {j : ℕ} (hp : Paradoxical start j) :
    publishedPairCheck start j = true := by
  obtain ⟨d, _hdnonneg, hdfuel, hterminal, hcovered⟩ :=
    classificationScanAux_sound
      (start := start) (fuel := fuel) (current := start) (length := 0) (odds := 0)
      (powTwo := 1) (powThree := 1)
      (by simp [endpoint]) (by simp) (by norm_num) (by norm_num) hcheck
  by_cases hjd : j ≤ d
  · exact hcovered j hp.length_pos hjd
      ⟨hp.factor_lt_one, hp.start_le_endpoint⟩
  · have hdj : d ≤ j := by omega
    have hjadd : d + (j - d) = j := Nat.add_sub_of_le hdj
    have hend : endpoint start j = endpoint (endpoint start d) (j - d) := by
      calc
        endpoint start j = endpoint start (d + (j - d)) := by rw [hjadd]
        _ = endpoint (endpoint start d) (j - d) := endpoint_add start d (j - d)
    have htail : endpoint start j ≤ 2 := by
      rw [hend]
      exact endpoint_le_two_of_le_two hterminal (j - d)
    exfalso
    have hnend := hp.start_le_endpoint
    omega

/-- Check `count` consecutive starts beginning at `lo`. -/
def classificationIntervalCheck (fuel lo count : ℕ) : Bool :=
  (List.range count).all fun i => classificationStartCheck fuel (lo + i)

theorem classificationIntervalCheck_sound
    {fuel lo count n j : ℕ}
    (hcheck : classificationIntervalCheck fuel lo count = true)
    (hnlo : lo ≤ n) (hnhi : n < lo + count) (hnstart : 2 < n)
    (hp : Paradoxical n j) :
    publishedPairCheck n j = true := by
  have hall : ∀ i, i ∈ List.range count →
      classificationStartCheck fuel (lo + i) = true := by
    simpa [classificationIntervalCheck] using hcheck
  let i := n - lo
  have hi : i < count := by
    dsimp [i]
    omega
  have himem : i ∈ List.range count := by simpa using hi
  have hsum : lo + i = n := by
    dsimp [i]
    omega
  apply classificationStartCheck_sound hnstart
  · simpa [hsum] using hall i himem
  · exact hp

/-- Production-sized block: 100 starts, beginning at `3`, with fuel `150`. -/
def baseClassificationBlockCheck (block : ℕ) : Bool :=
  classificationIntervalCheck 150 (3 + 100 * block) 100

/-- The 47 blocks cover starts `3,...,4702`, hence all starts through `4614`. -/
def baseClassificationAllBlocksCheck : Bool :=
  (List.range 47).all baseClassificationBlockCheck

theorem baseClassificationAllBlocksCheck_sound
    (hcheck : baseClassificationAllBlocksCheck = true)
    {n j : ℕ} (hnhi : n ≤ 4614) (hp : Paradoxical n j) :
    publishedPairCheck n j = true := by
  have hall : ∀ b, b ∈ List.range 47 → baseClassificationBlockCheck b = true := by
    simpa only [baseClassificationAllBlocksCheck, List.all_eq_true] using hcheck
  have hnlo : 3 ≤ n := hp.start_gt_two
  let x := n - 3
  let b := x / 100
  let t := x % 100
  have hx : 3 + x = n := by
    dsimp [x]
    omega
  have hxlt : x < 4700 := by
    dsimp [x]
    omega
  have hb : b < 47 := by
    dsimp [b]
    exact (Nat.div_lt_iff_lt_mul (by norm_num : 0 < 100)).2 (by omega)
  have ht : t < 100 := by
    dsimp [t]
    exact Nat.mod_lt _ (by norm_num)
  have hdecomp : t + 100 * b = x := by
    simpa only [t, b] using Nat.mod_add_div x 100
  have hbmem : b ∈ List.range 47 := by simpa only [List.mem_range] using hb
  have hbcheck := hall b hbmem
  have hblo : 3 + 100 * b ≤ n := by omega
  have hbhi : n < (3 + 100 * b) + 100 := by omega
  exact classificationIntervalCheck_sound
    (by simpa only [baseClassificationBlockCheck] using hbcheck)
    hblo hbhi (by omega) hp

/--
The complete theorem follows from one concrete Boolean acceptance fact.  The
remaining theorem `baseClassificationAllBlocksCheck = true` is assembled from
47 independent ordinary-`decide` block modules.
-/
theorem finiteBaseClassification_4614_of_check
    (hcheck : baseClassificationAllBlocksCheck = true) :
    RecordBounds.FiniteBaseClassification 4614 PublishedClassificationUpTo4614 := by
  intro n j hn
  constructor
  · intro hp
    have hpair := baseClassificationAllBlocksCheck_sound hcheck hn hp
    exact ⟨hn, (publishedPairCheck_bounds hpair).2,
      publishedPairCheck_iff.mp hpair⟩
  · intro hpublished
    exact publishedPairCheck_paradoxical
      (publishedPairCheck_iff.mpr hpublished.2.2)

end Collatz.Certified.Finite
