---
name: run-long-job
description: >-
  Launch commands expected to run longer than five minutes without model
  polling. Use for training, backfills, migrations, materializations,
  benchmarks, large builds, batch downloads, overnight work, or requests to
  wait, watch, or keep checking until a local process completes.
---

# Run Long Job

Read `skills/run-long-job/SKILL.md` from the repository root and follow it as
the authoritative detached-job workflow.

Treat text supplied with the skill invocation as the command or long-running
objective. Return control after one initial health check rather than keeping the
agent active to monitor the process.
