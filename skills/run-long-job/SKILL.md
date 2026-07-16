---
name: run-long-job
description: >-
  Launch and supervise local commands expected to run longer than five minutes
  without keeping a language model in a polling loop. Use before starting
  training, backfills, migrations, materializations, benchmarks, large builds,
  batch downloads, or any job the user asks to watch, keep checking, or leave
  running overnight. Also use when a foreground command remains active after
  one health check. Do not use for ordinary interactive commands or bounded
  agent reasoning.
---

# Run Long Job

Detach compute from the agent lifecycle. Leave compact, durable evidence that a
later turn or fresh task can inspect once.

## Hard rules

- Never alternate model turns with `sleep`, log tails, PID checks, resource
  checks, or wait-tool calls.
- Allow at most one initial health check and one terminal-state check in a
  task. After two unchanged checks across resumptions, stop and leave a handoff.
- Never keep a sub-agent alive to monitor a process.
- Never invoke this skill's `wait` command through an agent-managed shell tool.
  It is only for an external, non-LLM watcher.
- Treat "keep working until complete" as permission to detach the computation,
  not permission to poll it.

## Launch

Resolve `scripts/long_job.py` relative to this `SKILL.md`, then run:

```bash
<skill-root>/scripts/long_job.py start \
  --name <short-name> \
  --cwd "$PWD" \
  -- <executable> <arg> ...
```

Pass an argv vector directly. For a pipeline or redirection, make the shell
explicit with `-- sh -lc '<pipeline>'`. Do not place credentials in command-line
arguments: the launcher records the command and parameters in `status.json`.
Use inherited environment variables or the project's secret mechanism instead.
The launched command must remain in the foreground and own its child processes;
do not append `&` or invoke a self-daemonizing mode.

The launcher performs a bounded, non-LLM health check and returns one compact
JSON line containing the run directory, state, PIDs, log path, status path, and
terminal-sentinel path. It records the working directory, command, parameters,
Git SHA, tracked-dirty state, timestamps, and process identifiers. By default,
run state is stored under the operating system's temporary directory. Set
`METIS_RUNS_DIR` or pass `--root` when a specific durable location is required.

Treat that result as the initial health check. If it reports `running`, stop
using tools and end the turn with the run directory and this later-resume
command:

```bash
<skill-root>/scripts/long_job.py status <run-directory>
```

Only call `status` immediately when the launch result remains `starting`; call
it at most once, then end the turn. If the job failed during launch, inspect at
most the final 40 log lines once.

## Milestones

The child receives `METIS_RUN_DIR`, `METIS_MILESTONE_PATH`, and
`METIS_LONG_JOB_CLI`. A cooperative job can publish one concise milestone:

```bash
"$METIS_LONG_JOB_CLI" milestone "$METIS_RUN_DIR" "epoch 4/20"
```

`status` returns only the latest milestone. Do not tail the full log to infer
progress.

## Resume and close out

Prefer a fresh, small-context closeout task after completion. On resume, run
`status` once:

- `running`: report the compact state and stop; do not schedule another check
  unless the user explicitly requested a bounded follow-up.
- `succeeded`: verify the requested artifacts and continue with closeout work.
- `failed` or `lost`: inspect at most the final 40 log lines, diagnose once, and
  either make a bounded fix or ask for the decision the failure requires.

For a non-LLM shell watcher, this command emits nothing until terminal state and
then returns one compact JSON line:

```bash
<skill-root>/scripts/long_job.py wait <run-directory>
```

Do not call it from the agent loop. A manual resume is the lowest-cost wakeup.
If the user explicitly requests scheduled follow-up, use a 30-60 minute cadence,
a hard check limit, and a durable stop condition; scheduled checks still consume
model turns and are not completion events.
