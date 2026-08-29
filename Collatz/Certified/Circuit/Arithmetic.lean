import Collatz.Map
import Mathlib.Tactic

/-!
# Width-generic accelerated-Collatz word semantics

Bits are least-significant first.  These proofs are structural in the bit list: they do not
enumerate all `2^w` words and therefore apply at production widths such as 64 bits.

The final theorem makes wrapping explicit.  `overflow w output = false` means every discarded
high bit is zero; only under that checked condition does truncation equal the natural-number
accelerated map `Collatz.T` rather than equality modulo `2^w`.
-/

namespace Collatz.Certified.Circuit.Bits

def bitNat : Bool → Nat
  | false => 0
  | true => 1

@[simp] theorem bitNat_false : bitNat false = 0 := rfl
@[simp] theorem bitNat_true : bitNat true = 1 := rfl

/-- Natural-number value of a little-endian bit list. -/
def value : List Bool → Nat
  | [] => 0
  | b :: bs => bitNat b + 2 * value bs

@[simp] theorem value_nil : value [] = 0 := rfl
@[simp] theorem value_cons (b : Bool) (bs : List Bool) :
    value (b :: bs) = bitNat b + 2 * value bs := rfl

def fullAdd (x y carry : Bool) : Bool × Bool :=
  (x ^^ y ^^ carry, (x && y) || (x && carry) || (y && carry))

theorem fullAdd_value (x y carry : Bool) :
    bitNat (fullAdd x y carry).1 + 2 * bitNat (fullAdd x y carry).2 =
      bitNat x + bitNat y + bitNat carry := by
  cases x <;> cases y <;> cases carry <;> decide

/-- Equal-width ripple addition, returning low bits and the final carry. -/
def rippleAdd : List Bool → List Bool → Bool → List Bool × Bool
  | [], [], carry => ([], carry)
  | x :: xs, y :: ys, carry =>
      let sc := fullAdd x y carry
      let rest := rippleAdd xs ys sc.2
      (sc.1 :: rest.1, rest.2)
  | _, _, carry => ([], carry)

theorem rippleAdd_length {xs ys : List Bool} (h : xs.length = ys.length) (carry : Bool) :
    (rippleAdd xs ys carry).1.length = xs.length := by
  induction xs generalizing ys carry with
  | nil =>
      cases ys with
      | nil => rfl
      | cons y ys => simp at h
  | cons x xs ih =>
      cases ys with
      | nil => simp at h
      | cons y ys =>
          have hlen : xs.length = ys.length := by simpa using h
          simp [rippleAdd, ih hlen]

theorem rippleAdd_value {xs ys : List Bool} (h : xs.length = ys.length) (carry : Bool) :
    value (rippleAdd xs ys carry).1 +
        2 ^ xs.length * bitNat (rippleAdd xs ys carry).2 =
      value xs + value ys + bitNat carry := by
  induction xs generalizing ys carry with
  | nil =>
      cases ys with
      | nil => simp [rippleAdd, value]
      | cons y ys => simp at h
  | cons x xs ih =>
      cases ys with
      | nil => simp at h
      | cons y ys =>
          have hlen : xs.length = ys.length := by simpa using h
          have hi := ih hlen (fullAdd x y carry).2
          have hf := fullAdd_value x y carry
          simp only [rippleAdd, value, List.length_cons, Nat.pow_succ]
          ring_nf at hi hf ⊢
          omega

def zeros (n : Nat) : List Bool := List.replicate n false

@[simp] theorem value_zeros (n : Nat) : value (zeros n) = 0 := by
  induction n with
  | zero => rfl
  | succ n ih => simpa [zeros, List.replicate_succ, value] using ih

theorem value_append_zeros (xs : List Bool) (n : Nat) :
    value (xs ++ zeros n) = value xs := by
  induction xs with
  | nil => simp
  | cons x xs ih => simp [value, ih]

@[simp] theorem value_append_false (xs : List Bool) : value (xs ++ [false]) = value xs := by
  simpa [zeros] using value_append_zeros xs 1

@[simp] theorem value_append_false_false (xs : List Bool) :
    value (xs ++ [false, false]) = value xs := by
  induction xs with
  | nil => rfl
  | cons b bs ih => simp [value, ih]

theorem value_shift (xs : List Bool) : value (false :: xs) = 2 * value xs := by
  simp [value]

/-- Add `x + 2*x + 1` at width `xs.length + 2`. -/
def threeXPlusOneBits (xs : List Bool) : List Bool × Bool :=
  let xpad := xs ++ [false, false]
  let shifted := false :: xs ++ [false]
  rippleAdd xpad shifted true

theorem threeXPlusOneBits_value (xs : List Bool) :
    value (threeXPlusOneBits xs).1 +
        2 ^ (xs.length + 2) * bitNat (threeXPlusOneBits xs).2 =
      3 * value xs + 1 := by
  have hlen : (xs ++ [false, false]).length = (false :: xs ++ [false]).length := by simp
  have h := rippleAdd_value hlen true
  simp only [threeXPlusOneBits, value_append_false_false, value_cons, bitNat_false,
    value_append_false, bitNat_true, Nat.zero_add, List.length_append, List.length_cons,
    List.length_nil, Nat.add_zero] at h ⊢
  ring_nf at h ⊢
  omega

theorem value_lt_pow_length (xs : List Bool) : value xs < 2 ^ xs.length := by
  induction xs with
  | nil => simp [value]
  | cons b bs ih =>
      cases b <;> simp only [value_cons, bitNat_false, bitNat_true, List.length_cons,
        Nat.pow_succ] <;> omega

theorem threeXPlusOneBits_no_high_carry (xs : List Bool) :
    (threeXPlusOneBits xs).2 = false := by
  have hv := threeXPlusOneBits_value xs
  have hbound := value_lt_pow_length xs
  have hp : 0 < 2 ^ xs.length := pow_pos (by omega) _
  have hpow : 2 ^ (xs.length + 2) = 4 * 2 ^ xs.length := by
    rw [pow_add]
    ring
  have hrhs : 3 * value xs + 1 < 2 ^ (xs.length + 2) := by
    rw [hpow]
    omega
  cases hc : (threeXPlusOneBits xs).2 with
  | false => rfl
  | true =>
      simp [hc] at hv
      omega

theorem threeXPlusOneBits_exact (xs : List Bool) :
    value (threeXPlusOneBits xs).1 = 3 * value xs + 1 := by
  have hv := threeXPlusOneBits_value xs
  rw [threeXPlusOneBits_no_high_carry] at hv
  simpa using hv

/-!
The odd branch below is the tail of the exact `3*x+1` word.  Consequently its value is
`(3*n+1)/2`.  This is the accelerated convention; the ordinary map's odd branch is `3*n+1`.
-/

theorem value_div_two (bs : List Bool) : value bs / 2 = value bs.tail := by
  cases bs with
  | nil => rfl
  | cons b bs =>
      cases b <;> simp [value, bitNat, Nat.add_mul_div_left]

/-- One exact accelerated step before output-width truncation. -/
def acceleratedBits (xs : List Bool) : List Bool :=
  match xs with
  | [] => []
  | odd :: _ =>
      if odd then (threeXPlusOneBits xs).1.tail
      else xs.tail ++ [false, false]

theorem acceleratedBits_value (xs : List Bool) :
    value (acceleratedBits xs) = Collatz.T (value xs) := by
  cases xs with
  | nil => simp [acceleratedBits, value, Collatz.T]
  | cons odd xs =>
      cases odd with
      | false =>
          simp [acceleratedBits, value, Collatz.T]
      | true =>
          simp [acceleratedBits]
          rw [← value_div_two, threeXPlusOneBits_exact]
          simp [value, Collatz.T]

/-- Exact truncation identity for little-endian words. -/
theorem value_take_add_drop (bs : List Bool) (w : Nat) :
    value (bs.take w) + 2 ^ w * value (bs.drop w) = value bs := by
  induction w generalizing bs with
  | zero => simp [value]
  | succ w ih =>
      cases bs with
      | nil => simp [value]
      | cons b bs =>
          simp only [List.take_succ_cons, List.drop_succ_cons, value_cons, Nat.pow_succ]
          have h := ih bs
          ring_nf at h ⊢
          omega

/-- True exactly when a high bit discarded above width `w` is set. -/
def overflow (w : Nat) (bs : List Bool) : Bool :=
  (bs.drop w).any fun b => b

theorem value_eq_zero_of_any_eq_false (bs : List Bool)
    (h : (bs.any fun b => b) = false) : value bs = 0 := by
  induction bs with
  | nil => rfl
  | cons b bs ih =>
      cases b with
      | false =>
          change (bs.any fun b => b) = false at h
          simp [value, ih h]
      | true =>
          change (true || (bs.any fun b => b)) = false at h
          simp at h

def fixedWidthAcceleratedBits (w : Nat) (xs : List Bool) : List Bool :=
  (acceleratedBits xs).take w

/-!
Exact no-wrap bridge.  When every discarded high bit is zero, the truncated output is equal in
`Nat` to `Collatz.T`; this is not merely a congruence modulo `2^w`.
-/
theorem fixedWidthAcceleratedBits_value_of_no_overflow (w : Nat) (xs : List Bool)
    (hno : overflow w (acceleratedBits xs) = false) :
    value (fixedWidthAcceleratedBits w xs) = Collatz.T (value xs) := by
  have hzero : value ((acceleratedBits xs).drop w) = 0 :=
    value_eq_zero_of_any_eq_false _ hno
  have hsplit := value_take_add_drop (acceleratedBits xs) w
  rw [hzero, Nat.mul_zero, Nat.add_zero] at hsplit
  rw [fixedWidthAcceleratedBits, hsplit, acceleratedBits_value]

end Collatz.Certified.Circuit.Bits
