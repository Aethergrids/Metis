---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

I'm working on point-in-time correct feature retrieval for ML training data. We have a label table (entity_id, label_ts, label) and several feature tables, each one an event log (entity_id, event_ts, a few value columns). For every label row we need the latest value of each feature with event_ts <= label_ts (an as-of join), optionally limited to a lookback window like 30 days. I want to compare DuckDB, Spark and DataFusion on this, both for offline batch generation of training sets (millions to billions of label rows) and for online serving (one entity at "now", where latency matters). Can you design the evaluation workload and benchmark for my project? Write the spec to benchmark-spec.md.
