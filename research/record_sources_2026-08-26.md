# Record-source audit, 2026-08-26

These observations explain the external propositions in
`certificates/external-claims-v1.json`. They are provenance, not proofs of the
reported searches.

## Current coverage boundary

The primary main page reports class-record coverage through
`46.5 * 10^18`. The detailed progress page defines each coordinate unit as
`10^12`, marks all large ranges through coordinate `45,000,000` complete, and
marks the contiguous cells through `46,500,000` complete. The next cell starts
at that boundary. Accordingly the theorem uses the source-minimal half-open
integer range

```text
n < 46,500,000 * 10^12 = 46,500,000,000,000,000,000.
```

The progress history abbreviates the same coordinate as `46,500`; the full
grid and main status disambiguate the omitted thousands.

- Main page: <http://www.ericr.nl/wondrous/>
  - retrieved SHA-256:
    `4bf0c36bf4d779f4f09814d742c2d4d5b40c26c1120a066636d1449a28a567f5`
- Progress page: <http://www.ericr.nl/wondrous/progress.html>
  - status date displayed: 2026-07-29
  - retrieved SHA-256:
    `64b42e1ad232e7748f5bfedd6e230b0233b47827e62e9428a40b403dc846dcd2`

## Delay semantics and conservative cap

The site's `Delay` is the least ordinary Collatz index reaching 1. Its delay
record table still ends at delay 2456, but the 2026-06-12 progress entry reports
one possible delay-2480 record that is not yet confirmed. The extension theorem
therefore assumes the weaker external proposition that every covered start
reaches 1 within 2480 ordinary steps. It does not assume that the possible
candidate lies beyond the completed range.

- Delay page: <http://www.ericr.nl/wondrous/delrecs.html>
  - retrieved SHA-256:
    `59dd4ca4d14e5a90d9d881f90bef1782638b229fc233e8a0f051da3919436964`
- Raw table: <http://www.ericr.nl/wondrous/delays.txt>
  - retrieved SHA-256:
    `f168da1b973c5ab44fff60144cb8248f8732ccb9529fec5638e8c36251d01507`

## Current excursion bracket

The path-record page's consecutive relevant starts are checked locally by the
trajectory verifier:

```text
M_T(45871962271) = 41170824451011417002 < 46499999999999999999
M_T(51739336447) = 57319808570806999220 > 46499999999999999999
```

Completeness of the preceding path-record rows remains an external envelope
hypothesis.

- Path page: <http://www.ericr.nl/wondrous/pathrecs.html>
  - retrieved SHA-256:
    `276e6d504c51043477dadce9976f31d1055475499e901c8c2f4829edf0b53591`

## Archival limitation

The raw retrieved HTML bytes live in the ignored development cache and are not
redistributed in this package. Thus the hashes identify the exact bytes used
during this audit but cannot be re-hashed from the repository alone. The pages
were retrieved over the HTTP URLs used by the paper after the HTTPS endpoint
presented a certificate-name error; the hashes do not authenticate the mutable
site. This limitation affects provenance strength, not the Lean theorem's
logic, because every coverage claim remains an explicit parameter.
