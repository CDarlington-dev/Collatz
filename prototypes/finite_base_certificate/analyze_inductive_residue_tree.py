#!/usr/bin/env python3
"""Prototype a compositional residue certificate for finite exclusion.

The leaf rule is deliberately stronger than ordinary ``first descent``.
For every start represented by a leaf after ``k`` accelerated steps it checks

* the state is strictly below its own start, and
* ``2**k <= 3**q``, where ``q`` is the prefix odd count.

If a later prefix were paradoxical, the second condition forces its tail from
the smaller state to have multiplier below one.  Its endpoint is at least the
original (hence larger than the tail start), so the tail itself would be a
paradoxical segment.  Strong induction on the start therefore closes the
leaf.  Every earlier node with multiplier below one is also checked to have
endpoint below its start.

This file only measures certificate size; it is not a trusted verifier.
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
        depth=node.depth + 1,
        odd_count=node.odd_count + int(current_is_odd),
        residue=node.residue + (parameter_parity << node.depth),
        coefficient=coefficient,
        intercept=intercept,
        parameter_lo=lo,
        parameter_hi=hi,
    )


def has_paradoxical_member(node: Node) -> bool:
    """Exact for this affine cylinder because the relevant slope is negative."""
    modulus = 1 << node.depth
    return node.coefficient < modulus and (
        node.current(node.parameter_lo) >= node.start(node.parameter_lo)
    )


def inductive_descent_leaf(node: Node) -> bool:
    """Exact all-member test for ``coefficient >= modulus`` and ``current < start``."""
    modulus = 1 << node.depth
    return node.coefficient >= modulus and (
        node.current(node.parameter_hi) < node.start(node.parameter_hi)
    )


def analyze(lo: int, hi: int, max_depth: int) -> dict[str, object]:
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
            if has_paradoxical_member(node):
                t = node.parameter_lo
                raise RuntimeError(
                    f"paradoxical prefix n={node.start(t)} j={node.depth} "
                    f"q={node.odd_count} end={node.current(t)}"
                )
            if node.current(node.parameter_hi) <= 2 or inductive_descent_leaf(node):
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
        "seconds": seconds,
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
    parser.add_argument("--max-depth", type=int, default=10000)
    args = parser.parse_args()
    print(json.dumps(analyze(args.lo, args.hi, args.max_depth), sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
