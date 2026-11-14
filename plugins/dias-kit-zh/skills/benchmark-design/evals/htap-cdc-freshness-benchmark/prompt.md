---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

我们在做一条 CDC 流水线，把 Postgres OLTP 数据库（一个电商应用：orders、order_items、payments、inventory）的变更流到 DuckDB + Parquet 分析副本，分析师在副本上跑仪表板。我们想拿自己的设计对照两个替代方案来评测：Debezium + Kafka 喂给同一个副本，以及直接在 Postgres 只读副本上跑分析。要紧的是仪表板数据有多陈旧，以及写入负载高的时候仪表板还能不能保持快。请设计这个基准（负载、数据、指标、规则），写到 freshness-benchmark-spec.md。
