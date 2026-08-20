---
name: design-tool-workflow
description: >-
  设计或审计 Agent tool set、function tool、MCP tool、检索路由和
  Programmatic Tool Calling 阶段。适用于决定暴露哪些工具、编写工具说明、
  安排前置步骤、选择直接或程序化调用、限制重试与 fallback、定义引用或证据要求，
  以及将大型工具结果压缩为紧凑 schema。
---

# 设计工具工作流

先设计从证据到行动的路由，再润色工具说明。模型或 API 相关细节以最新官方
[GPT-5.6 prompt guidance](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6)
和
[Programmatic Tool Calling guide](https://developers.openai.com/api/docs/guides/tools-programmatic-tool-calling)
为准。

## 定义契约

记录：

- 用户可见的目标结果与必需证据；
- 允许的读取、写入和审批边界；
- 必需的发现与验证前置步骤；
- 最终输出 schema 与引用要求；
- 重试、fallback、handoff 和停止条件。

只暴露与该契约相关的工具。每项说明必须写明工具做什么、何时使用、重要输入与返回字段、
副作用和有意义的错误行为。删除“高效使用工具”之类的泛化鼓励。

## 路由调用

- 即使目标状态看起来显而易见，也要在行动前完成必要的检索和验证。
- 独立读取可以并行；有依赖的调用保持顺序，并在行动前综合并行结果。
- 结果为空、不完整或范围可疑地窄时，尝试一到两个有意义的 fallback，不要循环改写
  表面相似的查询。
- 审批、语义判断、引用和最终验证由模型直接控制。

## 选择直接调用或程序化调用

以下情况使用直接 tool call：一次调用即可完成；中间结果较小；每个结果都会改变下一步；
涉及审批；需要保留引用或原生 artifact；或者调用之间需要语义判断。

Programmatic Tool Calling 只用于有界、确定性的归约阶段，例如过滤、连接、排序、排名、
去重、聚合、同类记录批处理、重复验证或压缩大型结构化结果。必须定义：

- 可调用的工具，通常只读；
- 精确的结果 schema，包括证据字段；
- 重试上限，通常不超过两次瞬时错误重试；
- 停止条件与资源预算；
- 一次返回模型直接判断的 handoff。

不要让工作流反复切换路由或重做已完成工作。

## 设置检索预算

普通 grounded Q&A 先做一次使用简短区分词的宽检索。只有在缺少必需事实、来源、日期、
owner、identifier 或 citation，用户要求穷举比较，必须读取指定 artifact，或实质性主张
仍缺证据时才继续检索。不要只为改善措辞或增加非必要细节而再次搜索。

引用必须来自已经检索的来源，并紧邻其支持的主张；明确标注推断、暴露来源冲突，并在证据
不足时收窄回答。缺少证据本身不等于反面证据。

## 验证两层契约

分别测试结构化 tool 或 `program_output` 结果，以及最终 assistant 消息。归约结果可以
正确，但最终回复仍可能漏掉字段、引用或 caveat。使用相同用例比较直接路由与程序化路由；
只有两者都满足契约时，才接受资源节省。
