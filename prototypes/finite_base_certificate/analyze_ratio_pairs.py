#!/usr/bin/env python3
"""Count (length, odd-count) pairs not ruled out by the universal remainder bound."""

from __future__ import annotations

import argparse
import json
import math


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--max-length", type=int, required=True)
    parser.add_argument("--minimum-start", type=int, required=True)
    args = parser.parse_args()
    rows: list[dict[str, int]] = []
    total_words = 0
    for j in range(1, args.max_length + 1):
        two_j = 1 << j
        power3 = 1
        power2q = 1
        for q in range(j + 1):
            if power3 < two_j:
                # R_max = ((3^q-2^q)/2^q) * 2^j/(2^j-3^q).
                numerator = (power3 - power2q) * two_j
                denominator = power2q * (two_j - power3)
                if numerator >= args.minimum_start * denominator:
                    words = math.comb(j, q)
                    rows.append({"j": j, "q": q, "word_count": words})
                    total_words += words
            power3 *= 3
            power2q <<= 1
    print(
        json.dumps(
            {
                "maximum_length": args.max_length,
                "minimum_start": args.minimum_start,
                "pair_count": len(rows),
                "pairs": rows,
                "sum_binomial_word_counts": total_words,
            },
            sort_keys=True,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
