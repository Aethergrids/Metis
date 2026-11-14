---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Here's the plan for the evaluation section of our paper. Our system is a new vectorized query engine on Arrow (call it Quark). Plan: generate TPC-H SF10 with dbgen, load it into Quark, Postgres 16 (default config) and DuckDB 1.1. Run the 22 queries once each, in order, right after loading, and report total runtime per system as a bar chart plus a speedup table vs Postgres. Quark runs hand-written physical plans for Q1-Q22 because our optimizer isn't finished yet. Everything runs on my laptop (M2, 16 GB RAM). We also want to claim that Quark "scales better", so we'll add SF1 next to SF10. Can you review this plan, tell me what's wrong with it, and write a revised evaluation plan to eval-plan-revised.md?
