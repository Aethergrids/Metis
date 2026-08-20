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

Context management is a separate product boundary, also published as parallel
English and Chinese plugins:

| Namespace | Language | Example |
|---|---|---|
| `metis-context-ledger` | English | `$metis-context-ledger:update` |
| `metis-context-ledger-zh` | 中文 | `$metis-context-ledger-zh:update` |

These plugins own all context lifecycle skills and their runtime dependencies:

| Skill | Purpose |
|---|---|
| `update` | Maintain the mutable `.metis/context/` workspace in place. |
| `export` | Snapshot an already curated six-file ledger for another host. |
| `export-memory-context` | Distill an unstructured long session into one-fact-per-file Claude memories. |

Invoke the Chinese variants with the same skill names under the
`metis-context-ledger-zh` namespace. Context Ledger intentionally does not
contain the atomic `handoff` skill.

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
plugins/metis-prelude/          English Prelude plugin and canonical skills
plugins/metis-prelude-zh/       Chinese Prelude plugin and skill versions
plugins/metis-context-ledger/   English context lifecycle plugin and export runtime
plugins/metis-context-ledger-zh/
                                Chinese context lifecycle plugin and export runtime
.agents/plugins/marketplace.json
                                Codex plugin catalog
.claude-plugin/marketplace.json Claude Code plugin catalog
agents/codex/agents/            Codex Orca worker definitions
agents/claude/agents/           Claude Code Orca worker definitions
agents/opencode2/agents/        OpenCode2 primary and worker definitions
agents/opencode2/commands/      OpenCode2 command definitions
scripts/install-metis.sh        project-local multi-harness installer
```

The plugin directories are the canonical skill sources. Prelude contains the
general skill set; Context Ledger owns context curation and export. The former
standalone `skills/` tree was folded into these plugin namespaces to avoid
duplicate discovery.

## Codex installation

The repo-local catalog is `.agents/plugins/marketplace.json` and contains all
four product/language plugins. Install only the namespaces needed for the task.
Start a new task after installing or updating so Codex discovers them.

## Claude Code installation

The repository-level `.claude-plugin/marketplace.json` publishes the same four
plugins. Each plugin includes a `.claude-plugin/plugin.json`; Prelude also
bundles the Claude-native Orca worker agents. Claude Code addresses installed
skills as `/plugin-name:skill-name`.

## Project-local harness adapters

`scripts/install-metis.sh` installs any of the four plugins into Codex, Claude
Code, or OpenCode2 project-local discovery paths. It copies complete skill
directories so supporting scripts, references, assets, and metadata stay with
the skill:

```bash
./scripts/install-metis.sh --target /path/to/target-repository
```

This defaults to `--plugin metis-prelude --skill all --harness all`. A filtered
Chinese Context Ledger install looks like:

```bash
./scripts/install-metis.sh \
  --target /path/to/target-repository \
  --plugin metis-context-ledger-zh \
  --skill export \
  --harness opencode2
```

The skill selector is `all` or any skill present in the selected plugin.
Harness selectors are `all`, `codex`, `claude`, and `opencode2`. Existing
destination files are preserved unless `--force` is supplied.

Project-local installation exposes standalone skill names because plugin
namespaces belong to the marketplace distributions. OpenCode2 uses the V2
binary and schema while retaining `.opencode/` for project configuration. Its
discovered skills already become slash commands, so only Orca Fleet keeps an
explicit command bridge to select the dedicated orchestrator.

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
| OpenCode2 | `.opencode/{skills,agents,commands}/` | `/orca-fleet <objective>` |

Shared definitions do not pin concrete models. Workers inherit the active
model unless a harness-local override is added. Long compute belongs to
`run-long-job`; an Agent should not remain alive solely to poll a process.
