#!/usr/bin/env python3
"""Launch and inspect detached local jobs without model polling."""

from __future__ import annotations

import argparse
import json
import os
import re
import secrets
import shlex
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SCHEMA_VERSION = 1
TERMINAL_STATES = frozenset({"succeeded", "failed", "lost"})


def _utc_now() -> str:
    return (
        datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
    )


def _atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    temporary_path.write_text(content, encoding="utf-8")
    temporary_path.replace(path)


def _write_status(run_dir: Path, status: dict[str, Any]) -> None:
    _atomic_write(
        run_dir / "status.json", json.dumps(status, indent=2, sort_keys=True) + "\n"
    )


def _read_status(run_dir: Path) -> dict[str, Any]:
    status_path = run_dir / "status.json"
    if not status_path.is_file():
        raise ValueError(f"status file does not exist: {status_path}")
    value = json.loads(status_path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"status file is not a JSON object: {status_path}")
    return value


def _write_terminal(run_dir: Path, status: dict[str, Any]) -> None:
    terminal = {
        "exit_code": status.get("exit_code"),
        "finished_at": status.get("finished_at"),
        "run_id": status["run_id"],
        "state": status["state"],
    }
    _atomic_write(
        run_dir / "terminal.json", json.dumps(terminal, separators=(",", ":")) + "\n"
    )


def _git_metadata(cwd: Path) -> tuple[str | None, bool | None]:
    revision = subprocess.run(
        ["git", "-C", str(cwd), "rev-parse", "HEAD"],
        check=False,
        capture_output=True,
        text=True,
    )
    if revision.returncode != 0:
        return None, None

    dirty = subprocess.run(
        ["git", "-C", str(cwd), "diff-index", "--quiet", "HEAD", "--"],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    tracked_dirty = None if dirty.returncode not in {0, 1} else dirty.returncode == 1
    return revision.stdout.strip(), tracked_dirty


def _normalize_name(name: str) -> str:
    normalized = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")[:48]
    return normalized or "job"


def _run_directory(root: Path, name: str) -> Path:
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    return root / f"{timestamp}-{_normalize_name(name)}-{secrets.token_hex(4)}"


def _default_root() -> Path:
    configured = os.environ.get("METIS_RUNS_DIR")
    return (
        Path(configured).expanduser()
        if configured
        else Path(tempfile.gettempdir()) / "metis-long-jobs"
    )


def _summary(run_dir: Path, status: dict[str, Any]) -> dict[str, Any]:
    milestone_path = run_dir / "milestone.txt"
    milestone = (
        milestone_path.read_text(encoding="utf-8").strip()[:500]
        if milestone_path.is_file()
        else None
    )
    return {
        "exit_code": status.get("exit_code"),
        "finished_at": status.get("finished_at"),
        "log_path": status["log_path"],
        "milestone": milestone,
        "process_pid": status.get("process_pid"),
        "run_dir": str(run_dir),
        "run_id": status["run_id"],
        "sentinel_path": status["sentinel_path"],
        "started_at": status["started_at"],
        "state": status["state"],
        "status_path": str(run_dir / "status.json"),
        "supervisor_pid": status.get("supervisor_pid"),
    }


def _emit(value: dict[str, Any], *, stream: Any = sys.stdout) -> None:
    stream.write(json.dumps(value, separators=(",", ":"), sort_keys=True) + "\n")
    stream.flush()


def _process_is_alive(pid: object) -> bool:
    if not isinstance(pid, int) or pid <= 0:
        return False
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def _mark_lost_if_needed(run_dir: Path, status: dict[str, Any]) -> dict[str, Any]:
    if status.get("state") != "running" or (run_dir / "terminal.json").is_file():
        return status
    if _process_is_alive(status.get("supervisor_pid")) or _process_is_alive(
        status.get("process_pid")
    ):
        return status

    status.update(
        state="lost",
        finished_at=_utc_now(),
        error="supervisor and child exited without writing a terminal sentinel",
    )
    _write_status(run_dir, status)
    _write_terminal(run_dir, status)
    return status


def _finish(
    run_dir: Path, status: dict[str, Any], exit_code: int, error: str | None = None
) -> None:
    status.update(
        state="succeeded" if exit_code == 0 else "failed",
        exit_code=exit_code,
        finished_at=_utc_now(),
    )
    if error is not None:
        status["error"] = error
    _write_status(run_dir, status)
    _write_terminal(run_dir, status)


def _supervise(run_dir: Path) -> int:
    status = _read_status(run_dir)
    command = status["command"]
    environment = os.environ.copy()
    environment.update(
        METIS_LONG_JOB_CLI=str(Path(__file__).resolve()),
        METIS_MILESTONE_PATH=str(run_dir / "milestone.txt"),
        METIS_RUN_DIR=str(run_dir),
    )

    with (run_dir / "run.log").open("ab", buffering=0) as log_file:
        try:
            process = subprocess.Popen(
                command,
                cwd=status["cwd"],
                env=environment,
                stdin=subprocess.DEVNULL,
                stdout=log_file,
                stderr=subprocess.STDOUT,
                close_fds=True,
            )
        except FileNotFoundError as error:
            message = f"executable not found: {error}"
            log_file.write(f"[metis] {message}\n".encode())
            _finish(run_dir, status, 127, message)
            return 127
        except PermissionError as error:
            message = f"executable is not runnable: {error}"
            log_file.write(f"[metis] {message}\n".encode())
            _finish(run_dir, status, 126, message)
            return 126
        except OSError as error:
            message = f"could not start command: {error}"
            log_file.write(f"[metis] {message}\n".encode())
            _finish(run_dir, status, 125, message)
            return 125

        status.update(
            state="running", supervisor_pid=os.getpid(), process_pid=process.pid
        )
        _write_status(run_dir, status)
        exit_code = process.wait()

    _finish(run_dir, status, exit_code)
    return exit_code


def _start(args: argparse.Namespace) -> int:
    command = list(args.command)
    if command[:1] == ["--"]:
        command = command[1:]
    if not command:
        raise ValueError("a command is required after --")

    cwd = args.cwd.expanduser().resolve(strict=True)
    if not cwd.is_dir():
        raise ValueError(f"working directory is not a directory: {cwd}")
    run_dir = _run_directory(args.root.expanduser().resolve(), args.name)
    run_dir.mkdir(parents=True)
    code_sha, code_dirty_tracked = _git_metadata(cwd)
    status: dict[str, Any] = {
        "code_dirty_tracked": code_dirty_tracked,
        "code_sha": code_sha,
        "command": command,
        "command_display": shlex.join(command),
        "cwd": str(cwd),
        "exit_code": None,
        "finished_at": None,
        "log_path": str(run_dir / "run.log"),
        "name": args.name,
        "parameters": command[1:],
        "process_pid": None,
        "run_id": run_dir.name,
        "schema_version": SCHEMA_VERSION,
        "sentinel_path": str(run_dir / "terminal.json"),
        "started_at": _utc_now(),
        "state": "starting",
        "supervisor_pid": None,
    }
    _write_status(run_dir, status)

    supervisor = subprocess.Popen(
        [sys.executable, str(Path(__file__).resolve()), "_supervise", str(run_dir)],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        close_fds=True,
        start_new_session=True,
    )
    deadline = time.monotonic() + 2.0
    while time.monotonic() < deadline:
        status = _read_status(run_dir)
        if status["state"] != "starting":
            break
        if supervisor.poll() is not None:
            _finish(
                run_dir,
                status,
                supervisor.returncode or 125,
                "supervisor exited during launch",
            )
            break
        time.sleep(0.05)

    status = _read_status(run_dir)
    _emit(_summary(run_dir, status))
    exit_code = status.get("exit_code")
    if status["state"] == "failed" and isinstance(exit_code, int):
        return exit_code if 0 < exit_code <= 255 else 1
    return 0


def _status(args: argparse.Namespace) -> int:
    run_dir = args.run_dir.expanduser().resolve(strict=True)
    _emit(_summary(run_dir, _mark_lost_if_needed(run_dir, _read_status(run_dir))))
    return 0


def _milestone(args: argparse.Namespace) -> int:
    run_dir = args.run_dir.expanduser().resolve(strict=True)
    _read_status(run_dir)
    _atomic_write(run_dir / "milestone.txt", args.text.replace("\n", " ")[:500] + "\n")
    return 0


def _wait(args: argparse.Namespace) -> int:
    run_dir = args.run_dir.expanduser().resolve(strict=True)
    deadline = None if args.timeout is None else time.monotonic() + args.timeout
    while True:
        status = _mark_lost_if_needed(run_dir, _read_status(run_dir))
        if status["state"] in TERMINAL_STATES:
            _emit(_summary(run_dir, status))
            exit_code = status.get("exit_code")
            return (
                exit_code if isinstance(exit_code, int) and 0 <= exit_code <= 255 else 1
            )
        sleep_seconds = 5.0
        if deadline is not None:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return 124
            sleep_seconds = min(sleep_seconds, remaining)
        time.sleep(sleep_seconds)


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="subcommand", required=True)

    start = commands.add_parser("start", help="launch a detached job")
    start.add_argument("--name", required=True)
    start.add_argument("--cwd", type=Path, default=Path.cwd())
    start.add_argument("--root", type=Path, default=_default_root())
    start.add_argument("command", nargs=argparse.REMAINDER)
    start.set_defaults(handler=_start)

    status = commands.add_parser("status", help="print one compact status line")
    status.add_argument("run_dir", type=Path)
    status.set_defaults(handler=_status)

    milestone = commands.add_parser("milestone", help="replace the latest milestone")
    milestone.add_argument("run_dir", type=Path)
    milestone.add_argument("text")
    milestone.set_defaults(handler=_milestone)

    wait = commands.add_parser("wait", help="wait silently for terminal state")
    wait.add_argument("run_dir", type=Path)
    wait.add_argument("--timeout", type=float)
    wait.set_defaults(handler=_wait)

    supervise = commands.add_parser("_supervise", help="internal detached supervisor")
    supervise.add_argument("run_dir", type=Path)
    supervise.set_defaults(handler=lambda args: _supervise(args.run_dir))
    return parser


def main() -> int:
    args = _parser().parse_args()
    try:
        return args.handler(args)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        _emit({"error": str(error)}, stream=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
