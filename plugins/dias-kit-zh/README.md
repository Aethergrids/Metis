# dias-kit-zh

实验系统研究的三份方法技能（查询引擎与数据系统、存储、运行时、分布式与机器学习系统）。技能本身不绑定具体项目：目标、研究问题、实验定义和噪声水平由各项目自己的文档提供。

| 技能 | 用途 |
| --- | --- |
| `think-sharp` | 思考并执行研究步骤：第一性原理分解、自顶向下刻画问题、自底向上一次扩展一个维度，以及假设—实现—评估的短循环。假设写成形式化的工作量表达式，不预测运行结果；每步一个正确性门槛，报告带量化。 |
| `benchmark-design` | 按 Jim Gray《The Benchmark Handbook for Database and Transaction Systems》设计、扩展或审查评测负载与基准（relevant、portable、scaleable、simple）。 |
| `research-writing` | 精确书写研究文本：论文与幻灯片、记录、报告，以及结果的对话摘要。 |

三项技能互相指向：`benchmark-design` 写出的基准规范是 `think-sharp` 步骤的输入，两者的文本都按 `research-writing` 书写。

本目录是 Metis 的中文插件。从仓库 marketplace 安装为 `dias-kit-zh`，或用 `scripts/install-metis.sh --plugin dias-kit-zh` 复制技能。英文对应插件是 `plugins/dias-kit`。两边的技能名相同。每个技能的测试用例在 `skills/<skill>/evals/`。
