---
type: llm
focus: trace
weight: 1
---

回复指出分配器的工作不在 TTFT 的关键路径上：调度器每步 4.1 ms 的 CPU 工作与 38 ms 的 GPU 步重叠，因此合计 CPU 时间中 14% 的占比并不能对应到延迟上
