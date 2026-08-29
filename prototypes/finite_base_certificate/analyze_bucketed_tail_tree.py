#!/usr/bin/env python3
"""Measure a bucketed filtered-tail residue certificate.

This is an analysis prototype, not a trusted verifier.  It refines
``analyze_filtered_tail_tree.py`` by using an exact interval maximum over the
small-state database instead of one maximum over every state below the seed
limit.  Fixed buckets are conservative: a symbolic node whose current values
lie in ``[xlo,xhi]`` is checked against every small start in every intersecting
bucket.  Cached bucket queries make it possible to measure whether this
stronger leaf rule yields a genuinely compact proof certificate.
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


def build_small_trajectories(
    seed_limit: int, max_steps: int
) -> list[list[tuple[int, int, int]]]:
    trajectories: list[list[tuple[int, int, int]]] = []
    for start in range(seed_limit):
        if start == 0:
            trajectories.append([(0, 0, 0)])
            continue
        current = start
        odds = 0
        trajectory = [(0, 0, current)]
        for elapsed in range(max_steps + 1):
            if current == 1:
                trajectory.append((elapsed + 1, odds + 1, 2))
                break
            if elapsed == max_steps:
                raise RuntimeError(
                    f"seed {start} did not reach 1 within {max_steps}"
                )
            odds += current & 1
            current = accelerated(current)
            trajectory.append((elapsed + 1, odds, current))
        trajectories.append(trajectory)
    return trajectories


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


def factor_below_one(k: int, q: int, s: int, p: int) -> bool:
    return pow(3, q + p) < (1 << (k + s))


class BucketBounds:
    def __init__(
        self,
        trajectories: list[list[tuple[int, int, int]]],
        bucket_size: int,
    ) -> None:
        self.trajectories = trajectories
        self.bucket_size = bucket_size
        self.bucket_cache: dict[tuple[int, int, int], int] = {}
        self.point_cache: dict[tuple[int, int, int], int] = {}
        self.bucket_scans = 0
        self.point_scans = 0

    def point(self, x: int, k: int, q: int) -> int:
        key = (x, k, q)
        cached = self.point_cache.get(key)
        if cached is not None:
            return cached
        answer = 0
        for s, p, state in self.trajectories[x]:
            if factor_below_one(k, q, s, p):
                answer = max(answer, state)
        self.point_cache[key] = answer
        self.point_scans += 1
        return answer

    def bucket(self, b: int, k: int, q: int) -> int:
        key = (b, k, q)
        cached = self.bucket_cache.get(key)
        if cached is not None:
            return cached
        lo = b * self.bucket_size
        hi = min(len(self.trajectories), lo + self.bucket_size)
        answer = max(self.point(x, k, q) for x in range(lo, hi))
        self.bucket_cache[key] = answer
        self.bucket_scans += 1
        return answer

    def interval(self, lo: int, hi: int, k: int, q: int) -> int:
        """Conservative maximum for every integer ``x`` in ``[lo,hi]``."""
        if lo > hi:
            return 0
        first_full = (lo + self.bucket_size - 1) // self.bucket_size
        last_full_exclusive = (hi + 1) // self.bucket_size
        answer = 0
        left_stop = min(hi + 1, first_full * self.bucket_size)
        for x in range(lo, left_stop):
            answer = max(answer, self.point(x, k, q))
        for b in range(first_full, last_full_exclusive):
            answer = max(answer, self.bucket(b, k, q))
        right_start = max(lo, last_full_exclusive * self.bucket_size)
        for x in range(right_start, hi + 1):
            answer = max(answer, self.point(x, k, q))
        return answer


def analyze(
    lo: int,
    hi: int,
    seed_limit: int,
    seed_max_steps: int,
    bucket_size: int,
    max_depth: int,
) -> dict[str, object]:
    database_started = time.perf_counter()
    trajectories = build_small_trajectories(seed_limit, seed_max_steps)
    database_seconds = time.perf_counter() - database_started
    bounds = BucketBounds(trajectories, bucket_size)
    stack = [Node(0, 0, 0, 1, 0, lo, hi)]
    nodes = leaves = represented = terminal_leaves = 0
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
            current_lo = node.current(node.parameter_lo)
            current_hi = node.current(node.parameter_hi)
            minimum_start = node.start(node.parameter_lo)
            accepted = False
            if current_hi <= 2:
                terminal_leaves += 1
                accepted = True
            elif current_hi < seed_limit:
                tail_bound = bounds.interval(
                    current_lo, current_hi, node.depth, node.odd_count
                )
                accepted = tail_bound < minimum_start
            if accepted:
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

    tree_seconds = time.perf_counter() - started
    if represented != hi - lo + 1:
        raise AssertionError((represented, hi - lo + 1))
    return {
        "domain": {"inclusive_lo": lo, "inclusive_hi": hi, "starts": represented},
        "small_tail_database": {
            "seed_limit_exclusive": seed_limit,
            "trajectory_points": sum(map(len, trajectories)),
            "construction_seconds": database_seconds,
        },
        "bucket_size": bucket_size,
        "tree_seconds": tree_seconds,
        "nodes": nodes,
        "leaves": leaves,
        "terminal_leaves": terminal_leaves,
        "bucket_queries": len(bounds.bucket_cache),
        "point_queries": len(bounds.point_cache),
        "bucket_scans": bounds.bucket_scans,
        "point_scans": bounds.point_scans,
        "maximum_depth": maximum_depth,
        "maximum_stack": maximum_stack,
        "leaf_depth_histogram": dict(sorted(leaf_depths.items())),
        "leaf_size_log2_histogram": dict(sorted(leaf_sizes.items())),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lo", type=int, default=4615)
    parser.add_argument("--hi", type=int, required=True)
    parser.add_argument("--seed-limit", type=int, default=113383)
    parser.add_argument("--seed-max-steps", type=int, default=223)
    parser.add_argument("--bucket-size", type=int, default=64)
    parser.add_argument("--max-depth", type=int, default=1000)
    args = parser.parse_args()
    print(
        json.dumps(
            analyze(
                args.lo,
                args.hi,
                args.seed_limit,
                args.seed_max_steps,
                args.bucket_size,
                args.max_depth,
            ),
            sort_keys=True,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
