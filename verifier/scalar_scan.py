#!/usr/bin/env python3
"""Independently verify a paradoxical-segment CSV by scalar T iteration.

Unlike ``tools/odd_core_scan.py``, this verifier does not factor starts into odd
cores and does not use the lattice reduction.  It visits every start and every
accelerated-Collatz step until 1, then compares its exact result with the
supplied canonical CSV.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import os
import sys
import time
from pathlib import Path
from typing import Iterable, Sequence


Hit = tuple[int, int, int, int]


def _canonical_json_bytes(value: object) -> bytes:
    return (
        json.dumps(value, ensure_ascii=True, sort_keys=True, separators=(",", ":"))
        + "\n"
    ).encode("ascii")


def _sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


SCALAR_VERIFIER_SHA256 = _sha256_bytes(Path(__file__).resolve().read_bytes())


def _checkpoint_path(checkpoint_dir: Path, shard_id: int) -> Path:
    return checkpoint_dir / "shards" / f"shard-{shard_id:06d}.json"


def _checkpoint_object(
    shard_id: int,
    start: int,
    stop: int,
    max_steps: int,
    result: dict[str, object],
) -> dict[str, object]:
    payload: dict[str, object] = {
        "format": "collatz-scalar-replay-shard-v2",
        "map": "accelerated-collatz-even-half-odd-3n-plus-1-half",
        "max_steps": max_steps,
        "numeric_start": start,
        "numeric_stop_exclusive": stop,
        "result": {
            "hits": [list(hit) for hit in result["hits"]],
            "max_col_delay": list(result["max_col_delay"]),
            "max_delay": list(result["max_delay"]),
            "max_state": list(result["max_state"]),
            "starts": result["starts"],
            "total_steps": result["total_steps"],
        },
        "shard_id": shard_id,
        "verifier_sha256": SCALAR_VERIFIER_SHA256,
    }
    return {
        **payload,
        "payload_sha256": _sha256_bytes(_canonical_json_bytes(payload)),
    }


def _atomic_write(path: Path, raw: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f"{path.name}.tmp-{os.getpid()}")
    temporary.write_bytes(raw)
    temporary.replace(path)


def _write_checkpoint(
    checkpoint_dir: Path,
    shard_id: int,
    start: int,
    stop: int,
    max_steps: int,
    result: dict[str, object],
) -> None:
    value = _checkpoint_object(shard_id, start, stop, max_steps, result)
    _atomic_write(_checkpoint_path(checkpoint_dir, shard_id), _canonical_json_bytes(value))


def _pair(value: object, name: str) -> tuple[int, int]:
    if not (
        isinstance(value, list)
        and len(value) == 2
        and all(isinstance(item, int) for item in value)
    ):
        raise ValueError(f"checkpoint {name} must be a pair of integers")
    return value[0], value[1]


def _read_checkpoint(
    path: Path,
    shard_id: int,
    start: int,
    stop: int,
    max_steps: int,
) -> dict[str, object]:
    raw = path.read_bytes()
    try:
        value = json.loads(raw.decode("ascii"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ValueError(f"invalid checkpoint JSON: {path}") from error
    if not isinstance(value, dict) or raw != _canonical_json_bytes(value):
        raise ValueError(f"non-canonical checkpoint: {path}")
    expected_keys = {
        "format",
        "map",
        "max_steps",
        "numeric_start",
        "numeric_stop_exclusive",
        "payload_sha256",
        "result",
        "shard_id",
        "verifier_sha256",
    }
    if set(value) != expected_keys:
        raise ValueError(f"unexpected checkpoint fields: {path}")
    recorded_hash = value["payload_sha256"]
    if not isinstance(recorded_hash, str) or len(recorded_hash) != 64:
        raise ValueError(f"invalid checkpoint payload hash: {path}")
    payload = {key: item for key, item in value.items() if key != "payload_sha256"}
    if _sha256_bytes(_canonical_json_bytes(payload)) != recorded_hash:
        raise ValueError(f"checkpoint payload hash mismatch: {path}")
    identity = (
        value["format"] == "collatz-scalar-replay-shard-v2"
        and value["map"] == "accelerated-collatz-even-half-odd-3n-plus-1-half"
        and value["shard_id"] == shard_id
        and value["numeric_start"] == start
        and value["numeric_stop_exclusive"] == stop
        and value["max_steps"] == max_steps
        and value["verifier_sha256"] == SCALAR_VERIFIER_SHA256
    )
    if not identity:
        raise ValueError(f"checkpoint identity/range mismatch: {path}")
    body = value["result"]
    if not isinstance(body, dict) or set(body) != {
        "hits",
        "max_col_delay",
        "max_delay",
        "max_state",
        "starts",
        "total_steps",
    }:
        raise ValueError(f"invalid checkpoint result fields: {path}")
    if body["starts"] != stop - start:
        raise ValueError(f"checkpoint coverage count mismatch: {path}")
    if not isinstance(body["total_steps"], int) or body["total_steps"] < 0:
        raise ValueError(f"invalid checkpoint step count: {path}")
    raw_hits = body["hits"]
    if not isinstance(raw_hits, list):
        raise ValueError(f"checkpoint hits must be a list: {path}")
    hits: list[Hit] = []
    for raw_hit in raw_hits:
        if not (
            isinstance(raw_hit, list)
            and len(raw_hit) == 4
            and all(isinstance(item, int) for item in raw_hit)
        ):
            raise ValueError(f"invalid checkpoint hit: {path}")
        hit = raw_hit[0], raw_hit[1], raw_hit[2], raw_hit[3]
        n, j, q, end = hit
        if not (start <= n < stop and j >= 1 and 0 <= q <= j and end >= n):
            raise ValueError(f"out-of-domain checkpoint hit: {path}")
        hits.append(hit)
    if hits != sorted(hits) or len({(n, j) for n, j, _q, _end in hits}) != len(hits):
        raise ValueError(f"non-canonical or duplicate checkpoint hits: {path}")
    max_delay = _pair(body["max_delay"], "max_delay")
    max_col_delay = _pair(body["max_col_delay"], "max_col_delay")
    max_state = _pair(body["max_state"], "max_state")
    for _value, record_start in (max_delay, max_col_delay, max_state):
        if not start <= record_start < stop:
            raise ValueError(f"checkpoint record start outside its shard: {path}")
    return {
        "hits": hits,
        "max_delay": max_delay,
        "max_col_delay": max_col_delay,
        "max_state": max_state,
        "starts": body["starts"],
        "total_steps": body["total_steps"],
    }


def _canonical_hits_bytes(hits: Iterable[Hit]) -> bytes:
    rows = ["n,j,q,end\n"]
    rows.extend(f"{n},{j},{q},{end}\n" for n, j, q, end in hits)
    return "".join(rows).encode("ascii")


def _read_expected(path: Path, limit: int) -> tuple[list[Hit], bytes]:
    raw = path.read_bytes()
    try:
        text = raw.decode("ascii")
    except UnicodeDecodeError as error:
        raise ValueError("hits CSV is not ASCII") from error
    lines = text.splitlines()
    if not lines or lines[0] != "n,j,q,end":
        raise ValueError("hits CSV must begin with the exact header n,j,q,end")

    hits: list[Hit] = []
    for line_number, line in enumerate(lines[1:], start=2):
        fields = line.split(",")
        if len(fields) != 4:
            raise ValueError(f"line {line_number}: expected four comma-separated integers")
        try:
            hit = tuple(int(field) for field in fields)
        except ValueError as error:
            raise ValueError(f"line {line_number}: non-integer field") from error
        n, j, q, end = hit
        if not (3 <= n <= limit and j >= 1 and 0 <= q <= j and end >= 1):
            raise ValueError(f"line {line_number}: out-of-domain hit {hit}")
        hits.append(hit)

    if hits != sorted(hits):
        raise ValueError("hits CSV is not sorted lexicographically")
    if len({(n, j) for n, j, _q, _end in hits}) != len(hits):
        raise ValueError("hits CSV contains a duplicate (n,j) pair")
    if raw != _canonical_hits_bytes(hits):
        raise ValueError("hits CSV is not in canonical LF-terminated form")
    return hits, raw


def _make_need(initial_size: int = 1024) -> tuple[list[int], int]:
    need = [1]
    power3 = 1
    for _q in range(1, initial_size):
        power3 *= 3
        need.append(power3.bit_length())
    return need, power3


def _scan_range(job: tuple[int, int, int]) -> dict[str, object]:
    start, stop, max_steps = job
    need, power3 = _make_need()
    hits: list[Hit] = []
    total_steps = 0
    max_delay = -1
    max_delay_start = 0
    max_col_delay = -1
    max_col_delay_start = 0
    max_state = -1
    max_state_start = 0

    for n in range(start, stop):
        x = n
        j = 0
        q = 0
        orbit_peak = n
        while x != 1:
            if j >= max_steps:
                raise RuntimeError(
                    f"start {n} did not reach 1 within the --max-steps bound {max_steps}"
                )
            if x & 1:
                q += 1
                x = (3 * x + 1) // 2
                if q >= len(need):
                    power3 *= 3
                    need.append(power3.bit_length())
            else:
                x //= 2
            j += 1
            total_steps += 1
            orbit_peak = max(orbit_peak, x)

            # Since 3**q is never a power of two, bit_length(3**q) is
            # exactly the least J for which 3**q < 2**J.
            if j >= need[q] and x >= n:
                hits.append((n, j, q, x))

        if j > max_delay or (j == max_delay and n < max_delay_start):
            max_delay = j
            max_delay_start = n
        col_delay = j + q
        if col_delay > max_col_delay or (
            col_delay == max_col_delay and n < max_col_delay_start
        ):
            max_col_delay = col_delay
            max_col_delay_start = n
        if orbit_peak > max_state or (orbit_peak == max_state and n < max_state_start):
            max_state = orbit_peak
            max_state_start = n

    return {
        "hits": hits,
        "max_delay": (max_delay, max_delay_start),
        "max_col_delay": (max_col_delay, max_col_delay_start),
        "max_state": (max_state, max_state_start),
        "starts": stop - start,
        "total_steps": total_steps,
    }


def _partition(start: int, stop: int, shard_count: int) -> list[tuple[int, int]]:
    size = stop - start
    return [
        (start + size * shard_id // shard_count, start + size * (shard_id + 1) // shard_count)
        for shard_id in range(shard_count)
    ]


def _first_difference(expected: Sequence[Hit], actual: Sequence[Hit]) -> str:
    shared = min(len(expected), len(actual))
    for index in range(shared):
        if expected[index] != actual[index]:
            return (
                f"first mismatch at row {index + 2}: expected {expected[index]}, "
                f"computed {actual[index]}"
            )
    if len(expected) > shared:
        return f"first missing computed hit at row {shared + 2}: {expected[shared]}"
    if len(actual) > shared:
        return f"first unexpected computed hit at row {shared + 2}: {actual[shared]}"
    return "no difference"


def _parse_args(argv: Sequence[str] | None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--limit", type=int, required=True, help="inclusive start bound")
    parser.add_argument("--hits", type=Path, required=True, help="canonical hits.csv to verify")
    parser.add_argument("--workers", type=int, default=1, help="worker processes")
    parser.add_argument(
        "--shards",
        type=int,
        default=64,
        help="deterministic numeric-start partitions",
    )
    parser.add_argument(
        "--checkpoint-dir",
        type=Path,
        help=(
            "optional crash-resumable directory of canonical per-shard JSON; "
            "valid existing shards are reused"
        ),
    )
    parser.add_argument(
        "--no-resume",
        action="store_true",
        help="recompute all scalar shards even when valid checkpoints exist",
    )
    parser.add_argument(
        "--max-steps",
        type=int,
        default=1_000_000,
        help="fail (never accept) if a start has not reached 1 by this many T steps",
    )
    parser.add_argument(
        "--expect-max-state",
        type=int,
        help="fail unless the exact maximum accelerated state has this value",
    )
    parser.add_argument(
        "--expect-max-state-start",
        type=int,
        help="fail unless the least start attaining the maximum state has this value",
    )
    parser.add_argument(
        "--expect-max-state-below",
        type=int,
        help="fail unless every checked accelerated trajectory stays below this threshold",
    )
    parser.add_argument(
        "--expect-max-col-delay-at-most",
        type=int,
        help="fail unless every checked ordinary-Col trajectory reaches 1 by this many steps",
    )
    return parser.parse_args(argv)


def _write_replay_manifest(
    checkpoint_dir: Path,
    *,
    args: argparse.Namespace,
    partitions: Sequence[tuple[int, int]],
    expected_bytes: bytes,
    actual_hash: str,
    covered: int,
    hit_count: int,
    total_steps: int,
    max_delay: tuple[int, int],
    max_col_delay: tuple[int, int],
    max_state: tuple[int, int],
    reused: int,
    elapsed: float,
) -> None:
    shard_rows: list[dict[str, object]] = []
    for shard_id, (start, stop) in enumerate(partitions):
        path = _checkpoint_path(checkpoint_dir, shard_id)
        raw = path.read_bytes()
        value = json.loads(raw.decode("ascii"))
        shard_rows.append(
            {
                "file": path.relative_to(checkpoint_dir).as_posix(),
                "file_sha256": _sha256_bytes(raw),
                "numeric_start": start,
                "numeric_stop_exclusive": stop,
                "payload_sha256": value["payload_sha256"],
                "shard_id": shard_id,
            }
        )
    source_path = Path(__file__).resolve()
    hits_path = args.hits.resolve()
    try:
        displayed_hits_path = hits_path.relative_to(Path.cwd().resolve()).as_posix()
    except ValueError:
        displayed_hits_path = str(hits_path)
    manifest: dict[str, object] = {
        "algorithm": "independent-scalar-T-iteration-v1",
        "coverage": {
            "numeric_start": 3,
            "numeric_stop_inclusive": args.limit,
            "starts": covered,
        },
        "format": "collatz-scalar-replay-manifest-v2",
        "hits_file": displayed_hits_path,
        "hits_sha256": _sha256_bytes(expected_bytes),
        "limit": args.limit,
        "map": "accelerated-collatz-even-half-odd-3n-plus-1-half",
        "max_steps": args.max_steps,
        "result": {
            "hit_count": hit_count,
            "hits_sha256": actual_hash,
            "max_col_delay": {
                "start": max_col_delay[1],
                "value": max_col_delay[0],
            },
            "max_delay": {"start": max_delay[1], "value": max_delay[0]},
            "max_state": {"start": max_state[1], "value": max_state[0]},
            "total_t_steps": total_steps,
        },
        "run": {
            "elapsed_seconds": f"{elapsed:.6f}",
            "reused_shards": reused,
            "workers": args.workers,
        },
        "scalar_verifier_file": source_path.name,
        "scalar_verifier_sha256": SCALAR_VERIFIER_SHA256,
        "shard_count": len(partitions),
        "shards": shard_rows,
    }
    _atomic_write(
        checkpoint_dir / "manifest.json", _canonical_json_bytes(manifest)
    )


def _write_replay_hashes(checkpoint_dir: Path) -> None:
    paths = [checkpoint_dir / "manifest.json"]
    paths.extend(sorted((checkpoint_dir / "shards").glob("shard-*.json")))
    rows = []
    for path in paths:
        relative = path.relative_to(checkpoint_dir).as_posix()
        rows.append(f"{_sha256_bytes(path.read_bytes())}  {relative}\n")
    _atomic_write(checkpoint_dir / "SHA256SUMS", "".join(rows).encode("ascii"))


def main(argv: Sequence[str] | None = None) -> int:
    args = _parse_args(argv)
    if args.limit < 3:
        raise SystemExit("--limit must be at least 3")
    if args.workers < 1 or args.shards < 1 or args.max_steps < 1:
        raise SystemExit("--workers, --shards, and --max-steps must be positive")

    expected, expected_bytes = _read_expected(args.hits.resolve(), args.limit)
    started = time.perf_counter()
    numeric_start = 3
    numeric_stop = args.limit + 1
    total_starts = numeric_stop - numeric_start
    shard_count = min(args.shards, total_starts)
    workers = min(args.workers, shard_count)
    partitions = _partition(numeric_start, numeric_stop, shard_count)
    checkpoint_dir = (
        args.checkpoint_dir.resolve() if args.checkpoint_dir is not None else None
    )
    if checkpoint_dir is not None:
        (checkpoint_dir / "shards").mkdir(parents=True, exist_ok=True)

    results: list[dict[str, object] | None] = [None] * shard_count
    pending: list[tuple[int, tuple[int, int, int]]] = []
    reused = 0
    for shard_id, (start, stop) in enumerate(partitions):
        path = (
            _checkpoint_path(checkpoint_dir, shard_id)
            if checkpoint_dir is not None
            else None
        )
        if path is not None and path.exists() and not args.no_resume:
            try:
                results[shard_id] = _read_checkpoint(
                    path, shard_id, start, stop, args.max_steps
                )
            except ValueError as error:
                print(f"discarding invalid checkpoint: {error}", file=sys.stderr)
            else:
                reused += 1
                continue
        pending.append((shard_id, (start, stop, args.max_steps)))

    if reused:
        print(f"reused {reused}/{shard_count} validated scalar shards", flush=True)

    completed = reused
    progress_stride = max(1, shard_count // 20)

    def accept_result(shard_id: int, result: dict[str, object]) -> None:
        nonlocal completed
        results[shard_id] = result
        if checkpoint_dir is not None:
            start, stop = partitions[shard_id]
            _write_checkpoint(
                checkpoint_dir, shard_id, start, stop, args.max_steps, result
            )
        completed += 1
        if completed == shard_count or completed % progress_stride == 0:
            print(f"completed {completed}/{shard_count} scalar shards", flush=True)

    if workers == 1:
        for shard_id, job in pending:
            accept_result(shard_id, _scan_range(job))
    else:
        with concurrent.futures.ProcessPoolExecutor(max_workers=workers) as pool:
            futures = {
                pool.submit(_scan_range, job): shard_id for shard_id, job in pending
            }
            for future in concurrent.futures.as_completed(futures):
                accept_result(futures[future], future.result())

    if any(result is None for result in results):
        raise RuntimeError("internal error: incomplete scalar shard result set")
    complete_results = [result for result in results if result is not None]

    actual = sorted(hit for result in complete_results for hit in result["hits"])
    if actual != expected:
        print("verification FAILED", file=sys.stderr)
        print(_first_difference(expected, actual), file=sys.stderr)
        return 1

    covered = sum(int(result["starts"]) for result in complete_results)
    if covered != total_starts:
        print(
            f"verification FAILED: covered {covered} starts, expected {total_starts}",
            file=sys.stderr,
        )
        return 1

    actual_bytes = _canonical_hits_bytes(actual)
    expected_hash = hashlib.sha256(expected_bytes).hexdigest()
    actual_hash = hashlib.sha256(actual_bytes).hexdigest()
    max_delay, delay_start = min(
        (result["max_delay"] for result in complete_results),
        key=lambda record: (-record[0], record[1]),
    )
    max_col_delay, col_delay_start = min(
        (result["max_col_delay"] for result in complete_results),
        key=lambda record: (-record[0], record[1]),
    )
    max_state, state_start = min(
        (result["max_state"] for result in complete_results),
        key=lambda record: (-record[0], record[1]),
    )
    expectation_errors: list[str] = []
    if args.expect_max_state is not None and max_state != args.expect_max_state:
        expectation_errors.append(
            f"maximum state {max_state} != expected {args.expect_max_state}"
        )
    if (
        args.expect_max_state_start is not None
        and state_start != args.expect_max_state_start
    ):
        expectation_errors.append(
            f"maximum-state start {state_start} != expected {args.expect_max_state_start}"
        )
    if (
        args.expect_max_state_below is not None
        and not max_state < args.expect_max_state_below
    ):
        expectation_errors.append(
            f"maximum state {max_state} is not below {args.expect_max_state_below}"
        )
    if (
        args.expect_max_col_delay_at_most is not None
        and max_col_delay > args.expect_max_col_delay_at_most
    ):
        expectation_errors.append(
            f"maximum Col delay {max_col_delay} exceeds {args.expect_max_col_delay_at_most}"
        )
    if expectation_errors:
        print("verification FAILED", file=sys.stderr)
        for error in expectation_errors:
            print(error, file=sys.stderr)
        return 1
    elapsed = time.perf_counter() - started
    total_steps = sum(int(result["total_steps"]) for result in complete_results)
    if checkpoint_dir is not None:
        _write_replay_manifest(
            checkpoint_dir,
            args=args,
            partitions=partitions,
            expected_bytes=expected_bytes,
            actual_hash=actual_hash,
            covered=covered,
            hit_count=len(actual),
            total_steps=total_steps,
            max_delay=(max_delay, delay_start),
            max_col_delay=(max_col_delay, col_delay_start),
            max_state=(max_state, state_start),
            reused=reused,
            elapsed=elapsed,
        )
        _write_replay_hashes(checkpoint_dir)
    print(
        "verification PASSED\n"
        f"range: 3..{args.limit} ({covered} starts)\n"
        f"hits: {len(actual)}\n"
        f"SHA-256: {actual_hash}\n"
        f"total T steps: {total_steps}\n"
        f"maximum delay: {max_delay} (start {delay_start})\n"
        f"maximum Col delay: {max_col_delay} (start {col_delay_start})\n"
        f"maximum state: {max_state} (start {state_start})\n"
        f"validated checkpoint shards reused: {reused}\n"
        f"elapsed: {elapsed:.3f}s",
        flush=True,
    )
    if actual_hash != expected_hash:
        # This is unreachable after the byte-level canonicalization and tuple
        # comparison, but keeping the check explicit documents the hash contract.
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
