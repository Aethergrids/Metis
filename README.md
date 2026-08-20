# Metis

🦬 Yet another agent-fleet harness with deep thoughts and wisdom.

Metis provides reusable Agent orchestration, workflow, context, and
communication skills without coupling the workflow to one model provider.

## Plugin boundaries

Prelude is the general-purpose Metis skill set, published through two parallel
language plugins:

| Namespace | Language | Example |
|---|---|---|
| `metis-prelude` | English | `$metis-prelude:handoff` |
| `metis-prelude-zh` | 中文 | `$metis-prelude-zh:handoff` |

The two plugins expose the same skill names. Language belongs to the plugin
namespace, so Chinese skill names do not carry a `-zh` suffix.

| Skill | Purpose |
|---|---|
| `agent-expression-refine` | Refine Agent writing into clear, neutral, evidence-calibrated language. |
| `artifact-xai-style` | Build self-contained HTML Artifacts in the xAI / grok-build visual language. |
| `craft-agent-prompt` | Create, simplify, evaluate, or migrate Agent prompt contracts. |
| `design-tool-workflow` | Design bounded tool sets, routing, retrieval, evidence, retries, and stop rules. |
| `handoff` | Create an atomic, artifact-first task transfer or bounded delegation. |
| `manage-long-workflow` | Run single-Agent work across phases or context windows with durable state. |
| `orca-fleet` | Orchestrate bounded multi-Agent work by purpose and complexity. |
| `run-long-job` | Detach long local compute without keeping a model in a polling loop. |

For example, invoke the English and Chinese versions as:

```text
$metis-prelude:handoff
$metis-prelude-zh:handoff
```

Context management is a separate product boundary. The
`metis-context-ledger` plugin owns all context lifecycle skills and their
runtime dependencies:

| Skill | Purpose |
|---|---|
| `update` | Maintain the mutable `.metis/context/` workspace in place. |
| `export` | Snapshot an already curated six-file ledger for another host. |
| `export-memory-context` | Distill an unstructured long session into one-fact-per-file Claude memories. |

Invoke them as `$metis-context-ledger:update`,
`$metis-context-ledger:export`, and
`$metis-context-ledger:export-memory-context`. Context Ledger intentionally
does not contain the atomic `handoff` skill.

## Context workflows

The filesystem-first `metis-context-ledger` workflow has three distinct
operations:

| Operation | Use |
|---|---|
| `update` | Maintain one mutable `.metis/context/` workspace containing `MEMORY.md`, goal, todo, delegation queue, information index, and learnings. |
| `export` | Copy that curated workspace into `.metis/exports/exp_<uuidv7>/` for filesystem or S3 transport. |
| `export-memory-context` | Extract selected durable facts from an unstructured session into a Claude memory layout. |

`export` is not version management. UUIDv7 only makes export directories unique
and time-sortable. It does not create project, session, node, lineage, or
checkpoint history. Python 3.14+ provides UUIDv7 directly; earlier versions use
`duckdb>=1.5.5`.

`handoff` remains a separate atomic transfer workflow. It may create a portable
handoff document and, only when explicitly requested, seed another task, fork,
or bounded sub-agent. Ledger export never creates or transfers an Agent task.

## Repository layout

```text
plugins/metis-prelude/          English Codex plugin and canonical English skills
plugins/metis-prelude-zh/       Chinese Codex plugin and Chinese skill versions
plugins/metis-context-ledger/   Context lifecycle skills and export runtime
.agents/plugins/marketplace.json
                                repo-local plugin catalog
agents/codex/agents/            Codex Orca worker definitions
agents/claude/agents/           Claude Code Orca worker definitions
agents/opencode/agents/         OpenCode primary and worker definitions
agents/opencode/commands/       OpenCode command definitions
scripts/install-metis.sh        legacy project-local multi-harness installer
```

The plugin directories are the canonical skill sources. Prelude contains the
general skill set; Context Ledger owns context curation and export. The former
standalone `skills/` tree was folded into these plugin namespaces to avoid
duplicate discovery.

## Codex installation

The repo-local catalog is `.agents/plugins/marketplace.json` and contains the
two Prelude language plugins plus Context Ledger. Install only the product and
language namespaces needed for the task. Start a new task after installing or
updating so Codex discovers the new namespaces.

## Project-local harness adapters

`scripts/install-metis.sh` remains available for existing Codex, Claude Code,
and OpenCode project-local workflows. It copies the portable English skill
subset from `plugins/metis-prelude/skills/` and provider definitions from
`agents/<provider>/`:

```bash
./scripts/install-metis.sh --target /path/to/target-repository
```

This is equivalent to `--skill all --harness all`. A filtered install looks
like:

```bash
./scripts/install-metis.sh \
  --target /path/to/target-repository \
  --skill handoff \
  --harness claude
```

Supported skill selectors are `all`, `craft-agent-prompt`,
`design-tool-workflow`, `handoff`, `manage-long-workflow`, `orca-fleet`, and
`run-long-job`. Harness selectors are `all`, `codex`, `claude`, and `opencode`.
Existing destination files are preserved unless `--force` is supplied.

The compatibility installer exposes standalone names such as `$handoff` because
Claude Code and OpenCode do not consume Codex plugin namespaces. The Chinese
namespace is currently distributed through the `metis-prelude-zh` Codex plugin.

`install-orca-fleet.sh` remains an Orca-only compatibility wrapper.

## Orca Fleet adapters

`orca-fleet` keeps one durable orchestrator responsible for plan, routing,
integration, and final verification, and uses four bounded worker roles:

| Role | Responsibility |
|---|---|
| Explorer | Gather evidence, map codebases, reproduce failures, and reduce uncertainty. |
| General Executor | Complete clear, routine, low-risk implementation and support work. |
| Hard Executor | Implement critical work requiring non-local reasoning and context consistency. |
| Evaluator | Perform independent adversarial review and return ranked findings. |

Provider-native definitions are installed at:

| Harness | Worker destination | Invocation |
|---|---|---|
| Codex | `.codex/agents/*.toml` | `$orca-fleet <objective>` through the compatibility installer, or the plugin namespace |
| Claude Code | `.claude/agents/*.md` | `/orca-fleet <objective>` |
| OpenCode | `.opencode/{agents,commands}/*.md` | `/orca-fleet <objective>` |

Shared definitions do not pin concrete models. Workers inherit the active
model unless a harness-local override is added. Long compute belongs to
`run-long-job`; an Agent should not remain alive solely to poll a process.
