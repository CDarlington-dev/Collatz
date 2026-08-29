# Formal explanation of the paradoxical-segment development

## 1. Scope

This repository formalizes the finite-exclusion method of Olivier Rozier and
Claude Terracol, *Paradoxical behavior in Collatz sequences*, Discrete
Mathematics 349 (2026), 115167, arXiv:2502.00948v5.  It does **not** prove the
Collatz conjecture and it does **not** currently prove the full
`4.65 × 10^19` exclusion without assumptions.

The purpose of the development is to keep three kinds of evidence separate:

1. statements checked by Lean's kernel;
2. exact, independently replayed finite computations; and
3. external computational-record claims.

Only the first kind is called an unconditional Lean theorem in this document.

## 2. Definitions

The accelerated Collatz map is

\[
T(n)=\begin{cases}
n/2,&n\text{ even},\\
(3n+1)/2,&n\text{ odd}.
\end{cases}
\]

For a start `n` and a positive length `j`, let `oddCount n j` be the number of
odd values among

\[
n,T(n),\ldots,T^{j-1}(n).
\]

The Lean predicate `Paradoxical n j` is exactly

\[
2<n,\qquad 0<j,\qquad 3^{\operatorname{oddCount}(n,j)}<2^j,
\qquad T^j(n)\ge n.
\]

Thus a paradoxical segment has an average multiplicative coefficient below one,
but nevertheless ends no lower than it began.

## 3. Unconditional Lean theorems

The following results have been compiled and checked by Lean's ordinary kernel
path.  Their numerical block proofs use `decide`, not `native_decide`, and the
recorded axiom audits contain no user-declared axiom, `sorry`, or `admit`.

### 3.1 Classification through 26,017

Lean proves

\[
\forall n,j,\quad n\le26017\ \Longrightarrow\
\bigl(\operatorname{Paradoxical}(n,j)\leftrightarrow
\operatorname{PublishedClassification}(n,j)\bigr).
\]

`PublishedClassification` is the literal list of the 593 published
paradoxical segments.  In particular, Lean proves that no paradoxical segment
of any length starts in the interval

\[
4614<n<26018.
\]

The central theorem file is
[`Collatz/Certified/Exclusion.lean`](Collatz/Certified/Exclusion.lean).
The pure-kernel direct-range certificate is in
[`Collatz/Certified/Finite/NoParadoxicalRange26017Kernel.lean`](Collatz/Certified/Finite/NoParadoxicalRange26017Kernel.lean).

### 3.2 Certified excursion envelopes

Lean proves both of the following universal statements:

\[
x<113383\ \Longrightarrow\ \forall r\ge0,\ T^r(x)<10^9,
\]

and the sharper statement

\[
x<99781\ \Longrightarrow\ \forall r\ge0,\ T^r(x)<785412369.
\]

These are genuine infinite-orbit statements: the finite certificates prove a
visit to the `(1,2)` cycle, and the Lean proof then handles every later
iterate.  Lean also proves the sharp exhibited value

\[
T^{39}(77671)=785412368.
\]

### 3.3 A length restriction above 26,017

The exact affine-remainder argument is formalized.  One consequence is

\[
n>26017\ \text{and}\ \operatorname{Paradoxical}(n,j)
\quad\Longrightarrow\quad j\ge35.
\]

This is a structural restriction; it is not a proof that no such larger
segments exist.

## 4. Exact computational evidence through one billion

Two separate exact computations covered every start through `10^9`:

- an odd-core/lattice computation divided into 4,096 shards; and
- a fresh scalar replay from an empty checkpoint directory.

They agree exactly: 593 paradoxical segments at 550 starts, all with starting
value at most 4,614.  They also agree with the published 593-row list.  The
replay records, manifests, source hashes, and instructions are retained under
[`certificates/`](certificates/).

This is strong reproducible computational evidence.  It is **not yet** a Lean
theorem through `10^9`, because the stored output is not a target-scale
certificate accepted by a Lean-proved global-coverage checker.

## 5. The conditional `4.65 × 10^19` theorem

The deterministic Rozier--Terracol reduction is formalized.  In its direct
form, Lean proves the implication

\[
\begin{aligned}
&\operatorname{FiniteBaseClassification}(10^9)
\ \wedge\\
&\operatorname{ColDelayCap}(46{,}499{,}999{,}999{,}999{,}999{,}999,2480)\\
&\Longrightarrow
\forall n,j,\;4614<n<46{,}500{,}000{,}000{,}000{,}000{,}000
\Longrightarrow\neg\operatorname{Paradoxical}(n,j).
\end{aligned}
\]

Here `ColDelayCap(B, 2480)` means that every positive integer at most `B`
reaches 1 under the **ordinary** Collatz map in at most 2,480 ordinary steps.
It is not merely a first descent below the starting value and it is not an
accelerated-step bound.

The first excursion envelope that originally appeared as an external input is
now internal to the Lean proof.  The two remaining assumptions are explicitly
listed in [`docs/TRUST-BOUNDARY.md`](docs/TRUST-BOUNDARY.md).

An optimized version reduces the finite side further, but still requires both
a filtered finite-gap proposition and the same ordinary-delay cap.  It does
not remove the conditional status.

## 6. Why the large result remains conditional

The public record project reports class/delay-record coverage through the
target range and lists a highest confirmed delay record of 2,456, which is
stronger than the conservative cap 2,480 used above.  This is ordinary
computer-assisted evidence and is the type of record data used in the
Rozier--Terracol argument.

For a stricter independently formal result, however, the repository would need
a hash-pinned, proof-producing coverage artifact: a complete manifest of the
searched work units and exact compressed evidence that every covered trajectory
reaches 1 within the claimed budget.  The public web pages and executable
provide results and methodology but not that artifact.

Likewise, the two local scans through `10^9` have not been converted into a
Lean-accepted certificate for every start and every possible segment length.

Therefore the correct status is:

| Statement | Status |
|---|---|
| Classification through 26,017 | Unconditional Lean theorem |
| Excursion envelopes stated above | Unconditional Lean theorems |
| Exact agreement with the 593-row list through `10^9` | Two exact independent computations |
| Exclusion through `4.65 × 10^19` | Lean-checked implication conditional on two explicit finite claims |

## 7. Reproduction and trust boundary

The top-level Lean import is [`Collatz.lean`](Collatz.lean); the main theorem
module is [`Collatz/Certified/Exclusion.lean`](Collatz/Certified/Exclusion.lean).
The exact build and audit procedure is in
[`REPRODUCING.md`](REPRODUCING.md).  The authoritative record of what is and is
not an assumption is [`docs/TRUST-BOUNDARY.md`](docs/TRUST-BOUNDARY.md).

The repository should not describe the `4.65 × 10^19` exclusion as
unconditional unless both remaining assumptions are discharged by Lean proofs
or by data accepted by Lean-proved checkers.
