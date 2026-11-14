# 来自 The Benchmark Handbook 的原则，附出处

来源：Jim Gray（编），*The Benchmark Handbook for Database and Transaction Systems*，第 2 版，Morgan Kaufmann，1993。下面的引文来自 Jim Gray 档案上的免费 online edition（jimgray.azurewebsites.net/BenchmarkHandbook/）。若干在线章节是草案（Sawyer 与 Serlin："First Draft"；DeWitt、AS3AP、O'Neil、Cattell："Second Draft"），其中两章晚于 1993（Ballinger 的 TPC-D 章与 Raab 的 TPC-C 评论，都大约在 1998）。措辞和数字可能与印刷版不同；引用时要说 "online edition"，并把每个想法归于其章节作者。

目录
1. 章节地图
2. 为何要领域特定基准（Gray）
3. 四条准则（Gray）
4. 基准的四种用途（Gray）
5. 指标：吞吐、响应时间约束、性价比
6. 基准大战、benchmarketing 与完全披露
7. 做你自己的基准（Sawyer）
8. 现实性与共同标尺
9. 以减法求简单
10. 一个数字，还是一条谱
11. 基准会老化

## 1. 章节地图

| 章（online edition） | 作者 | 领域 | 可借用的内容 |
| --- | --- | --- | --- |
| Introduction（引言） | Jim Gray | 全部 | 领域特定基准、四条准则、用途、benchmarketing（基准营销） |
| History of DebitCredit and the TPC（DebitCredit 与 TPC 的历史） | Omri Serlin | OLTP | 分位数约束下的吞吐、以成本为归一化因子、完全披露 |
| TPC-D: Benchmarking for Decision Support（TPC-D：为决策支持做基准） | Carrie Ballinger | 决策支持 | 业务问题优先、固定规模点、power 对 throughput、计入成本的调优 |
| The Wisconsin Benchmark（Wisconsin 基准） | David DeWitt | 关系运算符 | 选择率受控的数据、优化器陷阱、speedup/scaleup/sizeup |
| AS3AP | Turbyfill、Orji、Bitton | 混合的关系负载与实用程序 | 固定时间指标、稠密/稀疏区间、按公式确定的用户数 |
| The Set Query Benchmark（Set Query 基准） | Patrick O'Neil | 集合查询、决策支持 | 基数阶梯、映射到应用的查询套件、冷缓冲 |
| The Engineering Database Benchmark（Engineering Database Benchmark） | R. G. G. Cattell | 工程、客户端–服务器导航 | 局部性、冷/热协议、按出现频率确定规模的操作 |
| Doing Your Own Benchmark（做你自己的基准） | Tom Sawyer | 定制基准 | 负载规范与测量规范之分、访问模式网格、校准、war of wizards（巫师之战） |
| TPC-C | Francois Raab | OLTP 订单录入 | 规定配比之上的业务单位指标、按仓库缩放 |

手册还有关于全文检索、SPEC 以及 Neal Nelson 基准的章节；本技能不使用它们。

## 2. 为何要领域特定基准（Gray）

- "No single metric can measure the performance of computer systems on all applications. System performance varies enormously from one application domain to another."（没有任何单一指标能够度量计算机系统在全部应用上的性能。系统性能从一个应用领域到另一个差异极大。）
- 数据库性能 "is dominated by the performance of software algorithms rather than by raw hardware speed"（由软件算法的性能所主导，而不是由裸硬件速度所主导），因此数值基准给出的指导很少。
- "One system may be excellent at performing simple update-intensive transactions for an online database; but it may have poor performance on complex queries to that database."（一个系统可能很擅长为在线数据库执行简单的、以更新为主的事务；但它对该数据库上的复杂查询可能性能很差。）
- "Each such benchmark specifies a synthetic workload characterizing typical applications in that problem domain."（每一个这样的基准都规定一份合成负载，用以刻画该问题领域中的典型应用。）其结果给出该领域中相对性能的 "a rough estimate"（一个粗略估计）。
- Gray 指出，擅长三种查询基准（Wisconsin、AS3AP、Set Query）之一的系统，"are not necessarily good at the other two"（未必擅长另外两种）。
- 评分是粗略的，如同燃油经济性评分："Your actual mileage may vary"（你的实际里程可能不同）。

设计后果：先点名领域及其典型操作，再做别的事。一个说不出自己领域的基准，不可能 relevant（切合领域）。

## 3. 四条准则（Gray）

> **Relevant**: It must measure the peak performance and price/performance of systems when performing typical operations within that problem domain.
> **Portable**: It should be easy to implement the benchmark on many different systems and architectures.
> **Scaleable**: The benchmark should apply to small and large computer systems. It should be possible to scale the benchmark up to larger systems, and to parallel computer systems as computer performance and architecture evolve.
> **Simple**: The benchmark must be understandable, otherwise it will lack credibility.

中文：

> **Relevant**（切合领域）：必须度量系统在该问题领域内执行典型操作时的峰值性能与性价比。
> **Portable**（易于移植）：应当易于在许多不同的系统和体系结构上实现该基准。
> **Scaleable**（可随规模伸缩）：基准应当适用于小型和大型计算机系统。随着计算机性能和体系结构的演进，应当能够把基准放大到更大的系统，以及并行计算机系统上。
> **Simple**（简单易懂）：基准必须可理解，否则它将缺少可信度。

Gray 的反例是 MIPS：它 simple，但并不 portable（IBM 的 MIPS 与 VAX 的 MIPS 不可比较），并不 scaleable（一千个 1-MIPS 处理器并不是一个 1000-MIPS 处理器），尤其并不 relevant："it does not measure useful work"（它不度量有用的工作）。SPEC 和 Perfect Club 对数值工作而言是 relevant、portable 且 simple 的，但并不 scaleable，"in the sense that the problem size does not grow with processor power."（其含义是：问题规模并不随着处理器能力而增长。）

Gray 还说，手册的指标 "do not measure ease-of-use, ease-of-programming, or ease-of-operations"（不度量易用性、易编程性或易运维性）；它们只是性能和性价比。

## 4. 基准的四种用途（Gray）

1. 比较不同的软件系统和硬件系统。
2. 在一台机器上比较不同的软件产品（O'Neil 的 Model 204 与 DB2，在同一个处理器上）。
3. 比较一个兼容系列中的不同机器。
4. 在一台机器上比较一个产品的不同版本——一次性能回归测试（"often new features slow down old features"，新特性常常拖慢旧特性）。

"Of course, in each of these cases, the benchmarks must be chosen to reflect the problem-specific domain you are interested in."（当然，在每一种情形中，都必须选择能够反映你所关心的那个特定于问题的领域的基准。）

## 5. 指标：吞吐、响应时间约束、性价比

- Gray：性能 "is typically a throughput metric (work/second) and price is typically a five-year cost-of-ownership metric. Together, they give a price/performance ratio."（通常是一个吞吐指标（工作/秒），价格通常是一个五年拥有成本指标。二者合在一起给出一个性价比。）他的示例表说明为何两者都重要：最经济的系统取决于客户所需要的吞吐。
- Serlin 论 DebitCredit："to make tps ratings comparable, the paper proposed a constraint under which 95% of all transactions completed in 1 second or less."（为使 tps 评分可以比较，该文提出一条约束：全部事务中的 95% 在 1 秒或更短时间内完成。）TPC-A 把这放宽为 90% 在 2 秒以内，测量点在驱动端，而不是在被测系统处。
- Serlin："Instead of configuring equivalent systems, Gray suggested that the cost of the tested system be used as the rationalization factor."（Gray 建议，与其去配置等价的系统，不如用被测系统的成本作为合理化因子。）厂商可以配置任何系统，但必须公布每 tps 的成本。
- Serlin：TPC-A 要求随机（负指数）到达，因为 "there is some theoretical and practical evidence that allowing uniform arrivals doubles the transaction rate."（有一些理论上的和实践上的证据表明，允许均匀到达会使事务速率加倍。）
- Sawyer：用分位数，不用平均；两个平均相等的系统，第 90 百分位可以差很多。他建议用第 90 百分位，并说要定义响应时间在何处测量。

## 6. 基准大战、benchmarketing 与完全披露

- Gray："Benchmark wars start if someone loses an important or visible benchmark evaluation."（若有人在一次重要的或显眼的基准评测中失利，基准大战就开始。）每一方用更专业的调优者重跑，直至 "a special version of the system ... with promises that the enhanced performance features will be included in the next regular release."（系统的一个特殊版本……并承诺这些增强的性能特性将被包含进下一个常规版本。）
- Gray："Benchmarketing is a variation of benchmark wars. For each system, there is some benchmark that rates that system the best."（Benchmarketing 是基准大战的一个变体。对每个系统，都存在某个把该系统评为最佳的基准。）它 "leads to universal skepticism of all benchmark results."（导致对一切基准结果的普遍怀疑。）
- Gray 论 TPC 的回应：标准硬件，以及已发布的软件；"Any special tuning or parameter setting must be disclosed"（任何特殊调优或参数设置都必须披露）；独立审计被强烈建议。
- Serlin："to be credible, a test sponsor must furnish to the public sufficient back-up data to allow independent observers or end-users to judge the validity of the associated performance claims."（要有可信度，测试发起者必须向公众提供足够的备份数据，使独立的观察者或最终用户能够判断相关性能主张是否成立。）
- Raab：TPC-C 直到 Revision 2.0（1993）才加入一条反对 "benchmark specials"（基准特供）的成文规则。
- DeWitt：Wisconsin 之所以要紧，是因为它点名了产品；匿名的结果 "would most likely have simply been dismissed as an academic curiosity."（很可能会被直接当成一种学术猎奇而不予理会。）（在发表对商业系统的具名比较之前，先检查软件许可条款。）

## 7. 做你自己的基准（Sawyer）

- 三个问题，全程反复检验："What do you want to learn? How much are you prepared to invest? What are you prepared to give up?"（你想知道什么？你准备投入多少？你准备放弃什么？）"You will always spend more than you think and you will wind up learning less than you desire."（你花掉的总会多于你所想的，而你最终学到的会少于你所愿望的。）
- 成本：程序员时间（负载、事务逻辑、数据访问、数据分布与生成、测量仪器），机器资源，管理时间（报告、行政管理、对规则的裁决），失去的机会。
- 你不会得知的：未来的性能（"benchmarks are no better for future predictions than any of the other tea-leaf devices"，基准对未来的预测并不比别的茶叶占卜器具更高明），以及你日后会得到的支持。
- "A benchmark has two major components: the workload specification [and] the measurement specification."（一个基准有两个主要组成部分：负载规范［和］测量规范。）
- 负载缩减：先去掉应用逻辑（很少超过 CPU 的 10–15%）；绝不省略数据库访问；把一个事务分解成加权路径；按每表访问模式（随机读、更新、顺序取）把速率列表，并合并模式相匹配的事务；丢掉合并之后变得多余的表。每一刀 "will remove some element of reality"（都会去掉某种真实性的成分）；把它记下来。
- 模拟真实的用户数："A system that uses ten processes, each submitting one tps, may behave much differently than a system with one thousand users, each submitting a .01 tps."（一个使用十个进程、每个提交 1 tps 的系统，其行为可能与一个有一千个用户、每个提交 .01 tps 的系统大不相同。）
- 预先定义好的 "ad hoc"（即席）查询给调优留下机会；"The art is specifying the rules surrounding the execution of these queries."（技艺在于规定围绕这些查询的执行的那些规则。）
- 批处理工作：决定允许多少预先计划好的访问（输入顺序、索引中的重复数据、手工并行化）。
- 最低限度的错误检查，以使所有系统执行相同的访问模式；批处理作业 "should report some data that can be verified"（应当报告一些可以被核验的数据），例如计数和合计。
- 省略：稀有事务类型的一条长尾对内存的压力，不同于少数几个常驻的事务。
- "Make certain you are measuring the hardware/software environment and not the implementation team's degree of cleverness."（务必确认你在测量的是硬件/软件环境，而不是实现团队的聪明程度。）
- 测量环境："Once again, the trade-off between reality and simplicity governs all."（再一次：现实与简单之间的权衡支配一切。）当系统被推到其极限时，通过驱动端来测量。
- 校准："All systems will have a bottleneck. The trick is to force the one you want to measure to be the constraining resource."（所有系统都会有一个瓶颈。窍门是迫使你想要测量的那一个成为起约束作用的资源。）用回显事务使驱动端和网络饱和，并停留在远低于该速率之处。
- 巫师之战：宣布只有单次试验，"no excuses, no reruns"（没有借口，没有重跑）；当心 "the new-and-improved release"（那个新的、改进过的版本）。
- 把基准按 "in the same manner as a developement [sic] project with a budget, goals and time estimates."（与一个有预算、目标和时间估计的开发项目相同的方式；原文拼写作 developement，［sic］）来对待。

## 8. 现实性与共同标尺

- Serlin 论 TPC-A："Application realism took second place wherever it conflicted with the common yardstick goal."（凡是与共同标尺这一目标发生冲突的地方，应用的真实性都退居其次。）
- Ballinger 论 TPC-D："Drawing up a list of what to include in a benchmark is the easy part, it's what to leave out and what to bargain over that is difficult."（列出基准里要包含什么是容易的部分；难的是省去什么，以及拿什么去讨价还价。）均匀数据 "exists solely to enhance benchmark reproducibility"（之所以存在，仅仅是为了增强基准的可复现性），尽管每个国家的真实客户数、每个零件的销量都是偏斜的。
- Ballinger："Benchmark Options Both Widen and Weaken TPC-D"（基准选项既放宽 TPC-D，也削弱 TPC-D）——每一个选项（零流的 throughput 测试、在各次运行之间重置更新、更新位于查询流之外）都降低了可比性，或者打开一条绕过困难部分的路。
- AS3AP 的作者：该基准 "is not intended to model a specific workload or query mix"（并不打算去刻画某一个具体的负载或查询配比）；它用 12 小时的上限，以及能够 "detect query optimization problems without completely dominating the benchmark if something goes wrong."（检测出查询优化的问题，同时若出了错，也不让该查询完全支配整个基准。）的查询，拿完备性去换易处理性。

## 9. 以减法求简单

- Cattell 丢掉了其结果会跟着所保留的度量走的那些度量，并替换掉实现者无法一致地复现的度量。更丰富的特性 "belong in any more comprehensive benchmark; but they reduce the utility of a simple benchmark focussed on basic performance. They make it harder to implement and reproduce."（属于任何一个更全面的基准；但它们会降低一个聚焦于基本性能的简单基准的用处。它们使实现和复现变得更难。）
- Cattell："It is essential that a good benchmark be precisely reproducible."（一个好的基准必须可以精确地复现。）
- Cattell："The only truly accurate representation of performance is actually executing the application."（对性能唯一真正准确的表示，就是实际执行该应用。）
- O'Neil："a perfect apples-to-apples comparison between two products in every feature is generally impossible. Thus judgements must be made"（在每一项特性上对两个产品做完美的同类比较，一般是不可能的。因此必须做出判断）。

## 10. 一个数字，还是一条谱

- DeWitt：DebitCredit 之所以流行，是因为它 "reduces each system to one magic number"（把每个系统归约成一个魔法数字）；Wisconsin 的多用户后续工作之所以部分地失败，是因为它们没有产出这一个数字。
- O'Neil："We don't wish to lose this advantage by reporting a single number which fits no particular case"（我们不希望因为报告一个不适合任何具体情形的单一数字，而失去这一优势）；他定义了一个与价格相关的单一度量，但公布每条查询的细节，使读者可以重新给它加权。
- Cattell："it is important not to abuse of the 'overall' number, because the frequency of occurrence of these operations will differ widely between applications: the individual measures are important."（重要的是不要滥用那个 'overall'（总体）数字，因为这些操作的出现频率在不同应用之间会相差很远：个体的度量是重要的。）
- Ballinger：TPC-D 的几何平均 power 指标对百分比上的改进给予同等奖励，因此削短一条短查询，与修好一条长查询，算得一样多；很短的查询需要一条下限（最长者的 1/1000），并且几何平均被排除在多流测试之外，以堵上一个漏洞。

设计后果：公布那条向量；若需要一个标题数字，就给出它的公式、它的权重和它的病态。

## 11. 基准会老化

- Raab：厂商 "optimized their systems for the benchmark rather than for general applicability to real-life operations. This shift in focus is one of the basic laws that govern benchmarks."（针对基准来优化自己的系统，而不是针对真实操作上的普遍适用性来优化。这种焦点的转移，是支配基准的基本规律之一。）它使 TPC-A 过时。
- Ballinger：已发表的 TPC-D 配置显示出 "a trend towards precision-tuning the overly-familiar"（一种走向精细调优那些过于熟悉之物的趋势）；一个决策支持基准 "requires frequent rejuvenation"（需要经常更新更生）。
- Serlin：TPC 标准在发表之后的 12 个月内可以不改动；给规范标上版本，并使结果始终绑在某一个版本上。
