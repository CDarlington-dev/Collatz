#!/usr/bin/env python3
"""Regenerate the canonical repository-level SHA256SUMS manifest."""

from __future__ import annotations

import hashlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXCLUDED_TOP_LEVEL = {".git", ".lake", ".tooling", ".cache", "build"}
def included(path: Path) -> bool:
    relative = path.relative_to(ROOT)
    return (
        path.is_file()
        and relative.parts[0] not in EXCLUDED_TOP_LEVEL
        and relative.as_posix() != "SHA256SUMS"
        and "__pycache__" not in relative.parts
        and path.suffix != ".pyc"
    )


def main() -> None:
    rows: list[str] = []
    for path in sorted(
        (path for path in ROOT.rglob("*") if included(path)),
        key=lambda path: path.relative_to(ROOT).as_posix(),
    ):
        relative = path.relative_to(ROOT).as_posix()
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        rows.append(f"{digest}  {relative}\n")
    (ROOT / "SHA256SUMS").write_bytes("".join(rows).encode("ascii"))
    print(f"WROTE package SHA-256 manifest: {len(rows)} files")


if __name__ == "__main__":
    main()
