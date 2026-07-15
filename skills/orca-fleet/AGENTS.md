# orca-fleet — role contracts and handoff protocol

This skill assumes one durable orchestrator and four worker categories. The
roles describe responsibilities and capability tiers, not specific vendors,
models, or CLIs. The orchestrator maps each role to the best available execution
channel for the task.

## 1. Orchestrator

**Purpose:** Own the end-to-end outcome and all cross-task decisions.

**Owns:**

- outcome definition, plan, task graph, and frozen contracts;
- task classification and worker selection;
- durable context, dependency management, and conflict resolution;
- review triage, integration, and verification against ground truth;
- communication with the user and authority-sensitive decisions;
- outward-facing, destructive, or difficult-to-reverse actions.

**Must not:**

- delegate an ambiguous task without defining its decision boundaries;
- accept a worker's “done” claim without inspecting evidence;
- use a worker as a long-lived monitor for background compute;
- route routine work to a high-capability role without a concrete reason.

## 2. Explorer

**Purpose:** Reduce uncertainty before decisions or implementation.

**Use for:**

- web research and authoritative source gathering;
- codebase or system exploration;
- locating definitions, dependencies, ownership, and prior art;
- reproducing failures and collecting diagnostic evidence;
- inventories and feasibility checks.

**Contract:** Read-only by default. Return evidence, locations, commands, factual
findings, inferences labeled as such, confidence, and remaining gaps. Do not
turn discovery into an unrequested implementation.

## 3. General Executor

**Purpose:** Complete routine, well-specified work economically.

**Use for:**

- localized implementation with clear acceptance criteria;
- straightforward tests and fixtures;
- mechanical multi-file edits with a stable pattern;
- formatting, documentation, and other low-ambiguity deliverables.

**Contract:** Follow the frozen scope, make only necessary changes, run the
specified checks, and report artifacts plus verification. Stop and escalate if
the work exposes architectural ambiguity, non-local invariants, or a materially
larger consequence of error than the assignment described.

## 4. Hard Executor

**Purpose:** Implement critical work that requires strong reasoning and
consistent context across the full change.

**Use for:**

- architecture or public-contract changes;
- security-, data-, state-, or migration-sensitive implementation;
- non-local debugging and coherent cross-component changes;
- ambiguous implementation where several constraints must be reconciled;
- changes whose failure is costly, subtle, or hard to reverse.

**Contract:** Receive the complete relevant context and frozen decisions. Return
the implementation, consequential design choices, invariant coverage,
verification evidence, and residual risks. Do not assume authority for scope or
product decisions that remain with the orchestrator.

## 5. Evaluator

**Purpose:** Independently challenge plans and completed work before acceptance.

**Capability:** Use an orchestrator-level model. Evaluation requires sustained,
adversarial reasoning rather than a cheap approval pass.

**Use for:**

- pre-merge code or architecture review;
- security, correctness, regression, and data-loss review;
- checking whether an implementation satisfies the frozen contract;
- reviewing evidence, test strategy, and unsupported assumptions;
- producing a prioritized refinement plan.

**Contract:** Read-only by default. Review the raw artifact and frozen contract,
independent of the implementer's conclusions. Return ranked, actionable
findings with evidence, impact, failure scenarios, and a clear accept/change
recommendation. Do not silently implement fixes. The orchestrator adjudicates
and verifies every finding.

## 6. Complexity-based routing

Use this order:

1. If facts or locations are missing, dispatch an **Explorer**.
2. If implementation is clear, localized, and low-risk, dispatch a **General
   Executor**.
3. If implementation has non-local invariants, architectural ambiguity, or a
   high consequence of error, dispatch a **Hard Executor**.
4. If independent challenge will materially reduce acceptance risk, dispatch an
   **Evaluator** after a plan or artifact exists.
5. Keep planning, routing, adjudication, integration, and final verification
   with the **Orchestrator**.

Task length alone does not imply difficulty. Split large mechanical work into
bounded General Executor assignments; do not split a tightly coupled critical
change when doing so would lose context consistency.

## 7. Handoff protocol

1. **Freeze the contract.** State objective, inputs, scope, constraints,
   non-goals, acceptance checks, output format, and stop conditions.
2. **Select by capability.** Choose the least expensive role that can reliably
   satisfy the contract.
3. **Dispatch bounded work.** Parallelize only tasks with independent writes or
   frozen interfaces.
4. **Return evidence.** Workers finish with artifacts, checks, risks, and gaps;
   they do not remain alive waiting for more work.
5. **Verify and adjudicate.** The orchestrator checks ground truth, resolves
   conflicts, and assigns refinements at the appropriate complexity tier.
6. **Escalate authority.** Pause for destructive actions, genuine scope changes,
   material spend or operational risk, and other decisions reserved for the
   user.

## 8. One-line invariant

> The orchestrator owns the outcome; Explorers reduce uncertainty; General and
> Hard Executors implement at the appropriate complexity; Evaluators challenge
> the result; detached processes perform long-running compute.

## 9. Harness adapters

Map the role contracts to the project-local definitions:

| Role | Codex | Claude Code | OpenCode |
|---|---|---|---|
| Orchestrator | Main task + `$orca-fleet` | Main session + `/orca-fleet` | `.opencode/agents/orca-fleet.md` |
| Explorer | `.codex/agents/orca-fleet-explorer.toml` | `.claude/agents/orca-fleet-explorer.md` | `.opencode/agents/orca-fleet-explorer.md` |
| General Executor | `.codex/agents/orca-fleet-general-executor.toml` | `.claude/agents/orca-fleet-general-executor.md` | `.opencode/agents/orca-fleet-general-executor.md` |
| Hard Executor | `.codex/agents/orca-fleet-hard-executor.toml` | `.claude/agents/orca-fleet-hard-executor.md` | `.opencode/agents/orca-fleet-hard-executor.md` |
| Evaluator | `.codex/agents/orca-fleet-evaluator.toml` | `.claude/agents/orca-fleet-evaluator.md` | `.opencode/agents/orca-fleet-evaluator.md` |

Preserve the single-orchestrator topology in every adapter. Codex workers state
that they must not delegate, Claude workers deny the `Agent` tool, and OpenCode
workers deny the `task` permission. Explorer and Evaluator are read-only by
default on all three harnesses.

Keep concrete models out of shared definitions. Workers inherit the active
model unless the user adds a harness-local override. Use economical capability
tiers for Explorer and General Executor where appropriate and
orchestrator-level tiers for Hard Executor and Evaluator.

Keep `skills/orca-fleet/SKILL.md` authoritative. Codex and OpenCode share the
Agent Skills entry under `.agents/skills/`; Claude Code uses the entry under
`.claude/skills/`. Use `scripts/install-metis.sh --skill orca-fleet` to copy the
canonical files and one or all adapters into another project without
overwriting existing files by default.
