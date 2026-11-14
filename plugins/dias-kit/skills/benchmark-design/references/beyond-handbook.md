# Beyond the handbook: later benchmarks and modern translations

Nothing in this file is from the handbook. It carries the handbook's rules
forward to current systems and lists the main later benchmarks, so step 2
("reuse before you invent") can check them. Verify version details against the
current specification before citing them in a paper.

## 1. Translating 1990s rules

| Handbook rule | Today's equivalent |
| --- | --- |
| Five-year price of hardware, software and maintenance (Gray, TPC) | Cost per hour of the instance or cluster (state provider, region, list price, date); for owned hardware, amortized cost per hour; per core or per GiB when price is not meaningful; energy per operation when power is the constraint. Keep Gray's point: normalize by cost instead of forcing "equivalent" configurations. |
| Remote terminal emulator with think times (TPC-A, TPC-C) | A load generator. Decide *open* load (arrivals independent of completions, e.g. Poisson) vs *closed* load (N clients, each waiting for its reply, then thinking). Closed drivers send fewer requests when the system stalls, which hides tail latency ("coordinated omission"); use open arrivals for latency targets. See Schroeder, Wierman, Harchol-Balter, "Open Versus Closed: A Cautionary Tale", NSDI 2006. |
| Terminals per tps, level-of-concurrency T×R (Serlin) | Little's law for a closed driver: clients N = throughput X × (response time R + think time Z). Use it to size the driver and to sanity-check measured throughput. |
| 90th percentile (Sawyer, TPC-A) | Online services often target p99 or p99.9. A percentile needs enough samples: report the sample count, and do not quote p99.9 from a few hundred requests. |
| Buffer pool flushed between queries (O'Neil, Cattell) | Name every cache layer: DBMS buffer and result caches, OS page cache, SSD/controller cache, object-store or remote caches, compiled-code or JIT caches, metadata/statistics caches. State how each is cleared or warmed. |
| Single machine, dedicated (handbook era) | Cloud and shared hardware add noise: repeat across days or instances, interleave systems in randomized order, report median and spread with n. |
| Full disclosure report (TPC) | Publish an artifact: generator with seed, configurations, scripts, raw per-run results, query plans; pin software versions and hardware. |
| Licence restrictions | Some commercial licences restrict publishing benchmark results (often called the "DeWitt clause"); check before naming a commercial system. |

## 2. Later benchmarks to check before inventing one

| Benchmark | Domain | Lineage and notes |
| --- | --- | --- |
| TPC-H | Decision support, ad hoc queries | Successor of TPC-D: 22 queries, 8 tables, fixed scale factors, power and throughput tests. Uniform data; heavily tuned for by vendors and engines. |
| TPC-DS | Decision support, reporting, data maintenance | Snowflake schemas, 99 query templates, skewed data. Large; many studies run a subset, which must be disclosed. |
| Star Schema Benchmark (SSB) | Star-schema analytics | O'Neil, O'Neil, Chen; derived from TPC-H; 13 queries in 4 flights. |
| TPC-C | OLTP order entry | Still the OLTP reference; tpmC; warehouses scale with throughput. |
| TPC-E | OLTP, brokerage | Richer schema and read-heavier mix than TPC-C. |
| YCSB | Key-value and cloud serving | Cooper et al., SoCC 2010: core workloads A–F mixing read, update, insert, scan; Zipfian, uniform and latest request distributions. |
| Join Order Benchmark (JOB) | Query optimization | Leis et al., VLDB 2015: real IMDB data with correlations and skew; tests cardinality estimation and join ordering. |
| LDBC Social Network Benchmark | Graph workloads | Interactive and Business Intelligence workloads over a generated social network. |
| CH-benCHmark | Mixed OLTP and analytics (HTAP) | Cole et al., DBTest 2011: TPC-C transactions and TPC-H-derived queries on one database. |
| Nexmark, Linear Road | Stream processing | Nexmark: auction event stream with a query set; Linear Road (Arasu et al., VLDB 2004): toll computation with latency requirements. |
| ann-benchmarks, big-ann-benchmarks | Vector similarity search | Recall vs throughput curves; report both, never throughput alone. |

Use one as is when its typical operations and data properties match the
scenario; otherwise extend it and give the result a new name (handbook
principle: a relaxed variant gets its own name).

## 3. Common pitfalls, mapped to the handbook

Raasveldt, Holanda, Gubner and Mühleisen, "Fair Benchmarking Considered
Difficult: Common Pitfalls in Database Performance Testing" (DBTest 2018),
discuss pitfalls that restate the handbook's warnings for today's systems:

| Pitfall | Handbook counterpart |
| --- | --- |
| Results that cannot be reproduced (unknown versions, settings, data) | TPC full disclosure; Cattell: "precisely reproducible" |
| Baselines run untuned or misconfigured while the proposed system is tuned | Sawyer's war of wizards; Gray's benchmarketing |
| Comparing systems that do different work (apples vs oranges: missing features, different result semantics) | Gray's relevance; Sawyer's minimal error checking so access patterns match |
| Tuning to the benchmark's specific queries or data | Raab: optimizing "for the benchmark rather than for general applicability"; Ballinger: "precision-tuning the overly-familiar" |
| Mixing cold and hot runs, or not saying which | Cattell's cold/warm protocol; O'Neil's buffer flushing |
| Excluding data loading or preprocessing that one system needs | TPC-D's load time as a secondary metric |
| Wrong answers that go unnoticed | Set Query's expected counts; Sawyer's verifiable outputs |
