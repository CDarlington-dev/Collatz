# Runtime and hardware notes

These are reproducibility observations from one development machine, not
performance guarantees or a benchmark study.

## Environment captured on 2026-08-26

- Windows host reporting build 26200
- AMD Ryzen 7 260 with Radeon 780M
- 16 logical processors
- Git 2.55.0
- Elan 4.2.3 (workspace-local during development)
- Lean 4.32.1, x86_64-w64-windows-gnu, commit `f054605`
- Lake 5.0.0-src+f054605
- mathlib tag `v4.32.1`, resolved commit beginning `520045ab`
- Node.js 24.19.0
- Python 3.12.13 from the bundled Codex runtime

The Lean and mathlib downloads are excluded from all timings below. The
workspace-local `.tooling`, `.lake`, `.cache`, and `build` directories are not
reproducibility artifacts.

## Recorded wall-clock runs

| Operation | Command shape | Workers/shards | Time |
|---|---|---:|---:|
| Generate committed finite certificate through `10^6` | `odd_core_scan.py --limit 1000000` | 8 / 32 | 10.163 s |
| Independent scalar replay through `10^6` | `scalar_scan.py --limit 1000000` | 8 / 32 | 6.419 s |
| Compact Node certificate verifier (3 Farey rows) | `node tools\verify_exact.mjs` | 1 process | 0.335 s |
| Python reference verifier, including first excursion replay | `python verifier\reference.py` | 1 process | 6.903 s |
| Build the added current Farey certificate | `lake build Collatz.Certified.Exclusion` | Lean/Lake | 337 s Farey + 24 s exclusion, as reported by Lake |
| Clean optimized finite certificate through `10^9` | `odd_core_scan.py --limit 1000000000 --no-resume` | 8 / 4096 | About 6,751 s (1 h 52 min 31 s) |
| Fresh independent scalar replay through `10^9` | `scalar_scan.py --limit 1000000000 --no-resume` | 8 / 4096, reused 0 | 5,245.591715 s |
| Scalar checkpoint validation/reuse | same command without `--no-resume` | 8 / 4096, reused 4096 | 1.013257 s |
| Pure-kernel classification through `4614` | `& .\scripts\build_kernel_blocks.ps1 -Family Base` | 47 blocks of 100 starts | Built and audited; no clean end-to-end time retained |
| Pure-kernel first-excursion aggregate | `& .\scripts\build_kernel_blocks.ps1 -Family Excursion` | Two block targets per Lake invocation | Built and audited; precise build time not retained |
| Pure-kernel direct range aggregate | `& .\scripts\build_kernel_blocks.ps1 -Family Range` | Two block targets per Lake invocation | Built and audited; precise build time not retained |
| Symbolic affine bound | `lake build Collatz.AffineBound` | Lean/Lake | Built and audited; precise build time not retained |
| Static circuit/CNF/LRAT demo | `lake build Collatz.Certified.Circuit.Demo` | 48 variables / 206 clauses | 49 s warm module build; 10 s separate audit |
| Direct range through `26017` | `& .\scripts\build_kernel_blocks.ps1 -Family Range26017` | 40 blocks of 400 plus tail | 1,697.504 s paired loop; 17.870 s aggregate |
| Optimized first-excursion aggregate | `& .\scripts\build_optimized_first_excursion.ps1` | 99 blocks of 1000 plus 781-start tail | 1,004.896 s paired replay; passed |
| Optimized Farey and exclusion target | `lake build Collatz.Certified.Exclusion Collatz` | 9,040 loaded jobs | Built and audited; precise wall time not retained |

Earlier generator/scalar replays took 5.714 s and 5.570 s; the difference is
normal run-to-run variation and concurrent Lean compilation materially slowed
some later runs. No cold end-to-end Lean build time was retained, so none is
claimed here.

The completed `10^6` scalar replay covered 999,998 starts (`3..1000000`) and 87,826,477
accelerated steps. It reported maximum delay 329 at start 837799 and maximum
state 28,495,741,760 at start 704511. The optimized generator's manifest
records 500,000 odd cores, 22,996,390 odd blocks, and 45,803,239 accelerated
steps from odd cores.

The clean optimized `10^9` manifest records 500,000,000 odd cores,
34,969,255,812 odd blocks, and 69,762,619,290 accelerated steps from odd
cores. It reports maximum accelerated delay 616 at start 670617279 and maximum
state 707118223359971240 at start 319804831. The recorded clean command launch
was 20:02:54 EDT; the first shard, last shard, and original final manifest were
timestamped 20:02:59, 21:54:33, and 21:55:25 respectively. The resulting
observed wall interval is about 6,751 seconds (1 h 52 min 31 s). The complete
provenance is in `certificates/finite-1000000000/RUN.md`.

The fresh scalar replay covered 999,999,998 starts (`3..1000000000`) and
135,705,965,843 accelerated steps. It reported 593 hits, maximum accelerated
delay 616 at start 670617279, maximum ordinary delay 986 at the same start,
and maximum state 707118223359971240 at start 319804831. Its source SHA-256 is
`1127da520f9946c72e23818a90699df2ef369b5b913ed3ce9c7d50a9b9d455cf`;
the preserved fresh manifest and sums hashes are
`033501eed471312f83b589bd204a697c02a21f6101964ecb8103ad73aa2cd752`
and `6d68fc3d99557262b41b3a133304246c016fc29ec2f5a3035dd90a1e5eb32a16`.
The reuse pass produced live hashes
`69c4add41a1198ce3402ed0e8287cc2af4a53a0e8eb0d4c4be9d9927aed8a85c`
and `99a8c9f79585ab8bbfb8bc45a331ce2ec92233027e6e30c4cf2fe395dd325c2`.
See `certificates/scalar-1000000000/RUN.md` for the fresh-versus-live distinction.

The first-excursion kernel build compiles 114 ordinary-`decide` blocks. Blocks
43, 46, and 48 through 113 use explicit `maxHeartbeats 500000`; the others use
Lean's default. Its audit contains only `propext`, `Classical.choice`, and
`Quot.sound`. A legacy native-decision comparison theorem remains in
`FirstExcursion.lean`, but it is not used by the kernel aggregate or target
exclusion.

The base-classification build has a common checker, 47 blocks of 100 starts,
and an aggregate. Representative concurrently loaded module times recorded in
its certificate README were 23 seconds for the checker, 18 seconds for block
000, 20 seconds for block 037, and 53 seconds for the aggregate importer. These
are not additive and are not presented as a clean full-build time.

The static LRAT demonstration replay uses no solver at build time. The 49-second
warm demo build parses the committed CNF/LRAT text and reconstructs a proof
term; the separate 10-second audit reported no native-evaluation axiom. This is
a proof-path timing, not evidence of target-scale circuit feasibility. The
larger SAT feasibility measurements are in `notes/circuit-benchmarks.md`.

Lake 5 ignored `-Kjobs=2` as a concurrency cap in this checkout and spawned 16
reducers. The checked replacement is to run
the needed `scripts/build_kernel_blocks.ps1` families before a bare
`lake build`. During the block phase, the script submits exactly two block
targets to each Lake invocation; the base and aggregate invocations are
single-target. The completed families are `Base`, `Range`, `Range26017`,
`Excursion`, and `OptimizedExcursion`. This batching rule, rather than
`-Kjobs=2`, is the recorded resource-control mechanism.

The optimized envelope replay proves the strict threshold
`AcceleratedExcursionEnvelope 785412369 99781` and exact peak
`endpoint 77671 39 = 785412368`. Fuel 134 fails closed and fuel 135 accepts the
extremal first-descent start `35655`. Its 1,004.896-second run reused the
immediately preceding probe builds for blocks 076 and 077, so it is a checked
production replay time rather than a clean-build benchmark. The sealed
106-entry source manifest has digest
`910dfa86fa2812b461bdfde2572db650e855699fc8ae430ff2d907f3e49779b9`;
semantic-source hash
`15d495cddf760905fad5d21fa50677be102b6ea9a2d9433e821e2755c6d31f51`;
package-`SHA256SUMS` hash
`9077033661a33d4df93a22eb049b5630c19f654ffc1d11d496e187be0c622ed7`.
The envelope and optimized target audits list only standard Lean/Mathlib
logical axioms; concrete block reductions and the peak equality list none.

## Residue-certificate design measurements

The exact compression experiments are summarized, with source hashes, in
[residue-certificate-benchmarks.md](residue-certificate-benchmarks.md). Their
important runtime conclusion is structural rather than a timing projection:
fixed-parity and state-only tail
summaries degenerate to essentially pointwise proof work on gap-relevant
samples. Since `2^35 > 10^9`, a fixed parity residue at a remaining candidate
length identifies at most one start. The missing improvement is the relational
affine-cylinder tail invariant stated in that note, not a faster implementation
of the same tree.

## Scaling and trust note

The committed optimized computation and a fresh independent scalar replay now
both reach `10^9`; the earlier `10^6` certificate remains useful as a quick
reproduction target. A timing projection is never used as a certificate. Lean
now proves the complete classification through `26017`, but a proof connecting
the larger external coverage to `FiniteBaseClassification` is still missing.
The verified optimized proof-engine route filters its remaining finite field to
`26017 < n ≤ 785412368`, `35 ≤ j`, and
`j + oddCount n j < 2480`. The Farey module, envelope, target, 9,040-job root
build, and full audit sweep passed, but the displayed filtered gap and `DC-1`
remain mathematical inputs.

The ordinary-delay domain below `4.65 * 10^19` is many orders of magnitude
larger. No naive-enumeration timing is projected for it. A viable reproduction
must use a compressed, proof-producing coverage representation accepted by a
Lean-proved checker.
