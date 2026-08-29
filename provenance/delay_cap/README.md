# Roosendaal class-record provenance snapshot

Retrieved on 2026-08-26 from Eric Roosendaal's official `ericr.nl/wondrous`
site over HTTP.  HTTPS was not used because the server presented a certificate
whose name did not match the host.  These files preserve public evidence; they
are not, by themselves, proof of a completed computation.

## Official files

| File | Official URL | SHA-256 |
|---|---|---|
| `index.html` | `http://www.ericr.nl/wondrous/index.html` | `4bf0c36bf4d779f4f09814d742c2d4d5b40c26c1120a066636d1449a28a567f5` |
| `progress.html` | `http://www.ericr.nl/wondrous/progress.html` | `64b42e1ad232e7748f5bfedd6e230b0233b47827e62e9428a40b403dc846dcd2` |
| `classrec.html` | `http://www.ericr.nl/wondrous/classrec.html` | `ff85440b5aff69831d691992fd2e992a457ab1bb53d3c4c4c992034ef56692da` |
| `delrecs.html` | `http://www.ericr.nl/wondrous/delrecs.html` | `59dd4ca4d14e5a90d9d881f90bef1782638b229fc233e8a0f051da3919436964` |
| `search.html` | `http://www.ericr.nl/wondrous/search.html` | `d113da436177a41e221c84290e0d4b5db17627b2d624d78b272bd2ad71f9dee3` |
| `techpage.html` | `http://www.ericr.nl/wondrous/techpage.html` | `3bb4a5e25ffc9c17d7022458e8200ec003186335ecab85171c6b73a0c772323e` |
| `searchgpu6_41.zip` | `http://www.ericr.nl/wondrous/searchgpu6_41.zip` | `4eff1acf99b7788602f93772fccb3032e05e1f75be496c68b03dc0de4e87375f` |
| `search64_4.zip` | `http://www.ericr.nl/wondrous/search64_4.zip` | `074c35576c888b07361784881c56561b244b79fe479dd750e784ebfe458e0067` |

The two extracted directories are byte-for-byte expansions of those ZIP
archives.  Important executable hashes are:

- GPU 6.41 native worker `cudawon641.exe`:
  `babfbdb07dd90e15497ac7731a9d886637118258fa57e7dc9d1d01783cd58502`;
- CPU 6.0.2 .NET worker `won600.exe`:
  `dc37569377e9a46498b3830b0bff600e13ce52f3cc5dbbcba5549c523fe38d01`.

## What the public snapshot says

- `index.html` defines delay as the least ordinary-Collatz index at which the
  orbit reaches `1`.  This matches `Collatz.RecordBounds.ColDelayCap`; it is not
  accelerated delay or first descent below the start.
- `progress.html` says intervals are in units of `10^12`.  Its detailed grid
  marks complete every cell below unit `46,500,000`, so its half-open numerical
  boundary is `46,500,000 * 10^12 = 46,500,000,000,000,000,000`.
- `classrec.html` labels itself “All 2425 Class Records up to
  46,500000,000000,000000”.  The largest populated delay class in that table is
  class `2456`, at start `28,019077,177231,758495`.  Empty cells above it do not
  constitute a certificate by themselves.
- `progress.html` separately reports a *possible* delay-2480 record.  The Lean
  predicate conservatively uses `2480`, but a record-page number is not used as
  proof.
- `search.html` says the current program logs an entry every `2^42` starts,
  logs interesting starts and an overflow count, and asks volunteers to email
  the resulting log files to the record holder.  It does not publish those log
  files or a manifest of their hashes.

## Program audit

The official download contains executable binaries, not source code.  To make
the older public CPU algorithm inspectable, `won600.exe` was decompiled with the
official ILSpy 10.1.1 x64 release (release ZIP SHA-256
`24b02fbc306948c1163ec6ed0cd1c1f720a54d100eb22d356547c9245c1b73d5`).
The mechanically derived `won600.decompiled.cs` has SHA-256
`aaacefd4e0e8471f633c9bf1b71427835ba491ae91a6543f947bc8c5b1efe74b`.
It exposes the `2^25` path-merging sieve, congruence skips, cutoff table,
multi-limb ordinary-Collatz evaluator, and exact delay counter.  Decompilation
is not author-supplied source, and this older CPU binary is not the native GPU
6.41 worker used for the current frontier.

## Missing proof artifact

No public file found in this snapshot binds all completed cells to replayable
work-unit results.  The narrow artifact needed from the record project is the
complete set of raw logs (or an authenticated lossless aggregate) for every
work unit below `46,500,000 * 10^12`, together with the exact GPU 6.41 source or
a formally specified output/certificate format.  Even those logs would first
need a Lean-verified checker proving that sieve exclusions, path joins,
cutoffs, overflow handling, coverage adjacency, and delay accounting imply the
Lean `ColDelayCap` predicate.
