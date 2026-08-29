import Collatz.RecordBounds
import Mathlib.Tactic

/-!
# Exact finite-classification certificate primitives

This file supplies the arithmetic kernel for a proof-producing version of the
odd-core/lattice scan used by `tools/odd_core_scan.py`.  It does **not** assert
coverage through `10^9`: it proves that an accepted cell has exactly the
meaning assigned to it by the scanner.

Every positive start has the form `2^a * u` with `u` odd.  The first `a`
accelerated steps are even halvings; all later segment data are therefore data
from the orbit of `u`, with `a` added to the segment length.  A scanner cell
stores a core prefix of length `s+t`, its odd count `q`, and the exact scaled
endpoint `y = 2^t * T^(s+t)(u)`.  The endpoint comparison is then the integer
lattice inequality

`2^(a+t) * u <= y`.

No hash or unchecked output occurs in the soundness theorem below.  The small
example at the end is discharged by ordinary kernel reduction (`decide`).
-/

namespace Collatz

namespace Certified

namespace Finite

/-! ## Removing and restoring the initial power of two -/

@[simp] theorem T_two_mul (n : ℕ) : T (2 * n) = n := by
  simp [T]

/-- `a` initial accelerated steps remove the factor `2^a`. -/
theorem endpoint_two_pow_mul (u a : ℕ) :
    endpoint (2 ^ a * u) a = u := by
  induction a with
  | zero => simp
  | succ a ih =>
      rw [pow_succ]
      have hmul : 2 ^ a * 2 * u = 2 * (2 ^ a * u) := by ring
      rw [hmul, endpoint_succ_apply, T_two_mul]
      exact ih

/-- Those initial `a` steps contain no odd inputs. -/
theorem oddCount_two_pow_mul (u a : ℕ) :
    oddCount (2 ^ a * u) a = 0 := by
  induction a with
  | zero => simp
  | succ a ih =>
      rw [pow_succ]
      have hmul : 2 ^ a * 2 * u = 2 * (2 ^ a * u) := by ring
      rw [hmul, oddCount_succ_apply]
      simp [ih]

/-- After the initial halvings, endpoints are exactly core endpoints. -/
theorem endpoint_two_pow_mul_add (u a k : ℕ) :
    endpoint (2 ^ a * u) (a + k) = endpoint u k := by
  rw [endpoint_add, endpoint_two_pow_mul]

/-- After the initial halvings, odd counts are exactly core odd counts. -/
theorem oddCount_two_pow_mul_add (u a k : ℕ) :
    oddCount (2 ^ a * u) (a + k) = oddCount u k := by
  rw [oddCount_add, oddCount_two_pow_mul, endpoint_two_pow_mul]
  simp

/-- An intermediate initial-halving endpoint, before the odd core is reached. -/
theorem endpoint_two_pow_mul_of_le {u a j : ℕ} (hj : j ≤ a) :
    endpoint (2 ^ a * u) j = 2 ^ (a - j) * u := by
  have ha : j + (a - j) = a := Nat.add_sub_of_le hj
  have hn : 2 ^ a * u = 2 ^ j * (2 ^ (a - j) * u) := by
    calc
      2 ^ a * u = 2 ^ (j + (a - j)) * u := by rw [ha]
      _ = 2 ^ j * (2 ^ (a - j) * u) := by rw [pow_add]; ac_rfl
  calc
    endpoint (2 ^ a * u) j =
        endpoint (2 ^ j * (2 ^ (a - j) * u)) j :=
      congrArg (fun n => endpoint n j) hn
    _ = 2 ^ (a - j) * u := endpoint_two_pow_mul _ _

/-- A nonempty proper part of the initial halving run ends below its start. -/
theorem endpoint_two_pow_mul_lt {u a j : ℕ}
    (hu : 0 < u) (hj : 0 < j) (hja : j ≤ a) :
    endpoint (2 ^ a * u) j < 2 ^ a * u := by
  have ha : j + (a - j) = a := Nat.add_sub_of_le hja
  let r := 2 ^ (a - j) * u
  have hr : 0 < r := Nat.mul_pos (Nat.pow_pos (by omega)) hu
  have hp : 1 < 2 ^ j := by
    exact one_lt_pow' (by omega) (Nat.ne_of_gt hj)
  have hlt : r < 2 ^ j * r := by
    rw [Nat.mul_comm]
    exact (Nat.lt_mul_iff_one_lt_right hr).2 hp
  have hn : 2 ^ a * u = 2 ^ j * r := by
    dsimp [r]
    calc
      2 ^ a * u = 2 ^ (j + (a - j)) * u := by rw [ha]
      _ = 2 ^ j * (2 ^ (a - j) * u) := by rw [pow_add]; ac_rfl
  calc
    endpoint (2 ^ a * u) j = r := by
      simpa [r] using endpoint_two_pow_mul_of_le (u := u) hja
    _ < 2 ^ j * r := hlt
    _ = 2 ^ a * u := hn.symm

/-! ## One exact odd-core/lattice cell -/

/--
One proof-producing cell from an odd-core scan.

`offset + width` is the core-prefix length.  `numerator` is not trusted: the
Boolean checker below verifies that it is exactly `2^width` times the actual
core endpoint.  For an odd-to-odd block, `offset` is the number of accelerated
steps before the block and `width` is the substep inside that block.
-/
structure ScaledPrefixCell where
  core : ℕ
  exponent : ℕ
  offset : ℕ
  width : ℕ
  odds : ℕ
  numerator : ℕ
deriving DecidableEq, Repr

namespace ScaledPrefixCell

def start (c : ScaledPrefixCell) : ℕ := 2 ^ c.exponent * c.core

def coreLength (c : ScaledPrefixCell) : ℕ := c.offset + c.width

def length (c : ScaledPrefixCell) : ℕ := c.exponent + c.coreLength

/--
The exact integer inequalities used by the lattice scanner for this cell.
-/
def LatticeCondition (c : ScaledPrefixCell) : Prop :=
  2 < c.start ∧
    0 < c.length ∧
    3 ^ c.odds < 2 ^ c.length ∧
    2 ^ (c.exponent + c.width) * c.core ≤ c.numerator

instance (c : ScaledPrefixCell) : Decidable c.LatticeCondition := by
  unfold LatticeCondition
  infer_instance

/--
The untrusted fields of a cell are accepted only if recomputation agrees with
Lean's `endpoint` and `oddCount` definitions.
-/
def check (c : ScaledPrefixCell) : Bool :=
  decide (
    0 < c.core ∧
      oddCount c.core c.coreLength = c.odds ∧
      c.numerator = 2 ^ c.width * endpoint c.core c.coreLength)

theorem check_sound {c : ScaledPrefixCell} (h : c.check = true) :
    0 < c.core ∧
      oddCount c.core c.coreLength = c.odds ∧
      c.numerator = 2 ^ c.width * endpoint c.core c.coreLength := by
  simpa [check] using h

/-- Exact cancellation behind the scanner's endpoint lattice inequality. -/
theorem start_le_endpoint_iff_lattice {c : ScaledPrefixCell}
    (hnumer : c.numerator = 2 ^ c.width * endpoint c.core c.coreLength) :
    c.start ≤ endpoint c.core c.coreLength ↔
      2 ^ (c.exponent + c.width) * c.core ≤ c.numerator := by
  rw [hnumer]
  change 2 ^ c.exponent * c.core ≤ endpoint c.core c.coreLength ↔
    2 ^ (c.exponent + c.width) * c.core ≤
      2 ^ c.width * endpoint c.core c.coreLength
  rw [pow_add]
  have hpow : 0 < 2 ^ c.width := Nat.pow_pos (by omega)
  constructor
  · intro h
    have hm := Nat.mul_le_mul_left (2 ^ c.width) h
    simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using hm
  · intro h
    have hm :
        2 ^ c.width * (2 ^ c.exponent * c.core) ≤
          2 ^ c.width * endpoint c.core c.coreLength := by
      simpa [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using h
    exact Nat.le_of_mul_le_mul_left hm hpow

/--
Soundness of one accepted odd-core/lattice cell.  This is the bridge a
certificate importer uses: after `check` succeeds, the four integer tests in
`LatticeCondition` are equivalent to the project's authoritative
`Paradoxical` predicate.
-/
theorem paradoxical_iff_lattice {c : ScaledPrefixCell} (h : c.check = true) :
    Paradoxical c.start c.length ↔ c.LatticeCondition := by
  obtain ⟨_corePos, hodds, hnumer⟩ := check_sound h
  rw [paradoxical_iff]
  have hend : endpoint c.start c.length = endpoint c.core c.coreLength := by
    exact endpoint_two_pow_mul_add c.core c.exponent c.coreLength
  have hcount : oddCount c.start c.length = oddCount c.core c.coreLength := by
    exact oddCount_two_pow_mul_add c.core c.exponent c.coreLength
  rw [hend, hcount, hodds, start_le_endpoint_iff_lattice hnumer]
  rfl

end ScaledPrefixCell

/-! ## Exact coverage of the scanner's `(z,a)` loop -/

/-- The pair of bounds used by the scanner for a fixed `z = a + t`. -/
def scannerCellBounds (maxExponent valuation z exponent : ℕ) : Prop :=
  max 0 (z - valuation) ≤ exponent ∧
    exponent ≤ min maxExponent (z - 1)

instance (maxExponent valuation z exponent : ℕ) :
    Decidable (scannerCellBounds maxExponent valuation z exponent) := by
  unfold scannerCellBounds
  infer_instance

/--
The scanner bounds enumerate exactly the scale/substep lattice points
`0 <= a <= maxExponent`, `1 <= t <= valuation`, `z = a+t`.
-/
theorem scannerCellBounds_iff
    {maxExponent valuation z exponent : ℕ}
    (_hvaluation : 0 < valuation) (hz : 0 < z) :
    scannerCellBounds maxExponent valuation z exponent ↔
      exponent ≤ maxExponent ∧
        ∃ t, 1 ≤ t ∧ t ≤ valuation ∧ z = exponent + t := by
  unfold scannerCellBounds
  simp only [max_eq_right (Nat.zero_le _), le_min_iff,
    Nat.le_sub_one_iff_lt hz]
  constructor
  · rintro ⟨hlow, hmax, hltz⟩
    have haez : exponent ≤ z := Nat.le_of_lt hltz
    have hadd : exponent + (z - exponent) = z := Nat.add_sub_of_le haez
    refine ⟨hmax, z - exponent, ?_, ?_, hadd.symm⟩
    · omega
    · by_cases hvz : valuation ≤ z
      · have hsub : z - valuation + valuation = z := Nat.sub_add_cancel hvz
        omega
      · have hzv : z ≤ valuation := Nat.le_of_not_ge hvz
        exact (Nat.sub_le z exponent).trans hzv
  · rintro ⟨hmax, t, htpos, htval, rfl⟩
    refine ⟨?_, hmax, ?_⟩
    · omega
    · omega

/-! ## A complete, sharply scoped ordinary-kernel classification -/

/-- Both states in the accelerated terminal cycle stay at most `2`. -/
theorem endpoint_one_two_cycle_le_two_for_classification (r : ℕ) :
    endpoint 1 r ≤ 2 ∧ endpoint 2 r ≤ 2 := by
  induction r with
  | zero => norm_num [endpoint]
  | succ r ih =>
      rw [endpoint_succ_apply, endpoint_succ_apply]
      norm_num [T]
      exact ⟨ih.2, ih.1⟩

/--
Once a start greater than `2` has reached `1`, no later endpoint can make a
paradoxical segment.
-/
theorem not_paradoxical_after_reaching_one
    {n d j : ℕ} (hn : 2 < n) (hone : endpoint n d = 1) (hdj : d ≤ j) :
    ¬ Paradoxical n j := by
  intro hp
  have hjadd : d + (j - d) = j := Nat.add_sub_of_le hdj
  have hend : endpoint n j = endpoint 1 (j - d) := by
    calc
      endpoint n j = endpoint n (d + (j - d)) := by rw [hjadd]
      _ = endpoint (endpoint n d) (j - d) := endpoint_add n d (j - d)
      _ = endpoint 1 (j - d) := by rw [hone]
  have hcycle : endpoint 1 (j - d) ≤ 2 :=
    (endpoint_one_two_cycle_le_two_for_classification (j - d)).1
  have hnend := hp.start_le_endpoint
  rw [hend] at hnend
  omega

/-- A finite prefix check plus an exact visit to `1` excludes all lengths. -/
theorem no_paradoxical_of_checked_prefix
    {n d : ℕ} (hn : 2 < n) (hone : endpoint n d = 1)
    (hprefix : ∀ j ≤ d, ¬ Paradoxical n j) :
    ∀ j, ¬ Paradoxical n j := by
  intro j
  by_cases hj : j ≤ d
  · exact hprefix j hj
  · exact not_paradoxical_after_reaching_one hn hone (by omega)

theorem no_paradoxical_start_three (j : ℕ) : ¬ Paradoxical 3 j := by
  apply no_paradoxical_of_checked_prefix (d := 5) (by norm_num) (by decide)
  intro k hk
  interval_cases k <;> decide

theorem no_paradoxical_start_four (j : ℕ) : ¬ Paradoxical 4 j := by
  apply no_paradoxical_of_checked_prefix (d := 2) (by norm_num) (by decide)
  intro k hk
  interval_cases k <;> decide

theorem no_paradoxical_start_five (j : ℕ) : ¬ Paradoxical 5 j := by
  apply no_paradoxical_of_checked_prefix (d := 4) (by norm_num) (by decide)
  intro k hk
  interval_cases k <;> decide

theorem no_paradoxical_start_six (j : ℕ) : ¬ Paradoxical 6 j := by
  apply no_paradoxical_of_checked_prefix (d := 6) (by norm_num) (by decide)
  intro k hk
  interval_cases k <;> decide

/-- The exact (empty) classification predicate through start `6`. -/
def EmptyClassification (_n _j : ℕ) : Prop := False

/--
A complete pure-kernel finite theorem: starts `0,...,6`, at every length, have
no paradoxical segments.  The bound is sharp because start `7` is certified
below.
-/
theorem finiteBaseClassification_six :
    RecordBounds.FiniteBaseClassification 6 EmptyClassification := by
  intro n j hn
  constructor
  · intro hp
    have hnlow : 3 ≤ n := hp.start_gt_two
    have hnot : ¬ Paradoxical n j := by
      interval_cases n
      · exact no_paradoxical_start_three j
      · exact no_paradoxical_start_four j
      · exact no_paradoxical_start_five j
      · exact no_paradoxical_start_six j
    exact (hnot hp).elim
  · intro h
    exact False.elim h

/-! ## Small ordinary-kernel cell replay -/

/--
The published `(n,j,q,T^j(n)) = (7,8,5,8)` row in the same final-block
coordinates emitted by the odd-core scanner: seven completed accelerated
steps followed by substep one of the final odd block.
-/
def cell7x8 : ScaledPrefixCell where
  core := 7
  exponent := 0
  offset := 7
  width := 1
  odds := 5
  numerator := 16

theorem cell7x8_check : cell7x8.check = true := by
  decide

theorem cell7x8_lattice : cell7x8.LatticeCondition := by
  decide

/-- Kernel-checked reproduction of the row through the generic checker lemma. -/
theorem cell7x8_paradoxical : Paradoxical cell7x8.start cell7x8.length :=
  (ScaledPrefixCell.paradoxical_iff_lattice cell7x8_check).2 cell7x8_lattice

/-- The complete bound `6` above is the largest empty initial classification. -/
theorem finiteBaseClassification_six_is_sharp : Paradoxical 7 8 := by
  simpa [cell7x8, ScaledPrefixCell.start, ScaledPrefixCell.length,
    ScaledPrefixCell.coreLength] using cell7x8_paradoxical

end Finite

end Certified

end Collatz
