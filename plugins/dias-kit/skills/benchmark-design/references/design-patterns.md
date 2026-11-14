# Design patterns from the classic benchmarks

Each pattern is a technique one of the handbook's benchmarks used, phrased so it
transfers to a new domain. Source chapters are in `handbook-principles.md`;
numbers are as printed in the online edition. Use the index to find the
patterns for the decision at hand, then adapt the *mechanism*, not the original
constants.

## Index by design need

| Need | Patterns |
| --- | --- |
| Predicates or operations with exactly known, scale-independent cost | P1, P2 |
| Realistic skew, hot spots, locality | P3, P4 |
| A rule that sets every size from one number | P5, P6, P7 |
| A score when systems differ in what size they can handle | P8 |
| A latency-aware throughput metric and a cost normalizer | P9, P10, P11 |
| Single-user vs multi-user behaviour | P12, P13 |
| Defeating caches and result reuse | P14, P15 |
| Steady state, repetitions, repeatability | P16 |
| Fair tuning rules | P17 |
| Correct answers, not just fast ones | P18 |
| Shrinking a real workload to a small benchmark | P19 |
| Proving the system under test is the bottleneck | P20 |
| Exposing optimizer and access-path weaknesses | P21, P22 |
| Parallel and distributed scaling claims | P23 |
| Trusting the numbers | P24 |
| Keeping the benchmark honest over time | P25, P26 |

---

### P1. Controlled-selectivity columns — Wisconsin (DeWitt), AS3AP
- **Problem.** Real data cannot be scaled, and with it "it is very difficult to
  specify a selection query with a 10% or 50% selectivity factor".
- **Mechanism.** Generate `unique1` as a random permutation of 0..N−1 and
  `unique2` as 0..N−1 in order (for clustering). Derive columns as
  `unique1 mod k` and name them by their selectivity (`onePercent` = mod 100,
  `twentyPercent` = mod 5), so "x.four=2" selects 25% "regardless of the size of
  the relation". Keep strings fixed-length so every page holds the same number of
  rows. AS3AP adds *dense* ranges (0..N: a predicate returns an absolute number
  of rows) and *sparse* ranges (0..10⁹: a predicate returns a fixed fraction).
- **Use when** an operator's cost depends on selectivity, result size or group
  count and you want to sweep it while everything else stays fixed.
- **Pitfall.** Columns are uniform and independent; AS3AP's authors note
  Wisconsin's "confounding variables such as predicate independence". Add
  correlated columns deliberately if correlation drives cost in your domain.

### P2. Cardinality ladder, templates swept across it — Set Query (O'Neil)
- **Mechanism.** One table, columns named by cardinality (K2, K4, K5, K10, K25,
  K100, K1K, K10K, K40K, K100K, K250K, K500K), each uniform over 1..cardinality,
  plus a sequential key. Each query *template* (count, AND, NOT, range + filter,
  group-by, self-join) is run once per ladder column, so one template yields a
  selectivity curve. Templates were chosen from surveyed applications (document
  search, direct marketing, decision support) and mapped back to them.
- **Use when** you need coverage of a selectivity or fan-out spectrum with few
  query shapes, and readers in different applications need their own subset.
- **Adapt.** Name each column by the property it controls (e.g. rows per key,
  versions per key) and sweep templates across it.

### P3. Skewed or non-uniform inputs — TPC-C, AS3AP; uniform by choice — TPC-D
- **Mechanism.** TPC-C models "popular items" and "Non-uniform patterns of data
  access to simulate data hot spots". AS3AP's generator offers uniform, normal,
  exponential and Zipfian distributions with set parameters. TPC-D chose uniform
  values "solely to enhance benchmark reproducibility".
- **Decision rule.** If skew changes which algorithm wins (hash partitioning,
  caching, per-key work), make skew a knob with a uniform level *and* the
  measured real level, and report both. If it does not, uniform is simpler; log
  the choice.

### P4. Locality of reference, with an ablation — Engineering Database Benchmark (Cattell)
- **Mechanism.** "90% of the connections are randomly selected among the 1% of
  parts that are 'closest'"; the rest go to any part. Cattell also reports runs
  without locality, which changed traversal and insert times, concluding "it is
  important to include locality of reference in a benchmark measure, assuming
  the applications the benchmark is to represent exhibits such locality."
- **Use when** caching, clustering or prefetching matter. Make locality a knob
  and include the no-locality point to show its effect.

### P5. Size tied to claimed throughput — DebitCredit, TPC-A, TPC-C
- **Mechanism.** TPC-A: per tps, 1 branch, 100,000 accounts and 10 terminals at
  10 s average think time. TPC-C: "Each warehouse has ten terminals", and
  implementations "must scale both the number of terminals and the size of the
  database proportionally to the computing power of the measured system."
- **Why.** A high rate cannot be claimed on a database that fits in cache or
  with a handful of clients; the scale unit (warehouse, branch) is a business
  entity, so the rule reads in domain terms.

### P6. Fixed scale points, uniform growth — TPC-D (Ballinger)
- **Mechanism.** Data volume is defined as raw data before loading; results may
  be published only at a fixed set of scale factors and compared only at equal
  scale. All tables (except fixed lookup tables) grow at the same rate, so a
  query does proportionally more work at a larger scale, which enables sizeup
  analysis.
- **Pitfall.** Uniform growth hides operations whose cost grows faster than the
  data (joins with fan-out, per-key histories). If your domain has them, add a
  knob that grows them separately.

### P7. Sizes relative to memory — Wisconsin, Engineering Database Benchmark, Set Query
- **Mechanism.** DeWitt: relations "at least a factor of 5 larger than the total
  main memory buffer space". Cattell: a small database that fits in cache and a
  large one sized well beyond client and server caches. O'Neil flushes buffers
  between queries, which "models an extremely large database".
- **Use when** the claim is about out-of-memory behaviour; state each scale
  point as a multiple of the relevant memory (buffer pool, RAM, cache).

### P8. Fixed time, variable size: equivalent database size — AS3AP
- **Mechanism.** The metric is "the maximum size of the AS3AP database for which
  the system is able to perform the designated AS3AP set of single and
  multiuser tests in under 12 hours", and cost per megabyte follows from it.
- **Use when** systems differ in the largest scale they handle, or when "how far
  does it scale within a budget" is the question. Pairs with a failure-point
  report per system.

### P9. Throughput under a response-time percentile, random arrivals — DebitCredit → TPC-A
- **Mechanism.** DebitCredit: tps with 95% of transactions under 1 s. TPC-A: 90%
  under 2 s, measured at the driver (network included), with random (negative
  exponential) arrivals because uniform arrivals were believed to double the
  rate. TPC-A also requires the full throughput-versus-response-time curve.
- **Adapt.** Choose the percentile and threshold from the service target, the
  measurement point from what the user experiences, and publish the curve.

### P10. Cost of the tested system as the normalizer — DebitCredit (Gray's proposal, per Serlin)
- **Mechanism.** Do not try to configure "equivalent" systems; let each be
  configured freely and publish performance divided by total cost (five-year
  hardware, software and maintenance in the original).
- **Adapt.** Cost per hour of the instance type, or per core / per GiB, or energy;
  see `beyond-handbook.md`.

### P11. Business-unit metric over a mandated mix — TPC-C (Raab)
- **Mechanism.** Five transaction types in a fixed mix; the reported metric is
  only the rate of New-Order, "a measure of business throughput". The other
  transactions must run in their proportions, so the mix cannot be skipped.
- **Use when** the domain has one operation users care about and supporting
  operations that create contention.

### P12. Single-stream and multi-stream tests, and composite pitfalls — TPC-D (Ballinger)
- **Mechanism.** Power test (one stream, geometric mean of query times) and
  throughput test (several streams, arithmetic), combined for price/performance.
- **Lessons.** Making the multi-stream test optional meant few vendors ran it.
  The geometric mean over-rewards very short queries (a floor of 1/1000 of the
  longest was added) and invited a loophole under concurrency. Streams had no
  think time, so one stream is several real users.

### P13. Concurrency set by formula — AS3AP; and a warning — TPC-D
- **Mechanism.** AS3AP: number of users = logical database size / 4 MB, "to
  prevent single-user versions of the multiuser tests". TPC-D tied the number
  of update pairs to the number of query streams so updates kept their weight;
  Ballinger reports this distorted the throughput test, because real update
  volume does not grow with users.
- **Rule.** Derive concurrency from the domain (users per data unit, arrival
  rate), not from what the implementer finds convenient.

### P14. Run-time input parameters — TPC-D, Wisconsin, Engineering Database Benchmark
- **Mechanism.** TPC-D substitutes input variables per execution so repeated
  runs "touch different groupings of data and yet do the equivalent work",
  reducing advantage from caching or pre-aggregation. Wisconsin runs several
  parameter variants alternating between two identical copies of the base
  relations. Cattell picks a fresh random set of parts in each iteration.
- **Rule.** Each parameter has a distribution and a guarantee of equal work.
  Keep this variation out of the repetitions that estimate noise: repeat the
  same parameter set to measure run-to-run spread, and vary parameters across
  streams or in a separate sensitivity run.

### P15. Cold and warm protocol — Engineering Database Benchmark, Set Query, AS3AP
- **Mechanism.** Cattell: at least 10 iterations; the first is "cold" (database
  closed and reopened, OS file caches cleared on client and server by reading a
  large unrelated file), the asymptotic best is "warm". O'Neil flushes buffers
  between queries and checks for overlap by running query pairs in both orders.
  AS3AP orders tests so consecutive queries touch different relations.
- **Rule.** Write down exactly how each cache layer is emptied or filled, and
  report both states when both occur in the domain.

### P16. Warm-up, measurement window, repeatability — AS3AP, TPC-D
- **Mechanism.** AS3AP multi-user tests run 15 minutes, then measure for 5,
  "to give the system time to 'warm up' before throughput is measured without
  allowing an arbitrary time interval for reaching steady state." TPC-D requires
  a complete rerun within 5% (two runs) or 10% (three runs) and publication of
  the lower result.

### P17. Fix the logical workload, cost or fix the physical design — TPC-D, Set Query, Engineering Database Benchmark
- **Mechanism.** TPC-D: "SQL-as-written" (no hints, no arbitrary rewrites),
  physical structures free but charged through load time, update cost and a
  storage-to-raw-data ratio. Set Query: "only these 13 indices are allowed". 
  Cattell: physical structures are free but may not change between measures,
  and shortcuts that exploit generator artifacts are banned ("It is not
  acceptable to take advantage of the fact that the benchmark part-ids are
  numbered sequentially").

### P18. Self-verifying results — Set Query, Sawyer, AS3AP, TPC
- **Mechanism.** Set Query publishes the generator, the first rows and the
  expected row count of every query. Sawyer has batch jobs emit counts and
  totals. AS3AP runs correctness queries after recovery. TPC benchmarks
  specify ACID tests.
- **Rule.** Every operation has a checkable output; a run with a wrong answer
  is invalid, however fast.

### P19. Shrink a real workload with an access-pattern grid — Sawyer
- **Mechanism.** Split operations into weighted paths; tabulate rate × per-table
  access pattern (R random read, U update, F sequential fetch); merge operations
  with matching patterns and add their rates; drop tables made redundant; keep
  data access, drop application logic. Note the long tail of rare operations
  you removed.

### P20. Calibrate the driver — Sawyer
- **Mechanism.** Replace the operation with an echo, submit with no think time,
  find the rate at which network or driver saturates, and keep the benchmark
  well below it; replicate drivers if needed.

### P21. Optimizer traps — Wisconsin, AS3AP, TPC-D
- **Mechanism.** Wisconsin's JoinAselB writes the join before the selection "to
  test whether the system has even a rudimentary query optimizer". AS3AP's
  `variable_select` runs one precompiled query with two parameter values, one
  favouring an index and one a scan. Ballinger's TPC-D Query 9 punishes a wrong
  join order by "20 times or more work than is actually required".
- **Rule.** Include a few such cases on purpose, and keep each from dominating
  the total if it goes wrong (AS3AP's tractability rule).

### P22. Application interleaving at the real grain — Engineering Database Benchmark
- **Mechanism.** Each object fetched calls a host-language procedure, so a system
  cannot win by answering with one "super-query" when the real application
  works one object at a time.
- **Use when** the real client mixes its own code with data access; do not let
  the benchmark batch what the application cannot.

### P23. Speedup, scaleup, sizeup — Wisconsin (DeWitt), TPC-D
- **Definitions.** Linear speedup: "twice as much hardware can perform a given
  task in half the elapsed time". Scaleup: constant response time as workload
  and hardware grow together. Sizeup: more data on fixed hardware.
- **Barriers** (DeWitt): startup, interference ("Even if the interference is
  only 1% per process, with 50 processors ... a maximum speedup of 25") and
  skew. Keep data large enough that per-node structures do not shrink as nodes
  are added, or speedup appears superlinear.

### P24. Cross-check measurements against a model — Set Query, Engineering Database Benchmark
- **Mechanism.** O'Neil predicts page I/O from each system's architecture and
  checks it against the measurement: "multiple entry bookkeeping" that
  "validate[s] the conclusions on 'multiple strands' of evidence". Cattell
  compares predicted cold times with measured ones.
- **Rule.** For each headline result, state the expected cost from first
  principles; a large gap is a finding or a bug.

### P25. Version the spec and forbid benchmark specials — TPC (Serlin, Raab)
- **Mechanism.** Results are tied to a spec revision; TPC standards were frozen
  for 12 months after publication; TPC-C added an explicit rule against
  "benchmark specials".

### P26. A distinct name for each relaxed variant — DebitCredit/TP1 (Serlin)
- **Mechanism.** Three names for loosely the same test (DebitCredit, ET1, TP1)
  "led to very undesirable consequences". TPC-A reports tpsA-Wide and
  tpsA-Local separately; TPC-B is a separate standard for the database-only
  variant.
- **Rule.** Any deviation from the spec gets a different name; never let a
  relaxed run borrow the strict run's label.
