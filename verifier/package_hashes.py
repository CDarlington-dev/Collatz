#!/usr/bin/env python3
"""Verify the repository-level SHA256SUMS manifest with Python's stdlib."""

from __future__ import annotations

import hashlib
import pathlib
import re
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
LINE = re.compile(r"^([0-9a-f]{64})  (.+)$")


def main() -> int:
    manifest = ROOT / "SHA256SUMS"
    seen: set[str] = set()
    count = 0
    for number, line in enumerate(manifest.read_text(encoding="ascii").splitlines(), 1):
        if not line:
            continue
        match = LINE.fullmatch(line)
        if match is None:
            raise ValueError(f"SHA256SUMS:{number}: non-canonical row")
        expected, relative = match.groups()
        if relative in seen:
            raise ValueError(f"SHA256SUMS:{number}: duplicate path {relative}")
        seen.add(relative)
        path = ROOT / pathlib.PurePosixPath(relative)
        if not path.is_file():
            raise ValueError(f"SHA256SUMS:{number}: missing file {relative}")
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != expected:
            raise ValueError(
                f"SHA256SUMS:{number}: {relative}: expected {expected}, got {actual}"
            )
        count += 1
    print(f"PASS package SHA-256 manifest: {count} files")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as error:
        print(f"FAIL package SHA-256 manifest: {error}", file=sys.stderr)
        raise SystemExit(1)
