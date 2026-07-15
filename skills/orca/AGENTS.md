# orca — agent roster & handoff protocol

The topology this skill assumes: **one orchestrator brain, many cheap hands.**
The scarce, expensive resource is Claude-orchestrator tokens; everything else is
routed to keep that spend low. See `SKILL.md` for the rules and recipes; this
file defines who each agent is, what it owns, and how work hands off.

---

## 1. Orchestrator — Claude Fable 5 / Opus 4.8 (the interactive session)

**Role.** The single durable brain. Holds the plan, the frozen contracts, the
human relationship, and the persistent memory. Everything that requires judgment
lives here.

**Owns:**
- Planning; writing specs/contracts before any dispatch.
- Deciding and *ruling* (resolving ambiguity, adjudicating review findings).
- Reviewing worker output and **verifying claims against ground truth** (never
  trust a worker's "done" — check the repo, the S3 object, the CI status).
- Merging / releasing / anything outward-facing or hard to reverse.
- Cost governance: choosing the cheapest capable channel for each task.

**Must NOT:**
- Babysit background jobs (that's a shell loop's job).
- Run long iterative loops or accumulate a giant transcript — keep context lean;
  summarize tool output; write big artifacts to files and reference paths.
- Do mechanical/bulk execution that a worker can do off the Claude budget.

**Budget:** Claude quota — treat as the constrained resource. Prefer Fable/Opus
only where reasoning quality genuinely pays for itself.

---

## 2. Codex worker — GPT-5.6-Sol (`codex exec` / `codex -p`)

**Role.** The default execution + review hand. Bounded code writing, refactors,
test authoring, and — especially — **adversarial pre-merge review**.

**Budget.** OpenAI, **separate from the Claude quota** → the cheap channel.
Route review and one-pass implementation here whenever quality allows.

**Invocation.**
```bash
codex exec --dangerously-bypass-approvals-and-sandbox -c tools.web_search=true - < prompt.md > out.md 2>&1
```
- Bypass the sandbox on externally-sandboxed boxes (default bwrap can't create
  netns and silently blocks all file reads).
- `codex exec` has **no `--search` flag** → use `-c tools.web_search=true`.
- Model/effort come from `config.toml` (e.g. gpt-5.6-sol, xhigh).

**Strengths / limits.** Rigorous, skeptical, good at concrete repro. Can be
plausibly wrong — the orchestrator triages every finding and verifies before
adopting. Give it the full frozen spec inline; ask for ranked findings with
file:line + failing scenario + a MERGE-OK / CHANGES-REQUIRED verdict.

---

## 3. Paseo worker — agent fleet via the `paseo` CLI

**Role.** Dispatch and control coding agents from the command line; the fan-out
channel for parallel work across many files/targets, and an alternative
execution hand.

**Commands.**
```bash
paseo run "<full bounded task>"   # create + start
paseo ls                          # status
paseo logs <id> / paseo attach <id>
paseo stop <id> / paseo delete <id>
```
Structured flows: the companion skills `paseo-orchestrate`, `paseo-committee`,
`paseo-loop`, `paseo-handoff`, `paseo-chat`.

**Budget caveat.** Confirm which model/provider a Paseo agent runs on before
counting it as "free" of the Claude quota — a Paseo agent backed by a Claude
model still spends it.

---

## 4. Box compute — detached shell processes (not an agent, a channel)

**Role.** All heavy lifting: `dg` materializations, model training, backfills,
encodes, big DuckDB queries. Pure CPU/GPU cost, effectively free of tokens.

**Protocol.** Launch with `setsid nohup … > run.log 2>&1 &`; ensure a terminal
marker (`echo "EXIT=$?"`). Monitor with a single shell `until` loop + stall
detector (see `SKILL.md`) that invokes the orchestrator **once** at completion.
Never wrap in a live Claude agent; never tail the full log into context.

---

## 5. Handoff protocol

1. **Scope first.** Orchestrator decides: reasoning (keep) vs execution
   (delegate). If delegating, write the complete spec/contract first.
2. **Pick the cheapest capable channel** (table in `SKILL.md`): review → Codex;
   parallel codegen → Paseo; heavy compute → detached shell; hard reasoning →
   orchestrator.
3. **Dispatch once, bounded.** Full context up front, a clear deliverable, a hard
   cap. No open-ended "keep iterating."
4. **Worker returns a result, not a running session.** Its final output is the
   handoff; the channel then goes idle/stops.
5. **Verify, don't trust.** Orchestrator checks the artifact against ground
   truth (repo diff, S3 object, CI status, real numbers) before accepting or
   merging.
6. **Escalate/pause** on: destructive or irreversible actions, genuine scope
   changes, approaching a usage/spend limit, or work that would run unattended
   overnight. Keep state resumable so pausing is free.

## 6. The one-line invariant

> The orchestrator thinks and decides; workers execute and return; box compute
> does the heavy work; and **nothing premium is ever left alive just to watch.**
