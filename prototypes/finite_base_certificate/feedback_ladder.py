#!/usr/bin/env python3
"""Explore an exact excursion/delay feedback ladder from a small finite base.

This is design analysis, not a certificate.  Every Farey comparison and every
trajectory calculation performed here uses integers.  The delay-record starts
are read from the pinned provenance snapshot; their completeness is *not*
assumed as proof evidence.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def accelerated(n: int) -> int:
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def ordinary(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1


def trajectory_max(n: int) -> int:
    current = n
    maximum = n
    while current != 1:
        current = accelerated(current)
        maximum = max(maximum, current)
    return max(maximum, 2)


def ordinary_delay(n: int) -> int:
    delay = 0
    while n != 1:
        n = ordinary(n)
        delay += 1
    return delay


def farey_bracket(m: int) -> tuple[int, int, int, int]:
    """Tight Stern--Brocot neighbours bracketing log2(3), log2(3+1/m)."""
    a, b = 1, 1
    c, d = 2, 1
    while True:
        p, q = a + c, b + d
        lower_side = pow(2, p) < pow(3, q)
        upper_side = pow(3 * m + 1, q) < pow(2, p) * pow(m, q)
        if lower_side:
            a, b = p, q
        elif upper_side:
            c, d = p, q
        else:
            return a, b, c, d


def read_delay_records(path: Path) -> list[tuple[int, int]]:
    starts = [int(line.strip().replace(",", "")) for line in path.read_text().splitlines() if line.strip()]
    return [(start, ordinary_delay(start)) for start in starts]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", type=int, default=4614)
    parser.add_argument("--target", type=int, default=1_000_000_000)
    parser.add_argument("--seed-limit", type=int, default=113_384)
    parser.add_argument("--find-bootstrap", action="store_true")
    parser.add_argument(
        "--delay-records",
        type=Path,
        default=Path("provenance/delay_cap/delays.txt"),
    )
    args = parser.parse_args()

    maxima = [trajectory_max(x) if x else 0 for x in range(args.seed_limit)]
    records = read_delay_records(args.delay_records)
    if args.find_bootstrap:
        excursion_record = 0
        candidates: list[dict[str, int]] = []
        for seed, maximum in enumerate(maxima):
            if maximum <= excursion_record:
                continue
            lower_threshold = max(args.base, excursion_record + 1)
            upper_threshold = min(args.target, maximum)
            excursion_record = maximum
            if lower_threshold > upper_threshold or seed <= 1:
                continue
            a, b, c, d = farey_bracket(seed)
            floor = a + b + c + d
            delay_at_lower = max(
                delay for start, delay in records if start <= lower_threshold
            )
            delay_at_upper = max(
                delay for start, delay in records if start <= upper_threshold
            )
            if floor >= delay_at_lower:
                candidates.append(
                    {
                        "lower_threshold": lower_threshold,
                        "upper_threshold": upper_threshold,
                        "seed": seed,
                        "seed_excursion": maximum,
                        "ordinary_floor": floor,
                        "delay_at_lower": delay_at_lower,
                        "delay_at_upper": delay_at_upper,
                    }
                )
                break
        print(json.dumps({"bootstrap_candidates": candidates}, sort_keys=True))
        return 0
    rows: list[dict[str, int]] = []
    base = args.base
    while base < args.target:
        seed = next((x for x, maximum in enumerate(maxima) if maximum >= base), None)
        if seed is None:
            raise RuntimeError(f"seed limit too small for threshold {base}")
        a, b, c, d = farey_bracket(seed)
        length_floor = a + c
        odds_floor = b + d
        ordinary_floor = length_floor + odds_floor
        first_too_long = next(
            ((start, delay) for start, delay in records if delay > ordinary_floor),
            None,
        )
        if first_too_long is None:
            raise RuntimeError(f"delay records exhausted at floor {ordinary_floor}")
        next_start, next_delay = first_too_long
        upper = next_start - 1
        rows.append(
            {
                "base": base,
                "seed": seed,
                "seed_excursion": maxima[seed],
                "a": a,
                "b": b,
                "c": c,
                "d": d,
                "length_floor": length_floor,
                "odds_floor": odds_floor,
                "ordinary_floor": ordinary_floor,
                "first_delay_record_above_floor": next_start,
                "first_delay_above_floor": next_delay,
                "new_upper": upper,
            }
        )
        if upper <= base:
            break
        base = min(upper, args.target)

    print(json.dumps({"rows": rows, "reached": base}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
