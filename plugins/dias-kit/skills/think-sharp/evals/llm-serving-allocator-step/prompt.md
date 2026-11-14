---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

I'm a PhD student building Tachyon, a research LLM inference server in Rust (continuous batching, paged KV cache), on one A100 80 GB with Llama-3-8B. One run of our serving benchmark (ShareGPT trace, 64 concurrent clients, 2,000 requests) gave p99 time-to-first-token 820 ms, median TTFT 210 ms, and 1,840 output tokens/s. A perf profile of the CPU side shows the KV-block allocator (a Mutex<Vec<BlockId>> free list) at 14% of summed CPU time across the 8 scheduler and worker threads. Decode is GPU-bound: one step takes 38 ms on the GPU, while the scheduler's CPU work for a step (allocation included) takes 4.1 ms and overlaps the previous step's kernels. The allocator serves about 3,000 alloc/free calls per step at about 0.25 µs each, and the lock's p99 hold time is 2 µs. I want to replace it with a lock-free slab allocator; I think that could cut p99 TTFT by 10-15%. Should we do it? Plan the next research step, write the step record to step-allocator.md, and give me a short chat summary.
