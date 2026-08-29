# Independent scalar replay through 1,000,000,000

Evidence label: **fresh exhaustive exact-arithmetic computation**, followed by
an integrity/identity validation of its checkpoints.  These files are strong
independent computational evidence, but they are not accepted by a Lean-proved
certificate checker and therefore do not by themselves prove
`FiniteBaseClassification 1000000000 PublishedClassification`.

## Fresh production replay

The checkpoint directory did not exist before launch.  The exact command was:

```text
python verifier/scalar_scan.py --limit 1000000000 --hits certificates/finite-1000000000/hits.csv --workers 8 --shards 4096 --checkpoint-dir certificates/scalar-1000000000 --no-resume
```

- Date: 2026-08-27 (America/New_York)
- Starts: every integer from 3 through 1,000,000,000, inclusive
- Reused shards: 0
- Measured elapsed time: 5,245.591715 seconds (1 h 27 min 25.592 s)
- Python: CPython 3.12.13
- Host: Windows build 26200; AMD Ryzen 7 260 with Radeon 780M;
  16 logical processors
- Scalar verifier source SHA-256:
  `1127da520f9946c72e23818a90699df2ef369b5b913ed3ce9c7d50a9b9d455cf`

The verifier iterated each start independently with the accelerated map, tested
every positive prefix through the first exact visit to 1, and compared the full
canonical tuple list `(n,j,q,end)` with the optimized computation's CSV.

Fresh result:

- covered starts: 999,999,998
- paradoxical rows: 593
- hit-list SHA-256:
  `9a4db72c9c5ab79eda689f42a15d92ed5100abceee566442b9579a0894d0a37a`
- total accelerated steps: 135,705,965,843
- maximum accelerated delay: 616, least start 670,617,279
- maximum ordinary Collatz delay: 986, least start 670,617,279
- maximum accelerated state: 707,118,223,359,971,240,
  least start 319,804,831
- preserved `manifest-fresh.json` SHA-256:
  `033501eed471312f83b589bd204a697c02a21f6101964ecb8103ad73aa2cd752`
- preserved `SHA256SUMS-fresh` SHA-256:
  `6d68fc3d99557262b41b3a133304246c016fc29ec2f5a3035dd90a1e5eb32a16`

`SHA256SUMS-fresh` is the exact checksum file written by the fresh run.  Its
historical `manifest.json` row refers to the bytes now preserved as
`manifest-fresh.json`.

## Checkpoint-validation replay

The same command was then run without `--no-resume`.  It reported
`reused 4096/4096 validated scalar shards`, repeated the exact aggregate result,
and completed in 1.013257 seconds.  The live aggregate files therefore describe
the reuse pass:

- `manifest.json` SHA-256:
  `69c4add41a1198ce3402ed0e8287cc2af4a53a0e8eb0d4c4be9d9927aed8a85c`
- `SHA256SUMS` SHA-256:
  `99a8c9f79585ab8bbfb8bc45a331ce2ec92233027e6e30c4cf2fe395dd325c2`

Checkpoint validation checks canonical encoding, payload integrity, exact
source-hash and parameter identity, assigned half-open range, and coverage
count.  It does **not** recompute the trajectories recorded in a reused shard;
unkeyed hashes can be deliberately forged.  Thus only the zero-reuse pass is an
independent computation, and neither pass crosses the Lean trust boundary.
