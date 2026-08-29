#!/usr/bin/env node

// Prototype a prefix-free accelerated-Collatz residue tree.  A leaf certifies
// that every represented n in [lower, upper] reaches at most n/2 after the
// recorded accelerated parity prefix.

const lower = Number(process.argv[2] ?? "10015");
const upper = Number(process.argv[3] ?? "1000000000");
const maxDepth = Number(process.argv[4] ?? "1000");
const targetNumerator = BigInt(process.argv[5] ?? "1");
const targetDenominator = BigInt(process.argv[6] ?? "2");
const absoluteCutoff = process.argv[7] === undefined ? null : BigInt(process.argv[7]);

if (!Number.isSafeInteger(lower) || !Number.isSafeInteger(upper) ||
    lower < 1 || upper < lower) {
  throw new Error("expected safe integer bounds with 1 <= lower <= upper");
}

const lo = BigInt(lower);
const hi = BigInt(upper);

function firstInClass(residue, modulus) {
  if (residue >= lo) return residue;
  return residue + ((lo - residue + modulus - 1n) / modulus) * modulus;
}

function lastInClass(residue, modulus) {
  if (residue > hi) return null;
  return residue + ((hi - residue) / modulus) * modulus;
}

function classBounds(residue, modulus) {
  const first = firstInClass(residue, modulus);
  const last = lastInClass(residue, modulus);
  if (last === null || first > last) return null;
  return [first, last];
}

function endpointNumerator(A, C, n) {
  return A * n + C;
}

function contractsEvery(A, C, modulus, first, last) {
  if (absoluteCutoff !== null) {
    return A * last + C < absoluteCutoff * modulus;
  }
  // targetDenominator * endpoint <= targetNumerator * n.
  const coefficient = targetDenominator * A - targetNumerator * modulus;
  const worst = coefficient >= 0n ? last : first;
  return coefficient * worst + targetDenominator * C <= 0n;
}

const stack = [{
  residue: 0n,
  modulus: 1n,
  A: 1n,
  C: 0n,
  depth: 0,
  odds: 0,
}];

let nodes = 0;
let leaves = 0;
let singletonLeaves = 0;
let covered = 0n;
let maxLeafDepth = 0;
let maxLeafCost = 0;
let maxLeafWidth = 0n;
const depthHistogram = new Map();

while (stack.length > 0) {
  const node = stack.pop();
  const bounds = classBounds(node.residue, node.modulus);
  if (bounds === null) continue;
  nodes += 1;
  const [first, last] = bounds;
  const count = (last - first) / node.modulus + 1n;

  if (node.depth > 0 && contractsEvery(
      node.A, node.C, node.modulus, first, last)) {
    leaves += 1;
    covered += count;
    if (count === 1n) singletonLeaves += 1;
    maxLeafDepth = Math.max(maxLeafDepth, node.depth);
    maxLeafCost = Math.max(maxLeafCost, node.depth + node.odds);
    maxLeafWidth = maxLeafWidth > count ? maxLeafWidth : count;
    depthHistogram.set(node.depth, (depthHistogram.get(node.depth) ?? 0) + 1);
    continue;
  }

  if (node.depth >= maxDepth) {
    throw new Error(
      `depth cap ${maxDepth} reached at residue ${node.residue} mod ${node.modulus}`);
  }

  const nextModulus = 2n * node.modulus;
  for (const residue of [node.residue, node.residue + node.modulus]) {
    const numerator = endpointNumerator(node.A, node.C, residue);
    if (numerator % node.modulus !== 0n) {
      throw new Error("broken affine divisibility invariant");
    }
    const endpointParity = (numerator / node.modulus) & 1n;
    if (endpointParity === 0n) {
      stack.push({
        residue,
        modulus: nextModulus,
        A: node.A,
        C: node.C,
        depth: node.depth + 1,
        odds: node.odds,
      });
    } else {
      stack.push({
        residue,
        modulus: nextModulus,
        A: 3n * node.A,
        C: 3n * node.C + node.modulus,
        depth: node.depth + 1,
        odds: node.odds + 1,
      });
    }
  }
}

const expected = hi - lo + 1n;
if (covered !== expected) {
  throw new Error(`coverage mismatch: ${covered} != ${expected}`);
}

const histogram = [...depthHistogram.entries()].sort((a, b) => a[0] - b[0]);
console.log(JSON.stringify({
  lower,
  upper,
  contraction: absoluteCutoff === null
    ? `${targetNumerator}/${targetDenominator}`
    : `endpoint<${absoluteCutoff}`,
  nodes,
  leaves,
  singletonLeaves,
  covered: covered.toString(),
  maxLeafDepth,
  maxLeafCost,
  maxLeafClassSize: maxLeafWidth.toString(),
  depthHistogram: histogram,
}, null, 2));
