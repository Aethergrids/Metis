---
name: orca
description: >-
  Cost-safe orchestration playbook for long-running, multi-step, or multi-agent
  engineering work. Use this WHENEVER you act as an orchestrator — planning and
  dispatching work to workers, coordinating parallel execution, monitoring
  background training / backfill / materialization / encode jobs, running an
  adversarial review-then-merge loop, or about to spawn a sub-agent for anything
  that runs longer than one pass. It defines the Claude (Fable/Opus) orchestrator
  + Codex worker + Paseo worker + detached-box-compute topology and the HARD
  cost-discipline rules that prevent runaway token spend (the pattern that once
  cost ~$1000 in a single night). Consult it BEFORE delegating, BEFORE launching
  anything unattended, and BEFORE leaving work running overnight. See AGENTS.md
  for the full agent roster and handoff protocol.
---

# orca — orchestrating agents without burning the budget

**One durable Claude orchestrator does the thinking; cheap workers do the doing.**
The orchestrator (Claude Fable 5 / Opus 4.8, the interactive session) plans,
writes specs, decides, reviews, verifies, and merges. Execution is pushed to
workers whose token cost is *not* on the Claude quota — Codex (GPT-5.6-Sol),
Paseo agent fleets, and plain detached box processes. The failure mode this
skill exists to prevent: keeping premium Claude sub-agents alive for hours to
babysit work that a shell loop could watch for free.

## Why long-lived Claude sub-agents get catastrophically expensive

Read this once; it explains every rule below.

1. **Context is re-billed every step.** On each tool call the model reprocesses
   the *entire* transcript so far (system prompt + all messages + all tool calls
   + **all tool results**) as input tokens. A session of N steps pays ~the sum of
   context size at each step → **O(N²)** when context grows as it runs. 100+ tool
   calls over a 150k-token context ≈ 10M+ input tokens for one agent.
2. **Big tool results poison context permanently.** Every log tail, table dump,
   or file Read stays in context and is re-billed on *every later step*. Tailing
   a log 30× costs the log × all subsequent steps, not 30× once.
3. **Idle waits break the prompt cache.** Caching makes the repeated prefix ~10×
   cheaper, but it expires after a short TTL (5 min; 1 hr extended). A monitor
   that sleeps then wakes an agent after the TTL re-bills the whole context at
   **full price** on every wake.
4. **Opus + high effort + parallelism multiply it.** Premium rate × extra
   reasoning tokens × several agents at once × all night = four figures.

Box compute (DuckDB, `dg` materialize, GPU training, `codex`) is cheap by
comparison. **The cost is the Claude wrapper, not the work.**

## Cardinal rules (hard)

1. **Never wrap a background box job in a live Claude sub-agent that polls it.**
   The LLM adds nothing while the job runs. Launch DETACHED, monitor with a
   shell loop, wake the orchestrator ONCE on terminal state.
2. **Sub-agents are short and single-pass.** Full spec up front → do it → finish.
   Do NOT resume/re-nudge the same agent dozens of times; each resume re-bills
   the grown context (at full price if it idled past the cache TTL).
3. **Never inline large tool output.** Grep/summarize to ≤10 lines; write big
   results to files and pass paths.
4. **Match model to task.** Mechanical / monitoring / formatting / bounded
   codegen → Codex or a cheap model. Reserve Claude Opus/Fable for genuinely
   hard reasoning, design, review, and decisions.
5. **Cap every dispatch:** one bounded deliverable, ~25 tool calls. Over that →
   stop, report, re-plan. Don't grind.
6. **Long or overnight work → PAUSE and confirm with the human.** Keep all state
   resumable (scratch on durable storage, code committed) so pausing costs
   nothing and nothing is lost.
7. **Prefer non-Claude budget.** Codex and Paseo workers don't spend the Claude
   quota — route execution and review there whenever quality allows.

## The background-job pattern (use for train / backfill / materialize / encode)

Launch detached, write a terminal marker, monitor from the MAIN session:

```bash
# launch — detached, survives the session, logs to a file
setsid nohup <cmd> > run.log 2>&1 &
echo $! > run.pid
# ...ensure the command's last line prints a terminal marker, e.g.:
#   <cmd> ...; echo "EXIT=$?" >> run.log
```

```bash
# monitor — ONE blocking shell loop; wakes the orchestrator once, not on a timer.
# Includes a stall detector so a hung job is caught, not slept through.
LOG=run.log; last=""; stall=0
until grep -qE 'EXIT=|RUN_SUCCESS|RUN_FAILURE' "$LOG"; do
  cur=$(grep -cE '<progress-marker>' "$LOG")
  if [ "$cur" = "$last" ]; then stall=$((stall+1)); else stall=0; last=$cur; fi
  [ "$stall" -ge 10 ] && { echo "STALLED: no progress in ~10 checks"; break; }
  sleep 60
done
grep -E 'EXIT=|RUN_SUCCESS|RUN_FAILURE|Error|Maximum resident' "$LOG" | tail -5
```

Run this monitor with the harness's own background/Monitor mechanism if it has
one, so the orchestrator is invoked a single time at completion. Never tail the
full log into the orchestrator's context — grep the ≤5 lines that matter.

## Who does what (dispatch decision table)

| Work | Send to | Why |
|---|---|---|
| Planning, specs/contracts, rulings, final decisions | **Orchestrator** (Claude) | needs durable context + judgment |
| Adversarial code review before merge | **Codex** (read-only) | non-Claude budget; strong, skeptical |
| Bounded code writing / refactor / test authoring | **Codex** or **Paseo** | non-Claude budget; one-pass |
| Parallel work across many files/targets | **Paseo** fleet | fan-out without Claude cost |
| Heavy compute (train, materialize, backfill, encode) | **Detached box shell** | pure CPU/GPU; monitored by shell loop |
| Verifying a worker's claims, merging | **Orchestrator** | trust-but-verify is the orchestrator's job |

## Codex worker recipe (non-Claude budget)

```bash
# Adversarial review / analysis (read-only intent). On externally-sandboxed
# boxes the default bwrap sandbox can fail to make netns — bypass it there:
codex exec --dangerously-bypass-approvals-and-sandbox -c tools.web_search=true - < prompt.md > out.md 2>&1
# For bounded implementation, run in the target worktree; give the full spec in
# prompt.md. Codex is GPT-5.6-Sol; config.toml sets model/effort defaults.
# NOTE: `codex exec` has NO `--search` flag — use `-c tools.web_search=true`.
```
Give Codex the frozen contract/spec inline; ask for ranked, evidenced findings
with file:line + a failing scenario; end with a MERGE-OK / CHANGES-REQUIRED
verdict. The orchestrator triages — Codex can be plausibly wrong; verify before
adopting.

## Paseo worker recipe (agent fleet, non-Claude budget)

```bash
paseo run "<full bounded task>"     # create+start an agent
paseo ls                            # list agents/status
paseo logs <id>                     # timeline (grep it; don't inline)
paseo attach <id>                   # stream output
paseo stop <id> / paseo delete <id> # wind down
```
For structured multi-agent flows use the companion skills `paseo-orchestrate`,
`paseo-committee`, `paseo-loop`, `paseo-handoff`. **Verify which model/budget a
Paseo agent runs on before relying on it for cost savings.**

## When to spawn a Claude sub-agent at all

Rarely. Only for a discrete task that needs Claude-grade reasoning AND cannot go
to Codex/Paseo. Then: give it everything up front, cap it, let it finish in one
pass, and read its final message — do not keep it alive to iterate or monitor.

## Pre-flight checklists

**Before dispatching any worker:** Is this reasoning (→ orchestrator) or
execution (→ worker)? Is the spec complete enough for one pass? Is the cheapest
capable channel chosen? Is there a hard cap?

**Before leaving work unattended / overnight:** Is every heavy job a detached
shell with a terminal marker + stall detector (NOT an agent)? Are all
sub-agents stopped, not idling on monitors? Is state resumable? Have I confirmed
with the human that long/overnight run is wanted?

## Anti-patterns (these caused the $1000 night)

- ✗ An Opus sub-agent looping `tail` + `sleep` to watch a `dg`/training run.
- ✗ Re-nudging the same agent 100+ times instead of one clean pass.
- ✗ Monitors waking idle premium agents every N minutes (cache-cold re-bills).
- ✗ Pasting full logs / table dumps / file contents into an agent's context.
- ✗ Running several Opus/xhigh agents in parallel unattended overnight.
- ✗ Using Opus for formatting, monitoring, or mechanical edits.
