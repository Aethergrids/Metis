---
name: update
description: >-
  在 .metis/context 下创建或刷新紧凑、与 session 无关的上下文工作区。适用于在
  compact 或继续工作前整理当前目标、工作队列、可委派工作、证据索引和持久 learning。
  不创建历史版本、不导出 bundle、不转交任务，也不调用 Agent。
---

# 更新 Context Ledger

维护一个可变的 pre-ledger 工作区。它是当前工作的紧凑视图，不是事件日志、transcript、
任务数据库或 session registry。

## 定位工作区

存在 Git 仓库时使用仓库根目录，否则使用当前目录。除非用户指定其他位置，只维护
`.metis/context/` 下这六个文件：

| 文件 | 持久内容 |
|---|---|
| `MEMORY.md` | 当前目标、状态、下一步、blocker，以及其他文件的链接 |
| `goal.md` | 目标、成功标准、约束和明确的 non-goal |
| `todo.md` | 进行中、下一步、blocked 和最近完成的工作 |
| `delegation-queue.md` | 以后可以委派的自包含工作单元 |
| `information-index.md` | 路径、URL、commit、命令、artifact，以及每项为何重要 |
| `learnings.md` | 决策、已验证发现、pitfall 和未解决问题 |

缺少文件时按上述用途创建。保留仍有价值的内容并原地更新，不创建 checkpoint 或版本目录。

## 整理状态

读取足够的当前对话和工作区信息，以区分已验证事实与假设。只记录会改变后续决策，或能让
另一个 orchestrator 继续工作的内容。

- `MEMORY.md` 保持简短；它是入口，不是其他文件的副本。
- 下一步必须具体且可验证。即使 `todo.md` 有多个候选，`MEMORY.md` 也只保留一个当前
  next action。
- 链接到详情，不复制日志、patch、大型输出或源文件。
- 未确认内容明确标记为未验证，不把推断写成事实。
- 不持久化仅对本次调用有效的指令，例如“这次不要 export”或“刷新时不要修改源码”；
  只有它们同样约束后续项目工作时才保留。
- 失效状态不再影响工作时将其删除；持久决策和 learning 放入各自文件。
- 不记录 credential、token、隐藏推理或原始 transcript。

六个文件之间使用相对 Markdown 链接，确保目录可移植。`MEMORY.md` 末尾保留简短的
`Read next`，链接到 `goal.md`、`todo.md`、`delegation-queue.md`、
`information-index.md` 和 `learnings.md`。

## 委派与 ledger 分离

`delegation-queue.md` 只索引可能的有界工作。每项写明目标、完成条件、依赖和有用引用。
不要创建 task、fork、sub-agent 或 handoff artifact。

用户明确要求现在转交或委派工作时，使用独立的原子
`$metis-prelude-zh:handoff` skill；该流程不属于 ledger 更新。

## 完成

重新检查六个文件是否相互矛盾、相对链接损坏、next action 过期或意外包含敏感内容。
报告哪些文件有实质变化，以及当前 next action。
