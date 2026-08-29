#!/usr/bin/env python3
"""Prototype a symbolic full-prefix exclusion tree using certified tail envelopes.

For starts in an interval, parity cylinders are advanced symbolically.  Every
visited prefix is checked for the exact paradoxical inequalities.  A cylinder
may terminate when all of its current values lie below a seed ``S`` whose exact
accelerated maximum-excursion envelope is strictly below every original start
in the cylinder.  Unlike a first-descent tree, that leaf rule excludes *all*
later prefixes and is therefore compositionally adequate for paradoxical
segments.

This Python program measures the prospective certificate.  Its output is not a
proof; the intended Lean checker must reconstruct every affine transition and
accept kernel-checked envelope records for the small seed domain.
"""

from __future__ import annotations

import argparse
import bisect
import collections
import json
import time
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True, slots=True)
class Node:
    depth: int
    odd_count: int
    residue: int
    coefficient: int
    intercept: int
    parameter_lo: int
    parameter_hi: int

    @property
    def count(self) -> int:
        return self.parameter_hi - self.parameter_lo + 1

    def start(self, parameter: int) -> int:
        return (1 << self.depth) * parameter + self.residue

    def current(self, parameter: int) -> int:
        return self.coefficient * parameter + self.intercept


def accelerated(n: int) -> int:
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def prefix_excursion_envelope(seed_limit: int, max_steps: int) -> list[int]:
    """Return H[S] = max orbit value over every 0 <= x < S."""

    maxima = [0] * seed_limit
    maxima[0] = 0
    for start in range(1, seed_limit):
        current = start
        peak = max(start, 2)  # the post-convergence (1,2) tail
        for elapsed in range(max_steps + 1):
            if current == 1:
                break
            if elapsed == max_steps:
                raise RuntimeError(
                    f"seed {start} did not reach 1 within {max_steps}"
                )
            current = accelerated(current)
            peak = max(peak, current)
        maxima[start] = peak
    envelope = [0] * (seed_limit + 1)
    for start, maximum in enumerate(maxima):
        envelope[start + 1] = max(envelope[start], maximum)
    return envelope


def parity_interval(lo: int, hi: int, parity: int) -> tuple[int, int] | None:
    first = lo if lo % 2 == parity else lo + 1
    if first > hi:
        return None
    last = hi if hi % 2 == parity else hi - 1
    return (first - parity) // 2, (last - parity) // 2


def advance(node: Node, parameter_parity: int) -> Node | None:
    interval = parity_interval(
        node.parameter_lo, node.parameter_hi, parameter_parity
    )
    if interval is None:
        return None
    lo, hi = interval
    raw_intercept = node.coefficient * parameter_parity + node.intercept
    current_is_odd = raw_intercept % 2 == 1
    if current_is_odd:
        coefficient = 3 * node.coefficient
        intercept = (3 * raw_intercept + 1) // 2
    else:
        coefficient = node.coefficient
        intercept = raw_intercept // 2
    return Node(
        depth=node.depth + 1,
        odd_count=node.odd_count + int(current_is_odd),
        residue=node.residue + (parameter_parity << node.depth),
        coefficient=coefficient,
        intercept=intercept,
        parameter_lo=lo,
        parameter_hi=hi,
    )


def paradoxical_parameter_stop(node: Node) -> int | None:
    """Exclusive upper parameter for paradoxical starts, if the factor is < 1."""

    modulus = 1 << node.depth
    if node.coefficient >= modulus:
        return None
    # (modulus - coefficient) * t <= intercept - residue.
    remainder = node.intercept - node.residue
    if remainder < 0:
        return node.parameter_lo
    return remainder // (modulus - node.coefficient) + 1


def safe_seed(node: Node, envelope: list[int]) -> int:
    minimum_start = node.start(node.parameter_lo)
    # envelope is nondecreasing.  Find the largest S with H[S] < minimum_start.
    return bisect.bisect_left(envelope, minimum_start) - 1


def analyze(
    lo: int, hi: int, seed_limit: int, seed_max_steps: int, max_depth: int
) -> dict[str, object]:
    envelope_started = time.perf_counter()
    envelope = prefix_excursion_envelope(seed_limit, seed_max_steps)
    envelope_seconds = time.perf_counter() - envelope_started
    stack = [Node(0, 0, 0, 1, 0, lo, hi)]
    nodes = 0
    leaves = 0
    represented = 0
    maximum_depth = 0
    maximum_stack = 1
    leaf_depths: collections.Counter[int] = collections.Counter()
    leaf_sizes: collections.Counter[int] = collections.Counter()
    safe_seeds: collections.Counter[int] = collections.Counter()
    started = time.perf_counter()

    while stack:
        node = stack.pop()
        nodes += 1
        maximum_depth = max(maximum_depth, node.depth)
        if node.depth > 0:
            paradox_stop = paradoxical_parameter_stop(node)
            if paradox_stop is not None and paradox_stop > node.parameter_lo:
                first = node.parameter_lo
                raise RuntimeError(
                    "paradoxical prefix encountered: "
                    f"n={node.start(first)}, j={node.depth}, q={node.odd_count}, "
                    f"end={node.current(first)}"
                )
            seed = safe_seed(node, envelope)
            if seed > 0 and node.current(node.parameter_hi) < seed:
                leaves += 1
                represented += node.count
                leaf_depths[node.depth] += 1
                leaf_sizes[node.count.bit_length() - 1] += 1
                safe_seeds[seed] += 1
                continue
        if node.depth >= max_depth:
            raise RuntimeError(f"unresolved node at depth {node.depth}: {node!r}")
        for parity in (0, 1):
            child = advance(node, parity)
            if child is not None:
                stack.append(child)
        maximum_stack = max(maximum_stack, len(stack))

    elapsed = time.perf_counter() - started
    if represented != hi - lo + 1:
        raise AssertionError((represented, hi - lo + 1))
    return {
        "domain": {"inclusive_lo": lo, "inclusive_hi": hi, "starts": represented},
        "envelope": {
            "seed_limit_exclusive": seed_limit,
            "maximum": envelope[-1],
            "construction_seconds": envelope_seconds,
        },
        "tree_seconds": elapsed,
        "leaves": leaves,
        "leaf_depth_histogram": dict(sorted(leaf_depths.items())),
        "leaf_size_log2_histogram": dict(sorted(leaf_sizes.items())),
        "maximum_depth": maximum_depth,
        "maximum_stack": maximum_stack,
        "nodes": nodes,
        "distinct_safe_seed_indices": len(safe_seeds),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lo", type=int, default=4615)
    parser.add_argument("--hi", type=int, required=True)
    parser.add_argument("--seed-limit", type=int, default=113383)
    parser.add_argument("--seed-max-steps", type=int, default=223)
    parser.add_argument("--max-depth", type=int, default=1000)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = analyze(
        args.lo,
        args.hi,
        args.seed_limit,
        args.seed_max_steps,
        args.max_depth,
    )
    rendered = json.dumps(result, sort_keys=True)
    if args.output is None:
        print(rendered)
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered + "\n", encoding="ascii")
        print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
