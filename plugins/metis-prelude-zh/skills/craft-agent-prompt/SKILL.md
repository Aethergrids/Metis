---
name: craft-agent-prompt
description: >-
  使用结果导向的契约和可度量 eval，创建、审计、简化或迁移 system
  prompt、developer prompt、Agent 指令与 prompt stack。适用于定义 Agent
  的目标、性格、自主边界、成功标准、输出形式与停止条件，清除冲突或冗余脚手架，
  以及将已有 prompt stack 迁移到 GPT-5.6 Sol 或 GPT-5.6 系列。不用于普通的
  最终用户 prompt 润色。
---

# 构建 Agent Prompt

编写能够可靠改变行为的最小 prompt 契约。涉及 GPT-5.6 时，在修改前重新打开
最新的官方
[prompting guide](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6)，
不要依赖记忆中的设置或可用性信息。

## 建立基线

1. 按优先级列出当前生效的 prompt 层、可用工具、输出 schema、模型、reasoning
   effort 和代表性 eval。
2. 修改前运行已有 eval。若 harness 可提供，则记录正确性、完整性、token、延迟、
   成本、tool call、turn 和重试次数。
3. 明确已经观察到的失败模式。不要仅因 prompt 较长或格式不整齐而重写。

## 编写结果契约

只保留会改变行为的章节：

```text
Role：模型的职责和必要背景
Personality：简短的用户体验选择
Goal：用户可见的目标结果
Success criteria：完成前必须成立的事实
Constraints：安全、证据、权限和副作用边界
Tools：路由规则与前置条件
Output：必要的形式、内容和任务相关长度
Stop rules：重试、fallback、拒答、澄清和完成条件
```

- 描述目标状态和完成标准，不规定常规推理步骤。
- 保留用户明确给出的价值判断；只有必须推断时才补充决策标准。
- `always`、`never`、`must` 和 `only` 仅用于真正的不变量；需要判断的事项写成决策规则。
- 将 personality 与协作方式分开并保持简短。personality 控制语气；协作方式控制假设、
  主动性、提问、权衡、验证与不确定性。
- 只定义一次自主边界：安全且范围内的本地操作可直接执行；外部、破坏性、高成本或扩展
  范围的操作需要确认。
- 编辑任务先说明必须保留的事实、结构、长度、体裁和语气，再要求改进。

## 外科式简化

每次只移除一类内容，然后运行同一组 eval：

- 同一规则的多个版本；
- 不改变实测行为的风格或流程要求；
- 不影响结果的示例；
- 模型已经能稳定完成的行为脚手架；
- 与任务无关的工具和工具说明。

检查 system、developer、skill、tool 与 user 层之间的冲突。优先保留一条权威表述，
而不是多个略有不同的重复版本。不要在一次实验中同时改变模型、reasoning、prompt、
tool set 和 runtime。

## 迁移到 GPT-5.6

1. 保持 reasoning effort 和 prompt 不变，只更换模型。
2. 修改指令前先运行基线用例。
3. 分组移除过时脚手架。
4. 对已经复现的回归，只增加能够修复它的最小定向指令。
5. 测试原 reasoning effort 和低一级的设置。只有在确认不是 success criterion、
   dependency、tool rule 或 verification loop 缺失后，才提高 effort。

只有输出仍通过已有验收检查时，资源消耗下降才算改进。

## 交付与验证

返回修改后的 prompt 或最小 diff、每项修改对应的失败、删除的内容、修改前后的 eval
结果，以及尚未解决的风险。无法运行 eval 时要明确说明，并将结果标记为提案，而不是
已经验证的迁移。
