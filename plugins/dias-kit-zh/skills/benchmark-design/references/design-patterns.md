# 来自经典基准的设计模式

每种模式都是手册中某一个基准用过的一种技术，表述成可以迁到新领域的形式。出处章节在 `handbook-principles.md`；数字按 online edition 所印。用索引找到手头这个决策对应的模式，然后改写其*机制*，不要照搬原来的常数。

## 按设计需求索引

| 需求 | 模式 |
| --- | --- |
| 选择率或代价恰好已知、且与规模无关的谓词或操作 | P1, P2 |
| 真实的偏斜、热点、局部性 | P3, P4 |
| 用一个数定出每一个大小的规则 | P5, P6, P7 |
| 当各系统所能处理的规模不同时用的一个得分 | P8 |
| 一个顾及延迟的吞吐指标，以及一个成本归一化因子 | P9, P10, P11 |
| 单用户行为与多用户行为 | P12, P13 |
| 使缓存和结果复用失效 | P14, P15 |
| 稳态、重复、可重复性 | P16 |
| 公平的调优规则 | P17 |
| 要正确答案，而不只是要快 | P18 |
| 把一份真实负载缩小成一个小型基准 | P19 |
| 证明被测系统才是瓶颈 | P20 |
| 暴露优化器和访问路径的弱点 | P21, P22 |
| 关于并行与分布式扩展的主张 | P23 |
| 信任这些数字 | P24 |
| 让基准随着时间保持诚实 | P25, P26 |

---

### P1. 选择率受控的列 — Wisconsin（DeWitt），AS3AP
- **问题。** 真实数据无法按规模放大，因此 "it is very difficult to specify a selection query with a 10% or 50% selectivity factor"（很难指定一条选择率为 10% 或 50% 的选择查询）。
- **机制。** 把 `unique1` 生成为 0..N−1 的一个随机排列，把 `unique2` 生成为按顺序的 0..N−1（用于聚簇）。派生列取 `unique1 mod k`，并按其选择率命名（`onePercent` = mod 100，`twentyPercent` = mod 5），于是 "x.four=2" 选出 25%，"regardless of the size of the relation"（与关系的大小无关）。字符串保持定长，使每一页容纳的行数相同。AS3AP 加上*稠密*区间（0..N：一个谓词返回绝对行数）和*稀疏*区间（0..10⁹：一个谓词返回固定比例）。
- **何时使用。** 某个算子的代价取决于选择率、结果大小或分组数，而你希望在其余一切保持固定时扫描它。
- **陷阱。** 这些列是均匀且独立的；AS3AP 的作者指出 Wisconsin 的 "confounding variables such as predicate independence"（诸如谓词独立性之类的混杂变量）。若相关才是本领域里驱动代价的因素，就有意地加入相关列。

### P2. 基数阶梯，模板沿阶梯扫描 — Set Query（O'Neil）
- **机制。** 一张表，列按基数命名（K2、K4、K5、K10、K25、K100、K1K、K10K、K40K、K100K、K250K、K500K），每一列在 1..基数上均匀，另加一个顺序键。每个查询*模板*（count、AND、NOT、range + filter、group-by、自连接）对阶梯上的每一列运行一次，于是一个模板得到一条选择率曲线。模板选自被调查的应用（文档检索、直邮营销、决策支持），并映射回这些应用。
- **何时使用。** 需要用少数查询形状覆盖一条选择率谱或扇出谱，并且不同应用的读者需要各自的子集。
- **改写。** 按每一列所控制的性质为它命名（例如每个键的行数、每个键的版本数），并让模板沿它扫描。

### P3. 偏斜或非均匀的输入 — TPC-C、AS3AP；出于选择而均匀 — TPC-D
- **机制。** TPC-C 刻画 "popular items"（热门商品）以及 "Non-uniform patterns of data access to simulate data hot spots"（非均匀的数据访问模式，用以模拟数据热点）。AS3AP 的生成器提供均匀、正态、指数和 Zipfian 分布，参数可以设定。TPC-D 选择均匀取值，"solely to enhance benchmark reproducibility"（仅仅为了增强基准的可复现性）。
- **决策规则。** 若偏斜会改变哪一种算法胜出（哈希划分、缓存、按键的工作量），就把偏斜做成一个旋钮，同时包含一个均匀水平*以及*测得的真实水平，并且两者都报告。若不会改变，均匀更简单；把这个选择记下来。

### P4. 访问局部性，并带一次消融 — Engineering Database Benchmark（Cattell）
- **机制。** "90% of the connections are randomly selected among the 1% of parts that are 'closest'"（90% 的连接是在那 1%「最近」的零件之中随机选取的）；其余连到任意零件。Cattell 也报告了去掉局部性的运行，遍历时间和插入时间因此改变，并得出结论："it is important to include locality of reference in a benchmark measure, assuming the applications the benchmark is to represent exhibits such locality."（要把访问局部性纳入基准度量，其假定是：该基准所要代表的应用确实表现出这种局部性。）
- **何时使用。** 缓存、聚簇或预取要紧时。把局部性做成一个旋钮，并纳入无局部性的那个点，以显示它的影响。

### P5. 大小绑定于所声称的吞吐 — DebitCredit、TPC-A、TPC-C
- **机制。** TPC-A：每 tps 对应 1 个分行、100,000 个账户和 10 个终端，平均思考时间 10 s。TPC-C："Each warehouse has ten terminals"（每个仓库有十个终端），并且实现 "must scale both the number of terminals and the size of the database proportionally to the computing power of the measured system."（必须使终端数量和数据库大小都按被测系统的计算能力成比例缩放。）
- **原因。** 不能在一个放得进缓存的数据库上、或只用少数几个客户端，就声称高速率；规模单位（仓库、分行）是一个业务实体，因此这条规则是用领域的术语来读的。

### P6. 固定的规模点，均匀增长 — TPC-D（Ballinger）
- **机制。** 数据量定义为装载之前的原始数据；结果只可以在一组固定的规模因子上发表，并且只在相同规模上比较。所有的表（固定的查找表除外）以相同的速率增长，因此一条查询在更大的规模上做按比例更多的工作，从而使 sizeup（硬件不变、数据增多）分析成为可能。
- **陷阱。** 均匀增长会掩盖那些代价增长快于数据的操作（带扇出的连接、按键的历史）。若本领域有这类操作，就另加一个让它们单独增长的旋钮。

### P7. 相对于内存的大小 — Wisconsin、Engineering Database Benchmark、Set Query
- **机制。** DeWitt：关系 "at least a factor of 5 larger than the total main memory buffer space"（至少比全部主存缓冲空间大到 5 倍）。Cattell：一个放得进缓存的小数据库，以及一个远大于客户端缓存和服务器缓存的大数据库。O'Neil 在查询之间刷空缓冲区，这 "models an extremely large database"（模拟一个极大的数据库）。
- **何时使用。** 主张是关于内存装不下时的行为；把每个规模点说成所涉内存（缓冲池、RAM、缓存）的倍数。

### P8. 时间固定、规模可变：等价数据库大小 — AS3AP
- **机制。** 指标是 "the maximum size of the AS3AP database for which the system is able to perform the designated AS3AP set of single and multiuser tests in under 12 hours"（系统能够在 12 小时以内完成所指定的那一组 AS3AP 单用户与多用户测试的最大 AS3AP 数据库大小），每兆字节的成本由此得出。
- **何时使用。** 各系统在它们所能处理的最大规模上彼此不同，或者所问的是「在一份预算之内能扩到多远」。与每个系统的一份失效点报告配对。

### P9. 在响应时间分位数之下的吞吐，随机到达 — DebitCredit → TPC-A
- **机制。** DebitCredit：tps，且 95% 的事务在 1 s 以内。TPC-A：90% 在 2 s 以内，在驱动端测量（含网络），到达是随机的（负指数），因为当时认为均匀到达会使速率加倍。TPC-A 还要求完整的吞吐对响应时间曲线。
- **改写。** 分位数和阈值取自服务目标，测量点取自用户实际体验到的位置，并公布这条曲线。

### P10. 以被测系统的成本作为归一化因子 — DebitCredit（Gray 的提议，据 Serlin）
- **机制。** 不要去配置出「等价」的系统；让每一个自由配置，并发表性能除以总成本（最初是五年的硬件、软件和维护）。
- **改写。** 实例类型的每小时成本，或每核 / 每 GiB，或能耗；见 `beyond-handbook.md`。

### P11. 在规定配比之上的业务单位指标 — TPC-C（Raab）
- **机制。** 五种事务类型，配比固定；所报告的指标只是 New-Order 的速率，"a measure of business throughput"（一种业务吞吐的度量）。其余事务必须按其比例运行，因此这个配比不能被跳过。
- **何时使用。** 领域里有一个用户关心的操作，以及会制造争用的配套操作。

### P12. 单流测试与多流测试，以及复合指标的陷阱 — TPC-D（Ballinger）
- **机制。** Power 测试（一条流，查询时间的几何平均）和 throughput 测试（若干条流，算术平均），合并起来用于性价比。
- **教训。** 把多流测试做成可选项，意味着很少有厂商去跑它。几何平均过度奖励很短的查询（后来加了一条下限：最长查询的 1/1000），并在并发之下留下一个漏洞。这些流没有思考时间，因此一条流相当于若干个真实用户。

### P13. 用公式设定并发 — AS3AP；以及一条警告 — TPC-D
- **机制。** AS3AP：用户数 = 逻辑数据库大小 / 4 MB，"to prevent single-user versions of the multiuser tests"（用以防止多用户测试的单用户版本）。TPC-D 把更新对的数量绑到查询流的数量上，使更新保持其权重；Ballinger 报告说，这扭曲了 throughput 测试，因为真实的更新量并不随着用户数增长。
- **规则。** 并发从领域导出（每单位数据的用户数、到达率），而不是从实现者觉得方便的做法导出。

### P14. 运行时的输入参数 — TPC-D、Wisconsin、Engineering Database Benchmark
- **机制。** TPC-D 在每次执行时替换输入变量，使重复运行 "touch different groupings of data and yet do the equivalent work"（触及不同的数据分组，但做等价的工作），从而减少来自缓存或预聚合的好处。Wisconsin 在基关系的两份相同副本之间交替，运行若干个参数变体。Cattell 在每次迭代中另取一组新的随机零件。
- **规则。** 每个参数都有一个分布，以及工作量相等的保证。把这种变化排除在用来估计噪声的那些重复之外：重复同一参数集，以测量逐次运行的散布；参数的变化放在各流之间，或放在单独一次敏感性运行里。

### P15. 冷协议与热协议 — Engineering Database Benchmark、Set Query、AS3AP
- **机制。** Cattell：至少 10 次迭代；第一次是 "cold"（冷：关闭数据库再重新打开，在客户端和服务器上通过读取一个大的无关文件来清空操作系统文件缓存），渐近最好的那次是 "warm"（热）。O'Neil 在查询之间刷空缓冲区，并通过按两种顺序运行查询对来检查重叠。AS3AP 安排测试的顺序，使相邻查询触及不同的关系。
- **规则。** 写明每一层缓存究竟如何被清空或被填满，并且当两种状态在领域里都会出现时，两种都要报告。

### P16. 预热、测量窗口、可重复性 — AS3AP、TPC-D
- **机制。** AS3AP 的多用户测试先运行 15 分钟，再测量 5 分钟，"to give the system time to 'warm up' before throughput is measured without allowing an arbitrary time interval for reaching steady state."（在测量吞吐之前给系统 'warm up'（预热）的时间，同时又不允许用任意长的时间间隔去达到稳态。）TPC-D 要求一次完整重跑落在 5% 以内（两次运行）或 10% 以内（三次运行），并发表较低的那个结果。

### P17. 固定逻辑负载，给物理设计计价或把物理设计固定死 — TPC-D、Set Query、Engineering Database Benchmark
- **机制。** TPC-D："SQL-as-written"（按所写 SQL 执行；无 hint，无任意改写），物理结构自由，但通过装载时间、更新成本，以及存储与原始数据之比来计价。Set Query："only these 13 indices are allowed"（只允许这 13 个索引）。Cattell：物理结构自由，但不得在各次度量之间改变，并且禁止利用生成器人工痕迹的捷径（"It is not acceptable to take advantage of the fact that the benchmark part-ids are numbered sequentially"，不允许利用基准的零件号按顺序编号这一事实）。

### P18. 能够自行核验的结果 — Set Query、Sawyer、AS3AP、TPC
- **机制。** Set Query 公布生成器、开头的那些行，以及每条查询的期望行数。Sawyer 让批处理作业发出计数和合计。AS3AP 在恢复之后运行正确性查询。TPC 基准规定了 ACID 测试。
- **规则。** 每个操作都有可检查的输出；答案错误的一次运行是无效的，无论它多快。

### P19. 用访问模式网格缩小一份真实负载 — Sawyer
- **机制。** 把操作拆成加权路径；按速率 × 每表访问模式列表（R 随机读、U 更新、F 顺序取）；合并模式相匹配的操作，并累加它们的速率；丢掉因此变得多余的表；保留数据访问，丢掉应用逻辑。记下你去掉的那条稀有操作长尾。

### P20. 校准驱动端 — Sawyer
- **机制。** 用回显替换该操作，以零思考时间提交，找出网络或驱动端达到饱和的速率，并把基准保持在远低于该速率之处；需要时复制驱动端。

### P21. 优化器陷阱 — Wisconsin、AS3AP、TPC-D
- **机制。** Wisconsin 的 JoinAselB 把连接写在选择之前，"to test whether the system has even a rudimentary query optimizer"（用以测试该系统是否连一个最起码的查询优化器都有）。AS3AP 的 `variable_select` 用两个参数值运行同一条预编译查询，一个偏向索引，一个偏向扫描。Ballinger 笔下的 TPC-D Query 9 以 "20 times or more work than is actually required"（实际所需工作量的 20 倍或更多）来惩罚错误的连接顺序。
- **规则。** 有意地纳入少数几个这样的情形，并且在它出错时不让它支配总量（AS3AP 的易处理性规则）。

### P22. 按真实粒度交错应用 — Engineering Database Benchmark
- **机制。** 每取到一个对象就调用一个宿主语言过程，因此当真实应用一次处理一个对象时，系统不能靠用一条 "super-query"（超查询）作答来取胜。
- **何时使用。** 真实客户端把自己的代码和数据访问混在一起时；不要让基准去批处理应用做不到的事情。

### P23. Speedup、scaleup、sizeup — Wisconsin（DeWitt），TPC-D
- **定义。** 线性 speedup："twice as much hardware can perform a given task in half the elapsed time"（两倍的硬件能够用一半的耗时完成给定任务）。Scaleup：负载与硬件一起增长时，响应时间保持不变。Sizeup：在固定硬件上放更多数据。
- **障碍**（DeWitt）：启动、干扰（"Even if the interference is only 1% per process, with 50 processors ... a maximum speedup of 25"，即便每个进程的干扰只有 1%，有 50 个处理器时……最大 speedup 为 25）以及偏斜。数据要保持足够大，使每个节点上的结构不因为增加节点而变小，否则 speedup 会显得超线性。

### P24. 用一个模型交叉核验测量 — Set Query、Engineering Database Benchmark
- **机制。** O'Neil 根据每个系统的架构预测页 I/O，并对照测量结果来检查：一种 "multiple entry bookkeeping"（多笔记账），用以 "validate[s] the conclusions on 'multiple strands' of evidence"（在「多股」证据上验证结论）。Cattell 把预测的冷时间与测得的时间相比较。
- **规则。** 对每一个标题结果，用第一性原理陈述期望代价；大的差距是一项发现，或者是一个缺陷。

### P25. 给规范标版本，并禁止基准特供 — TPC（Serlin、Raab）
- **机制。** 结果绑定到规范的某一个修订版；TPC 标准在发表之后冻结 12 个月；TPC-C 增加了一条明确的规则，反对 "benchmark specials"（基准特供）。

### P26. 每一种放宽后的变体用一个不同的名字 — DebitCredit/TP1（Serlin）
- **机制。** 大体上同一个测试的三个名字（DebitCredit、ET1、TP1）"led to very undesirable consequences"（导致了非常不良的后果）。TPC-A 分别报告 tpsA-Wide 和 tpsA-Local；TPC-B 是仅数据库这一变体的单独标准。
- **规则。** 对规范的任何偏离都得到一个不同的名字；绝不让一次放宽了的运行借用严格运行的标签。
