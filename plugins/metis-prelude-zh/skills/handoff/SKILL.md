---
name: handoff
description: >-
  为另一个 Agent 或新 task 创建紧凑、artifact-first 的当前任务转交。适用于用户明确要求
  handoff、在新 context 中继续、通过 fork 建立分支，或委派下一项有界阶段（包括轻量
  background assignment）的场景。记录已验证状态、决策、下一步和建议 skill，移除敏感
  信息，并在操作系统临时目录写入可移植 Markdown fallback。
---

# Handoff

转移持久任务状态，而不是携带嘈杂 transcript。将 context window 使用约三分之二视为
主动 handoff 的经验性提示，不把它当作已证明的质量边界。界面能报告 context 使用量时，
读取该数值，不要根据 transcript 长度估算。

## 选择转移模式

skill 调用后面的文本是下一项任务的 focus。将其原样保留为输入，再围绕它定制 handoff。

使用用户要求的最窄模式：

- **可移植文档（默认）：** 写入 handoff 并返回路径。用户没有要求时，不创建其他 task
  或 Agent。
- **新 task：** 目标是回收 context 时优先使用。只有用户明确要求时才创建 task，并使用
  handoff 而不是完整 transcript 初始化。
- **Fork：** 用户需要保留源历史的替代分支时使用原生 fork。fork 会复制历史，因此本身
  不回收 context。
- **Background sub-agent：** 只用于用户明确要求的有界委派，尤其是轻量后台任务。发送
  handoff、具体 deliverable 和停止条件，不发送 transcript。
- **同一 task：** 用户只想腾出 context 而不转移 owner 时，使用或建议界面的原生
  compact；必要时保留 handoff 文档作为恢复点。

不要把 context 转移与仅在本地 checkout 和 worktree 之间移动同一 task 的产品控制混淆。

## 收集 ground truth

只检查安全恢复工作所需的证据：

1. 记录用户目标、可选的下一 session focus、当前计划、已完成工作、决策、blocker 和
   未解决问题。
2. 相关时检查仓库或系统状态：repository root、branch、commit、working-tree status、
   changed files、验证结果和活动 background work。
3. 定位权威 artifact，例如 spec、plan、ADR、issue、commit、diff、log 和生成结果。
4. 区分观察事实与推断；不要把对话中的未验证说法写成事实。

命令输出保持有界。不要只为让 handoff 看起来完整而加载大型 diff、log 或 dataset。

## 编写文档

解析操作系统临时目录，并在其中写入唯一文件，例如
`handoff-YYYYMMDD-HHMMSS.md`。不得把生成的 handoff 放入当前 workspace。若 policy
不允许写入临时目录，在回复中直接给出文档并说明未保存；不要静默选择 workspace 路径。

使用以下结构，省略空章节：

```markdown
# Handoff: <下一项 focus 或当前目标>

Generated: <UTC timestamp>
Next focus: <用户提供的 focus 或 "Continue the current objective">

## Objective
<目标结果与验收标准>

## Current state
<已完成、进行中和未开始的内容>

## Decisions and constraints
<转移后必须保留的决策及简短理由>

## Artifacts and ground truth
- Repository: <可移植的仓库引用>
- Branch / commit: <branch 和 commit>
- Working tree: <clean，或简短 changed-file 摘要>
- <path 或 URL>: <重要原因>

## Verification
- <命令或检查>: <结果；必要时含 timestamp>

## Next actions
1. <价值最高的下一步及其验证>

## Risks, blockers, and open questions
- <事项、owner 或所需决策，以及影响>

## Suggested skills
- `$skill-name`: <下一 Agent 应在何时以及为何调用>

## Resume prompt
<告诉新 Agent 读取什么、执行什么、验证什么的简短命令式 prompt>
```

引用已有 artifact，不复制其内容。总结 artifact 为什么重要。仓库内文件优先使用相对路径，
home directory 使用 `~`，远端内容使用稳定 URL 或 identifier。列出 changed files 和
查看 diff 的命令，不嵌入 diff。

`Suggested skills` 只列出确认可用的 skill，使用完整准确的 invocation name，并说明相关性。
有顺序要求时按调用顺序排列；找不到可用 skill 时写 `None identified`，不要杜撰。

## 转移前移除敏感信息

- 不包含 secret value、credential、token、cookie、private key、password 或敏感环境变量
  内容。可以写需要哪项 secret 或配置来源，但不能写其值。
- 删除无关个人信息。不影响恢复时，将姓名、邮箱、电话、account identifier 和用户专属
  home path 替换为中性标签。
- 不为 handoff 检查 credential store，也不 dump environment。
- 保存或发送前扫描 draft，检查常见 credential 格式，以及意外混入的 log 或 clipboard
  内容。

## 完成转移

始终先创建并验证文档，再打开 destination：

- **新 task：** 发送简短 prompt，指向文档，说明 next focus，要求验证 ground truth 并
  调用建议 skill。destination 在远端、container 内或无法访问本地临时目录时，直接通过
  支持的 prompt 或 attachment channel 发送已清理的 handoff 正文，不粘贴旧 transcript。
- **Fork：** 文档存在后再创建 fork。fork 可能复制已完成历史但遗漏当前 handoff turn，
  因此需要 follow-up，包含 handoff 路径和 next focus，并说明 fork 保留历史、不是 context
  reset。
- **Background sub-agent：** 提供一个有界目标、允许范围、验收检查、输出契约、停止条件
  和 handoff 路径。源 Agent 仍负责集成并验证结果。
- **仅可移植文档：** 返回已验证路径，以及一句 next focus 说明。

除非用户明确要求，不 archive、delete、commit、stash，也不以其他方式修改源 task 或
working tree。报告文档路径、选定的转移模式，以及任何 destination task 或 Agent
identifier。
