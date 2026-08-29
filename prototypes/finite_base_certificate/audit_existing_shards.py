#!/usr/bin/env python3
"""Audit whether the committed 1e9 shard formats retain proof data.

The audit is intentionally structural.  It verifies canonical JSON, hashes,
gap-free ranges, counts, and the exact fields retained in every shard.  It then
reports literal-trace lower bounds from the published aggregate step counts.
It does not replay Collatz trajectories and makes no mathematical claim from a
hash.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]


def canonical_json(value: object) -> bytes:
    return (
        json.dumps(value, ensure_ascii=True, sort_keys=True, separators=(",", ":"))
        + "\n"
    ).encode("ascii")


def sha256(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def read_canonical(path: Path) -> tuple[dict[str, Any], bytes]:
    raw = path.read_bytes()
    value = json.loads(raw.decode("ascii"))
    if not isinstance(value, dict) or canonical_json(value) != raw:
        raise ValueError(f"non-canonical JSON: {path}")
    return value, raw


def check_payload(value: dict[str, Any], path: Path) -> None:
    recorded = value.get("payload_sha256")
    payload = dict(value)
    payload.pop("payload_sha256", None)
    if recorded != sha256(canonical_json(payload)):
        raise ValueError(f"payload hash mismatch: {path}")


def audit_finite(path: Path) -> dict[str, Any]:
    manifest, manifest_raw = read_canonical(path / "manifest.json")
    expected_start = 0
    shard_bytes = 0
    hits = 0
    nonempty = 0
    keysets: set[tuple[str, ...]] = set()
    for entry in manifest["shards"]:
        shard_path = path / entry["file"]
        shard, raw = read_canonical(shard_path)
        check_payload(shard, shard_path)
        if shard["odd_index_start"] != expected_start:
            raise ValueError(f"odd-core coverage gap before {shard_path}")
        expected_start = shard["odd_index_stop"]
        if sha256(raw) != entry["file_sha256"]:
            raise ValueError(f"file hash mismatch: {shard_path}")
        shard_bytes += len(raw)
        local_hits = len(shard["hits"])
        hits += local_hits
        nonempty += local_hits != 0
        keysets.add(tuple(sorted(shard)))
    if expected_start != manifest["statistics"]["odd_cores"]:
        raise ValueError("odd-core coverage does not end at aggregate count")
    return {
        "directory": path.relative_to(ROOT).as_posix(),
        "format": manifest["format"],
        "manifest_bytes": len(manifest_raw),
        "manifest_sha256": sha256(manifest_raw),
        "shard_bytes": shard_bytes,
        "shards": len(manifest["shards"]),
        "shard_keysets": [list(keys) for keys in sorted(keysets)],
        "hit_rows": hits,
        "nonempty_shards": nonempty,
        "odd_cores": manifest["statistics"]["odd_cores"],
        "represented_starts": manifest["coverage"]["represented_starts"],
        "total_t_steps": manifest["statistics"]["total_t_steps_from_odd_cores"],
        "proof_data_absent": [
            "per-core summaries (only core_summary_sha256 is retained)",
            "per-core trajectories or odd-block valuations",
            "per-prefix lattice decisions for negative cells",
            "proof terms accepted by Lean",
        ],
    }


def audit_scalar(path: Path) -> dict[str, Any]:
    manifest_path = path / "manifest-fresh.json"
    manifest, manifest_raw = read_canonical(manifest_path)
    expected_start = 3
    shard_bytes = 0
    hits = 0
    nonempty = 0
    keysets: set[tuple[str, ...]] = set()
    result_keysets: set[tuple[str, ...]] = set()
    total_starts = 0
    total_steps = 0
    for entry in manifest["shards"]:
        shard_path = path / entry["file"]
        shard, raw = read_canonical(shard_path)
        check_payload(shard, shard_path)
        if shard["numeric_start"] != expected_start:
            raise ValueError(f"scalar coverage gap before {shard_path}")
        expected_start = shard["numeric_stop_exclusive"]
        if sha256(raw) != entry["file_sha256"]:
            raise ValueError(f"file hash mismatch: {shard_path}")
        body = shard["result"]
        shard_bytes += len(raw)
        local_hits = len(body["hits"])
        hits += local_hits
        nonempty += local_hits != 0
        total_starts += body["starts"]
        total_steps += body["total_steps"]
        keysets.add(tuple(sorted(shard)))
        result_keysets.add(tuple(sorted(body)))
    if expected_start != manifest["coverage"]["numeric_stop_inclusive"] + 1:
        raise ValueError("scalar coverage does not end at manifest endpoint")
    if total_steps != manifest["result"]["total_t_steps"]:
        raise ValueError("scalar total-step sum mismatch")
    scalar_steps = manifest["result"]["total_t_steps"]
    delay_bits = manifest["result"]["max_delay"]["value"].bit_length()
    return {
        "directory": path.relative_to(ROOT).as_posix(),
        "format": manifest["format"],
        "fresh_manifest_bytes": len(manifest_raw),
        "fresh_manifest_sha256": sha256(manifest_raw),
        "shard_bytes": shard_bytes,
        "shards": len(manifest["shards"]),
        "shard_keysets": [list(keys) for keys in sorted(keysets)],
        "result_keysets": [list(keys) for keys in sorted(result_keysets)],
        "hit_rows": hits,
        "nonempty_shards": nonempty,
        "represented_starts": total_starts,
        "total_t_steps": scalar_steps,
        "literal_parity_trace_minimum_bytes": (scalar_steps + 7) // 8,
        "per_start_accelerated_delay_minimum_bits": delay_bits,
        "packed_delay_table_minimum_bytes":
            (total_starts * delay_bits + 7) // 8,
        "proof_data_absent": [
            "per-start delays (only shard maximum is retained)",
            "per-start trajectories or parity traces",
            "per-prefix paradoxical decisions for negative starts",
            "proof terms accepted by Lean",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "prototypes/finite_base_certificate/shard-audit.json",
    )
    args = parser.parse_args()
    result = {
        "finite": audit_finite(ROOT / "certificates/finite-1000000000"),
        "scalar": audit_scalar(ROOT / "certificates/scalar-1000000000"),
        "conclusion": (
            "The committed shards can be integrity-checked and their declared "
            "ranges are gap-free, but they cannot be converted into a Lean proof: "
            "all negative trajectory evidence was discarded before serialization."
        ),
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(canonical_json(result))
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
