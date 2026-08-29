"""Generate the mechanical Lean block modules and aggregate importer.

The semantic checker lives in
`Collatz/Certified/Finite/OptimizedFirstExcursion.lean`.  This script only
emits the 99 identical 1000-start reduction wrappers, the exact tail wrapper,
and the aggregate theorem's repetitive import/simp lists.
"""

import hashlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BLOCK_COUNT = 99
BLOCK_DIR = ROOT / "Collatz" / "Certified" / "Finite" / "OptimizedFirstExcursionBlocks"
AGGREGATE = ROOT / "Collatz" / "Certified" / "Finite" / "OptimizedFirstExcursionKernel.lean"
CERTIFICATE_DIR = ROOT / "certificates" / "optimized-first-excursion-99781"


def block_source(block: int) -> str:
    digits = f"{block:03d}"
    return f"""import Collatz.Certified.Finite.OptimizedFirstExcursion

namespace Collatz.Certified.Finite

set_option maxHeartbeats 1000000

theorem optimizedFirstExcursionBlock{digits}_true :
    optimizedFirstExcursionBlockCheck {block} = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
"""


def aggregate_source() -> str:
    imports = "\n".join(
        f"import Collatz.Certified.Finite.OptimizedFirstExcursionBlocks.Block{b:03d}"
        for b in range(BLOCK_COUNT)
    )
    facts = ",\n      ".join(
        f"optimizedFirstExcursionBlock{b:03d}_true" for b in range(BLOCK_COUNT)
    )
    return f"""{imports}
import Collatz.Certified.Finite.OptimizedFirstExcursionBlocks.Tail
import Mathlib.Tactic

/-!
# Kernel aggregate for the optimized first-excursion envelope

All 99 full blocks and the exact tail are accepted by ordinary kernel
reduction.  No theorem on this proof path uses `native_decide`.
-/

namespace Collatz.Certified.Finite

/-- Every full 1000-start block was accepted by ordinary `decide`. -/
theorem optimizedFirstExcursionEveryBlock_true (b : ℕ) (hb : b ≤ 98) :
    optimizedFirstExcursionBlockCheck b = true := by
  interval_cases b <;>
    simp only [
      {facts}
    ]

/-- The full-block aggregate is accepted without recomputing trajectories. -/
theorem optimizedFirstExcursionAllBlocksCheck_true :
    optimizedFirstExcursionAllBlocksCheck = true := by
  simp only [optimizedFirstExcursionAllBlocksCheck, List.all_eq_true]
  intro b hb
  have hblt : b < 99 := by simpa using hb
  exact optimizedFirstExcursionEveryBlock_true b (by omega)

/--
Pure-kernel optimized envelope: every accelerated orbit starting below 99781
stays strictly below 785412369 for all time.
-/
theorem optimizedFirstExcursionEnvelope_kernel :
    RecordBounds.AcceleratedExcursionEnvelope 785412369 99781 :=
  optimizedFirstExcursionChecks_sound
    optimizedFirstExcursionAllBlocksCheck_true
    optimizedFirstExcursionTail_true

/-- The strict threshold is sharp, witnessed at start 77671 and step 39. -/
theorem optimizedFirstExcursionThresholdExact_kernel :
    RecordBounds.AcceleratedExcursionEnvelope 785412369 99781 ∧
      endpoint 77671 39 = 785412368 :=
  ⟨optimizedFirstExcursionEnvelope_kernel, optimizedFirstExcursion_peak⟩

end Collatz.Certified.Finite
"""


def main() -> None:
    BLOCK_DIR.mkdir(parents=True, exist_ok=True)
    for block in range(BLOCK_COUNT):
        (BLOCK_DIR / f"Block{block:03d}.lean").write_text(
            block_source(block), encoding="utf-8", newline="\n"
        )
    (BLOCK_DIR / "Tail.lean").write_text(
        """import Collatz.Certified.Finite.OptimizedFirstExcursion

namespace Collatz.Certified.Finite

set_option maxHeartbeats 1000000

theorem optimizedFirstExcursionTail_true :
    optimizedFirstExcursionTailCheck = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
""",
        encoding="utf-8",
        newline="\n",
    )
    AGGREGATE.write_text(aggregate_source(), encoding="utf-8", newline="\n")


def write_source_hashes() -> None:
    """Seal every proof source after generation using byte-exact SHA-256."""
    sources = [
        ROOT / "Collatz" / "Certified" / "Finite" / "OptimizedFirstExcursion.lean",
        AGGREGATE,
        ROOT
        / "Collatz"
        / "Certified"
        / "Finite"
        / "OptimizedFirstExcursionAxiomAudit.lean",
        *sorted(BLOCK_DIR.glob("*.lean")),
        Path(__file__).resolve(),
        ROOT / "scripts" / "build_optimized_first_excursion.ps1",
        ROOT / "experiments" / "OptimizedFirstExcursionReplayProbe.lean",
    ]
    rows = []
    for source in sources:
        digest = hashlib.sha256(source.read_bytes()).hexdigest()
        relative = source.relative_to(ROOT)
        rows.append(f"{digest}  {str(relative)}\n")
    CERTIFICATE_DIR.mkdir(parents=True, exist_ok=True)
    (CERTIFICATE_DIR / "SOURCE-SHA256SUMS").write_text(
        "".join(rows), encoding="ascii", newline="\n"
    )


if __name__ == "__main__":
    main()
    write_source_hashes()
