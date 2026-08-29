#!/usr/bin/env python3
"""Independent stdlib-only verifier for the compact exact certificates.

Assertions and provenance observations in `external-claims-v1.json` are
intentionally not accepted as proofs.  They are printed as undischarged external
claims after all locally decidable rows have been checked.
"""

from __future__ import annotations

import csv
import hashlib
import json
import pathlib
import time


ROOT = pathlib.Path(__file__).resolve().parents[1]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def data_lines(filename: pathlib.Path):
    with filename.open("r", encoding="utf-8", newline="") as handle:
        yield from (line for line in handle if line.strip() and not line.startswith("#"))


def t_step(n: int) -> int:
    return (3 * n + 1) // 2 if n & 1 else n // 2


def col_step(n: int) -> int:
    return 3 * n + 1 if n & 1 else n // 2


def trajectory(start: int, step) -> tuple[int, int]:
    value = maximum = start
    delay = 0
    while value != 1:
        value = step(value)
        maximum = max(maximum, value)
        delay += 1
        require(delay < 1_000_000, f"trajectory guard exceeded at {start}")
    return delay, maximum


def verify_farey(filename: pathlib.Path) -> int:
    document = json.loads(filename.read_text(encoding="utf-8"))
    require(document["schema"] == "collatz-farey-v1", "unexpected Farey schema")
    for row in document["certificates"]:
        m, a, b, c, d = (int(row[key]) for key in ("m", "a", "b", "c", "d"))
        j, q = int(row["optimal_j"]), int(row["optimal_q"])
        require(2**a < 3**b, f"{row['id']}: lower comparison")
        require((3 * m + 1) ** d < 2**c * m**d, f"{row['id']}: upper comparison")
        require(b * c - a * d == 1, f"{row['id']}: determinant")
        require((j, q) == (a + c, b + d), f"{row['id']}: sums")
        require(3**q < 2**j, f"{row['id']}: endpoint coefficient")
        require(2**j * m**q <= (3 * m + 1) ** q, f"{row['id']}: endpoint growth")
    return len(document["certificates"])


def verify_trajectories(filename: pathlib.Path) -> int:
    rows = list(csv.DictReader(data_lines(filename)))
    for row in rows:
        start = int(row["start"])
        require(trajectory(start, t_step) == (int(row["t_delay"]), int(row["t_max"])),
                f"{start}: accelerated trajectory differs")
        require(trajectory(start, col_step) == (int(row["col_delay"]), int(row["col_max"])),
                f"{start}: unaccelerated trajectory differs")
    return len(rows)


def verify_witnesses(filename: pathlib.Path) -> tuple[int, int]:
    rows = list(csv.DictReader(data_lines(filename)))
    counts: dict[tuple[int, int], int] = {}
    starts: set[int] = set()
    for row in rows:
        j, expected_q, start = int(row["j"]), int(row["q"]), int(row["n"])
        require(start > 2 and j > 0, f"{start}/{j}: convention")
        value, q = start, 0
        for _ in range(j):
            q += value & 1
            value = t_step(value)
        require(q == expected_q, f"{start}/{j}: odd count")
        require(3**q < 2**j, f"{start}/{j}: coefficient")
        require(value >= start, f"{start}/{j}: endpoint")
        counts[(j, q)] = counts.get((j, q), 0) + 1
        starts.add(start)
    expected = {
        (8, 5): 5, (27, 17): 50, (46, 29): 231, (54, 34): 2,
        (65, 41): 244, (73, 46): 56, (92, 58): 5,
    }
    require(len(rows) == 593, f"witness count is {len(rows)}")
    require(len(starts) == 550, f"distinct-start count is {len(starts)}")
    require(max(starts) == 4614, f"maximum start is {max(starts)}")
    require(counts == expected, f"group counts differ: {counts}")
    return len(rows), len(starts)


def verify_record_bounds(filename: pathlib.Path) -> int:
    """Replay compact finite record claims by direct scalar T iteration."""

    document = json.loads(filename.read_text(encoding="utf-8"))
    require(
        document["schema"] == "collatz-record-bounds-v1",
        "unexpected record-bound schema",
    )
    for row in document["claims"]:
        lower = int(row["domain_start"])
        upper = int(row["domain_stop_inclusive"])
        target = int(row["convergence_target"])
        expected_max = int(row["maximum_state"])
        expected_start = int(row["least_start_attaining_maximum"])
        threshold = int(row["strict_threshold"])
        expected_t_delay = int(row["maximum_accelerated_delay"])
        expected_col_delay = int(row["maximum_col_delay"])
        require(lower == 0 and target == 1, f"{row['id']}: unsupported domain/target")

        maximum = 0
        maximum_start = 0
        maximum_t_delay = 0
        maximum_col_delay = 0
        for start in range(lower, upper + 1):
            # The zero orbit is fixed; positive orbits must explicitly reach 1.
            if start == 0:
                continue
            value = start
            t_delay = 0
            odd_steps = 0
            orbit_maximum = start
            while value != target:
                odd_steps += value & 1
                value = t_step(value)
                orbit_maximum = max(orbit_maximum, value)
                t_delay += 1
                require(t_delay < 1_000_000, f"{row['id']}: guard at {start}")
            col_delay = t_delay + odd_steps
            maximum_t_delay = max(maximum_t_delay, t_delay)
            maximum_col_delay = max(maximum_col_delay, col_delay)
            if orbit_maximum > maximum:
                maximum = orbit_maximum
                maximum_start = start

        require(maximum == expected_max, f"{row['id']}: maximum state")
        require(maximum_start == expected_start, f"{row['id']}: maximum witness")
        require(maximum < threshold, f"{row['id']}: strict threshold")
        require(maximum_t_delay == expected_t_delay, f"{row['id']}: T delay")
        require(maximum_col_delay == expected_col_delay, f"{row['id']}: Col delay")

        manifest = ROOT / row["finite_certificate_manifest"]
        require(
            sha256(manifest) == row["finite_certificate_manifest_sha256"],
            f"{row['id']}: manifest hash",
        )
        manifest_document = json.loads(manifest.read_text(encoding="utf-8"))
        require(manifest_document["limit"] == upper, f"{row['id']}: manifest range")
        require(
            manifest_document["hits_sha256"] == row["hits_sha256"],
            f"{row['id']}: hit-list hash",
        )
    return len(document["claims"])


def sha256(filename: pathlib.Path) -> str:
    return hashlib.sha256(filename.read_bytes()).hexdigest()


def main() -> None:
    files = {
        "farey": ROOT / "certificates" / "farey-v1.json",
        "trajectories": ROOT / "certificates" / "trajectory-fixtures-v1.csv",
        "witnesses": ROOT / "certificates" / "published-witnesses-v1.csv",
        "record_bounds": ROOT / "certificates" / "record-bounds-v1.json",
    }
    started = time.perf_counter()
    farey_count = verify_farey(files["farey"])
    trajectory_count = verify_trajectories(files["trajectories"])
    witness_count, distinct_count = verify_witnesses(files["witnesses"])
    record_count = verify_record_bounds(files["record_bounds"])
    elapsed = time.perf_counter() - started

    print(f"PASS exact Farey certificates: {farey_count}")
    print(f"PASS exact trajectory fixtures: {trajectory_count}")
    print(f"PASS published paradoxical witnesses: {witness_count} ({distinct_count} starts)")
    print(f"PASS locally exhaustive record bounds: {record_count}")
    for name, filename in files.items():
        print(f"SHA256 {sha256(filename)}  {filename.relative_to(ROOT).as_posix()}")

    claims_file = ROOT / "certificates" / "external-claims-v1.json"
    claims = json.loads(claims_file.read_text(encoding="utf-8"))
    require(claims["schema"] == "collatz-external-claims-v1", "unexpected claim schema")
    print(f"RECORDED (not locally discharged): {len(claims['claims'])} external claims")
    print(f"SHA256 {sha256(claims_file)}  {claims_file.relative_to(ROOT).as_posix()}")
    print(f"Runtime: {elapsed:.3f} s on Python")


if __name__ == "__main__":
    main()
