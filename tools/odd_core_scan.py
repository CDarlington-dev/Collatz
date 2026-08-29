#!/usr/bin/env python3
"""Exact exhaustive scanner for paradoxical accelerated-Collatz segments.

The scanner factors every positive start uniquely as ``n = 2**a * u`` with
``u`` odd.  It follows the fully accelerated (odd-to-odd) orbit of each odd
core only once and solves the possible ``(a, substep)`` pairs as a small
integer lattice interval.  No floating-point arithmetic is used.

Output is a deterministic, resumable directory of shard JSON files, a
canonical CSV containing all hits, a manifest, and SHA-256 checksums.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import os
import sys
import time
from collections import Counter
from pathlib import Path
from typing import Any, Iterable, Sequence


FORMAT_VERSION = "collatz-paradoxical-certificate-v1"
SHARD_FORMAT = "collatz-paradoxical-odd-core-shard-v1"
MAP_ID = "accelerated-collatz-even-half-odd-3n-plus-1-half"


Hit = tuple[int, int, int, int]  # (n, j, q, T^j(n))


def _canonical_json_bytes(value: Any) -> bytes:
    return (
        json.dumps(value, ensure_ascii=True, separators=(",", ":"), sort_keys=True)
        + "\n"
    ).encode("ascii")


def _sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _atomic_write(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp-{os.getpid()}")
    with temporary.open("wb") as stream:
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)


def _floor_log2_ratio(numerator: int, denominator: int) -> int:
    """Return floor(log2(numerator / denominator)), or -1 if numerator < denominator."""

    if numerator < denominator:
        return -1
    shift = numerator.bit_length() - denominator.bit_length()
    if (denominator << shift) > numerator:
        shift -= 1
    return shift


def _v2(value: int) -> int:
    """The exact 2-adic valuation of a positive even integer."""

    return (value & -value).bit_length() - 1


def _need_table() -> list[int]:
    # need[q] is extended lazily by _ensure_need.  For q = 0, 1 < 2**j
    # first holds at j = 1, and bit_length(3**0) is indeed 1.
    return [1]


def _ensure_need(need: list[int], power3: int, q: int) -> int:
    """Extend need through q and return the updated exact power 3**q."""

    while len(need) <= q:
        power3 *= 3
        need.append(power3.bit_length())
    return power3


def _prefer_max(
    current_value: int,
    current_witness: int,
    candidate_value: int,
    candidate_witness: int,
) -> tuple[int, int]:
    if candidate_value > current_value:
        return candidate_value, candidate_witness
    if candidate_value == current_value and candidate_witness < current_witness:
        return candidate_value, candidate_witness
    return current_value, current_witness


def _scan_shard(job: tuple[int, int, int, int, int]) -> dict[str, Any]:
    limit, shard_count, shard_id, odd_index_start, odd_index_stop = job
    need = _need_table()
    power3 = 1
    hits: list[Hit] = []
    represented_starts = 0
    odd_blocks = 0
    total_t_steps = 0
    max_delay = -1
    max_delay_start = 0
    max_state = -1
    max_state_start = 0
    max_odd_steps = -1
    max_odd_steps_core = 0
    core_digest = hashlib.sha256()

    for odd_index in range(odd_index_start, odd_index_stop):
        u = 2 * odd_index + 1
        max_scale = _floor_log2_ratio(limit, u)
        represented_starts += max_scale + 1

        x = u
        cumulative_steps = 0
        odd_steps = 0
        core_peak = u
        core_hit_count = 0

        while x != 1:
            y = 3 * x + 1
            valuation = _v2(y)
            odd_steps += 1
            odd_blocks += 1
            power3 = _ensure_need(need, power3, odd_steps)

            # The first endpoint in this odd block is y/2; all later ones
            # decrease, so this also updates the exact orbit maximum.
            core_peak = max(core_peak, y >> 1)

            endpoint_log_bound = _floor_log2_ratio(y, u)
            z_low = max(1, need[odd_steps] - cumulative_steps)
            z_high = min(endpoint_log_bound, max_scale + valuation)

            for z in range(z_low, z_high + 1):
                a_low = max(0, z - valuation)
                a_high = min(max_scale, z - 1)
                for a in range(a_low, a_high + 1):
                    substep = z - a
                    n = u << a
                    if n > 2:
                        hits.append(
                            (n, cumulative_steps + z, odd_steps, y >> substep)
                        )
                        core_hit_count += 1

            x = y >> valuation
            cumulative_steps += valuation

        total_t_steps += cumulative_steps
        largest_scaled_start = u << max_scale
        delay = cumulative_steps + max_scale
        max_delay, max_delay_start = _prefer_max(
            max_delay, max_delay_start, delay, largest_scaled_start
        )
        max_odd_steps, max_odd_steps_core = _prefer_max(
            max_odd_steps, max_odd_steps_core, odd_steps, u
        )

        represented_peak = max(core_peak, largest_scaled_start)
        peak_witness = u if core_peak >= largest_scaled_start else largest_scaled_start
        max_state, max_state_start = _prefer_max(
            max_state, max_state_start, represented_peak, peak_witness
        )

        # This is a reproducibility digest of deterministic per-core summaries.
        # Correctness comes from replaying the shard, not from trusting the hash.
        core_digest.update(
            (
                f"{u},{max_scale},{cumulative_steps},{odd_steps},"
                f"{core_peak},{core_hit_count}\n"
            ).encode("ascii")
        )

    hits.sort()
    first_odd = 2 * odd_index_start + 1 if odd_index_start < odd_index_stop else None
    last_odd = 2 * (odd_index_stop - 1) + 1 if odd_index_start < odd_index_stop else None
    payload: dict[str, Any] = {
        "core_summary_sha256": core_digest.hexdigest(),
        "first_odd": first_odd,
        "format": SHARD_FORMAT,
        "hits": [
            {"end": end, "j": j, "n": n, "q": q} for n, j, q, end in hits
        ],
        "last_odd": last_odd,
        "limit": limit,
        "map": MAP_ID,
        "max_delay": {"start": max_delay_start, "value": max_delay},
        "max_odd_steps": {"core": max_odd_steps_core, "value": max_odd_steps},
        "max_state": {"start": max_state_start, "value": max_state},
        "odd_blocks": odd_blocks,
        "odd_cores": odd_index_stop - odd_index_start,
        "odd_index_start": odd_index_start,
        "odd_index_stop": odd_index_stop,
        "represented_starts": represented_starts,
        "shard_count": shard_count,
        "shard_id": shard_id,
        "total_t_steps": total_t_steps,
    }
    payload["payload_sha256"] = _sha256_bytes(_canonical_json_bytes(payload))
    return payload


def _expected_bounds(total_odd_cores: int, shard_count: int, shard_id: int) -> tuple[int, int]:
    start = total_odd_cores * shard_id // shard_count
    stop = total_odd_cores * (shard_id + 1) // shard_count
    return start, stop


def _validate_shard(
    shard: dict[str, Any],
    *,
    limit: int,
    shard_count: int,
    shard_id: int,
    odd_index_start: int,
    odd_index_stop: int,
) -> None:
    claimed_hash = shard.get("payload_sha256")
    body = dict(shard)
    body.pop("payload_sha256", None)
    actual_hash = _sha256_bytes(_canonical_json_bytes(body))
    if claimed_hash != actual_hash:
        raise ValueError(f"shard {shard_id}: payload SHA-256 mismatch")

    expected = {
        "format": SHARD_FORMAT,
        "limit": limit,
        "map": MAP_ID,
        "odd_index_start": odd_index_start,
        "odd_index_stop": odd_index_stop,
        "odd_cores": odd_index_stop - odd_index_start,
        "shard_count": shard_count,
        "shard_id": shard_id,
    }
    for key, value in expected.items():
        if shard.get(key) != value:
            raise ValueError(
                f"shard {shard_id}: expected {key}={value!r}, got {shard.get(key)!r}"
            )

    raw_hits = shard.get("hits")
    if not isinstance(raw_hits, list):
        raise ValueError(f"shard {shard_id}: hits is not a list")
    hit_tuples: list[Hit] = []
    for item in raw_hits:
        if not isinstance(item, dict) or set(item) != {"n", "j", "q", "end"}:
            raise ValueError(f"shard {shard_id}: malformed hit")
        hit_tuples.append((item["n"], item["j"], item["q"], item["end"]))
    if hit_tuples != sorted(hit_tuples):
        raise ValueError(f"shard {shard_id}: hits are not canonically sorted")


def _load_shard(
    path: Path,
    *,
    limit: int,
    shard_count: int,
    shard_id: int,
    odd_index_start: int,
    odd_index_stop: int,
) -> dict[str, Any]:
    with path.open("r", encoding="ascii") as stream:
        shard = json.load(stream)
    _validate_shard(
        shard,
        limit=limit,
        shard_count=shard_count,
        shard_id=shard_id,
        odd_index_start=odd_index_start,
        odd_index_stop=odd_index_stop,
    )
    return shard


def _hits_from_shards(shards: Sequence[dict[str, Any]]) -> list[Hit]:
    hits = [
        (item["n"], item["j"], item["q"], item["end"])
        for shard in shards
        for item in shard["hits"]
    ]
    hits.sort()
    keys = [(n, j) for n, j, _q, _end in hits]
    if len(keys) != len(set(keys)):
        raise ValueError("duplicate (n,j) hit across shards")
    return hits


def _hits_csv_bytes(hits: Iterable[Hit]) -> bytes:
    rows = ["n,j,q,end\n"]
    rows.extend(f"{n},{j},{q},{end}\n" for n, j, q, end in hits)
    return "".join(rows).encode("ascii")


def _max_record(shards: Sequence[dict[str, Any]], field: str, witness: str) -> dict[str, int]:
    records = [shard[field] for shard in shards]
    return min(records, key=lambda record: (-record["value"], record[witness]))


def _combine(
    *,
    output_dir: Path,
    limit: int,
    shard_count: int,
    shards: Sequence[dict[str, Any]],
) -> tuple[Path, Path, Path]:
    represented_starts = sum(shard["represented_starts"] for shard in shards)
    if represented_starts != limit:
        raise ValueError(
            f"coverage failure: shards represent {represented_starts} starts, expected {limit}"
        )

    hits = _hits_from_shards(shards)
    hits_path = output_dir / "hits.csv"
    _atomic_write(hits_path, _hits_csv_bytes(hits))
    hits_hash = _sha256_file(hits_path)

    group_counts = Counter((j, q) for _n, j, q, _end in hits)
    shard_entries = []
    shard_dir = output_dir / "shards"
    for shard in shards:
        relative = Path("shards") / f"shard-{shard['shard_id']:06d}.json"
        shard_path = output_dir / relative
        shard_entries.append(
            {
                "file": relative.as_posix(),
                "file_sha256": _sha256_file(shard_path),
                "hit_count": len(shard["hits"]),
                "odd_index_start": shard["odd_index_start"],
                "odd_index_stop": shard["odd_index_stop"],
                "payload_sha256": shard["payload_sha256"],
                "represented_starts": shard["represented_starts"],
                "shard_id": shard["shard_id"],
            }
        )

    scanner_hash = _sha256_file(Path(__file__).resolve())
    manifest: dict[str, Any] = {
        "algorithm": "odd-core-lattice-v1",
        "coefficient_test": "need(q)=bit_length(3^q); coefficient<1 iff j>=need(q)",
        "coverage": {
            "domain_start": 1,
            "domain_stop": limit,
            "paradox_definition_start": 3,
            "represented_starts": represented_starts,
            "unique_factorization": "n=2^a*u with u odd",
        },
        "format": FORMAT_VERSION,
        "generator_sha256": scanner_hash,
        "hits_file": "hits.csv",
        "hits_sha256": hits_hash,
        "limit": limit,
        "map": MAP_ID,
        "result": {
            "distinct_starts": len({n for n, _j, _q, _end in hits}),
            "group_counts": [
                {"count": count, "j": j, "q": q}
                for (j, q), count in sorted(group_counts.items())
            ],
            "hit_count": len(hits),
            "maximum_start": max((n for n, _j, _q, _end in hits), default=None),
            "minimum_start": min((n for n, _j, _q, _end in hits), default=None),
        },
        "shard_count": shard_count,
        "shards": shard_entries,
        "statistics": {
            "max_delay": _max_record(shards, "max_delay", "start"),
            "max_odd_steps": _max_record(shards, "max_odd_steps", "core"),
            "max_state": _max_record(shards, "max_state", "start"),
            "odd_blocks": sum(shard["odd_blocks"] for shard in shards),
            "odd_cores": sum(shard["odd_cores"] for shard in shards),
            "total_t_steps_from_odd_cores": sum(
                shard["total_t_steps"] for shard in shards
            ),
        },
    }
    manifest_path = output_dir / "manifest.json"
    _atomic_write(manifest_path, _canonical_json_bytes(manifest))

    checksum_entries = [
        (_sha256_file(hits_path), "hits.csv"),
        (_sha256_file(manifest_path), "manifest.json"),
    ]
    checksum_entries.extend(
        (entry["file_sha256"], entry["file"]) for entry in shard_entries
    )
    checksum_entries.sort(key=lambda item: item[1])
    checksums = "".join(f"{digest}  {name}\n" for digest, name in checksum_entries)
    checksums_path = output_dir / "SHA256SUMS"
    _atomic_write(checksums_path, checksums.encode("ascii"))
    return hits_path, manifest_path, checksums_path


def _parse_args(argv: Sequence[str] | None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--limit", type=int, required=True, help="inclusive start bound")
    parser.add_argument(
        "--workers",
        type=int,
        default=1,
        help="worker processes (8 physical cores are preferable to SMT on the target host)",
    )
    parser.add_argument(
        "--shards",
        type=int,
        default=256,
        help="deterministic resumable shard count (4096 is recommended for 1e9)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="certificate directory (default: build/odd-core-<limit>)",
    )
    parser.add_argument(
        "--no-resume",
        action="store_true",
        help="recompute and overwrite expected shard files instead of reusing valid ones",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = _parse_args(argv)
    if args.limit < 1:
        raise SystemExit("--limit must be positive")
    if args.workers < 1:
        raise SystemExit("--workers must be positive")
    if args.shards < 1:
        raise SystemExit("--shards must be positive")

    started = time.perf_counter()
    output_dir = args.output_dir or Path("build") / f"odd-core-{args.limit}"
    output_dir = output_dir.resolve()
    shard_dir = output_dir / "shards"
    shard_dir.mkdir(parents=True, exist_ok=True)

    total_odd_cores = (args.limit + 1) // 2
    shard_count = min(args.shards, total_odd_cores)
    workers = min(args.workers, shard_count)
    shards_by_id: dict[int, dict[str, Any]] = {}
    jobs: list[tuple[int, int, int, int, int]] = []

    for shard_id in range(shard_count):
        start, stop = _expected_bounds(total_odd_cores, shard_count, shard_id)
        path = shard_dir / f"shard-{shard_id:06d}.json"
        if path.exists() and not args.no_resume:
            shards_by_id[shard_id] = _load_shard(
                path,
                limit=args.limit,
                shard_count=shard_count,
                shard_id=shard_id,
                odd_index_start=start,
                odd_index_stop=stop,
            )
        else:
            jobs.append((args.limit, shard_count, shard_id, start, stop))

    print(
        f"odd-core scan: limit={args.limit}, shards={shard_count}, workers={workers}, "
        f"reused={len(shards_by_id)}, pending={len(jobs)}",
        flush=True,
    )

    def accept(shard: dict[str, Any]) -> None:
        shard_id = shard["shard_id"]
        path = shard_dir / f"shard-{shard_id:06d}.json"
        _atomic_write(path, _canonical_json_bytes(shard))
        shards_by_id[shard_id] = shard
        completed = len(shards_by_id)
        if completed == shard_count or completed % max(1, shard_count // 20) == 0:
            print(f"completed {completed}/{shard_count} shards", flush=True)

    if workers == 1:
        for job in jobs:
            accept(_scan_shard(job))
    elif jobs:
        with concurrent.futures.ProcessPoolExecutor(max_workers=workers) as pool:
            futures = [pool.submit(_scan_shard, job) for job in jobs]
            for future in concurrent.futures.as_completed(futures):
                accept(future.result())

    ordered_shards = [shards_by_id[shard_id] for shard_id in range(shard_count)]
    hits_path, manifest_path, checksums_path = _combine(
        output_dir=output_dir,
        limit=args.limit,
        shard_count=shard_count,
        shards=ordered_shards,
    )
    elapsed = time.perf_counter() - started
    hit_count = sum(len(shard["hits"]) for shard in ordered_shards)
    print(
        f"complete: {hit_count} hits in {elapsed:.3f}s\n"
        f"hits: {hits_path}\nmanifest: {manifest_path}\nchecksums: {checksums_path}",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
