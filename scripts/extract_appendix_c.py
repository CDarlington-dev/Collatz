#!/usr/bin/env python3
"""Extract Appendix C witnesses from a saved arXiv v5 HTML document.

This script deliberately uses only the Python standard library.  It is a
provenance tool, not part of the mathematical checker: the resulting rows are
rechecked from scratch by both exact verifiers and by Lean.
"""

from __future__ import annotations

import argparse
import hashlib
import html
import pathlib
import re


EXPECTED_COUNTS = {
    (8, 5): 5,
    (27, 17): 50,
    (46, 29): 231,
    (54, 34): 2,
    (65, 41): 244,
    (73, 46): 56,
    (92, 58): 5,
}


def extract(source: bytes) -> list[tuple[int, int, int]]:
    text = source.decode("utf-8")
    match = re.search(
        r'<table id="A3\.T2\.1".*?</table>', text, flags=re.DOTALL
    )
    if match is None:
        raise ValueError("Appendix C table A3.T2.1 was not found")

    rows: list[tuple[int, int, int]] = []
    for row_html in re.findall(r"<tr\b.*?</tr>", match.group(0), re.DOTALL):
        pair = re.search(
            r'<annotation encoding="application/x-tex">\((\d+),(\d+)\)</annotation>',
            row_html,
        )
        if pair is None:
            continue
        j, q = map(int, pair.groups())
        paragraphs = re.findall(
            r'<span[^>]*class="ltx_p"[^>]*>(.*?)</span>', row_html, re.DOTALL
        )
        if not paragraphs:
            raise ValueError(f"missing start list for ({j},{q})")
        plain = html.unescape(re.sub(r"<[^>]+>", "", paragraphs[-1]))
        starts = [int(token) for token in re.findall(r"\d+", plain)]
        rows.extend((j, q, n) for n in starts)

    actual: dict[tuple[int, int], int] = {}
    for j, q, _ in rows:
        actual[(j, q)] = actual.get((j, q), 0) + 1
    if actual != EXPECTED_COUNTS:
        raise ValueError(f"group counts differ: expected {EXPECTED_COUNTS}, got {actual}")
    if len(rows) != 593:
        raise ValueError(f"expected 593 rows, got {len(rows)}")
    return rows


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=pathlib.Path)
    parser.add_argument("output", type=pathlib.Path)
    parser.add_argument("--expected-sha256", required=True)
    args = parser.parse_args()

    source = args.source.read_bytes()
    digest = hashlib.sha256(source).hexdigest()
    if digest.lower() != args.expected_sha256.lower():
        raise SystemExit(
            f"source SHA-256 mismatch: expected {args.expected_sha256}, got {digest}"
        )
    rows = extract(source)

    lines = [
        "# collatz-paradox-witnesses-v1",
        f"# source_sha256={digest}",
        "j,q,n",
    ]
    lines.extend(f"{j},{q},{n}" for j, q, n in rows)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"wrote {len(rows)} rows to {args.output} (source SHA-256 {digest})")


if __name__ == "__main__":
    main()

