---
type: llm
focus: trace
weight: 1
---

The response states that the allocator's work is off the critical path of TTFT, because the scheduler's 4.1 ms of CPU work per step overlaps the 38 ms GPU step, so a 14% share of summed CPU time does not translate into latency
