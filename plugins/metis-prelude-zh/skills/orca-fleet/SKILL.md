---
name: orca-fleet
description: >-
  面向长时间、多步骤或多 Agent 工程工作的模型中立编排手册。适用于协调 sub-agent、
  按复杂度分解工作、分派研究或实现、执行独立对抗性 review、管理 background compute
  或集成 worker 结果，包括通过 Codex、Claude Code 或 OpenCode2 的 Agent 定义工作。
  定义 orchestrator、Explorer、General Executor、Hard Executor 和 Evaluator 的职责，
  以及有界 handoff、验证规则和成本安全的监控方式。委派、启动无人值守任务或让任务过夜
  运行前应先使用。完整角色契约见 AGENTS.md。
---

# orca-fleet — 模型中立的 Agent 编排

由一个持久 orchestrator 对最终结果负责。具体模型、CLI 和 Agent harness 都是可替换的
执行通道，应按角色所需能力选择，不按 provider 或模型名硬编码。

## Harness 集成

根据当前 harness 可用的 distribution mode 使用本 canonical playbook：

- **Codex：** Plugin 安装暴露 `$metis-prelude-zh:orca-fleet`，使用主 task 当前可用的
  sub-agent。Project-local 安装暴露 `$orca-fleet`，并从 `agents/codex/agents/` 安装
  精确命名的 `.codex/agents/orca-fleet-*.toml` worker。
- **Claude Code：** Plugin 安装暴露 `/metis-prelude-zh:orca-fleet`，加载 plugin root
  内打包的 worker。Project-local 安装暴露 `/orca-fleet`，并把
  `agents/claude/agents/` 中的相同 worker 复制到 `.claude/agents/`。
- **OpenCode2：** Project-local 安装暴露 `/orca-fleet`，从 `agents/opencode2/` 安装主
  orchestrator 与 worker，并继续使用 `.opencode/` 配置目录。不支持 OpenCode V1。

为保证可移植性，默认继承当前模型。只有明确知道可用 catalog 和成本/能力层级时，才在
harness 层设置 model 或 reasoning override。Explorer 与 General Executor 优先使用经济
配置，Hard Executor 与 Evaluator 使用 orchestrator 级能力。

## 核心不变量

> Orchestrator 负责计划、路由、决策、集成和最终验证。Worker 完成有界 assignment，
> 返回有证据的结果。Detached process 负责长时间计算，不让 Agent 存活等待。

## Orchestrator 职责

Orchestrator 必须：

1. 定义目标结果、约束、验收标准和 frozen contract。
2. 将工作拆成具有明确依赖和写入范围的 task。
3. 按工作类型、复杂度和错误后果分类。
4. 将 task 分派给能够可靠完成它的最低成本角色。
5. 保存持久项目上下文，并解决歧义或冲突。
6. 根据 repository state、test、生成 artifact、service state 或权威来源检查 worker
   主张。
7. 集成被接受的工作，并负责 outward-facing 或难以回滚的动作。
8. 对需要用户权限或实质改变范围的决策升级处理。

委派成本高于直接执行时，orchestrator 可以自己实现；但不能成为长期 monitor，也不应仅因
自己能做就承担大型机械工作。

## 分派前分类

分两步分类：

1. **工作类型：** discovery、implementation、evaluation 或 background compute。
2. **复杂度：** routine 或 hard。

implementation 出现以下任一实质信号时视为 **hard**：

- 正确性依赖跨多个 component 保持上下文；
- 修改 architecture、public contract、state 或 security behavior；
- 需求有歧义，需要持续推理才能协调；
- 失败成本高、难发现或难回滚；
- debug 需要非局部推理，而不是已有明确 reproduction；
- 多个有依赖的修改必须作为一个整体保持一致。

task 很长本身不代表 hard。若大规模机械工作可以独立拆分，应拆成有界 routine assignment。

## Worker 路由

| 工作 | 角色 | 典型能力 |
|---|---|---|
| Web research、source gathering、codebase mapping、定位定义、reproduction、inventory | **Explorer** | 快速、善用工具、证据导向；默认只读 |
| 明确且常规的实现、测试、格式化、文档、机械修改 | **General Executor** | 通用且经济；遵守 frozen contract |
| 具有非局部约束和高上下文一致性要求的关键或复杂实现 | **Hard Executor** | 强实现推理与上下文一致性 |
| 对 spec、plan、diff 或 artifact 的独立对抗性 review | **Evaluator** | Orchestrator 级推理；怀疑式审查；默认只读 |
| 计划、路由、裁决、集成和最终验证 | **Orchestrator** | 持久上下文与决策权限 |
| 训练、backfill、materialization、encoding 等长计算 | **Detached process** | 不由 Agent 轮询的 CPU/GPU process |

缺少重要事实时先用 Explorer。implementation 默认交给 General Executor；只有 hard signal
成立时才升级。独立 review 能实质降低风险时使用 Evaluator，但不能把其 verdict 当作自动
成立。

## 分派协议

分派前提供完整且有界的契约：

- 目标与具体 deliverable；
- 相关上下文和权威输入；
- 允许的文件、系统和写入范围；
- 约束、frozen decision 与 non-goal；
- worker 可运行的验收检查；
- 必需输出形式，包括证据和未解决风险；
- 对范围增长、依赖 blocked 或 tool budget 的硬停止条件。

独立 task 可并行；有依赖的 task 保持顺序，除非接口已经冻结。worker 必须返回结果，不保持
开放式协作状态。task 超出契约时停止并重新规划，不要反复推动同一个重 context session。

## 各角色输出契约

- **Explorer：** 返回发现、source 或 file location、执行的命令、confidence 与 gap。
  区分观察事实和推断；除非重新明确分派，不进行 production 修改。
- **General Executor：** 返回 changed artifact、验证结果和任何 contract mismatch。
  发现 hard signal 时升级。
- **Hard Executor：** 返回实现、重要选择的理由、invariant 覆盖、验证结果和 residual risk。
- **Evaluator：** 按优先级返回 finding，每项含证据、影响、具体 failure scenario 和
  refinement plan；以 accept/change 建议结束，不静默修复被 review 的工作。

Orchestrator 必须审查每项输出，拒绝缺证据的主张，并决定 follow-up 应交给哪种复杂度角色。

## 独立评估

风险需要时将 evaluation 与 implementation 分开。给 Evaluator frozen contract 和原始
artifact 或 diff，不给 implementer 的结论。要求检查 spec gap、correctness failure、
security/data-loss risk、缺失测试、regression 和 unsupported assumption。Orchestrator
接受 finding 前必须复现或以其他方式验证。

## 长时间计算

不要让 sub-agent 只为轮询 background job 而保持活动。把工作作为 detached process
启动，记录 PID，将 log 写入磁盘，生成 terminal marker，并由 shell 或 harness monitor
在 terminal state 或 stall 时只唤醒 orchestrator 一次。

`$metis-prelude-zh:run-long-job` 可用时，调用它并遵循
[`../run-long-job/SKILL.md`](../run-long-job/SKILL.md)，不要在 Agent loop 中自建
detached launcher。它会记录 reproducibility metadata，并提供紧凑的 status 与
terminal-state 命令。

监控输出保持小：只报告 terminal state、最后一项相关错误和紧凑进度。不要把完整 log
stream 进 Agent context。长时间或 overnight 工作必须可恢复；跨越权限、成本或运营风险
边界时先获得用户确认。

## 成本与 context 纪律

1. Sub-agent 保持有界且单一目的。
2. 传递路径或紧凑摘要，不传大型 log 和 data dump。
3. 使用满足可靠性的最低能力角色。
4. Orchestrator 级容量只用于编排和 evaluation。
5. 限制每次 dispatch；假设或范围失效时重新规划。
6. 停止 idle worker，不为等待计算支付 Agent 成本。

## Pre-flight 检查

分派前：

- 工作类型和复杂度是否明确？
- 角色是否是最低成本的可靠选择？
- assignment 是否独立、有界且可验证？
- 依赖和写入边界是否清楚？
- worker 是否知道何时停止并升级？

接受结果前：

- Orchestrator 是否检查了真实 artifact 或 state？
- 是否针对 ground truth 运行验收检查？
- Evaluator finding 是否已复现，或附有拒绝理由？
- 未解决风险和用户决策是否明确？

无人值守运行前：

- 长计算是否 detached 且可恢复？
- 是否存在 terminal marker 与 stall signal？
- Orchestrator 是否只会被唤醒一次，而非反复轮询？
- 所有 Agent worker 是否已经结束，而不是 idle？
