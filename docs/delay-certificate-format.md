# Ordinary-delay certificate format

## Claim discharged

`Collatz.RecordBounds.ColDelayCap upper cap` means exactly:

> for every natural number `n` with `0 < n` and `n <= upper`, there is an
> ordinary (unaccelerated) Collatz iterate `d <= cap` whose value is `1`.

The ordinary map checked here is the repository definition

```text
Col(n) = n / 2       when n is even
Col(n) = 3*n + 1     when n is odd.
```

Thus a certificate supplies a possibly nonminimal ordinary visit time to `1`.
Existence of such a visit by `cap` entails that the first total stopping time is
also at most `cap`, exactly as required by `ColDelayCap`; the checker does not
claim that its stored budget is minimal. It is not accelerated-step delay and
it is not merely the first time the orbit drops below its start. The interval
has an inclusive upper endpoint, excludes `0`, and includes `1` with delay
zero.

## Version-1 descent-DAG data

The Lean type `DelayDAGCertificate` contains two arrays indexed by the start
`n`:

- `steps[n]`: length of an ordinary-Collatz trajectory prefix whose endpoint
  Lean recomputes (the prefix values are not stored);
- `budgets[n]`: claimed upper bound for a certified visit to `1` from `n`.

Index zero is unused. The Boolean checker requires the arrays to contain every
index through `upper`. At `n = 1`, it requires `budgets[1] = 0`. At every
`2 <= n <= upper`, it recomputes

```text
target = Col^[steps[n]](n)
```

and accepts only when all of the following exact conditions hold:

```text
0 < steps[n]
0 < target < n
budgets[n] = steps[n] + budgets[target]
budgets[n] <= cap
```

The strict decrease makes the links a well-founded DAG even though no graph
edges are trusted explicitly. Coverage is also not trusted: every integer in
the inclusive interval is selected by its index and checked.

## Soundness and trust boundary

`delayDAGCheck_sound` is proved in Lean by strong induction on `n`. It follows
the exact checked prefix, invokes the induction hypothesis at the strictly
smaller target, concatenates the two trajectories using `iterate_add`, and
adds the checked budgets. Therefore a successful check constructs the exact
`ColDelayCap` proposition used by the deterministic exclusion theorem.

The demonstrator `delayCertificate20` is accepted with the ordinary `decide`
tactic, not `native_decide`, and yields the unconditional theorem
`colDelayCap20 : ColDelayCap 20 20`. The generator functions used to populate
the two arrays are outside the trust argument: changing them can only cause
the independent checker to reject.

## Scaling and the missing target artifact

This version is a reference point-indexed checker, not a practical encoding
through `46,499,999,999,999,999,999`. A target-scale artifact must compress
coverage, most plausibly into residue cylinders or interval blocks. Each
compressed item must still provide enough data for a Lean-verified refinement
checker to establish:

1. disjoint, gap-free coverage of every positive integer through the inclusive
   target endpoint;
2. an exact affine/trajectory-prefix identity for every member of a cylinder;
3. a link into an already certified earlier interval; and
4. an additive ordinary-step budget no greater than `2480`.

No such target-scale cylinder table is present in this repository. In
particular, `DelayCertificate.lean` does **not** prove
`ColDelayCap 46499999999999999999 2480`; it only supplies a verified checker
architecture and a small kernel-checked example. The exact missing artifact is
the record-holder's compressed coverage data (or independently regenerated
equivalent data), including all residue/interval endpoints, prefix descriptors,
back-links, and delay budgets needed by a compressed checker.

Version 1 is a Lean in-memory reference format, not yet a canonical serialized
exchange format.  A target artifact would additionally require a specified
byte encoding/parser, hashes over the serialized coverage data, and a
kernel-checked acceptance theorem for the parsed compressed certificate.
