# Metis

🦬 Yet another agent-fleet harness with deep thoughts and wisdom.

Metis provides reusable orchestration utilities for coordinating coding agents
without coupling the workflow to a specific model provider or harness.

## Handoff

`handoff` creates a compact, artifact-first transfer for a fresh task, fork, or
explicitly requested background sub-agent. It is useful for assigning a
lightweight bounded task without forwarding a noisy transcript while keeping
integration and verification with the source agent.

The canonical workflow lives in `skills/handoff/`. Its Agent Skills entry is
`.agents/skills/handoff/SKILL.md`; in Codex, invoke it as
`$handoff <next focus or bounded assignment>`.

## Orca Fleet

`orca-fleet` is a model-neutral orchestration skill for multi-step engineering
work. It replaces the former `orca` skill and assigns bounded work by purpose
and complexity:

| Role | Responsibility |
|---|---|
| Orchestrator | Own the plan, routing, decisions, integration, and final verification. |
| Explorer | Gather web evidence, explore codebases, reproduce failures, and reduce uncertainty. |
| General Executor | Complete clear, routine, low-risk implementation and support work. |
| Hard Executor | Implement critical work that requires strong reasoning and non-local context consistency. |
| Evaluator | Perform independent adversarial review and return ranked findings with a refinement plan. |

The canonical playbook and role contracts live in
[`skills/orca-fleet/`](skills/orca-fleet/).

## Supported harnesses

Metis includes project-local skill and worker definitions for Codex, Claude
Code, and OpenCode:

| Harness | Skill entry | Worker definitions | Invoke |
|---|---|---|---|
| Codex | `.agents/skills/orca-fleet/SKILL.md` | `.codex/agents/*.toml` | `$orca-fleet <objective>` |
| Claude Code | `.claude/skills/orca-fleet/SKILL.md` | `.claude/agents/*.md` | `/orca-fleet <objective>` |
| OpenCode | `.agents/skills/orca-fleet/SKILL.md` | `.opencode/agents/*.md` | `/orca-fleet <objective>` |

Codex and Claude Code use the current main session as the orchestrator. OpenCode
also provides `.opencode/agents/orca-fleet.md` as a native primary agent. All
three harnesses expose the same four namespaced worker roles.

### Use Orca Fleet in this repository

Start the selected harness from the Metis repository root. Its project-local
configuration is discovered automatically. Invoke the skill explicitly with the
syntax in the table above and include the engineering objective after the skill
name.

If a harness was already running when its configuration directory was first
created, restart the session so it discovers the new skill and agents.

### Install into another repository

Use the installer from a Metis checkout. It copies the canonical playbook and
the selected project-local adapter without modifying unrelated configuration:

```bash
./scripts/install-orca-fleet.sh \
  --target /path/to/target-repository \
  --harness all
```

Use `codex`, `claude`, or `opencode` instead of `all` to install one adapter.
The target directory must already exist. Existing destination files are never
overwritten unless `--force` is supplied:

```bash
./scripts/install-orca-fleet.sh \
  --target /path/to/target-repository \
  --harness claude \
  --force
```

The installer is intentionally project-local. Commit the installed directories
to the target repository when the fleet should be shared with the team. Keep
`skills/orca-fleet/` alongside the harness-specific directories because each
skill entry points to that canonical playbook.

### Model selection

Shared definitions do not pin concrete models. Workers inherit the active model
unless a local override is added. Configure economical models for Explorer and
General Executor when appropriate, and orchestrator-level models for Hard
Executor and Evaluator.

Long-running compute should run as a detached process with compact terminal
reporting; an agent should never remain active solely to poll it.
