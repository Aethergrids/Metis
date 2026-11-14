# 手册之外：后来的基准与现代对应

本文件里没有任何内容来自手册。它把手册的规则延续到当前的系统，并列出主要的后来基准，以便步骤 2（「先复用，再发明」）能够核对它们。在论文里引用它们之前，先对照当前的规范核实版本细节。

## 1. 把 1990 年代的规则对应到今天

| 手册中的规则 | 今天的对应 |
| --- | --- |
| 硬件、软件和维护的五年价格（Gray，TPC） | 实例或集群的每小时成本（写明提供商、地域、标价、日期）；对自有硬件，用每小时的摊销成本；当价格没有意义时，用每核或每 GiB；当功率是约束时，用每次操作的能耗。保留 Gray 的要点：按成本来归一化，而不是强行做出「等价」的配置。 |
| 带思考时间的远程终端仿真器（TPC-A、TPC-C） | 一个负载发生器。决定采用*开放*负载（到达独立于完成，例如 Poisson）还是*封闭*负载（N 个客户端，各自等待自己的应答，然后思考）。系统停顿时，封闭的驱动端会少发请求，从而掩盖尾延迟（"coordinated omission"，协同遗漏）；延迟目标使用开放到达。见 Schroeder、Wierman、Harchol-Balter，"Open Versus Closed: A Cautionary Tale"，NSDI 2006。 |
| 每 tps 的终端数、并发水平 T×R（Serlin） | 封闭驱动端的 Little 定律：客户端数 N = 吞吐 X ×（响应时间 R + 思考时间 Z）。用它来给驱动端定规模，并用来抽查测得的吞吐。 |
| 第 90 百分位（Sawyer，TPC-A） | 在线服务常常以 p99 或 p99.9 为目标。一个分位数需要足够多的样本：报告样本数，不要凭几百个请求去引用 p99.9。 |
| 在查询之间刷空缓冲池（O'Neil，Cattell） | 点名每一层缓存：DBMS 的缓冲与结果缓存、操作系统页缓存、SSD/控制器缓存、对象存储或远程缓存、编译代码或 JIT 缓存、元数据/统计信息缓存。说明每一层如何被清空或被预热。 |
| 单机、专用（手册所处的时代） | 云和共享硬件会加入噪声：跨日或跨实例重复，以随机的顺序交错各个系统，报告中位数和散布，并给出 n。 |
| 完全披露报告（TPC） | 公布一份实验产物：带种子的生成器、配置、脚本、逐次运行的原始结果、查询计划；钉住软件版本和硬件。 |
| 许可证限制 | 有些商业许可证限制发表基准结果（常常被称为 "DeWitt clause"，DeWitt 条款）；在点名一个商业系统之前先检查。 |

## 2. 发明一个新基准之前要核对的后来基准

| 基准 | 领域 | 谱系与说明 |
| --- | --- | --- |
| TPC-H | 决策支持，即席查询 | TPC-D 的后继：22 条查询、8 张表、固定的规模因子、power 测试与 throughput 测试。数据均匀；被厂商和引擎大量地针对着调优。 |
| TPC-DS | 决策支持、报表、数据维护 | 雪花模式、99 个查询模板、偏斜的数据。规模大；许多研究只跑一个子集，这一点必须披露。 |
| Star Schema Benchmark (SSB) | 星型模式分析 | O'Neil、O'Neil、Chen；由 TPC-H 派生；13 条查询，分成 4 个 flight。 |
| TPC-C | OLTP 订单录入 | 仍然是 OLTP 的参照；tpmC；仓库随着吞吐缩放。 |
| TPC-E | OLTP，经纪业务 | 模式比 TPC-C 更丰富，配比比 TPC-C 更偏读。 |
| YCSB | 键值与云服务 | Cooper 等人，SoCC 2010：核心负载 A–F，混合读、更新、插入、扫描；请求分布有 Zipfian、uniform 和 latest。 |
| Join Order Benchmark (JOB) | 查询优化 | Leis 等人，VLDB 2015：带相关和偏斜的真实 IMDB 数据；测试基数估计与连接顺序。 |
| LDBC Social Network Benchmark | 图负载 | 在一个生成的社交网络之上的 Interactive 负载与 Business Intelligence 负载。 |
| CH-benCHmark | 混合的 OLTP 与分析（HTAP） | Cole 等人，DBTest 2011：在同一个数据库上的 TPC-C 事务，以及由 TPC-H 派生的查询。 |
| Nexmark、Linear Road | 流处理 | Nexmark：带一组查询的拍卖事件流；Linear Road（Arasu 等人，VLDB 2004）：带延迟要求的通行费计算。 |
| ann-benchmarks、big-ann-benchmarks | 向量相似性搜索 | 召回率对吞吐的曲线；两者都要报告，绝不要只报告吞吐。 |

当某个基准的典型操作和数据性质与场景相符时，就按原样使用它；否则扩展它，并给结果起一个新名字（手册的原则：一个放宽后的变体得到它自己的名字）。

## 3. 常见陷阱，映射回手册

Raasveldt、Holanda、Gubner 与 Mühleisen，"Fair Benchmarking Considered Difficult: Common Pitfalls in Database Performance Testing"（DBTest 2018），讨论了一批陷阱；这些陷阱把手册的警告重述到了今天的系统上：

| 陷阱 | 手册中的对应 |
| --- | --- |
| 无法被复现的结果（版本、设置、数据未知） | TPC 的完全披露；Cattell："precisely reproducible"（可精确复现） |
| 基线未经调优或配置错误，而所提出的系统经过了调优 | Sawyer 的 war of wizards（巫师之战）；Gray 的 benchmarketing（基准营销） |
| 比较做着不同工作的系统（苹果对橘子：缺少特性、结果语义不同） | Gray 的 relevant（切合领域）；Sawyer 的最低限度错误检查，以使访问模式相一致 |
| 针对该基准的特定查询或数据来调优 | Raab：优化是 "for the benchmark rather than for general applicability"（为了基准，而不是为了普遍适用）；Ballinger："precision-tuning the overly-familiar"（精细调优那些过于熟悉的东西） |
| 把冷运行和热运行混在一起，或者不说明是哪一种 | Cattell 的冷/热协议；O'Neil 的缓冲区刷空 |
| 排除掉某一个系统所需要的数据装载或预处理 | TPC-D 把装载时间作为一项次要指标 |
| 错误的答案没有被发现 | Set Query 的期望计数；Sawyer 的可核验输出 |
