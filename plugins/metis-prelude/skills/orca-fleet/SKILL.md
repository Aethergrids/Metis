---
name: orca-fleet
description: >-
  Model-neutral orchestration playbook for long-running, multi-step, or
  multi-agent engineering work. Use whenever coordinating sub-agents,
  decomposing work by complexity, dispatching research or implementation,
  running an independent adversarial review, monitoring background compute, or
  integrating worker results, including through Codex, Claude Code, or OpenCode2
  agent definitions. Defines the orchestrator's responsibilities, Explorer,
  General Executor, Hard Executor, and Evaluator roles, bounded handoffs,
  verification rules, and cost-safe monitoring practices. Consult before
  delegating, launching unattended work, or leaving work running overnight. See
  AGENTS.md for the complete role contracts.
---

# orca-fleet — model-neutral orchestration

Use one durable orchestrator to own the outcome. Treat concrete models, CLIs,
and agent harnesses as replaceable execution channels. Select them by the
capability required for a role, not by a hard-coded provider or model name.

## Harness integration

Use this canonical playbook with the distribution mode available to the active
harness:

- **Codex:** A plugin install exposes `$metis-prelude:orca-fleet` and uses the
  subagents available to the main task. A project-local install exposes
  `$orca-fleet` and adds the exact named `.codex/agents/orca-fleet-*.toml`
  workers sourced from `agents/codex/agents/`.
- **Claude Code:** A plugin install exposes `/metis-prelude:orca-fleet` and
  loads the workers bundled at the plugin root. A project-local install exposes
  `/orca-fleet` and copies the same workers from `agents/claude/agents/` into
  `.claude/agents/`.
- **OpenCode2:** Project-local installation exposes `/orca-fleet`, installs the
  primary orchestrator and workers from `agents/opencode2/`, and keeps
  `.opencode/` as the configuration directory. OpenCode V1 is not supported.

Keep models inherited for a portable default. Add harness-local model and
reasoning overrides only when the available catalog and desired cost/capability
tiers are known. Prefer economical configurations for Explorer and General
Executor and orchestrator-level configurations for Hard Executor and Evaluator.

## Core invariant

> The orchestrator owns the plan, routing, decisions, integration, and final
> verification. Workers perform bounded assignments and return evidence-backed
> results. Detached processes perform long-running compute without keeping an
> agent alive to watch them.

## Orchestrator responsibilities

The orchestrator must:

1. Define the outcome, constraints, acceptance criteria, and frozen contracts.
2. Decompose the work into tasks with explicit dependencies and write scopes.
3. Classify each task by work type, complexity, and consequence of error.
4. Dispatch each task to the least expensive role that can complete it reliably.
5. Preserve the durable project context and resolve ambiguity or conflicts.
6. Check worker claims against ground truth such as repository state, tests,
   generated artifacts, service state, or authoritative sources.
7. Integrate accepted work and own outward-facing or hard-to-reverse actions.
8. Escalate decisions that require user authority or materially change scope.

The orchestrator may implement a task directly when delegation would cost more
coordination than execution, but it must not become a long-lived monitor or do
bulk mechanical work merely because it can.

## Classify before dispatching

Classify the task in two passes:

1. **Work type:** discovery, implementation, evaluation, or background compute.
2. **Complexity:** routine or hard.

Treat an implementation task as **hard** when one or more of these signals are
material:

- correctness depends on maintaining context across multiple components;
- the task changes architecture, public contracts, state, or security behavior;
- requirements are ambiguous and require sustained reasoning to reconcile;
- failure would be costly, difficult to detect, or difficult to reverse;
- debugging requires non-local reasoning rather than a concrete reproduction;
- several dependent edits must remain coherent as one implementation.

Do not classify a task as hard merely because it is long. Split large mechanical
work into bounded routine assignments when the pieces are independent.

## Worker routing

| Work | Role | Typical capability profile |
|---|---|---|
| Web research, source gathering, codebase mapping, locating definitions, reproduction, inventory | **Explorer** | Fast, tool-capable, evidence-oriented; read-only by default |
| Clear, routine implementation, tests, formatting, documentation, mechanical edits | **General Executor** | Broad and economical; follows a frozen contract |
| Critical or complex implementation with non-local constraints and high context-coherence demands | **Hard Executor** | Strong implementation reasoning and context consistency |
| Independent adversarial review of a spec, plan, diff, or artifact | **Evaluator** | Orchestrator-level reasoning; skeptical and read-only by default |
| Planning, routing, adjudication, integration, final verification | **Orchestrator** | Durable context and decision authority |
| Training, backfills, materialization, encoding, or other long compute | **Detached process** | CPU/GPU process monitored without an agent |

Use Explorers before Executors when important facts are missing. Use the General
Executor by default for implementation and promote to the Hard Executor only
when the hard-task signals justify it. Use an Evaluator when independent review
materially reduces risk; never treat its verdict as self-validating.

## Dispatch protocol

Before dispatching, give the worker a complete, bounded contract containing:

- objective and concrete deliverable;
- relevant context and authoritative inputs;
- allowed files, systems, and write scope;
- constraints, frozen decisions, and non-goals;
- acceptance checks the worker can run;
- required output format, including evidence and unresolved risks;
- a hard stop condition for scope growth, blocked dependencies, or tool budget.

Dispatch independent tasks in parallel. Keep dependent tasks sequential unless
the interface between them is already frozen. A worker must return a result, not
remain alive as an open-ended collaborator. If a task outgrows its contract,
stop and re-plan rather than repeatedly nudging the same context-heavy session.

## Role-specific output contracts

- **Explorer:** Return findings, source or file locations, commands used, and
  confidence or gaps. Separate observed facts from inference. Do not make
  production changes unless explicitly reassigned.
- **General Executor:** Return changed artifacts, verification results, and any
  contract mismatch. Escalate when the task reveals hard-task signals.
- **Hard Executor:** Return the implementation, reasoning for consequential
  choices, invariant coverage, verification results, and residual risks.
- **Evaluator:** Return ranked findings with evidence, impact, a concrete
  failure scenario, and a refinement plan. End with a clear accept/change
  recommendation. Do not silently repair the work under review.

The orchestrator triages every output, rejects unsupported claims, and decides
whether follow-up work belongs to a General Executor or Hard Executor.

## Independent evaluation

Keep evaluation separate from implementation when risk warrants it. Give the
Evaluator the frozen contract and raw artifact or diff, not the implementer's
conclusions. Ask it to look for specification gaps, correctness failures,
security or data-loss risks, missing tests, regressions, and unsupported
assumptions. The orchestrator must reproduce or otherwise verify actionable
findings before accepting them.

## Long-running compute

Never keep a sub-agent alive solely to poll a background job. Launch the work as
a detached process, record its PID, write logs to disk, emit a terminal marker,
and use a shell or harness monitor that wakes the orchestrator once on terminal
state or stall.

When `$metis-prelude:run-long-job` is available, invoke it and follow
[`../run-long-job/SKILL.md`](../run-long-job/SKILL.md) instead of constructing a
detached launcher in the agent loop. It records reproducibility metadata and
provides compact status and terminal-state commands.

Keep monitoring output small: report only terminal state, the last relevant
error, and a compact progress summary. Do not stream full logs into an agent's
context. Make long or overnight work resumable and obtain user confirmation
when it crosses an authority, spend, or operational-risk boundary.

## Cost and context discipline

1. Keep sub-agents bounded and single-purpose.
2. Pass paths or compact summaries instead of large logs and data dumps.
3. Use the lowest-capability role that meets the task's reliability needs.
4. Reserve orchestrator-level capacity for orchestration and evaluation.
5. Cap each dispatch and re-plan when its assumptions or scope no longer hold.
6. Stop idle workers; do not pay an agent to wait for compute.

## Pre-flight checklist

Before dispatch:

- Is the task's work type and complexity explicit?
- Is the selected role the least expensive reliable match?
- Is the assignment independent, bounded, and verifiable?
- Are dependencies and write boundaries clear?
- Does the worker know when to stop and escalate?

Before accepting:

- Did the orchestrator inspect the actual artifact or state?
- Were acceptance checks run against ground truth?
- Were Evaluator findings reproduced or rejected with reasons?
- Are unresolved risks and user decisions explicit?

Before leaving work unattended:

- Is long-running compute detached and resumable?
- Is there a terminal marker and a stall signal?
- Will the orchestrator be woken once rather than polled repeatedly?
- Are all agent workers finished rather than idling?
