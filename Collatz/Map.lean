import Mathlib.Data.Nat.Basic
import Mathlib.Logic.Function.Iterate
import Lean.Elab.Tactic.Omega
import Lean.Elab.Tactic.Decide

/-!
# The Collatz maps

This file fixes the conventions used throughout the development.  `T` is the
accelerated map used by Rozier--Terracol: an odd step includes the first
division by two.  `Col` is the usual, unaccelerated Collatz map.
-/

namespace Collatz

/-- The usual (unaccelerated) Collatz map. -/
def Col (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-- The accelerated Collatz map: both branches contain one division by two. -/
def T (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else (3 * n + 1) / 2

/-- Exact finite iteration, with `iterate f j n = f^[j](n)`. -/
def iterate {α : Type*} (f : α → α) : ℕ → α → α
  | 0, n => n
  | j + 1, n => iterate f j (f n)

@[simp] theorem iterate_zero {f : α → α} (n : α) : iterate f 0 n = n := rfl

@[simp] theorem iterate_succ_apply {f : α → α} (j : ℕ) (n : α) :
    iterate f (j + 1) n = iterate f j (f n) := rfl

theorem iterate_add {f : α → α} (i j : ℕ) (n : α) :
    iterate f (i + j) n = iterate f j (iterate f i n) := by
  induction i generalizing n with
  | zero => simp
  | succ i ih =>
      rw [Nat.succ_add]
      exact ih (f n)

theorem iterate_succ {f : α → α} (j : ℕ) (n : α) :
    iterate f (j + 1) n = f (iterate f j n) := by
  induction j generalizing n with
  | zero => rfl
  | succ j ih =>
      change iterate f (j + 1) (f n) = f (iterate f (j + 1) n)
      rw [ih (f n)]
      rfl

theorem iterate_eq_function_iterate {f : α → α} (j : ℕ) (n : α) :
    iterate f j n = (f^[j]) n := by
  induction j generalizing n with
  | zero => rfl
  | succ j ih => exact ih (f n)

@[simp] theorem Col_of_even {n : ℕ} (h : n % 2 = 0) : Col n = n / 2 := by
  simp [Col, h]

@[simp] theorem Col_of_odd {n : ℕ} (h : n % 2 = 1) : Col n = 3 * n + 1 := by
  simp [Col, h]

@[simp] theorem T_of_even {n : ℕ} (h : n % 2 = 0) : T n = n / 2 := by
  simp [T, h]

@[simp] theorem T_of_odd {n : ℕ} (h : n % 2 = 1) : T n = (3 * n + 1) / 2 := by
  simp [T, h]

theorem T_eq_Col_of_even {n : ℕ} (h : n % 2 = 0) : T n = Col n := by
  simp [T, Col, h]

theorem T_eq_Col_div_two_of_odd {n : ℕ} (h : n % 2 = 1) : T n = Col n / 2 := by
  simp [T, Col, h]

@[simp] theorem Col_zero : Col 0 = 0 := by decide

@[simp] theorem T_zero : T 0 = 0 := by decide

@[simp] theorem Col_one : Col 1 = 4 := by decide

@[simp] theorem T_one : T 1 = 2 := by decide

end Collatz
