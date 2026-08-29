#!/usr/bin/env python3
"""Independently verify workspace-relative SHA-256 source manifests."""

from __future__ import annotations

import argparse
import hashlib
import re
from pathlib import Path, PurePosixPath


LINE = re.compile(r"^([0-9a-f]{64})  (.+)$")


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def safe_workspace_path(root: Path, spelling: str) -> Path:
    normalized = spelling.replace("\\", "/")
    logical = PurePosixPath(normalized)
    if logical.is_absolute() or not logical.parts or ".." in logical.parts:
        raise ValueError(f"unsafe manifest path: {spelling!r}")
    candidate = root.joinpath(*logical.parts).resolve()
    candidate.relative_to(root)
    return candidate


def verify(root: Path, manifest: Path) -> int:
    failures = 0
    seen: set[str] = set()
    rows = manifest.read_text(encoding="ascii").splitlines()
    if not rows:
        raise ValueError("empty manifest")
    for line_number, line in enumerate(rows, 1):
        match = LINE.fullmatch(line)
        if match is None:
            print(f"FAIL line {line_number}: non-canonical row")
            failures += 1
            continue
        expected, spelling = match.groups()
        canonical = spelling.replace("\\", "/")
        if canonical in seen:
            print(f"FAIL line {line_number}: duplicate path {canonical}")
            failures += 1
            continue
        seen.add(canonical)
        try:
            path = safe_workspace_path(root, spelling)
        except (ValueError, OSError) as error:
            print(f"FAIL line {line_number}: {error}")
            failures += 1
            continue
        if not path.is_file():
            print(f"FAIL line {line_number}: missing {canonical}")
            failures += 1
            continue
        actual = digest(path)
        if actual != expected:
            print(
                f"FAIL line {line_number}: {canonical}\n"
                f"  expected {expected}\n  actual   {actual}"
            )
            failures += 1
    if failures:
        print(f"FAILED: {failures} error(s), {len(rows)} row(s)")
        return 1
    print(
        f"PASSED: {len(rows)} unique file(s); "
        f"manifest_sha256={digest(manifest)}"
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="workspace root (defaults to the verifier's parent workspace)",
    )
    args = parser.parse_args()
    root = args.root.resolve()
    manifest = args.manifest.resolve()
    manifest.relative_to(root)
    return verify(root, manifest)


if __name__ == "__main__":
    raise SystemExit(main())
