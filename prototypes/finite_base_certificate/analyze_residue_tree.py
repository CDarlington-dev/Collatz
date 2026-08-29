#!/usr/bin/env python3
"""Measure an exact symbolic stopping-time residue tree.

This is an analysis prototype, not a trusted verifier.  A node represents every
integer

    n = residue + 2**depth * parameter

for an inclusive interval of ``parameter`` values.  Its current accelerated
Collatz value is exactly

    current = coefficient * parameter + intercept.

Splitting on the parity of ``parameter`` fixes the parity of ``current`` and
therefore advances every represented start by one exact accelerated step.  A
leaf is accepted only when the current value is strictly below the original
start for the whole parameter interval.  Such leaves are the standard compact
certificate used for strong-induction Collatz convergence proofs; by themselves
they do *not* classify later paradoxical prefixes.
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
    residue: int
    coefficient: int
    intercept: int
    parameter_lo: int
    parameter_hi: int

    @property
    def count(self) -> int:
        return self.parameter_hi - self.parameter_lo + 1


def _parity_interval(lo: int, hi: int, parity: int) -> tuple[int, int] | None:
    first = lo if lo % 2 == parity else lo + 1
    if first > hi:
        return None
    last = hi if hi % 2 == parity else hi - 1
    return (first - parity) // 2, (last - parity) // 2


def _advance(node: Node, parameter_parity: int) -> Node | None:
    interval = _parity_interval(
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
        residue=node.residue + (parameter_parity << node.depth),
        coefficient=coefficient,
        intercept=intercept,
        parameter_lo=lo,
        parameter_hi=hi,
    )


def _all_current_below_start(node: Node) -> bool:
    modulus = 1 << node.depth
    slope = node.coefficient - modulus
    parameter = node.parameter_hi if slope > 0 else node.parameter_lo
    current = node.coefficient * parameter + node.intercept
    start = modulus * parameter + node.residue
    return current < start


def analyze(lo: int, hi: int, max_depth: int) -> dict[str, object]:
    stack = [Node(0, 0, 1, 0, lo, hi)]
    nodes = 0
    leaves = 0
    represented = 0
    maximum_depth = 0
    maximum_frontier = 1
    leaf_depths: collections.Counter[int] = collections.Counter()
    leaf_sizes: collections.Counter[int] = collections.Counter()
    started = time.perf_counter()

    while stack:
        node = stack.pop()
        nodes += 1
        maximum_depth = max(maximum_depth, node.depth)
        if node.depth > 0 and _all_current_below_start(node):
            leaves += 1
            represented += node.count
            leaf_depths[node.depth] += 1
            leaf_sizes[node.count.bit_length() - 1] += 1
            continue
        if node.depth >= max_depth:
            raise RuntimeError(
                f"unresolved node at depth {node.depth}: {node!r}"
            )
        for parity in (0, 1):
            child = _advance(node, parity)
            if child is not None:
                stack.append(child)
        maximum_frontier = max(maximum_frontier, len(stack))

    elapsed = time.perf_counter() - started
    if represented != hi - lo + 1:
        raise AssertionError((represented, hi - lo + 1))
    return {
        "domain": {"inclusive_lo": lo, "inclusive_hi": hi, "starts": represented},
        "elapsed_seconds": elapsed,
        "leaves": leaves,
        "leaf_depth_histogram": dict(sorted(leaf_depths.items())),
        "leaf_size_log2_histogram": dict(sorted(leaf_sizes.items())),
        "maximum_depth": maximum_depth,
        "maximum_stack": maximum_frontier,
        "nodes": nodes,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lo", type=int, default=3)
    parser.add_argument("--hi", type=int, required=True)
    parser.add_argument("--max-depth", type=int, default=1000)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if not (0 <= args.lo <= args.hi):
        parser.error("require 0 <= lo <= hi")
    rendered = json.dumps(analyze(args.lo, args.hi, args.max_depth), sort_keys=True)
    if args.output is None:
        print(rendered)
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered + "\n", encoding="ascii")
        print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
