---
name: manage-long-workflow
description: >-
  Manage single-agent, multi-step or tool-heavy work across phases, turns, or
  context windows. Use for sparse outcome updates, durable state, phase
  boundaries, compaction, persisted reasoning, prompt caching, or explicit
  stop rules. Do not use to poll compute or orchestrate multiple agents.
---

# Manage Long Workflow

Read `skills/manage-long-workflow/SKILL.md` from the repository root and follow
it as the authoritative single-agent long-workflow playbook.

Treat `$ARGUMENTS` as the long-running objective when arguments were supplied.
Route external compute to `/run-long-job`, multi-agent work to `/orca-fleet`,
and fresh-context transfer to `/handoff`.
