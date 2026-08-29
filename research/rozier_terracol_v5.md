# Rozier–Terracol reconstruction

Primary source: Olivier Rozier and Claude Terracol, “Paradoxical behavior in Collatz
sequences,” *Discrete Mathematics* 349 (2026), 115167,
doi:10.1016/j.disc.2026.115167; arXiv:2502.00948v5 (17 May 2026).

- arXiv abstract/version history: <https://arxiv.org/abs/2502.00948>
- v5 PDF: <https://arxiv.org/pdf/2502.00948v5>
- journal DOI: <https://doi.org/10.1016/j.disc.2026.115167>

Page numbers below refer to the v5 PDF.

## Definitions reconstructed

- Equation (1), p. 1 defines the accelerated map used in this repository:
  `T(n) = (3n+1)/2` for odd `n` and `T(n)=n/2` for even `n`.
- Equation (2), pp. 1–2 is
  `T^j(n) = (3^q/2^j)n + E_j(n)`, where `q` counts odd terms among
  `T^0(n),...,T^(j-1)(n)`.
- Definition 1.1, p. 2: for positive `j,n`, `n>2`, the segment
  `Omega_j(n)=(n,T(n),...,T^j(n))` is paradoxical when
  `3^q < 2^j` and `T^j(n) >= n`. Finite repetitions of `(1,2)` are
  excluded; the `n>2` convention already excludes them here.
- Definition 1.2, p. 3 defines stopping time `t(n)` and coefficient stopping
  time `tau(n)`. The paper notes the equivalence of CST, “a paradoxical length
  exceeds the stopping time,” and “a paradoxical segment never starts at its
  minimum.”
- Definition 2.1, pp. 4–5 defines `q_j(n)` and the parity vector `V_j(n)`.
- Definition 4.1, p. 11 names `Omega_j(n)` (which has `j+1` terms).
- Definition 5.2, p. 15 defines accelerated delay `d_T` and maximum excursion
  `M_T`. Equation (13) defines the unaccelerated map `Col`; equation (14) gives
  `d_Col(n)=d_T(n)+q` for a complete convergent trajectory.

## The theorem chain used by the exclusion

1. Lemma 2.3 and Theorem 2.4 (pp. 6–7) order parity-vector remainders and give
   `(3^q-2^q)/2^j <= E_j(n) <= (3^q-2^q)/2^q`.
2. Theorem 3.2 and Corollary 3.3 (pp. 9–10) show that an infinite stopping
   time gives infinitely many paradoxical segments; hence finiteness of such
   segments implies Collatz.
3. Equation (9), p. 11 rewrites paradoxicality as `0 < 1-C <= E/n`.
4. Theorem 4.2, pp. 11–12 bounds `E/n` using the harmonic mean `h` of the odd
   prefix terms.
5. Corollary 4.3, p. 12 constrains the ones-ratio between
   `log 2/log(3+1/h)` and `log 2/log 3`.
6. Corollary 4.4, p. 13 gives `h <= H(j)`, where
   `H(j)=1/(2^(j/floor((log 2/log 3)j))-3)`.
7. Theorem 5.3, pp. 15–16 reports exactly 593 segments with `n<=4614` and
   `j<=92`, none with `93<=j<=301993`, and none with
   `4615<=n<=2.8*10^19`.
8. Corollary 5.4, p. 17 derives CST through `2.8*10^19`.

## Published finite data

Table 1 and Appendix C give these seven `(j,q,count)` groups:

| `j` | `q` | count |
|---:|---:|---:|
| 8 | 5 | 5 |
| 27 | 17 | 50 |
| 46 | 29 | 231 |
| 54 | 34 | 2 |
| 65 | 41 | 244 |
| 73 | 46 | 56 |
| 92 | 58 | 5 |

The counts sum to 593, from 550 distinct starting integers. The simplest
fixture is `7,11,17,26,13,20,10,5,8`, with `(j,q)=(8,5)`. The paper also
gives the even-start fixture `Omega_8(18)` and notes that `859` is paradoxical
at lengths 46, 65, and 73, ending at 890, 911, and 866.

The Table 1 caption in v5 contains a reciprocal typo: it prints
`C=2^j/3^q`; Definition 1.1 and the table’s decimal values use
`C=3^q/2^j`.

## Reconstruction of Theorem 5.3’s numerical feedback

The finite search at `n0=10^9` is an external exhaustive computation in the
paper: no code, certificate, hash, runtime, or hardware is supplied. Appendix C
certifies positive witnesses but not exhaustiveness.

For a hypothetical segment above `n0`, let `m` be the least of its first `j`
terms. The external maximum-excursion envelope gives `m>=113383`; the adjacent
accelerated rows are

- `M_T(77671)=785412368 < 10^9`,
- `M_T(113383)=1241055674 > 10^9`.

The paper evaluates Corollaries 4.3–4.4 numerically to obtain
`j>=1539`, `q>=971`, hence an unaccelerated prefix of at least 2510 steps.
The confirmed delay record at
`28019077177231758495` has unaccelerated delay 2456. Its record-table
completeness therefore forces `n` above that exact integer (and hence above
`2.8*10^19`).

The next accelerated excursion bracket is

- `M_T(12327829503)=10361199457202525864`,
- `M_T(23035537407)=34419078320774113520`.

The paper's second numerical evaluation yields `j>=301994`.

## July 2026 record-conditional extension

The current primary status page reports class-record coverage below the grid
boundary `46.5*10^18 = 46500000000000000000`. The confirmed delay table ends
at 2456, while the progress log also mentions a possible, unconfirmed record
of 2480. Using the conservative external hypothesis that every start below the
boundary has ordinary delay at most 2480 is still sufficient, because the
first exact feedback gives `j+q>=2510`.

The corresponding accelerated excursion bracket is

- `M_T(45871962271)=41170824451011417002`, below the boundary;
- `M_T(51739336447)=57319808570806999220`, above it.

At `m=51739336447`, the exact Farey tuple
`(a,b,c,d)=(176251,111202,125743,79335)` yields
`j>=301994` and `q>=190537`. Consequently the Lean theorem, conditional on the
named finite classification, delay cap, and excursion inputs, excludes
`4614<n<46500000000000000000`; with the later excursion envelope it also gives
the displayed `j,q` bounds beyond that boundary. See
`record_sources_2026-08-26.md` for the unit and provenance audit.

## Evidence boundary

The analytic implications are mathematical proofs in the paper. The following
are separate computational inputs and remain named hypotheses until certified:

- exhaustiveness of the `n<=10^9` search;
- completeness of each maximum-excursion envelope;
- completeness of the delay-record search over its stated range.

Primary record sources cited or used here:

- Roosendaal delay records: <https://www.ericr.nl/wondrous/delrecs.html>
- Roosendaal path records: <https://www.ericr.nl/wondrous/pathrecs.html>
- Roosendaal progress/status: <https://www.ericr.nl/wondrous/progress.html>
- Oliveira e Silva, *Math. Comp.* 68 (1999), Table 3:
  <https://www.ams.org/mcom/1999-68-225/S0025-5718-99-01031-5/S0025-5718-99-01031-5.pdf>

## Related 2026 work

Tong Niu, arXiv:2605.13886, gives a fixed-parity-word exact enumerator and
reports reproducing the Rozier–Terracol groups through `n<=10^7`. It explicitly
does not claim an improvement to the global exclusion. It is corroborating
related work, not a record-bound input:
<https://arxiv.org/abs/2605.13886>.
