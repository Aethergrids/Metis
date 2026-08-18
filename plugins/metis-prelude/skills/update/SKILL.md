---
name: update
description: >-
  Create or refresh a compact, session-independent context workspace under
  .metis/context. Use when the current goal, work queue, delegatable work,
  evidence index, or durable learnings need to be organized before compaction
  or continued work. Do not create history, export a bundle, transfer a task,
  or invoke an agent.
---

# Update Context Ledger

Maintain one mutable pre-ledger workspace. It is a compact working view, not an
event log, transcript, task database, or session registry.

## Locate the workspace

Use the Git repository root when one is available; otherwise use the current
working directory. Unless the user names another location, maintain exactly
these files under `.metis/context/`:

| File | Durable content |
|---|---|
| `MEMORY.md` | Current goal, state, next action, blockers, and links to the other files |
| `goal.md` | Objective, success criteria, constraints, and explicit non-goals |
| `todo.md` | In-progress, next, blocked, and recently completed work |
| `delegation-queue.md` | Self-contained work units that could be delegated later |
| `information-index.md` | Paths, URLs, commits, commands, artifacts, and why each matters |
| `learnings.md` | Decisions, verified findings, pitfalls, and unresolved questions |

Create missing files with those headings. Preserve useful existing content and
update the files in place; never create checkpoint or version directories.

## Curate the state

Read enough of the current conversation and workspace to distinguish verified
facts from assumptions. Record only information that changes future decisions
or helps another orchestrator continue the work.

- Keep `MEMORY.md` short. It is the entry point, not a duplicate of every file.
- Write concrete, verifiable next actions. Keep only one current next action in
  `MEMORY.md` even when `todo.md` contains several candidates.
- Link details instead of copying logs, patches, large outputs, or source files.
- Mark uncertain statements as unverified. Do not turn inference into fact.
- Do not persist instructions scoped only to the current invocation, such as
  “do not export this turn” or “do not edit source while refreshing,” unless
  they also constrain the project work that follows.
- Remove stale state when it no longer affects the work. Preserve durable
  decisions and learnings in their dedicated files.
- Never store credentials, tokens, hidden reasoning, or raw transcripts.

Use relative Markdown links between the six files so the directory stays
portable. `MEMORY.md` should end with a small `Read next` section linking to
`goal.md`, `todo.md`, `delegation-queue.md`, `information-index.md`, and
`learnings.md`.

## Keep delegation separate

`delegation-queue.md` is only an index of possible bounded work. Each item
should state its objective, completion condition, dependencies, and useful
references. Do not create a task, fork, sub-agent, or handoff artifact.

If the user explicitly asks to transfer or delegate work now, use the separate
atomic `$metis-prelude:handoff` skill. That workflow is separate from ledger
maintenance.

## Finish

Re-read all six files for contradictions, broken relative links, stale next
actions, and accidental sensitive content. Report which files materially
changed and the current next action.
