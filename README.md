# Metis

🦬 Yet another agent-fleet harness with deep thoughts and wisdom.

Metis provides reusable orchestration utilities for coordinating coding agents
without coupling the workflow to a specific model provider or harness.

## Handoff

`handoff` creates a compact, artifact-first transfer for a fresh task, fork, or
explicitly requested background sub-agent. It is useful for assigning a
lightweight bounded task without forwarding a noisy transcript while keeping
integration and verification with the source agent.

The canonical workflow lives in `skills/handoff/`. Each supported coding agent
has a project-local entry point:

| Harness | Entry point | Invoke |
|---|---|---|
| Codex | `.agents/skills/handoff/SKILL.md` | `$handoff <focus or assignment>` |
| Claude Code | `.claude/skills/handoff/SKILL.md` | `/handoff <focus or assignment>` |
| OpenCode | `.agents/skills/handoff/SKILL.md` and `.opencode/commands/handoff.md` | `/handoff <focus or assignment>` |

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

### Install everything for every coding agent

Use the general installer from a Metis checkout. By default it installs both
`handoff` and `orca-fleet` for Codex, Claude Code, and OpenCode:

```bash
./scripts/install-metis.sh --target /path/to/target-repository
```

This is equivalent to passing `--skill all --harness all`. Filter the install
when only one skill or coding agent is needed:

```bash
./scripts/install-metis.sh \
  --target /path/to/target-repository \
  --skill handoff \
  --harness claude
```

Valid skill selectors are `all`, `handoff`, and `orca-fleet`. Valid harness
selectors are `all`, `codex`, `claude`, and `opencode`. The target directory
must already exist. Existing destination files are never overwritten unless
`--force` is supplied.

The previous `install-orca-fleet.sh` command remains available as an Orca-only
compatibility wrapper.

The installer is intentionally project-local. Commit the installed directories
to the target repository when the skills should be shared with the team. Keep
the canonical `skills/` files alongside the harness-specific entries because
the entries point back to those workflows.

### Model selection

Shared definitions do not pin concrete models. Workers inherit the active model
unless a local override is added. Configure economical models for Explorer and
General Executor when appropriate, and orchestrator-level models for Hard
Executor and Evaluator.

Long-running compute should run as a detached process with compact terminal
reporting; an agent should never remain active solely to poll it.
