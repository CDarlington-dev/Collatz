#!/usr/bin/env node

// Benchmark a prefix-free accelerated-Collatz residue tree.  A leaf covers
// every n in one residue cylinder intersected with [lower, upper] and proves
// that the recorded affine prefix ends strictly below n.  This is only a
// certificate-size experiment; no result from this file is imported by Lean.

const lower = Number(process.argv[2] ?? "3");
const upper = Number(process.argv[3] ?? "1000000000");
const maxDepth = Number(process.argv[4] ?? "1000");

if (!Number.isSafeInteger(lower) || !Number.isSafeInteger(upper) ||
    lower < 1 || upper < lower) {
  throw new Error("expected safe integer bounds with 1 <= lower <= upper");
}

const lo = BigInt(lower);
const hi = BigInt(upper);

function classBounds(residue, modulus) {
  const first = residue >= lo
    ? residue
    : residue + ((lo - residue + modulus - 1n) / modulus) * modulus;
  if (residue > hi) return null;
  const last = residue + ((hi - residue) / modulus) * modulus;
  return first <= last ? [first, last] : null;
}

function descendsEvery(A, C, modulus, first, last) {
  // (A*n+C)/modulus < n, equivalently
  // (A-modulus)*n+C < 0.  Check the monotone worst endpoint.
  const coefficient = A - modulus;
  const worst = coefficient >= 0n ? last : first;
  return coefficient * worst + C < 0n;
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
let weightedPrefixSteps = 0n;
let maxLeafDepth = 0;
let maxLeafCost = 0;
let maxLeafClassSize = 0n;
const depthHistogram = new Map();

while (stack.length > 0) {
  const node = stack.pop();
  const bounds = classBounds(node.residue, node.modulus);
  if (bounds === null) continue;
  nodes += 1;
  const [first, last] = bounds;
  const count = (last - first) / node.modulus + 1n;

  if (node.depth > 0 && descendsEvery(
      node.A, node.C, node.modulus, first, last)) {
    leaves += 1;
    covered += count;
    weightedPrefixSteps += BigInt(node.depth) * count;
    if (count === 1n) singletonLeaves += 1;
    maxLeafDepth = Math.max(maxLeafDepth, node.depth);
    maxLeafCost = Math.max(maxLeafCost, node.depth + node.odds);
    if (count > maxLeafClassSize) maxLeafClassSize = count;
    depthHistogram.set(node.depth, (depthHistogram.get(node.depth) ?? 0) + 1);
    continue;
  }

  if (node.depth >= maxDepth) {
    throw new Error(
      `depth cap ${maxDepth} reached at residue ${node.residue} mod ${node.modulus}`);
  }

  const nextModulus = 2n * node.modulus;
  for (const residue of [node.residue, node.residue + node.modulus]) {
    const numerator = node.A * residue + node.C;
    if (numerator % node.modulus !== 0n) {
      throw new Error("broken affine divisibility invariant");
    }
    const endpointOdd = ((numerator / node.modulus) & 1n) === 1n;
    stack.push(endpointOdd ? {
      residue,
      modulus: nextModulus,
      A: 3n * node.A,
      C: 3n * node.C + node.modulus,
      depth: node.depth + 1,
      odds: node.odds + 1,
    } : {
      residue,
      modulus: nextModulus,
      A: node.A,
      C: node.C,
      depth: node.depth + 1,
      odds: node.odds,
    });
  }
}

const expected = hi - lo + 1n;
if (covered !== expected) {
  throw new Error(`coverage mismatch: ${covered} != ${expected}`);
}

console.log(JSON.stringify({
  lower,
  upper,
  nodes,
  leaves,
  singletonLeaves,
  covered: covered.toString(),
  weightedPrefixSteps: weightedPrefixSteps.toString(),
  meanPrefixDepth: Number(weightedPrefixSteps) / Number(covered),
  maxLeafDepth,
  maxLeafCost,
  maxLeafClassSize: maxLeafClassSize.toString(),
  depthHistogram: [...depthHistogram.entries()].sort((a, b) => a[0] - b[0]),
}, null, 2));
