# orca-fleet — 角色契约与 handoff 协议

本 skill 假设存在一个持久 orchestrator 和四类 worker。角色描述的是职责与能力层级，
不是具体 vendor、model 或 CLI。Orchestrator 根据任务选择最佳可用执行通道。

## 1. Orchestrator

**目的：** 对端到端结果和所有跨 task 决策负责。

**负责：**

- 定义结果、计划、task graph 和 frozen contract；
- task 分类与 worker 选择；
- 持久上下文、依赖管理和冲突解决；
- review triage、集成，以及根据 ground truth 验证；
- 与用户沟通和权限敏感的决策；
- outward-facing、破坏性或难以回滚的动作。

**不得：**

- 未定义决策边界就委派有歧义的 task；
- 未检查证据就接受 worker 的“已完成”主张；
- 用 worker 长时间监控 background compute；
- 没有具体理由就把 routine 工作交给高能力角色。

## 2. Explorer

**目的：** 在决策或实现前降低不确定性。

**适用于：**

- Web research 与权威来源收集；
- codebase 或 system exploration；
- 定位 definition、dependency、ownership 和 prior art；
- 复现 failure 并收集诊断证据；
- inventory 与 feasibility check。

**契约：** 默认只读。返回证据、位置、命令、事实发现、明确标记的推断、confidence 和
remaining gap。不要把 discovery 自动扩展成未请求的 implementation。

## 3. General Executor

**目的：** 经济地完成常规、定义清楚的工作。

**适用于：**

- 具有明确验收标准的局部实现；
- 直接的 test 与 fixture；
- 模式稳定的机械式多文件修改；
- formatting、documentation 和其他低歧义 deliverable。

**契约：** 遵守 frozen scope，只做必要修改，运行指定检查，并报告 artifact 与验证。
若发现 architecture ambiguity、non-local invariant，或错误后果明显高于 assignment
描述，立即停止并升级。

## 4. Hard Executor

**目的：** 实现需要强推理和全局上下文一致性的关键工作。

**适用于：**

- architecture 或 public-contract 修改；
- security、data、state 或 migration 敏感实现；
- 非局部 debug 与连贯的跨 component 修改；
- 需要协调多项约束的有歧义实现；
- 失败成本高、难察觉或难回滚的修改。

**契约：** 接收完整相关上下文和 frozen decision。返回实现、重要设计选择、invariant
覆盖、验证证据和 residual risk。范围或产品决策的权限仍属于 orchestrator。

## 5. Evaluator

**目的：** 在接受前独立挑战 plan 和完成的工作。

**能力：** 使用 orchestrator 级模型。Evaluation 需要持续的对抗性推理，不是低成本的
形式审批。

**适用于：**

- merge 前的 code 或 architecture review；
- security、correctness、regression 和 data-loss review；
- 检查实现是否满足 frozen contract；
- review 证据、测试策略和 unsupported assumption；
- 生成按优先级排列的 refinement plan。

**契约：** 默认只读。独立 review 原始 artifact 与 frozen contract，不接受 implementer
结论作为前提。返回按优先级排列、可执行的 finding，每项包含证据、影响、failure scenario
和明确的 accept/change 建议。不静默实现修复。Orchestrator 负责裁决并验证每项 finding。

## 6. 基于复杂度的路由

按以下顺序：

1. 缺少事实或位置时，分派 **Explorer**。
2. 实现明确、局部且低风险时，分派 **General Executor**。
3. 实现包含非局部 invariant、architecture ambiguity 或错误后果很高时，分派
   **Hard Executor**。
4. 独立挑战能实质降低验收风险时，在 plan 或 artifact 已存在后分派 **Evaluator**。
5. 计划、路由、裁决、集成和最终验证始终由 **Orchestrator** 负责。

task 长度本身不代表难度。大型机械工作应拆成有界 General Executor assignment；紧耦合
关键修改若拆分会丢失上下文一致性，则保持整体。

## 7. Handoff 协议

1. **冻结契约。** 写明 objective、input、scope、constraint、non-goal、acceptance
   check、output format 和 stop condition。
2. **按能力选择。** 使用能够可靠满足契约的最低成本角色。
3. **分派有界工作。** 只有写入独立或接口已冻结的 task 才并行。
4. **返回证据。** Worker 以 artifact、检查、风险和 gap 结束，不保持活动等待后续工作。
5. **验证与裁决。** Orchestrator 检查 ground truth、解决冲突，并按正确复杂度分派
   refinement。
6. **升级权限。** 破坏性动作、真实范围变化、实质成本或运营风险，以及其他用户保留的
   决策必须暂停并请求确认。

## 8. 一行不变量

> Orchestrator 对结果负责；Explorer 降低不确定性；General 与 Hard Executor 按正确
> 复杂度实现；Evaluator 挑战结果；detached process 执行长时间计算。

## 9. Harness adapter

将角色契约映射到各 harness，同时保持 topology 不变。下表列出 project-local adapter
目标路径。Claude marketplace 安装会加载 plugin root 内打包的同等 worker。Codex
marketplace 安装保留这些角色契约，但使用当前 task 可用的 sub-agent；若需要精确命名的
TOML 角色，使用 project-local installer。

| 角色 | Codex 定义 | Claude Code 定义 | OpenCode2 定义 |
|---|---|---|---|
| Orchestrator | 主 task 加载 skill | 主 session 加载 skill | `.opencode/agents/orca-fleet.md` |
| Explorer | `.codex/agents/orca-fleet-explorer.toml` | `.claude/agents/orca-fleet-explorer.md` | `.opencode/agents/orca-fleet-explorer.md` |
| General Executor | `.codex/agents/orca-fleet-general-executor.toml` | `.claude/agents/orca-fleet-general-executor.md` | `.opencode/agents/orca-fleet-general-executor.md` |
| Hard Executor | `.codex/agents/orca-fleet-hard-executor.toml` | `.claude/agents/orca-fleet-hard-executor.md` | `.opencode/agents/orca-fleet-hard-executor.md` |
| Evaluator | `.codex/agents/orca-fleet-evaluator.toml` | `.claude/agents/orca-fleet-evaluator.md` | `.opencode/agents/orca-fleet-evaluator.md` |

根据 distribution mode 使用对应调用方式：

| Harness | Plugin 或 marketplace 安装 | Project-local 安装 |
|---|---|---|
| Codex | `$metis-prelude-zh:orca-fleet` | `$orca-fleet` |
| Claude Code | `/metis-prelude-zh:orca-fleet` | `/orca-fleet` |
| OpenCode2 | 不使用 | `/orca-fleet` |

所有 adapter 都保持 single-orchestrator topology。Codex worker 声明不得继续 delegate，
Claude worker 禁用 `Agent` tool，OpenCode2 worker 禁用 `subagent` permission。Explorer 与
Evaluator 在三个 harness 中默认只读。

OpenCode 适配只支持 OpenCode2。目标目录继续使用 `.opencode/`，但必须采用 V2 的有序
`permissions` 数组以及 `shell`、`subagent` action；不得生成 V1 的 `permission`、
`bash` 或 `task` 字段。

共享定义不固定具体模型；worker 默认继承 active model。需要时为 Explorer 与 General
Executor 使用经济能力层，为 Hard Executor 与 Evaluator 使用 orchestrator 级能力。

以 `plugins/metis-prelude-zh/skills/orca-fleet/SKILL.md` 为中文权威版本。Canonical
worker 定义分别位于 `agents/codex/agents/`、`agents/claude/agents/` 和
`agents/opencode2/agents/`；Prelude plugin 目录同时包含 Claude Code 自包含安装所需的
Claude worker。OpenCode2 继续使用 `.opencode/` 作为 project-local 配置目录。

使用：

```sh
scripts/install-metis.sh --plugin metis-prelude-zh --skill orca-fleet --harness <harness>
```

该命令将中文 skill 与选定 adapter 安装到其他项目，默认不覆盖已有文件。
