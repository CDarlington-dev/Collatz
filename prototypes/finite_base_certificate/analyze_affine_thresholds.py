#!/usr/bin/env python3
"""Summarize the universal affine start bound by segment length."""

from __future__ import annotations

import argparse
import json


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--max-length", type=int, default=616)
    parser.add_argument(
        "--thresholds",
        default="4615,10000,100000,1000000,10000000,100000000,1000000000",
    )
    parser.add_argument(
        "--lengths",
        default="27,29,32,40,46,54,65,92,114,221,447,616",
        help="comma-separated lengths for which to print every qualifying q and its cap",
    )
    parser.add_argument(
        "--pair-list-limit",
        type=int,
        default=32,
        help="omit the full pair list when a selected length has more entries",
    )
    args = parser.parse_args()
    maxima: list[int] = [0]
    witnesses: list[int] = [0]
    for j in range(1, args.max_length + 1):
        best = 0
        best_q = 0
        two_j = 1 << j
        for q in range(j + 1):
            three_q = pow(3, q)
            if three_q >= two_j:
                continue
            numerator = (1 << (j - q)) * (three_q - (1 << q))
            bound = numerator // (two_j - three_q)
            if bound > best:
                best = bound
                best_q = q
        maxima.append(best)
        witnesses.append(best_q)
    threshold_rows = []
    for threshold in map(int, args.thresholds.split(",")):
        first = next((j for j, maximum in enumerate(maxima) if maximum >= threshold), None)
        pair_count = 0
        maximum_qs_at_one_length = 0
        for j in range(1, args.max_length + 1):
            qualifying = 0
            two_j = 1 << j
            for q in range(j + 1):
                three_q = pow(3, q)
                if three_q >= two_j:
                    continue
                numerator = (1 << (j - q)) * (three_q - (1 << q))
                if numerator >= threshold * (two_j - three_q):
                    qualifying += 1
            pair_count += qualifying
            maximum_qs_at_one_length = max(maximum_qs_at_one_length, qualifying)
        threshold_rows.append(
            {
                "minimum_start": threshold,
                "first_possible_length": first,
                "witness_q": None if first is None else witnesses[first],
                "universal_bound_at_length": None if first is None else maxima[first],
                "qualifying_length_odd_pairs": pair_count,
                "maximum_qualifying_qs_at_one_length": maximum_qs_at_one_length,
            }
        )
    selected_lengths = []
    minimum_threshold = min(map(int, args.thresholds.split(",")))
    for j in map(int, args.lengths.split(",")):
        if not 1 <= j <= args.max_length:
            continue
        pairs = []
        two_j = 1 << j
        for q in range(j + 1):
            three_q = pow(3, q)
            if three_q >= two_j:
                continue
            numerator = (1 << (j - q)) * (three_q - (1 << q))
            bound = numerator // (two_j - three_q)
            if bound >= minimum_threshold:
                pairs.append({"q": q, "maximum_start": bound})
        selected_lengths.append(
            {
                "length": j,
                "qualifying_pairs":
                    pairs if len(pairs) <= args.pair_list_limit else None,
                "minimum_q": None if not pairs else pairs[0]["q"],
                "maximum_q": None if not pairs else pairs[-1]["q"],
                "number_of_qualifying_qs": len(pairs),
                "maximum_start": max((p["maximum_start"] for p in pairs), default=0),
            }
        )
    print(
        json.dumps(
            {
                "maximum_length": args.max_length,
                "thresholds": threshold_rows,
                "selected_lengths": selected_lengths,
                "maximum_universal_bound": max(maxima),
                "length_of_maximum": maxima.index(max(maxima)),
            },
            sort_keys=True,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
