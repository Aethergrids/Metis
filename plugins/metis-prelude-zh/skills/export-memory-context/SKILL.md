---
name: export-memory-context
description: >-
  将长 session 中的持久上下文导出为 Claude memory store 风格的目录：每项事实一个
  文件，使用 memory-tool frontmatter，以可追加的 MEMORY.md 作为索引，并把大型材料
  放入 assets/。适用于用户要求导出、handoff、archive 或“把学到的内容写下来”，让
  另一个 session 或 teammate 接手；适用于提到 memory layout、memory tool，或希望内容
  可以合并进项目 memory 目录；也适用于长时间调查产生了重新发现成本很高的事实。接收方
  是 Agent 而不是只读一次的人类时，优先于单一长 handoff 文档。
---

# 导出与 memory 对齐的上下文

长 session 会积累两类不同内容：发生过程的叙事，以及会改变后续决策的持久事实。单一
handoff 文档把两者混在一起，适合人类浏览一次，却不适合 Agent 在数周后按需 recall
某一项事实。

本 skill 生成第二种形式：一个 Claude memory store 风格的目录，可以直接合并进项目的
memory 目录；叙事与大型证据则作为相邻 asset 保存。

## 写入前读取目标目录

导出文件只有无需再编辑就能放入目标 memory 目录时才真正有用。因此先读取
`~/.claude/projects/<project-slug>/memory/` 中的 `MEMORY.md` 和两三个 fact file，
匹配其中的 filename pattern、frontmatter field、index line format 与 body structure，
不要优先采用本 skill 的 fallback。

目标目录可能包含本 skill 无法预知的约定，例如 filename type prefix、
`originSessionId`、`modified` timestamp，或 index link 使用 bare filename 还是 path。
测试表明，只按模板写会产生看似正确但与真实目录细节不兼容的文件，并可能丢失 provenance；
先读目标目录能避免该问题。schema 也会随 memory tool 变化，不应写死为唯一真相。

确实无法访问目标目录时，例如位于 sub-agent 或用户没有指出目标项目，要在 README 中明确
说明，使用下方 fallback，并提醒接收方复制前 reconcile。不要静默归一化到某一套约定。

## 目录结构

```text
<export-name>/
├── MEMORY.md     可追加到项目 MEMORY.md 的索引行
├── memory/       每项事实一个文件，匹配目标目录约定
└── assets/       memory 文件引用的大型材料
```

无法看到目标目录时使用以下 fallback；与真实目标冲突时，以目标为准：

```markdown
---
name: <short-kebab-case-slug>
description: <一行 claim，让未来 Agent 不打开文件也能判断相关性>
metadata:
  node_type: memory
  type: project | reference | feedback | user
---

<第一句直接陈述事实>

**Why:** <为何成立；只用于 project/feedback>
**How to apply:** <未来 Agent 应如何改变行动；只用于 project/feedback>

Related: [[other-memory-name]]
```

`MEMORY.md` 每个文件占一行，遵守目标目录的 index format，常见形式是
`- [Title](file.md) — hook`。真实 index 通常与 fact file 同处 memory 目录，因此链接
经常是 bare filename，而不是带 `memory/` 前缀；必须实际检查。hook 要携带事实，不只是
主题，使 recall 只读 index 也能行动。

## 选择哪些内容成为 memory

判断标准不是“session 中是否重要”，而是：**未来 Agent 缺少它是否会做出更差决策，并且
重新发现是否昂贵？** 大部分 session 内容不满足。

高价值候选：

- **推翻原假设的测量。** 记录数值以及它否定了什么；新 Agent 最容易重新得出旧假设。
- **尝试后被证伪的设计。** 写明测量结果，不只写“失败”。
- **通过实际问题发现的约束。** 例如 consumer 无法提供必需 predicate，API tag 只在
  run 开始后出现，或 library 在测试和 production 中接受不同形式。
- **理由无法从代码直接看出的决策。**
- **新 Agent 根据过时认知行动会破坏的状态。** 例如已经完成、不得重跑的 backfill。

通常跳过：发生过程的叙事、repo 已经记录的内容、瞬时状态和自身推理过程。

**每个文件只写一个事实。** Recall 会加载整个文件；一个文件包含五项事实时，每次命中只
需要其中一项，却浪费另外四项 context。出现第二个 heading 往往意味着应拆成两个 memory。

对于集合尤其要拆分，例如三个已排除 theory、四个 rejected design 或五个失败 config。
未来问题通常是“retry-storm theory 是否检查过”，不是“列出全部 dead end”。只有成员真正
不可分割、单独知道一项会产生误导时才合并。

## 编写 description

Description 是未来 Agent 判断相关性时唯一先看到的内容，应写成 claim 而不是 label。
`"Join pruning notes"` 只是标签；`"按 id 连接 task profile 时，有 date hint 使用
0.90 GB，无 hint 使用 76 GB；behavioral event 无法提供 date，因此需要由 key 推导
band"` 是可行动的 claim。

## 链接且不重复

可以使用 `[[other-name]]` 连接本次导出的 memory，也可以链接目标项目中已有 memory。
指向尚不存在名称的链接也可以保留，表示值得以后补写。

写文件前检查目标 memory 是否已经覆盖该事实。若已覆盖，**只链接，不复述**。已有 memory
可能已被修正，复制一个分歧版本会让 recall 同时返回两种说法，危害大于缺失。README 中要
明确列出哪些 memory 因已有版本而没有重复导出。

## assets/ 中放什么

不适合作为单一事实的大型或结构化内容，例如 schema dump、SQL、narrative handoff、
plan、ledger extract 和 benchmark output。memory file 使用相对路径引用，例如
`assets/current-schema.sql`。

优先把这些内容复制进导出，而不是引用可能移动或变化的 repo 路径。即使 repo 位于不同
commit，导出也应能独立理解。

## README

编写简短 `README.md`，包含目录结构、三步集成说明、asset 表、刻意未重复的 memory，以及
一句 situation summary。加入 reading order，让接收 Agent 不必猜测哪个文件说明问题，
哪个文件记录当前状态。

## 完成前

- **扫描 credential。** 在整个导出中查找 key、password、token 和 connection string。
  可以写 credential 来源，例如 `.env 中的 pixai_… key`，但不得写其值，并明确禁止复制
  到文档。
- **每项事实都必须已验证。** 相信但未确认的内容放入 README 作为 open question，不放入
  `memory/` 充当事实。
- **单独重读每条 description。** 不打开正文仍无法理解事实时，重写。
- **统计文件数。** 超过约十二个通常意味着拆分过细或叙事混入。

## 对其他 Agent 的可移植性

内容是可移植的：普通 Markdown、YAML frontmatter 和 `[[link]]` 在其他工具中也能读取。
自动加载方式并不通用：Claude Code 会从 memory directory 自动 recall；Codex、OpenCode
和 Cursor 通常通过目录向上查找 `AGENTS.md`，不会自动发现 `memory/`。

导出还要服务这些 Agent 时，在根目录添加 `AGENTS.md`，列出每个 memory 文件的一行
description，并要求行动前读取相关文件。这样能保留 one-fact-per-file 的选择性 recall；
不要把全部 memory 拼成一个大文件。

## 示例形态

一次持续数日的 database table redesign 通常会产生约十余个 memory，并把 DDL、write
path SQL、narrative 与 ledger extract 放入 assets。每个 memory 回答未来 Agent 可能单独
提出的一个问题：目标是什么、layout 为何错误、normalization 测量说明什么、storage hazard
是什么、join 成本多少、必须保留哪条 precedence rule、backfill 当前状态，以及仍有哪些
open question。

三个被证伪的设计应写成三个 memory，因为 recall 问题是“approach X 是否试过”，而不是
“列出所有 rejected design”。拆分后才能只返回相关的一项。
