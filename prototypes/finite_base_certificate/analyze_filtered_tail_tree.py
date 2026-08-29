#!/usr/bin/env python3
"""Prototype coefficient-filtered tail leaves for full finite classification.

This refines ``analyze_full_safe_tree.py``.  A tail leaf uses the *same total
coefficient inequality* as the paradoxical predicate: after a symbolic prefix
of length ``k`` and odd count ``q``, it bounds only tail endpoints with

    3**(q + tail_odds) < 2**(k + tail_length).

The small-tail database covers starts below 113383 and is independently
recomputed here.  Global leaves use a conservative envelope over that whole
seed interval.  Tiny residual cylinders may use pointwise small-tail queries;
the output counts those concrete queries because they would need explicit
kernel-checkable support in a real certificate.
"""

from __future__ import annotations

import argparse
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


def build_small_trajectories(
    seed_limit: int, max_steps: int
) -> tuple[list[list[tuple[int, int, int]]], dict[tuple[int, int], int]]:
    trajectories: list[list[tuple[int, int, int]]] = []
    global_max: dict[tuple[int, int], int] = {}
    for start in range(seed_limit):
        if start == 0:
            trajectory = [(0, 0, 0)]
        else:
            current = start
            odds = 0
            trajectory = [(0, 0, current)]
            for elapsed in range(max_steps + 1):
                if current == 1:
                    # Add the other state of the terminal accelerated cycle.
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
        for length, odds, state in trajectory:
            key = (length, odds)
            global_max[key] = max(global_max.get(key, 0), state)
    return trajectories, global_max


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
    if node.coefficient >= modulus:
        return False
    t = node.parameter_lo
    return node.current(t) >= node.start(t)


def factor_below_one(k: int, q: int, s: int, p: int) -> bool:
    return pow(3, q + p) < (1 << (k + s))


def global_tail_bound(
    k: int,
    q: int,
    global_max: dict[tuple[int, int], int],
    cache: dict[tuple[int, int], int],
) -> int:
    key = (k, q)
    cached = cache.get(key)
    if cached is not None:
        return cached
    answer = 0
    for (s, p), state in global_max.items():
        if factor_below_one(k, q, s, p):
            answer = max(answer, state)
    cache[key] = answer
    return answer


def point_tail_bound(
    x: int, k: int, q: int, trajectories: list[list[tuple[int, int, int]]]
) -> int:
    answer = 0
    for s, p, state in trajectories[x]:
        if factor_below_one(k, q, s, p):
            answer = max(answer, state)
    return answer


def analyze(
    lo: int,
    hi: int,
    seed_limit: int,
    seed_max_steps: int,
    point_leaf_size: int,
    max_depth: int,
) -> dict[str, object]:
    database_started = time.perf_counter()
    trajectories, global_max = build_small_trajectories(seed_limit, seed_max_steps)
    database_seconds = time.perf_counter() - database_started
    global_cache: dict[tuple[int, int], int] = {}
    stack = [Node(0, 0, 0, 1, 0, lo, hi)]
    nodes = leaves = represented = concrete_queries = 0
    global_leaves = point_leaves = terminal_leaves = 0
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
            minimum_start = node.start(node.parameter_lo)
            accepted = False
            if current_hi <= 2:
                terminal_leaves += 1
                accepted = True
            elif current_hi < seed_limit:
                bound = global_tail_bound(
                    node.depth, node.odd_count, global_max, global_cache
                )
                if bound < minimum_start:
                    global_leaves += 1
                    accepted = True
                elif node.count <= point_leaf_size:
                    good = True
                    for t in range(node.parameter_lo, node.parameter_hi + 1):
                        concrete_queries += 1
                        x = node.current(t)
                        n = node.start(t)
                        if point_tail_bound(
                            x, node.depth, node.odd_count, trajectories
                        ) >= n:
                            good = False
                            break
                    if good:
                        point_leaves += 1
                        accepted = True
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
            "distinct_length_odd_pairs": len(global_max),
            "construction_seconds": database_seconds,
        },
        "tree_seconds": tree_seconds,
        "nodes": nodes,
        "leaves": leaves,
        "global_envelope_leaves": global_leaves,
        "pointwise_leaves": point_leaves,
        "terminal_leaves": terminal_leaves,
        "pointwise_tail_queries": concrete_queries,
        "global_query_pairs": len(global_cache),
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
    parser.add_argument("--point-leaf-size", type=int, default=16)
    parser.add_argument("--max-depth", type=int, default=1000)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = analyze(
        args.lo,
        args.hi,
        args.seed_limit,
        args.seed_max_steps,
        args.point_leaf_size,
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
