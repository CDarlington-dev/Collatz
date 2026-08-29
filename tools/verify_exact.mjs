#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { performance } from "node:perf_hooks";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, "..");

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function pow(base, exponent) {
  let b = BigInt(base);
  let e = BigInt(exponent);
  let out = 1n;
  while (e > 0n) {
    if (e & 1n) out *= b;
    e >>= 1n;
    if (e) b *= b;
  }
  return out;
}

function tStep(n) {
  return n & 1n ? (3n * n + 1n) / 2n : n / 2n;
}

function colStep(n) {
  return n & 1n ? 3n * n + 1n : n / 2n;
}

function trajectory(start, step) {
  let n = start;
  let maximum = n;
  let delay = 0n;
  while (n !== 1n) {
    n = step(n);
    if (n > maximum) maximum = n;
    delay += 1n;
    assert(delay < 1000000n, `trajectory guard exceeded at ${start}`);
  }
  return { delay, maximum };
}

function csvRows(filename) {
  const lines = fs.readFileSync(filename, "utf8").split(/\r?\n/)
    .filter((line) => line && !line.startsWith("#"));
  const header = lines.shift().split(",");
  return lines.map((line) => {
    const cells = line.split(",");
    assert(cells.length === header.length, `bad CSV row in ${filename}: ${line}`);
    return Object.fromEntries(header.map((key, i) => [key, cells[i]]));
  });
}

function verifyFarey(filename) {
  const document = JSON.parse(fs.readFileSync(filename, "utf8"));
  assert(document.schema === "collatz-farey-v1", "unexpected Farey schema");
  for (const row of document.certificates) {
    const m = BigInt(row.m), a = BigInt(row.a), b = BigInt(row.b);
    const c = BigInt(row.c), d = BigInt(row.d);
    const j = BigInt(row.optimal_j), q = BigInt(row.optimal_q);
    assert(pow(2n, a) < pow(3n, b), `${row.id}: lower power comparison failed`);
    assert(pow(3n * m + 1n, d) < pow(2n, c) * pow(m, d),
      `${row.id}: upper power comparison failed`);
    assert(b * c === a * d + 1n, `${row.id}: determinant is not one`);
    assert(j === a + c && q === b + d, `${row.id}: endpoint sums differ`);
    assert(pow(3n, q) < pow(2n, j), `${row.id}: optimal coefficient condition failed`);
    assert(pow(2n, j) * pow(m, q) <= pow(3n * m + 1n, q),
      `${row.id}: optimal growth condition failed`);
  }
  return document.certificates.length;
}

function verifyTrajectories(filename) {
  const rows = csvRows(filename);
  for (const row of rows) {
    const start = BigInt(row.start);
    const t = trajectory(start, tStep);
    const col = trajectory(start, colStep);
    assert(t.delay === BigInt(row.t_delay), `${start}: T delay differs`);
    assert(t.maximum === BigInt(row.t_max), `${start}: T maximum differs`);
    assert(col.delay === BigInt(row.col_delay), `${start}: Col delay differs`);
    assert(col.maximum === BigInt(row.col_max), `${start}: Col maximum differs`);
  }
  return rows.length;
}

function verifyWitnesses(filename) {
  const rows = csvRows(filename);
  const counts = new Map();
  const starts = new Set();
  let maximumStart = 0n;
  for (const row of rows) {
    const j = Number(row.j), claimedQ = Number(row.q), start = BigInt(row.n);
    assert(start > 2n && j > 0, `${start}/${j}: convention failed`);
    let n = start, q = 0;
    for (let k = 0; k < j; ++k) {
      if (n & 1n) q += 1;
      n = tStep(n);
    }
    assert(q === claimedQ, `${start}/${j}: odd count ${q} != ${claimedQ}`);
    assert(pow(3n, BigInt(q)) < pow(2n, BigInt(j)), `${start}/${j}: coefficient not < 1`);
    assert(n >= start, `${start}/${j}: endpoint ${n} is below start`);
    const key = `${j},${q}`;
    counts.set(key, (counts.get(key) ?? 0) + 1);
    starts.add(start.toString());
    if (start > maximumStart) maximumStart = start;
  }
  const expected = new Map([
    ["8,5", 5], ["27,17", 50], ["46,29", 231], ["54,34", 2],
    ["65,41", 244], ["73,46", 56], ["92,58", 5],
  ]);
  assert(rows.length === 593, `witness count ${rows.length} != 593`);
  assert(starts.size === 550, `distinct start count ${starts.size} != 550`);
  assert(maximumStart === 4614n, `maximum start ${maximumStart} != 4614`);
  assert(JSON.stringify([...counts]) === JSON.stringify([...expected]), "group counts differ");
  return { rows: rows.length, distinctStarts: starts.size };
}

function sha256(filename) {
  return crypto.createHash("sha256").update(fs.readFileSync(filename)).digest("hex");
}

const files = {
  farey: path.join(root, "certificates", "farey-v1.json"),
  trajectories: path.join(root, "certificates", "trajectory-fixtures-v1.csv"),
  witnesses: path.join(root, "certificates", "published-witnesses-v1.csv"),
};

const started = performance.now();
const fareyCount = verifyFarey(files.farey);
const trajectoryCount = verifyTrajectories(files.trajectories);
const witnessResult = verifyWitnesses(files.witnesses);
const elapsed = (performance.now() - started) / 1000;

console.log(`PASS exact Farey certificates: ${fareyCount}`);
console.log(`PASS exact trajectory fixtures: ${trajectoryCount}`);
console.log(`PASS published paradoxical witnesses: ${witnessResult.rows} (${witnessResult.distinctStarts} starts)`);
for (const [name, filename] of Object.entries(files)) {
  console.log(`SHA256 ${sha256(filename)}  ${path.relative(root, filename).replaceAll("\\", "/")}`);
}
console.log(`Runtime: ${elapsed.toFixed(3)} s on Node ${process.version}`);

