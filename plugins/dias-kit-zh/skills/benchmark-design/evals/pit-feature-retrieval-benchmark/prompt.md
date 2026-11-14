---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

我在做机器学习训练数据的时间点正确特征检索。我们有一张标签表（entity_id, label_ts, label）和若干特征表，每张都是事件日志（entity_id, event_ts，外加少数值列）。对每一行标签，需要各特征在 event_ts <= label_ts 时的最新值（as-of join），可选地限制在回看窗口内，比如 30 天。我想在这件事上比较 DuckDB、Spark 和 DataFusion：既有离线批量生成训练集（标签行从数百万到数十亿），也有在线服务（一个实体取「现在」的值，延迟要紧）。请为我的项目设计评测负载和基准，把规范写到 benchmark-spec.md。
