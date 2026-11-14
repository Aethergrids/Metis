---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

下面是我们论文评测部分的方案。我们的系统是 Arrow 上一个新的向量化查询引擎（叫做 Quark）。方案：用 dbgen 生成 TPC-H SF10，加载进 Quark、Postgres 16（默认配置）和 DuckDB 1.1。22 条查询各跑一遍，按顺序，加载完立刻跑，每个系统报告总运行时间，画成柱状图，再给一张相对 Postgres 的加速比表。Quark 对 Q1-Q22 跑手写物理计划，因为优化器还没做完。全部在我的笔记本上跑（M2，16 GB RAM）。我们还想声称 Quark「扩展得更好」（scales better），所以在 SF10 旁边加上 SF1。请审查这个方案，告诉我哪里有问题，并把修订后的评测方案写到 eval-plan-revised.md。
