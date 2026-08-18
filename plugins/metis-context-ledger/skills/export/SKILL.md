---
name: export
description: >-
  Export the current .metis/context workspace as a portable,
  Claude-memory-compatible directory identified by UUIDv7. Use when another
  host or session orchestrator needs to continue from filesystem state. Do not
  create or hand work to an agent, synchronize S3, or maintain export history
  as active state.
---

# Export Context Ledger

Create a point-in-time filesystem package from the current ledger. Export is a
copy operation, not the atomic `handoff` workflow: it never creates a task,
fork, session, sub-agent, or native handoff artifact.

Use the standalone `export-memory-context` skill instead when the source is an
unstructured long session and the desired output is one durable fact per
Claude memory file. This skill snapshots an already curated six-file ledger;
it does not perform another memory-extraction pass.

## Prepare the source

Locate `.metis/context/` from the Git root or current working directory. It
must contain:

- `MEMORY.md`
- `goal.md`
- `todo.md`
- `delegation-queue.md`
- `information-index.md`
- `learnings.md`

If material context changed since the last update, first apply the same
curation rules as `metis-context-ledger:update`. Before exporting, check the
six files for contradictions, stale next actions, broken relative links, and
secrets. Do not include raw transcripts or files outside this allowlist.

## Run the bundled exporter

Resolve `../../scripts/export_context.py` relative to this `SKILL.md`, then run
it from the workspace root. Its defaults read `.metis/context` and write under
`.metis/exports`:

```bash
python3 /absolute/path/to/export_context.py
```

When the workspace is a Git checkout, pass the current commit without requiring
a clean worktree:

```bash
python3 /absolute/path/to/export_context.py --git-commit <commit>
```

Python 3.14 and newer use the standard-library UUIDv7 implementation. Older
Python versions use DuckDB. If DuckDB is unavailable and dependency
installation is authorized, install the minimum fallback declared by this
plugin, for example:

```bash
python3 -m pip install "duckdb>=1.5.5"
```

Never install a system package silently. If installation is not authorized,
report the dependency and stop without leaving a partial export.

## Output contract

The script prints the final directory path. It has this shape:

```text
.metis/exports/exp_<uuidv7>/
├── MEMORY.md
├── goal.md
├── todo.md
├── delegation-queue.md
├── information-index.md
├── learnings.md
└── export.json
```

`export.json` contains `format_version`, `export_id`, `created_at`,
`entrypoint`, and `git_commit` when supplied. UUIDv7 exists only to make export
directories unique and time-sortable; it does not introduce project, session,
node, lineage, or checkpoint versioning.

Report the export directory and `MEMORY.md` entry point. The user may sync that
directory with `aws s3 sync`; do not run network synchronization unless they
explicitly request it.
