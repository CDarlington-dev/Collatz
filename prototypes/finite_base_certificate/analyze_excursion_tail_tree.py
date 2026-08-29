#!/usr/bin/env python3
"""Prototype residue coverage using an exact small-state excursion envelope.

At every symbolic prefix the checker rejects an actual paradoxical prefix.
A node becomes a leaf when all its current states are below ``seed_limit`` and
the exact maximum state ever reached by *any* such tail is below the smallest
represented original start.  This is compositional without any assumption on
the tail multiplier.  The monotone envelope can be stored as its sparse record
changes, although this analysis constructs it directly from exact orbits.

This file measures certificate size only; it is not a trusted verifier.
"""

from __future__ import annotations

import argparse
import collections
import json
import time
from dataclasses import dataclass


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


def build_excursion_envelope(seed_limit: int, max_steps: int) -> tuple[list[int], int, int]:
    """Return E[x] = max state on every orbit with start <= x."""
    envelope: list[int] = []
    running = 0
    record_changes = 0
    points = 0
    for start in range(seed_limit):
        current = start
        local_max = current
        for elapsed in range(max_steps + 1):
            points += 1
            if current <= 1:
                break
            if elapsed == max_steps:
                raise RuntimeError(f"seed {start} did not reach 1 within {max_steps}")
            current = accelerated(current)
            local_max = max(local_max, current)
        if local_max > running:
            running = local_max
            record_changes += 1
        envelope.append(running)
    return envelope, record_changes, points


def parity_interval(lo: int, hi: int, parity: int) -> tuple[int, int] | None:
    first = lo if lo % 2 == parity else lo + 1
    if first > hi:
        return None
    last = hi if hi % 2 == parity else hi - 1
    return (first - parity) // 2, (last - parity) // 2


def advance(node: Node, parameter_parity: int) -> Node | None:
    interval = parity_interval(node.parameter_lo, node.parameter_hi, parameter_parity)
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
        node.depth + 1,
        node.odd_count + int(current_is_odd),
        node.residue + (parameter_parity << node.depth),
        coefficient,
        intercept,
        lo,
        hi,
    )


def paradoxical_prefix(node: Node) -> bool:
    modulus = 1 << node.depth
    return node.coefficient < modulus and (
        node.current(node.parameter_lo) >= node.start(node.parameter_lo)
    )


def analyze(lo: int, hi: int, seed_limit: int, seed_max_steps: int, max_depth: int) -> dict[str, object]:
    database_started = time.perf_counter()
    envelope, record_changes, trajectory_points = build_excursion_envelope(
        seed_limit, seed_max_steps
    )
    database_seconds = time.perf_counter() - database_started
    stack = [Node(0, 0, 0, 1, 0, lo, hi)]
    nodes = leaves = represented = 0
    maximum_depth = maximum_stack = 0
    leaf_depths: collections.Counter[int] = collections.Counter()
    leaf_sizes: collections.Counter[int] = collections.Counter()
    started = time.perf_counter()

    while stack:
        node = stack.pop()
        nodes += 1
        maximum_depth = max(maximum_depth, node.depth)
        if node.depth > 0:
            if paradoxical_prefix(node):
                t = node.parameter_lo
                raise RuntimeError(
                    f"paradoxical prefix n={node.start(t)} j={node.depth} "
                    f"q={node.odd_count} end={node.current(t)}"
                )
            current_hi = node.current(node.parameter_hi)
            if current_hi < seed_limit and envelope[current_hi] < node.start(node.parameter_lo):
                leaves += 1
                represented += node.count
                leaf_depths[node.depth] += 1
                leaf_sizes[node.count.bit_length() - 1] += 1
                continue
        if node.depth >= max_depth:
            raise RuntimeError(f"unresolved node at depth {node.depth}: {node!r}")
        for parity in (0, 1):
            child = advance(node, parity)
            if child is not None:
                stack.append(child)
        maximum_stack = max(maximum_stack, len(stack))

    seconds = time.perf_counter() - started
    if represented != hi - lo + 1:
        raise AssertionError((represented, hi - lo + 1))
    return {
        "domain": {"inclusive_lo": lo, "inclusive_hi": hi, "starts": represented},
        "small_excursion_database": {
            "seed_limit_exclusive": seed_limit,
            "trajectory_points": trajectory_points,
            "record_changes": record_changes,
            "maximum_state": envelope[-1],
            "construction_seconds": database_seconds,
        },
        "tree_seconds": seconds,
        "nodes": nodes,
        "leaves": leaves,
        "maximum_depth": maximum_depth,
        "maximum_stack": maximum_stack,
        "leaf_depth_histogram": dict(sorted(leaf_depths.items())),
        "leaf_size_log2_histogram": dict(sorted(leaf_sizes.items())),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lo", type=int, default=26018)
    parser.add_argument("--hi", type=int, required=True)
    parser.add_argument("--seed-limit", type=int, default=113383)
    parser.add_argument("--seed-max-steps", type=int, default=223)
    parser.add_argument("--max-depth", type=int, default=1000)
    args = parser.parse_args()
    print(json.dumps(analyze(args.lo, args.hi, args.seed_limit, args.seed_max_steps, args.max_depth), sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
