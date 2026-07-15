# Metis

🦬 Yet another agent-fleet harness with deep thoughts and wisdom.

Metis provides reusable orchestration utilities for coordinating coding agents
without coupling the workflow to a specific model provider or harness.

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

### OpenCode

The repository includes project-local OpenCode integration:

- `.opencode/agents/orca-fleet.md` defines the primary orchestrator.
- Four `orca-fleet-*` subagents implement the worker roles.
- `.opencode/skills/orca-fleet/SKILL.md` exposes the canonical playbook.
- `.opencode/commands/orca-fleet.md` provides `/orca-fleet <objective>`.

OpenCode agent definitions intentionally omit concrete models. Subagents inherit
the invoking primary agent's model unless a local `provider/model-id` override is
added. This keeps the checked-in workflow portable while allowing economical
models for routine work and stronger models for hard execution or evaluation.

Run an objective from the OpenCode TUI with:

```text
/orca-fleet <objective>
```

Long-running compute should run as a detached process with compact terminal
reporting; an agent should never remain active solely to poll it.
