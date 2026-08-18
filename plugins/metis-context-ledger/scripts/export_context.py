#!/usr/bin/env python3
"""Export a Metis context workspace as a portable memory directory."""

from __future__ import annotations

import argparse
import json
import shutil
import sys
import time
import uuid
from datetime import UTC, datetime
from pathlib import Path
from typing import Final

REQUIRED_FILES: Final = (
    "MEMORY.md",
    "goal.md",
    "todo.md",
    "delegation-queue.md",
    "information-index.md",
    "learnings.md",
)
MAX_CLOCK_SKEW_MS: Final = 60_000


class ExportError(Exception):
    """Raised when a complete, valid export cannot be created."""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export .metis/context as a portable context directory."
    )
    parser.add_argument(
        "--workspace",
        type=Path,
        default=Path(".metis/context"),
        help="Source context directory (default: .metis/context).",
    )
    parser.add_argument(
        "--output-root",
        type=Path,
        default=Path(".metis/exports"),
        help="Parent directory for exports (default: .metis/exports).",
    )
    parser.add_argument(
        "--git-commit",
        help="Optional Git commit recorded in export.json.",
    )
    return parser.parse_args()


def validate_source(workspace: Path) -> None:
    if not workspace.is_dir():
        raise ExportError(f"context workspace does not exist: {workspace}")

    missing = [name for name in REQUIRED_FILES if not (workspace / name).is_file()]
    if missing:
        joined = ", ".join(missing)
        raise ExportError(f"context workspace is missing required files: {joined}")


def validate_uuid7(value: str) -> str:
    try:
        parsed = uuid.UUID(value)
    except ValueError as exc:
        raise ExportError("UUID backend returned an invalid value") from exc

    if parsed.version != 7:
        raise ExportError("UUID backend did not return UUIDv7")

    timestamp_ms = parsed.int >> 80
    now_ms = time.time_ns() // 1_000_000
    if abs(now_ms - timestamp_ms) > MAX_CLOCK_SKEW_MS:
        raise ExportError(
            "UUIDv7 timestamp is invalid; use Python 3.14+ or DuckDB 1.3.1+"
        )
    return str(parsed)


def generate_uuid7() -> str:
    native_uuid7 = getattr(uuid, "uuid7", None)
    if native_uuid7 is not None:
        return validate_uuid7(str(native_uuid7()))

    try:
        # DuckDB is an optional compatibility feature for Python before 3.14.
        import duckdb
    except ModuleNotFoundError as exc:
        raise ExportError(
            "UUIDv7 requires Python 3.14+ or DuckDB 1.3.1+; install the "
            'fallback with: python3 -m pip install "duckdb>=1.3.1"'
        ) from exc

    row = duckdb.sql("SELECT CAST(uuidv7() AS VARCHAR)").fetchone()
    if row is None or row[0] is None:
        raise ExportError("DuckDB did not return a UUIDv7 value")
    return validate_uuid7(str(row[0]))


def create_export(
    workspace: Path,
    output_root: Path,
    git_commit: str | None,
) -> Path:
    workspace = workspace.expanduser().resolve()
    output_root = output_root.expanduser().resolve()
    validate_source(workspace)

    export_id = generate_uuid7()
    output_root.mkdir(parents=True, exist_ok=True)
    destination = output_root / f"exp_{export_id}"
    staging = output_root / f".exp_{export_id}.tmp"
    staging.mkdir()

    try:
        for name in REQUIRED_FILES:
            shutil.copy2(workspace / name, staging / name)

        metadata: dict[str, object] = {
            "format_version": 1,
            "export_id": export_id,
            "created_at": datetime.now(UTC)
            .isoformat(timespec="milliseconds")
            .replace("+00:00", "Z"),
            "entrypoint": "MEMORY.md",
        }
        if git_commit is not None and git_commit.strip():
            metadata["git_commit"] = git_commit.strip()

        (staging / "export.json").write_text(
            json.dumps(metadata, indent=2) + "\n",
            encoding="utf-8",
        )
        staging.rename(destination)
    except Exception:
        shutil.rmtree(staging, ignore_errors=True)
        raise

    return destination


def main() -> int:
    args = parse_args()
    try:
        destination = create_export(
            workspace=args.workspace,
            output_root=args.output_root,
            git_commit=args.git_commit,
        )
    except (ExportError, OSError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    print(destination)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
