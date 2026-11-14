# Principles from The Benchmark Handbook, with sources

Source: Jim Gray (ed.), *The Benchmark Handbook for Database and Transaction
Systems*, 2nd ed., Morgan Kaufmann, 1993. Quotes below are from the free online
edition on Jim Gray's archive (jimgray.azurewebsites.net/BenchmarkHandbook/).
Several online chapters are drafts (Sawyer and Serlin: "First Draft"; DeWitt,
AS3AP, O'Neil, Cattell: "Second Draft"), and two are later than 1993 (Ballinger's
TPC-D chapter and Raab's TPC-C commentary, both about 1998). Wording and numbers
can differ from the printed book; say "online edition" when quoting, and
attribute each idea to its chapter author.

Contents
1. Chapter map
2. Why domain-specific benchmarks (Gray)
3. The four criteria (Gray)
4. The four uses of a benchmark (Gray)
5. Metrics: throughput, response-time constraint, price/performance
6. Benchmark wars, benchmarketing, full disclosure
7. Doing your own benchmark (Sawyer)
8. Realism versus a common yardstick
9. Simplicity by subtraction
10. One number or a spectrum
11. Benchmarks age

## 1. Chapter map

| Chapter (online edition) | Author | Domain | What to borrow |
| --- | --- | --- | --- |
| Introduction | Jim Gray | all | domain-specific benchmarks, four criteria, uses, benchmarketing |
| History of DebitCredit and the TPC | Omri Serlin | OLTP | throughput under a percentile, cost as normalizer, full disclosure |
| TPC-D: Benchmarking for Decision Support | Carrie Ballinger | decision support | business questions first, fixed scale points, power vs throughput, costed tuning |
| The Wisconsin Benchmark | David DeWitt | relational operators | controlled-selectivity data, optimizer traps, speedup/scaleup/sizeup |
| AS3AP | Turbyfill, Orji, Bitton | mixed relational workload and utilities | fixed-time metric, dense/sparse ranges, users by formula |
| The Set Query Benchmark | Patrick O'Neil | set queries, decision support | cardinality ladder, application-mapped query suites, cold buffers |
| The Engineering Database Benchmark | R. G. G. Cattell | engineering, client-server navigation | locality, cold/warm protocol, operations sized by frequency |
| Doing Your Own Benchmark | Tom Sawyer | custom benchmarks | workload vs measurement spec, access-pattern grid, calibration, war of wizards |
| TPC-C | Francois Raab | OLTP order entry | business-unit metric over a mandated mix, per-warehouse scaling |

The handbook also has chapters on full-text retrieval, SPEC and the Neal Nelson
benchmark; this skill does not use them.

## 2. Why domain-specific benchmarks (Gray)

- "No single metric can measure the performance of computer systems on all
  applications. System performance varies enormously from one application
  domain to another."
- Database performance "is dominated by the performance of software algorithms
  rather than by raw hardware speed", so numeric benchmarks give little guidance.
- "One system may be excellent at performing simple update-intensive
  transactions for an online database; but it may have poor performance on
  complex queries to that database."
- "Each such benchmark specifies a synthetic workload characterizing typical
  applications in that problem domain." Its results give "a rough estimate" of
  relative performance in that domain.
- Gray notes that systems good at one of the three query benchmarks (Wisconsin,
  AS3AP, Set Query) "are not necessarily good at the other two".
- Ratings are crude, like fuel-economy ratings: "Your actual mileage may vary".

Design consequence: name the domain and its typical operations before anything
else. A benchmark that cannot name its domain cannot be relevant.

## 3. The four criteria (Gray)

> **Relevant**: It must measure the peak performance and price/performance of
> systems when performing typical operations within that problem domain.
> **Portable**: It should be easy to implement the benchmark on many different
> systems and architectures.
> **Scaleable**: The benchmark should apply to small and large computer
> systems. It should be possible to scale the benchmark up to larger systems,
> and to parallel computer systems as computer performance and architecture
> evolve.
> **Simple**: The benchmark must be understandable, otherwise it will lack
> credibility.

Gray's counter-example is MIPS: simple, but not portable (IBM and VAX MIPS are
not comparable), not scaleable (a thousand one-MIPS processors are not one
1000-MIPS processor), and above all irrelevant: "it does not measure useful
work". SPEC and Perfect Club were relevant, portable and simple for numeric
work but not scaleable, "in the sense that the problem size does not grow with
processor power."

Gray also states that the handbook's metrics "do not measure ease-of-use,
ease-of-programming, or ease-of-operations"; they are performance and
price/performance only.

## 4. The four uses of a benchmark (Gray)

1. Compare different software and hardware systems.
2. Compare different software products on one machine (O'Neil's Model 204 vs
   DB2 on the same processor).
3. Compare different machines in a compatible family.
4. Compare different releases of a product on one machine — a performance
   regression test ("often new features slow down old features").

"Of course, in each of these cases, the benchmarks must be chosen to reflect the
problem-specific domain you are interested in."

## 5. Metrics: throughput, response-time constraint, price/performance

- Gray: performance "is typically a throughput metric (work/second) and price
  is typically a five-year cost-of-ownership metric. Together, they give a
  price/performance ratio." His example table shows why both matter: the most
  economical system depends on the throughput the customer needs.
- Serlin on DebitCredit: "to make tps ratings comparable, the paper proposed a
  constraint under which 95% of all transactions completed in 1 second or
  less." TPC-A relaxed this to 90% under 2 seconds, measured at the driver
  instead of at the system under test.
- Serlin: "Instead of configuring equivalent systems, Gray suggested that the
  cost of the tested system be used as the rationalization factor." Vendors may
  configure any system, but must publish cost per tps.
- Serlin: TPC-A requires random (negative exponential) arrivals because "there
  is some theoretical and practical evidence that allowing uniform arrivals
  doubles the transaction rate."
- Sawyer: use a percentile, not the average; two systems with equal averages
  can have very different 90th percentiles. He recommends the 90th, and says to
  define where response time is measured.

## 6. Benchmark wars, benchmarketing, full disclosure

- Gray: "Benchmark wars start if someone loses an important or visible
  benchmark evaluation." Each side reruns with more expert tuners, up to "a
  special version of the system ... with promises that the enhanced performance
  features will be included in the next regular release."
- Gray: "Benchmarketing is a variation of benchmark wars. For each system,
  there is some benchmark that rates that system the best." It "leads to
  universal skepticism of all benchmark results."
- Gray on the TPC response: standard hardware and released software; "Any
  special tuning or parameter setting must be disclosed"; independent audit is
  highly recommended.
- Serlin: "to be credible, a test sponsor must furnish to the public sufficient
  back-up data to allow independent observers or end-users to judge the
  validity of the associated performance claims."
- Raab: TPC-C added a written rule against "benchmark specials" only in
  Revision 2.0 (1993).
- DeWitt: Wisconsin mattered because it named products; anonymous results
  "would most likely have simply been dismissed as an academic curiosity."
  (Check software licence terms before publishing named comparisons of
  commercial systems.)

## 7. Doing your own benchmark (Sawyer)

- Three questions, re-examined throughout: "What do you want to learn? How much
  are you prepared to invest? What are you prepared to give up?" "You will
  always spend more than you think and you will wind up learning less than you
  desire."
- Costs: programmer time (workload, transaction logic, data access, data
  distributions and generation, instrumentation), machine resources, management
  time (reporting, administration, adjudication of rules), lost opportunity.
- What you won't learn: future performance ("benchmarks are no better for
  future predictions than any of the other tea-leaf devices"), and the support
  you will get later.
- "A benchmark has two major components: the workload specification [and] the
  measurement specification."
- Workload reduction: eliminate application logic first (rarely more than
  10–15% of CPU); never omit database access; decompose a transaction into
  weighted paths; tabulate rates against per-table access patterns (random read,
  update, sequential fetch) and merge transactions with matching patterns; drop
  tables that merging makes redundant. Each cut "will remove some element of
  reality"; record it.
- Simulate the real number of users: "A system that uses ten processes, each
  submitting one tps, may behave much differently than a system with one
  thousand users, each submitting a .01 tps."
- Predefined "ad hoc" queries give tuning opportunities; "The art is specifying
  the rules surrounding the execution of these queries."
- Batch work: decide how much pre-planned access is allowed (input order,
  duplicated data in indexes, manual parallelization).
- Minimal error checking, so that all systems perform the same access pattern;
  batch jobs "should report some data that can be verified", such as counts and
  totals.
- Omissions: a long tail of rare transaction types stresses memory differently
  from a few resident ones.
- "Make certain you are measuring the hardware/software environment and not the
  implementation team's degree of cleverness."
- Measurement environment: "Once again, the trade-off between reality and
  simplicity governs all." Measure through a driver when the system is pushed to
  its limits.
- Calibration: "All systems will have a bottleneck. The trick is to force the
  one you want to measure to be the constraining resource." Saturate the driver
  and network with echo transactions and stay well below that rate.
- War of wizards: announce a single trial, "no excuses, no reruns"; beware "the
  new-and-improved release".
- Treat the benchmark "in the same manner as a developement [sic] project with a
  budget, goals and time estimates."

## 8. Realism versus a common yardstick

- Serlin on TPC-A: "Application realism took second place wherever it
  conflicted with the common yardstick goal."
- Ballinger on TPC-D: "Drawing up a list of what to include in a benchmark is
  the easy part, it's what to leave out and what to bargain over that is
  difficult." Uniform data "exists solely to enhance benchmark
  reproducibility", although real customers per nation and sales per part are
  skewed.
- Ballinger: "Benchmark Options Both Widen and Weaken TPC-D" — every option
  (zero-stream throughput test, reset of updates between runs, updates outside
  the query streams) reduced comparability or opened a way around the hard part.
- AS3AP authors: the benchmark "is not intended to model a specific workload or
  query mix"; it trades completeness for tractability with a 12-hour limit and
  queries that "detect query optimization problems without completely
  dominating the benchmark if something goes wrong."

## 9. Simplicity by subtraction

- Cattell dropped measures whose results tracked retained ones and replaced
  measures that implementers could not reproduce consistently. Richer features
  "belong in any more comprehensive benchmark; but they reduce the utility of a
  simple benchmark focussed on basic performance. They make it harder to
  implement and reproduce."
- Cattell: "It is essential that a good benchmark be precisely reproducible."
- Cattell: "The only truly accurate representation of performance is actually
  executing the application."
- O'Neil: "a perfect apples-to-apples comparison between two products in every
  feature is generally impossible. Thus judgements must be made".

## 10. One number or a spectrum

- DeWitt: DebitCredit is popular because it "reduces each system to one magic
  number"; Wisconsin's multi-user follow-ups failed partly because they did not
  produce one.
- O'Neil: "We don't wish to lose this advantage by reporting a single number
  which fits no particular case"; he defines a single price-related measure but
  publishes per-query detail so readers can reweight it.
- Cattell: "it is important not to abuse of the 'overall' number, because the
  frequency of occurrence of these operations will differ widely between
  applications: the individual measures are important."
- Ballinger: TPC-D's geometric-mean power metric rewards percent improvements
  equally, so shaving a short query counts as much as fixing a long one; very
  short queries needed a floor (1/1000 of the longest), and the geometric mean
  was kept out of the multi-stream test to close a loophole.

Design consequence: publish the vector; if a headline number is needed, give
its formula, its weights and its pathologies.

## 11. Benchmarks age

- Raab: vendors "optimized their systems for the benchmark rather than for
  general applicability to real-life operations. This shift in focus is one of
  the basic laws that govern benchmarks." It made TPC-A obsolete.
- Ballinger: published TPC-D configurations show "a trend towards
  precision-tuning the overly-familiar"; a decision-support benchmark "requires
  frequent rejuvenation".
- Serlin: TPC standards may not change within 12 months of publication; version
  the spec and keep results tied to a version.
