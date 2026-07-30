---
name: manage-long-workflow
description: >-
  Manage single-agent, multi-step or tool-heavy work across phases, turns, or
  context windows with sparse updates and durable state. Use when a task spans
  research, design, implementation, review, or external coordination; when
  compaction, persisted reasoning, prompt caching, or Responses API state must
  be designed; or when "keep working until complete" needs explicit phase and
  stop rules. Do not use to poll external compute or orchestrate multiple agents.
---

# Manage Long Workflow

Keep one agent focused on the current layer of work and preserve only state that
changes future decisions. Follow the current official
[GPT-5.6 long-workflow guidance](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6#long-running-workflows-and-state)
for model-specific behavior.

## Route before starting

Choose the narrowest workflow:

- **Single-agent phase work:** use this skill.
- **Local compute longer than about five minutes:** invoke `run-long-job` and
  end the agent turn after its bounded launch check.
- **Multi-agent decomposition:** invoke `orca-fleet`.
- **Fresh-context transfer:** invoke `handoff` at a major milestone.
- **Long Responses API generation:** use background mode and prefer supported
  webhooks such as `response.completed`; an ordinary service, not a model turn,
  may poll for other terminal states or when webhooks are unavailable.

## Freeze the current phase

State the current layer: research, design, implementation, review, or external
coordination. Then define the goal, success criteria, constraints, available
evidence, authorized tools and actions, expected artifact, and stop rules.

Do not silently advance to another layer. Research does not authorize
implementation; implementation does not authorize external coordination. Ask
only when the next layer changes authority or a missing fact blocks correctness.

## Communicate by outcome

Before the first tool call, give a one- or two-sentence preamble naming the first
step. Update only at a major phase change or when a finding changes the plan.
Each update states one concrete outcome and the next step. Do not narrate routine
reads, commands, waits, or unchanged state.

Use a short plan when dependencies matter. Mark a phase complete when its
acceptance condition is satisfied, not merely when its tool calls finish.

## Preserve state deliberately

Keep durable state compact: objective, phase, completed milestones, decisions,
evidence or artifact paths, blockers, and next action. Reference logs, diffs,
datasets, and generated artifacts by path instead of replaying them.

For Responses API implementations, treat these as application/runtime
requirements; this skill documents them but cannot enforce them:

- Prefer `previous_response_id` when server-managed continuation fits the data
  policy. It preserves prior assistant state, but prior input tokens in the
  chain are still billed.
- When replaying history manually, preserve assistant phase values unchanged.
- Compact after major milestones, not every turn. Carry opaque compaction items
  forward exactly as returned and do not summarize or prune them manually.
- Reuse persisted reasoning only while the objective, assumptions, and
  priorities remain stable. Start from current-turn reasoning after a material
  change to avoid stale anchoring.
- Keep reusable prompt prefixes stable. Add cache breakpoints only when measured
  behavior justifies them.

Inside an interactive coding harness, use its native compaction control only at
a milestone. Prefer `handoff` and a fresh closeout task when the transcript is
large or the next phase needs little prior reasoning.

## Stop useful work, not just loops

After each material result, decide whether the core request can now be completed
with sufficient evidence. If yes, validate and finish. If not, name the missing
fact and take the smallest useful fallback.

Stop after repeated unchanged checks, exhausted retry budgets, loss of required
authority, or a material scope expansion. Never use an agent or sub-agent as a
process monitor. "Keep working until complete" authorizes persistent in-scope
reasoning, not unbounded polling or a transition into a new work layer.

## Close out

Run the validation named in the phase contract. Report the achieved outcome,
artifacts, evidence, decisions, unresolved risks, and the next authorized action.
If validation could not run, state why and identify the smallest credible next
check.
