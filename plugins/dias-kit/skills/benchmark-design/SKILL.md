---
name: benchmark-design
description: "Design, specify or critique an evaluation workload or benchmark for a data, query or transaction system, using the framework of Jim Gray's 'The Benchmark Handbook for Database and Transaction Systems' (relevant, portable, scaleable, simple; a workload plus a measurement specification; lessons from TPC-A/B/C/D, Wisconsin, AS3AP, Set Query and the Engineering Database Benchmark). Use it whenever the user must decide what to measure and how: choose or adapt a benchmark, define operations and their mix, build a data generator (skew, selectivity, locality), set scale factors, metrics, latency percentiles, cost normalization, run rules, correctness checks, tuning and fairness rules, or write a paper's experimental setup; and whenever they ask whether an evaluation plan is fair or convincing (e.g. 'we run TPC-H once per engine, is that enough?'). Trigger even without the words Gray, handbook or benchmark, e.g. 'how should I evaluate my engine', 'what workload should I use'."
---

# Benchmark design with Gray's handbook

A benchmark is an instrument for one decision. Gray opens the handbook with the
argument that "No single metric can measure the performance of computer systems
on all applications", because performance "varies enormously from one
application domain to another". His answer is the **domain-specific
benchmark**: a synthetic workload that characterizes the typical applications
of one problem domain, run under rules that make results comparable. This skill
turns a user's scenario into such a benchmark, written as a specification
another person could implement, and audits it against the handbook's criteria.

Sawyer's chapter ("Doing Your Own Benchmark") splits every benchmark into the
**workload specification** (what work is done) and the **measurement
specification** (how it is run, timed and judged). Every decision below belongs
to one of the two. His governing rule applies throughout: "the trade-off
between reality and simplicity governs all." Record each such trade-off where
you make it, because a reader can only trust a simplification they can see.

The value of this skill is the mapping from *this scenario's* cost drivers to
*specific* design choices. Generic advice ("use realistic data", "run several
times", "measure latency") is the failure mode. Every knob gets a default and a
range, every metric a unit, every rule a check someone could run.

## Files

- `references/spec-template.md` — the deliverable. Use its structure for every
  spec; scale sections to the scenario, but do not silently drop one.
- `references/design-patterns.md` — reusable techniques from the classic
  benchmarks (controlled selectivity, cardinality ladders, skewed inputs,
  throughput-tied scaling, cold/warm protocol, fixed-time metric, calibration,
  costed physical tuning, ...). In steps 3 and 4, start from its index and use
  the few patterns (typically three to six) that answer a cost driver of this
  scenario. A pattern without a scenario reason is cost, not rigour.
- `references/handbook-principles.md` — the principles with chapter
  attributions and short quotes. Read it in Critique mode, or when a decision
  needs a cited justification. Attribute an idea to the chapter author who wrote
  it (O'Neil, Sawyer, DeWitt, ...), not to "Gray" in general. In the spec, cite
  the handbook only where it justifies a decision a reader might dispute; the
  spec is for implementers, not a tour of the framework.
- `references/beyond-handbook.md` — later benchmarks (TPC-H, TPC-DS, YCSB, JOB,
  LDBC, CH-benCHmark) and modern translations of 1990s rules (cost per hour
  instead of five-year price, open vs closed load generation). Read it in
  step 2 and when you map metrics to today's hardware.

## Modes

- **Design.** The user describes a scenario: run steps 0–7 and write a spec.
- **Critique.** The user brings a plan, a script or a paper's evaluation
  section: run step 1 and step 6 against the plan *as it is*. List findings, each
  tied to a principle and graded *invalidates the conclusion*, *weakens it* or
  *cosmetic*. Then write the revised spec (or a focused change list if the plan
  is mostly sound).
- **Extend.** An existing benchmark lacks one property (skew, concurrency,
  updates, larger scale): run steps 2–5 for the delta only. Call the result
  "derived from X", because a standard benchmark run under changed rules is no
  longer that benchmark and must not borrow its name.

## Step 0 — Intake: collect the facts that drive the design

Extract these from the conversation, the repository (code, schemas, query logs,
data samples, earlier experiments) and the user's own words. Each fact drives a
named design decision; that is why it is collected.

| Fact | Decision it drives |
| --- | --- |
| The decision the results will inform, and who reads them | Gray's use category (step 1), primary metric, what is held fixed |
| Systems or variants compared; what is fixed and what each implementer may choose | Portability and fairness rules (step 5) |
| Typical operations, with frequencies or rates and data-access patterns | Operation set and mix (step 3a) |
| Data properties that drive cost: sizes, cardinalities, skew, correlation, locality, temporal structure, update rate | Generator knobs (step 3b) |
| Service target: latency threshold *and* percentile, or a batch deadline | Constraint on the primary metric (step 4a) |
| Concurrency: number of clients × per-client rate, think time | Driver design and tests (step 3d) |
| Scale range: smallest and largest data and hardware of interest | Scaling rule and scale points (step 3e) |
| Budget for the benchmark itself, and what may be given up | Simplifications (tradeoff log) |

If a missing fact would change the design materially, ask once, grouped. If the
user is not available or the fact is a judgement call, assume a value, say so,
and list it under *Assumptions* in the spec so it can be corrected later.
Measured numbers from the user's data beat guesses; if a data sample is
available, count the cost-driving properties (rows per key, skew, gaps) and cite
the counts.

## Step 1 — Frame: what do you want to learn?

Sawyer starts with three questions, re-examined throughout: *What do you want
to learn? How much are you prepared to invest? What are you prepared to give
up?* Answer them in the spec's first section.

Then name which of Gray's four uses the benchmark serves, because each fixes a
different set of variables:

1. Different systems on different hardware (whole-system comparison).
2. Different software on the same hardware (engine vs engine).
3. The same software across a family of machines (hardware scaling).
4. Successive releases of one product (regression; in research also: an
   optimization on vs off, i.e. an ablation).

State the claim the benchmark must be able to *refute* ("engine A sustains
higher throughput than B under a p99 ≤ 50 ms constraint at every scale point"),
and what it will *not* tell you. Sawyer lists future performance among the
things a benchmark cannot predict; Gray notes that the handbook's metrics do not
measure ease of use, programming or operations.

## Step 2 — Reuse before you invent

A benchmark's credibility comes from acceptance: Gray's main criterion for
including a benchmark in the handbook was whether it was widely accepted within
its domain-specific community. Compare the intake's typical operations and data
properties with existing benchmarks (`references/beyond-handbook.md`):

- **Relevant as is** → use it, under its rules, and say why it fits.
- **Relevant except for one property** → extend it (Extend mode) and name the
  missing property.
- **Not relevant** → build a new one, and say which typical operations or data
  properties the existing ones miss. The handbook's own new benchmarks were
  justified this way: O'Neil built Set Query because transaction benchmarks did
  not exercise set queries; Cattell built the Engineering Database Benchmark
  because neither TPC nor Wisconsin measured fine-grained navigation from a
  client program.

A custom benchmark can still borrow a standard benchmark's generator, schema or
queries for portability; say what was borrowed.

## Step 3 — Workload specification

**3a. Operations and their exact semantics.** Derive operations from the
domain's questions, not from what the system under test happens to do well;
TPC-D was "Designed with business questions built first, followed by SQL." For
each operation give its purpose, its exact definition (query text or operation
semantics), its parameters and its share of the mix.

Pin the semantics down to the edge cases before anything is timed, because two
systems that disagree on an edge case are doing different work, and the faster
one may simply be wrong. List each edge case the domain has — ties, boundary
inclusion, NULL and missing values, duplicates, empty inputs, ordering, type
precision — state the required result, and have the generator plant instances
of each with the expected output. For time-dependent workloads, treat
late-arriving and out-of-order data (an event whose ingestion time is after the
time it is queried for) as a first-class variant, not a footnote: it changes
both correctness and cost.

Then shrink the set the way Sawyer does: split an operation with several code
paths into weighted paths, tabulate rate × data-access
pattern (random read / update / sequential fetch per table), merge operations
whose patterns coincide, keep data access, drop application logic. Note
infrequent operations explicitly; a long tail of rare operations stresses
caches in a way a few hot ones do not.

**3b. Data and generator.** Prefer a seeded, deterministic generator so every
system loads *identical* data (TPC-D). Give each cost-driving property from the
intake its own knob with a default and a range, using the patterns in
`references/design-patterns.md`: columns with controlled selectivity
(Wisconsin), a ladder of cardinalities (Set Query), skewed or non-uniform inputs
(TPC-C, AS3AP), locality of reference (Engineering Database Benchmark),
temporal structure for time-dependent workloads. Decide uniform vs skewed
deliberately: TPC-D chose uniform values "solely to enhance benchmark
reproducibility", at a known cost in realism; log that kind of choice. Ship
checks with the generator (row counts, the first rows, measured skew) so an
implementer can confirm they generated the right data.

**3c. Input parameters.** Draw query parameters at run time from a stated
distribution, so repeated executions touch different data with equivalent work.
This defeats result caching and simulates ad hoc use (TPC-D's input variables;
fresh random parts in each Engineering Database Benchmark iteration).

**3d. Mix, concurrency and tests.** State concurrency as *clients × per-client
rate*, not only as an aggregate rate: Sawyer's example is that ten processes at
one transaction per second each behave differently from a thousand users at 0.01
each. State think times (or none). Include both a single-stream test and a
multi-stream test when the domain has concurrent users: because TPC-D made the
multi-user test optional, most published results, in Richard Winter's words
quoted by Ballinger, "say nothing about the ability of the database engine to
deal efficiently with multiple concurrent users". If the
domain updates data while it is read, run updates concurrently with reads, and
add a control that separates the two effects: a set of read operations over data
the writes never touch (historical partitions, frozen tables), measured with and
without the write load. Without it, "slower under writes" mixes interference
with the reads simply seeing more or different data.

**3e. Scaling rule.** One scale factor should determine every size, so a
reader can predict the work at any scale. Pick the rule that fits the domain
(see design patterns): database size tied to claimed throughput (TPC-A/C, so a
high rate cannot be claimed on a toy database); fixed legal scale points with
comparisons only at equal scale and uniform growth so work grows predictably
(TPC-D); sizes relative to cache capacity (Engineering Database Benchmark); or a
fixed-time metric that reports the largest size processed within a deadline
(AS3AP). Plan the scaling experiments explicitly: sizeup (more data, same
hardware), speedup (same data, more hardware), scaleup (both grow together), and
the failure point where a system stops completing. A claim about scaling needs
enough points to fit its trend with an uncertainty estimate; two points fit any
curve, and the smallest point is often dominated by fixed overhead.

## Step 4 — Measurement specification

**4a. Metrics.** The primary metric is useful work per unit time *subject to a
response-time constraint* (TPC: throughput while a stated percentile stays under
a threshold), and Gray pairs it with **price/performance**. Translate price to
the scenario: cost per hour of the hardware or cloud instance, cores, memory,
energy (see `references/beyond-handbook.md`). Report per-operation results, not
only a composite; if you define a composite, give its formula and its
pathologies (TPC-D's geometric mean rewards shaving short queries and needed a
floor rule). Add secondary metrics that make the cost of tuning visible: load
and preparation time, storage relative to raw data (TPC-D's disk storage ratio).

**4b. Response time.** Use a percentile, not the mean: Sawyer shows two
distributions with the same average and very different 90th percentiles, and
recommends the 90th. Pick the percentile from the service target. Define the
**measurement point**, where the clock starts and stops (client call to result
in program variables, as in the Engineering Database Benchmark; or receipt to
commit), because each point includes different components.

**4c. Run rules.** Specify warm-up to steady state, the measurement interval,
cold vs warm protocol (how caches are cleared, including the OS file cache, and
how many iterations; the Engineering Database Benchmark reports the first and
the asymptotic run), repetitions and a repeatability criterion (TPC-D: a
complete rerun within 5%, report the worse). Keep two sources of variation
apart: repetitions that estimate run-to-run noise reuse the *same* parameter
set; parameter variation (step 3c) is spread across streams or measured in its
own sensitivity run. Re-drawing parameters on every timed repetition makes the
reported spread a mix of noise and workload change. Then specify what happens
to updated data between runs (evolve or reset), timeouts, and how a failure is reported (a
failure at a scale point is a result, not a missing value).

**4d. Correctness.** A fast wrong answer is not a result. Sawyer requires
batch jobs to report verifiable data (counts, totals) and minimal error
checking so all systems execute the same access pattern. Specify reference
answers or checksums per operation, and consistency tests when there are
updates (the TPC benchmarks require ACID tests). Check the checker once: a
deliberately wrong variant of each operation (an off-by-one boundary, the wrong
tie-break) must fail validation, otherwise the gate proves nothing.

**4e. Calibration.** Prove that the system under test is the bottleneck.
Sawyer's method: replace the operation with an echo, submit with no think time,
find the rate at which the driver or the network saturates, and keep the
benchmark well below it. Monitor the driver's own CPU and memory during runs.

## Step 5 — Fairness, portability and disclosure

- **Fix the logical workload, cost the physical tuning.** TPC-D held schema
  and queries fixed ("SQL-as-written", no hints or rewrites) and allowed
  physical structures, but charged for them through load time, update cost and
  storage. Set Query took the other route and mandated the indexes. Choose one
  and write it down.
- **Equal tuning effort, fixed in advance.** Decide the tuning budget and the
  rerun policy before the first run. Sawyer's "war of wizards" is reruns
  escalating with ever more expert tuners; Gray describes the same dynamic as
  benchmark wars. Baselines get the same care as the system you favour.
- **Measure the system, not the implementer's cleverness.** If a trick in one
  implementation would also work in the others, apply it everywhere or forbid it
  (Sawyer). Forbid shortcuts that depend on artifacts of the generator (the
  Engineering Database Benchmark bans computing disk addresses from sequential
  part ids).
- **Released software, standard settings, disclosed deviations** (TPC full
  disclosure). Disclose versions, configuration, hardware, generator seed,
  query text and query plans; Ballinger names the decision not to disclose plans
  as a TPC-D mistake.
- **Portability.** Specify operations declaratively, keep per-system adapters
  thin, and avoid features only one system has unless that feature is the
  question. Still give the implementer a concrete start per system: the native
  operator or formulation to use, the settings that matter and their intended
  values, and known limitations. Mark each such claim "verify at version pin"
  rather than leaving it out; a spec without system detail pushes every
  implementer to rediscover it differently.

## Step 6 — Audit the design

1. **Gray's four criteria**, each with evidence for and against:
   *relevant* (peak performance and price/performance on typical operations of
   the domain), *portable* (easy to implement on many systems), *scaleable*
   (applies to small and large systems), *simple* (understandable, otherwise it
   lacks credibility). The criteria conflict; name where. A design that claims
   all four without tension has not been examined.
2. **Simplicity is a gate, not a confession.** If the audit finds the design
   is not simple, cut it before delivering. Use Cattell's method: drop measures
   whose results would track ones you keep, merge operations with the same
   access pattern (Sawyer's grid), and move everything not needed for the
   decision into named extensions. The core benchmark should sweep a handful of
   knobs (the cost drivers that can change the ranking), not every property
   you can name, and one full core run should fit in a working day on the
   target hardware. Every extension states the question it answers, so it can
   be scheduled or dropped on its own. Cut experiments and knobs, never the
   repetitions, correctness gate or calibration that make each kept result
   trustworthy.
3. **Benchmarketing check.** Gray: "For each system, there is some benchmark
   that rates that system the best." In research the author is both vendor and
   customer. Ask: Which operations or data properties would make the favoured
   system lose, and are they in the workload at their real frequency? Is the
   chosen scale where its advantage peaks? Were baselines tuned equally? Would
   the conclusion survive a sweep of the main cost-driving knob? Add that sweep
   to the experiment matrix.
4. **Explain the result.** A headline difference with no mechanism invites the
   suspicion Gray describes. Include one experiment that attributes the
   difference: an ablation (the system with its key technique switched off), a
   per-operator or per-phase time breakdown, a cross-check against a cost
   model (O'Neil's "multiple entry bookkeeping"), or a floor measured by
   differencing — DeWitt estimated display cost as the difference between two
   otherwise identical Wisconsin queries; a scan-and-write query with the same
   input and output isolates the cost of the operation itself.
5. **Limits.** List what the benchmark will not tell you.
6. **Lifecycle.** Ballinger observed published TPC-D configurations
   "precision-tuning the overly-familiar" query set. Plan parameter
   randomization and a refresh of the operation set.

## Step 7 — Deliver

Write the spec to a file using `references/spec-template.md` (default:
`benchmark/<short-name>-spec.md` in the project, or where the user asks). Keep
it self-contained: a reader who sees only the spec can implement and run the
benchmark. Keep the core readable in one sitting: put long query text,
generator details and per-system notes in appendices. Length is not rigour; if
the core sections run past roughly ten pages, cut before delivering. Include a
cost estimate for the benchmark itself (Sawyer's costs: people, machine time, wall time of one full run). If one full run takes hours,
define a reduced configuration for iteration and the order in which scale
points are climbed.

The chat reply is short: the decision the benchmark serves, the primary metric
and its constraint, the scaling rule, the three most consequential trade-offs,
and the open assumptions, with a link to the spec.

Write the spec precisely: numbers with units, one term per concept defined at
first use, no unquantified adjectives; the `research-writing` skill in this
plugin has the full rules. Running the benchmark and reporting measured results
follow the `think-sharp` skill in this plugin; this skill's spec is the
input to those steps (a scale point corresponds to a rung of its doubling
ladder, a failure point to its wall).
