---
name: manage-long-workflow
description: >-
  以稀疏更新和持久状态管理跨 phase、turn 或 context window 的单 Agent 多步骤或
  tool-heavy 工作。适用于跨研究、设计、实现、review 或外部协调的任务，需要设计
  compact、持久 reasoning、prompt caching 或 Responses API state 的场景，以及
  “持续工作直到完成”需要明确阶段与停止规则的场景。不用于轮询外部计算或编排多个 Agent。
---

# 管理长工作流

让一个 Agent 聚焦当前工作层，只保留会改变后续决策的状态。模型相关行为以最新官方
[GPT-5.6 long-workflow guidance](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6#long-running-workflows-and-state)
为准。

## 开始前路由

选择最窄的工作流：

- **单 Agent 分阶段工作：** 使用本 skill。
- **预计超过约五分钟的本地计算：** 调用
  `$metis-prelude-zh:run-long-job`，完成有界启动检查后结束 Agent turn。
- **多 Agent 分解：** 调用 `$metis-prelude-zh:orca-fleet`。
- **切换到新 context：** 在重要里程碑调用 `$metis-prelude-zh:handoff`。
- **长时间 Responses API generation：** 使用 background mode，并优先采用
  `response.completed` 等受支持 webhook；其他 terminal state 或 webhook 不可用时，
  由普通 service 而不是模型 turn 负责轮询。

## 固定当前阶段

明确当前层：研究、设计、实现、review 或外部协调。随后定义目标、成功标准、约束、已有
证据、已授权工具与动作、预期 artifact 和停止规则。

不要静默进入下一层。研究不自动授权实现，实现也不自动授权外部协调。只有下一层改变权限，
或缺失事实阻碍正确性时才提问。

## 按结果沟通

第一次 tool call 前，用一到两句话说明第一步。只在重大阶段变化或发现改变计划时更新；
每次更新写一个具体结果和下一步，不叙述常规读取、命令、等待或未变化状态。

存在依赖时使用短计划。阶段的验收条件满足时才标记完成，不以 tool call 结束为完成标准。

## 有意识地保存状态

持久状态保持紧凑：目标、阶段、已完成里程碑、决策、证据或 artifact 路径、blocker 和
next action。通过路径引用日志、diff、dataset 和生成物，不在上下文中重放。

Responses API 实现应将以下内容视为 application/runtime 要求；本 skill 只能记录，不能
替 runtime 强制执行：

- 数据策略允许 server-managed continuation 时，优先使用 `previous_response_id`。
  它保留之前的 assistant state，但链中之前的 input token 仍会计费。
- 手动 replay history 时，保持 assistant phase value 原样不变。
- 只在重要里程碑 compact，不要每个 turn 都 compact。opaque compaction item 必须原样
  传递，不手工总结或裁剪。
- 只有目标、假设和优先级稳定时才复用持久 reasoning。发生实质变化后从当前 turn 的
  reasoning 重新开始，避免 stale anchoring。
- 保持可复用 prompt prefix 稳定；只有测量结果支持时才添加 cache breakpoint。

在交互式 coding harness 中，只在里程碑使用原生 compact。transcript 较大或下一阶段
几乎不需要旧 reasoning 时，优先使用 `$metis-prelude-zh:handoff` 和新的收尾 task。

## 停止无效工作，而不只是停止循环

每次得到实质结果后，判断核心请求是否已有足够证据完成。若已满足，验证并结束；否则明确
缺失事实，并采取最小的有效 fallback。

出现重复不变检查、重试预算耗尽、失去必要权限或实质性范围扩展时停止。不要让 Agent 或
sub-agent 充当 process monitor。“持续工作直到完成”只授权范围内的持续推理，不授权
无界轮询或自动进入新的工作层。

## 收尾

运行阶段契约指定的验证。报告已达成结果、artifact、证据、决策、未解决风险和下一项已授权
动作。无法验证时说明原因，并指出最小可信的下一项检查。
