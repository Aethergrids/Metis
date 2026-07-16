---
name: design-tool-workflow
description: >-
  Design or audit agent tool sets, function or MCP tools, retrieval routes, and
  Programmatic Tool Calling stages. Use for tool descriptions, prerequisite
  routing, direct-versus-programmatic decisions, evidence and citation budgets,
  structured reductions, retries, fallbacks, and stop rules.
---

# Design Tool Workflow

Read `skills/design-tool-workflow/SKILL.md` from the repository root and follow
it as the authoritative tool-routing workflow.

Treat `$ARGUMENTS` as the tool set or workflow to design when arguments were
supplied. Keep the route bounded and verify structured results separately from
the final assistant message.
