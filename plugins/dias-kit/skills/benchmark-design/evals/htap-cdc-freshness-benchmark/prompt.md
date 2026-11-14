---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

We're building a CDC pipeline that streams changes from a Postgres OLTP database (an e-commerce app: orders, order_items, payments, inventory) into a DuckDB + Parquet analytical replica, and analysts run dashboards on the replica. We want to evaluate our design against two alternatives: Debezium + Kafka feeding the same replica, and simply running the analytics on a Postgres read replica. What matters is how stale the dashboard data is and whether dashboards stay fast while the write load is high. Please design the benchmark (workload, data, metrics, rules) and put it in freshness-benchmark-spec.md.
