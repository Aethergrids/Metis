# Metis

🦬 Yet another agent-fleet harness with deep thoughts and wisdom.

Metis provides reusable orchestration utilities for coordinating coding agents
without coupling the workflow to a specific model provider or harness.

## Repository layout

Repository sources are split by responsibility:

```text
skills/<skill>/                 canonical skill instructions and resources
plugins/<plugin>/               namespaced Codex plugin bundles
.agents/plugins/marketplace.json repo-local plugin catalog
agents/codex/agents/            Codex worker definitions
agents/claude/agents/           Claude Code worker definitions
agents/opencode/agents/         OpenCode primary and worker definitions
agents/opencode/commands/       OpenCode command definitions
```

Standalone skills live under `skills/`. Namespaced plugin skills live inside
their plugin under `plugins/`. The installer copies standalone canonical
sources and selected provider definitions into the hidden discovery paths
required by a target harness; generated discovery directories are not tracked
here.

## Context Ledger

`metis-context-ledger` is a filesystem-first Codex plugin with two focused
skills:

| Skill | Use |
|---|---|
| `metis-context-ledger:update` | Maintain the mutable `.metis/context/` workspace in place. |
| `metis-context-ledger:export` | Copy that workspace into a portable `exp_<uuidv7>` directory. |

The workspace contains a concise `MEMORY.md` entry point plus goal, todo,
delegation queue, information index, and learnings files. Exported directories
retain that memory layout so another host can start from `MEMORY.md` after the
user synchronizes the directory through S3 or another filesystem transport.

The plugin does not create version trees, sessions, agents, tasks, or handoff
artifacts. Its `export` skill is separate from the atomic `handoff` skill below.
Python 3.14+ supplies UUIDv7 directly; earlier versions use `duckdb>=1.3.1`.
Use the standalone `export-memory-context` skill instead when the source is an
unstructured long session that must be distilled into one-fact-per-file Claude
memories. `metis-context-ledger:export` only snapshots an already curated
six-file ledger for cross-host continuation.

## Handoff

`handoff` creates a compact, artifact-first transfer for a fresh task, fork, or
explicitly requested background sub-agent. It is useful for assigning a
lightweight bounded task without forwarding a noisy transcript while keeping
integration and verification with the source agent.

The canonical workflow lives in `skills/handoff/`. After installation, each
supported coding agent has a project-local entry point:

| Harness | Installed entry point | Invoke |
|---|---|---|
| Codex | `.agents/skills/handoff/SKILL.md` | `$handoff <focus or assignment>` |
| Claude Code | `.claude/skills/handoff/SKILL.md` | `/handoff <focus or assignment>` |
| OpenCode | `.agents/skills/handoff/SKILL.md` and `.opencode/commands/handoff.md` | `/handoff <focus or assignment>` |

## Run Long Job

`run-long-job` launches training, backfills, migrations, materializations,
benchmarks, large builds, and other long local commands as detached processes.
It records the command, working directory, Git SHA, PIDs, log path, compact
status, and a one-line terminal sentinel without keeping an agent alive to poll.

| Harness | Installed entry point | Invoke |
|---|---|---|
| Codex | `.agents/skills/run-long-job/SKILL.md` | `$run-long-job <command or objective>` |
| Claude Code | `.claude/skills/run-long-job/SKILL.md` | `/run-long-job <command or objective>` |
| OpenCode | `.agents/skills/run-long-job/SKILL.md` and `.opencode/commands/run-long-job.md` | `/run-long-job <command or objective>` |

## Prompt and Workflow Design

Three focused skills apply OpenAI's current
[GPT-5.6 Sol prompting guidance](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6)
without loading one large generic prompt playbook:

| Skill | Use |
|---|---|
| `craft-agent-prompt` | Create, simplify, evaluate, or migrate agent prompt contracts. |
| `design-tool-workflow` | Define tools, routing, retrieval budgets, programmatic reductions, evidence, retries, and stop rules. |
| `manage-long-workflow` | Run single-agent work across phases or context windows with sparse updates and deliberate state. |

Invoke them as `$craft-agent-prompt`, `$design-tool-workflow`, and
`$manage-long-workflow` in Codex, or use the corresponding slash commands in
Claude Code and OpenCode. `manage-long-workflow` routes detached local compute
to `run-long-job`, multi-agent work to `orca-fleet`, and context reset to
`handoff` rather than duplicating those workflows.

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

Metis keeps provider-native definitions under dedicated source directories:

| Harness | Definition source | Installed worker path | Invoke |
|---|---|---|---|
| Codex | `agents/codex/agents/*.toml` | `.codex/agents/*.toml` | `$orca-fleet <objective>` |
| Claude Code | `agents/claude/agents/*.md` | `.claude/agents/*.md` | `/orca-fleet <objective>` |
| OpenCode | `agents/opencode/{agents,commands}/*.md` | `.opencode/{agents,commands}/*.md` | `/orca-fleet <objective>` |

Codex and Claude Code use the current main session as the orchestrator. OpenCode
also provides `agents/opencode/agents/orca-fleet.md` as a native primary-agent
source. All three harnesses expose the same four namespaced worker roles.

### Use Orca Fleet in this repository

The source checkout deliberately does not track generated harness directories.
Install the desired local configuration into the checkout, then start the
harness from the repository root:

```bash
./scripts/install-metis.sh --target . --harness codex
```

Replace `codex` with `claude` or `opencode` as needed. The generated hidden
directories are ignored by Git. Invoke the skill with the syntax in the table
above and include the engineering objective after the skill name.

If a harness was already running when its configuration directory was first
created, restart the session so it discovers the new skill and agents.

### Install everything for every coding agent

Use the general installer from a Metis checkout. By default it installs every
Metis skill for Codex, Claude Code, and OpenCode:

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

Valid skill selectors are `all`, `craft-agent-prompt`, `design-tool-workflow`,
`handoff`, `manage-long-workflow`, `orca-fleet`, and `run-long-job`. Valid
harness selectors are `all`, `codex`, `claude`, and `opencode`. The target
directory must already exist. Existing destination files are never overwritten
unless `--force` is supplied.

The previous `install-orca-fleet.sh` command remains available as an Orca-only
compatibility wrapper.

The installer is intentionally project-local. It copies each canonical skill
directly into the selected harness's discovery directory and maps definitions
from `agents/<provider>/` into that provider's hidden configuration directory.
Commit installed output in a downstream repository only when its team wants to
share generated harness configuration.

### Model selection

Shared definitions do not pin concrete models. Workers inherit the active model
unless a local override is added. Configure economical models for Explorer and
General Executor when appropriate, and orchestrator-level models for Hard
Executor and Evaluator.

Use `run-long-job` for long-running compute. An agent should never remain active
solely to poll a process.
