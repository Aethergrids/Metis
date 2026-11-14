---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

我是博士生，正在用 Rust 做研究用的 LLM 推理服务 Tachyon（连续批处理、分页 KV cache），机器是一张 A100 80 GB，模型是 Llama-3-8B。服务基准跑了一次（ShareGPT trace，64 个并发客户端，2,000 个请求），p99 time-to-first-token 820 ms，TTFT 中位数 210 ms，输出 1,840 tokens/s。CPU 侧的 perf 画像显示，KV 块分配器（Mutex<Vec<BlockId>> 空闲链表）占 8 个调度线程和工作线程合计 CPU 时间的 14%。解码受 GPU 约束：一步在 GPU 上要 38 ms，调度器一步的 CPU 工作（含分配）要 4.1 ms，并且与上一步的 kernel 重叠。分配器每步大约处理 3,000 次 alloc/free，每次约 0.25 µs，锁的 p99 持有时间是 2 µs。我想换成无锁 slab 分配器，觉得这样能把 p99 TTFT 降 10-15%。该做吗？请规划下一步研究，把步骤记录写到 step-allocator.md，并给我一段简短的对话摘要。
