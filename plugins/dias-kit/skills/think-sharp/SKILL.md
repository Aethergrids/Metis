---
name: think-sharp
description: "Working method and thinking framework for experimental systems research (query engines and data systems, storage, runtimes, distributed and ML systems): first-principles decomposition, top-down problem characterization, bottom-up solution layer by layer, and a fast assumption-implementation-evaluation loop. Use it whenever the task is to plan, implement, measure, optimize, compare or report on a system's performance, memory, scalability or efficiency, or to run an experiment campaign, including 'characterize', 'bottleneck', 'why is it slow', 'baseline', 'ablation', 'ladder', 'sample the dataset', 'the run takes too long', 'does it hold at scale', 'is this worth trying', 'what next', 'write the step record', 'report the results'. Also use it when a session drifts into waiting, repeated verification, side quests, predicted run outcomes in place of a hypothesis, or vague numbers. Apply it even when the user does not name a method."
---

# Think sharp: a method for systems research

This skill sets the rules for research steps in experimental systems work. It addresses common problems: designs copy existing systems instead of asking what the problem needs; optimization starts before anyone understands the problem; people write code without evidence; a predicted number stands where a hypothesis about the problem should be; runs take hours; repeated checks replace progress; and reports contain numbers and sentences with unclear meanings. Each section below addresses one of these problems.

Thinking starts with first principles and moves from the top down (sections 1 and 2). Building starts at the bottom and adds one layer at a time (section 3). Each unit of work follows a short loop from assumption to implementation to evaluation (sections 4 to 6).

The method is general. Project documents supply the details for each project: its goals, research questions, experiment definition, systems under test and noise level (section 0). This file does not supply them. Templates for every record named here are in `references/templates.md`. Two sibling skills in this plugin cover the rest: `benchmark-design` designs a new workload or benchmark from scratch, and this skill carries out the research steps on it; `research-writing` sets how every text is worded (section 10).

## 0. Load the project's research profile

The method needs facts that only the project can supply. Read them from the project's documents (AGENTS.md, CLAUDE.md, README, a research-questions or paper-outline document, campaign READMEs) and from memory:

| Fact | Used for |
| --- | --- |
| **Goals**: the quantities the project wants to improve (throughput, tail latency, peak memory, bytes moved, cost) | Every step names the goal it serves (section 4). |
| **Research questions**, and the paper sections they map to | Every experiment answers one (section 4). |
| **Experiment definition**: workload, data, parameters, inputs, outputs, hardware and resource limits | It never changes without being stated (section 6). |
| **Systems under test**, each with its baseline configuration and pinned version | Naming, ablations and extensions (sections 3 and 9). |
| **Noise yardstick**: repetitions per setting and the measured spread | Significance (sections 5 and 8). |
| **Run rules**: the fixed rules that keep the iteration fast (a deadline per run, thread count, repetitions) | The loop (section 6). Ask the user before breaking one. |

Load only what the task needs. Tightening a paragraph needs none of it. A research step needs all of it.

If a fact is missing, do not invent it. The user decides the goals, research questions, experiment definition and run rules. Draft them from what the project already shows (template in `references/templates.md`), ask the user to confirm them, and write them where the project keeps its documents. Measure the noise yardstick; do not decide it. It comes from repeated runs of an unchanged setup.

## 1. Think from first principles

Reason from what the problem physically and semantically requires. Do not start from how current systems happen to solve it. "System X does it this way" describes one point in the design space. It does not limit that space. Break the problem down in this order:

1. **State the problem as observable facts.** Say what was measured, on which setup, and with what result. Do not interpret it yet.
2. **Reduce it to quantities that cannot be broken down further.**
   - *Required work*: what any correct solution must read, compute, hold and emit, counted on the actual data (section 5).
   - *Physical limits* of the hardware, for each resource: compute throughput, memory capacity and bandwidth, storage and network bandwidth and latency.
   - *Semantic constraints*: what correctness requires (ordering, visibility, consistency, precision).
3. **Compute the bound.** For each resource, divide the required work by the resource's capacity. Time is at least the largest of those values. State is at least what the semantics require a solution to hold. This bound is the yardstick for every design, including the current one.
4. **Break the gap down** between the measured result and the bound into three parts. Size each part:
   - *redundant work*: more work than required (recomputation, repeated reads, copies, materializing what is consumed once);
   - *necessary work done slowly*: poor locality, the wrong algorithm, per-element overhead;
   - *waiting*: serialization, synchronization, idle resources, no overlap.
   Each part needs a different kind of fix (share or skip, make faster, overlap or parallelize). Choose by size, not by what is most visible in a profile.
5. **Question every constraint the current design follows.** Is it real (semantics, physics) or inherited (the plan shape an optimizer emits, an API, a file format, a layer boundary, "how it has always been done")? Inherited constraints give a new design room to change.
6. **Rebuild from the fundamentals.** Design upward from the required work. Ask which work can be shared, skipped, reordered or overlapped under only the real constraints. The design's cost is then a formula over the counts (section 5). The bound shows how much room remains.

When the gap to the bound is small for the dominant resource, that problem is solved. Move to the next one. When a design appears to beat the bound, a count or constraint is wrong. Find it before believing the result.

## 2. Top-down: define the problem and abstract its essence

Understand the problem from the outside in before building anything. Each item answers one question. Together, the answers form the characterization (template in `references/templates.md`).

1. **What is the problem?** Is it functional (the system fails, returns wrong results, runs out of memory, cannot express the workload) or about performance (correct, but too slow, uses too much memory, or costs too much)? State the concrete symptom with its measurement: "runs out of memory at 2^21 keys under a 64 GiB limit", not "does not scale". Solve a functional problem before making performance claims about the same setup.
2. **Where are its boundaries?** At which sizes, configurations and data properties does it appear? Where does it not appear? Find the threshold where behavior changes (the size at which spilling starts, the thread count at which speedup stops). A problem without a stated boundary is not yet characterized.
3. **Vary one core variable at a time and watch the bottleneck.** For each variable the problem may depend on (data size, skew, key cardinality, threads, memory budget, request rate), sweep it while keeping everything else fixed. Record which resource or stage dominates in each regime. Then ask three questions:
   - *Does the bottleneck shift, and where?*
   - *What does the shift reveal about the workload?* Data grows past memory and the bottleneck moves from CPU to spill I/O: the workload is sensitive to memory capacity. Threads grow from 1 to 32 and it moves from compute to memory bandwidth: the cost is bytes moved, not instructions.
   - *What constraint does that put on the design?* State must be bounded or partitionable; an optimization past 8 threads must cut bytes moved, because cutting instructions buys nothing there.
   An optimization aimed at one regime's bottleneck does nothing in another. The sweep tells you which regime contains the target setting.
4. **Abstract the essence.** State the problem for the workload class, not just this instance. Use a causal chain: property of the workload or data → mechanism in the system → resource consumed → symptom. Label every link (measured, counted or inferred; section 4), and leave none out:

   > Requests that share an entity need overlapping state (counted: each item of state is needed by 31 requests on average) → the join materializes that state once per request (inferred from the plan) → memory grows with requests × state size (measured over four sizes) → the system runs out of memory at 2^21 requests (measured).

   If you cannot write the chain without a gap, measure that gap next.
5. **Derive the design constraints** from the essence and the regimes. State what any solution must do, what it must avoid, and which regimes it must work in.

When several systems are characterized side by side, their failures are usually signs of the same essential problem. A system that has not failed on it yet is also exposed to it. Build a problem × system matrix. For each essential problem, mark where it was *observed* (with the symptom), where it is *latent* (the design would pay the cost at a larger scale), and where the design *avoids* it (with the feature). Reduce symptoms to essential problems by asking what property of the workload class makes every system pay this cost.

## 3. Bottom-up: solve it layer by layer

Build the solution from the simplest setup that still shows the essential problem. Then extend it one dimension at a time.

1. **Start simple.** One thread, small data, offline, one node, one query: use the smallest setup in which the essential problem of section 2 still appears. Check that it appears (count the property, or reproduce the symptom). A simple setup runs fast (section 6) and leaves fewer possible explanations for a result.
2. **Address the essence point to point.** Use one mechanism per step, aimed at one link of the causal chain. State how the mechanism changes that link's work (section 5). A change that touches three links at once cannot show which one mattered.
3. **Extend one dimension per step.** Each extension is its own step (section 4). It asks: what new problem does this dimension introduce, and does the mechanism survive it?

| Extension | New problems it introduces | Claim it adds |
| --- | --- | --- |
| one thread → many threads | contention, synchronization, load imbalance, memory bandwidth | scales in terms of cores |
| small data → large data | spilling, cache and memory capacity, skew | scales in terms of data size |
| offline batch → online serving | per-request latency, incremental updates, freshness | serves batch and low-latency use |
| one node → distributed | partitioning, shuffle, network, stragglers | survives partitioning |
| one system → other systems | architecture-specific assumptions | not tied to one system |

If two dimensions change at once, you cannot tell which caused a regression. Choose the order based on the claims the paper needs and the project's goals. The order is not fixed. A project about serving latency may go offline → online before small → large. Write the planned sequence once (template), and revise it when a step changes what is known.

**Keep four kinds of claims apart**, because each needs different evidence:

| Claim | Evidence it needs |
| --- | --- |
| **Mechanism**: this design causes this gain | Ablations within one system: add or remove one component at a time. |
| **Generality**: the design is not tied to one system | Transfer to systems with different architectures, using the same experiment definition. |
| **Scalability** in terms of a named dimension | "As <dimension> grows over <range>, <design> keeps <metric> at <cost>, on <fixed hardware>." The per-unit cost and the failure point are evidence for this sentence, not its definition. Say when a dimension was not measured. |
| **End-to-end**: the whole pipeline improves | State the boundary explicitly. Work moved to another component (a cache, a stream processor, a key-value store, a log) is displaced, not removed. Account for where it went and what it costs. Link component findings (bottom-up) to architecture costs (top-down). |

## 4. One step at a time, in this order

Every step is a record with six links. Do not skip or reorder them. The chain is the assumption → implementation → evaluation loop. Links 1 to 4 state the assumption, link 5 implements it, and link 6 evaluates it. Section 6 keeps the loop fast.

```
evidence → question → analysis → hypothesis → implementation + test → retrospective
```

- **Evidence.** A measured number, a plan, a profile, or a count from the data. Cite where it is (file, table, campaign). "It should be slow" is not evidence.
- **Question.** State the one thing this step will answer so that an answer could be wrong.
- **Analysis.** Explain how the evidence leads to a possible explanation. Name the mechanism and the link of the causal chain (section 2), not the symptom.
- **Hypothesis.** State a claim about the problem and its mechanism, with the work of the existing scheme and of yours expressed formally (section 5). Say in words what observation would contradict it ("if the shared scan is not on the critical path, removing it leaves latency unchanged"). Do not predict the numbers of the run.
- **Implementation + test.** Make the smallest change that tests the hypothesis, with one correctness gate (section 7).
- **Retrospective.** Say whether the result supports the hypothesis, and compare it with the original evidence. Name any link that is still missing. If the hypothesis is refuted, say so. A refuted step is a result.

Do not implement anything without a hypothesis. Do not state a hypothesis without cited evidence. If a goal has no evidence yet, gather evidence next. Do not implement.

**Before a step, write two sentences.** First, state the research question it answers and the one sentence it would add to the paper. Name the section where that sentence belongs. Second, state the claim for the class of workloads or systems, not just this instance. The project's tables, datasets and query parts are examples of the class; another team's setup will not have them. A change that only helps one table of one workload is engineering, not a research result. If you cannot write either sentence, the step is a side quest. Park it as an open item.

**Name the goal the step serves, by name** ("serves: lower peak memory"), not by number. A reader of a slide does not have the list.

**Label every number with its kind:** *measured* (a recorded run), *counted* (an exact count on the data), or *inferred* (from the mechanism, not measured). Do not write predicted values of a run; older records may carry a *predicted* label, which stays as written.

## 5. State the hypothesis formally: the work of both schemes, and when the sharing holds

This applies section 1 to one step. Do not predict the outcome of a run. A predicted latency, memory peak or range, and its comparison with the measurement afterward ("I predicted this size would take so long and it took 10 s more"), says nothing about the research question and does not move the work forward. Write a hypothesis about the problem, and make it checkable through work expressions, not through a forecast number.

1. **State the hypothesis** as a claim about the workload class and a mechanism. Example: the look-back retrieval of a temporal analysis workload issues redundant lookups and keeps redundant intermediate state; removing them makes it faster and more memory-efficient.
2. **Express the existing, sub-optimal scheme formally:** its complexity and its work over the workload's variables (inputs read, intermediate rows, distinct keys, output elements, bytes per element), and the state it must hold.
3. **Express your scheme the same way,** over the same variables. The ratio of the two is the redundancy the hypothesis is about.
4. **State the conditions under which the sharing (or pruning, or reuse) holds or fails,** as constraints on those variables: where the ratio is above 1, and where it falls to 1.
5. **Count the variables on the data.** Count inputs read, intermediate rows, distinct keys, output elements, bytes per element and the largest partition's share. Use a query or the system's CLI on the actual inputs. An exact count beats an estimate. The counts instantiate the expressions:
   - the work any correct plan must do, and the time bound it implies on each resource (section 1);
   - the work each candidate design does;
   - the redundancy factor: the ratio of the two;
   - lower bounds on state (a blocking operator holds at least its input);
   - the parallelism bound: 1 / the largest partition's share;
   - which resource the counts exhaust first, and at what size.
6. **Run the experiment that checks the hypothesis.** It shows whether the measured cost follows the work expressions across the conditions of item 4: it falls where the sharing holds, and it does not where the sharing fails. Compare a measured difference with the noise yardstick, so that noise is not reported as a result.
7. **Read the measurement on the critical path of the goal metric.** Summed component time (operator timers, per-thread CPU) includes waiting and work that runs in parallel with the critical path. A component with 18% of summed time can move latency by 1%. Judge the effect on the metric the goal names (latency, throughput, memory, bytes).

The hypothesis is then a claim, two work expressions and a condition. Every optimization needs a specific, observed reason (the same payload is stored eight times, so dictionary encoding stores it once). The counts and the expressions explain the measurement afterward. When the run disagrees with the hypothesis, the disagreement is the finding.

## 6. Keep the loop fast

Measure a research loop by conclusions per unit time: how many questions get a definite, quantified answer per day. Waiting is the main loss. A 10-hour end-to-end run gives one answer per working day. A 5-minute sample with the same workload characteristics gives about 120 in the same time. Each answer sharpens the next question.

- **Aim for minutes per run, not hours.** Aim for about 5 to 10 minutes in the inner loop. Full-scale runs are milestones that confirm what the fast loop found. They are not the loop.
- **Shrink by a representative sample.** Keep the characteristics the hypothesis depends on: per-entity counts, key distributions and skew, selectivities, the hot/cold ratio, the working set relative to memory. A naive slice can destroy them. A time-ordered slice of a log keeps few events per entity, so a mechanism that shares work within an entity shows no gain there. Sampling by entity hash keeps all events of a fraction of the entities.
- **Verify the sample once.** Count the characteristics on the sample and on the full data side by side (template). Check that the stage breakdown (which stage dominates, with shares) at one larger anchor matches the sample's. If the bottleneck differs, the sample answers a different question.
- **Scale resources with the data when a ratio drives the phenomenon.** If spilling matters, shrink the memory limit with the data so that spilling still happens. If contention matters, keep the threads-per-key ratio.
- **A sample is part of the experiment definition.** Record how it was drawn (rule, fraction, seed), store it, and never redraw it. Never compare sampled and full-scale numbers as if they came from one setup.
- **Run the cheapest experiment that can decide the question:** a count on the data, a microbenchmark, an analytical model, or a single stage, before an end-to-end run. If no outcome of a run would change a decision, do not run it.
- **Do not wait idle.** While a run executes, write the analysis and derivation for the next step, or prepare the next variant. Run independent experiments in parallel only where they cannot disturb each other's measurements (separate machines, or work that is not timed).
- **Fail fast.** Give every run a deadline: a fixed run rule of the project that keeps the iteration fast. Check correctness on the small setup before spending time at scale. A run that hits the deadline is recorded as a timeout, which is a result. Ask the user before breaking a run rule.

**Climb a doubling ladder** to connect the small setup with the large one.

- Shrink along the dimension the hypothesis is about. Rung *k* takes `ceil(N / 2^k)` units; each step up doubles the size.
- Count the property the hypothesis needs on each rung before trusting the rung.
- Use one run configuration per rung, fixed resource limits, a deadline, and enough repetitions for the noise yardstick.
- A system stops at its first failure or timeout; that rung is its *wall*. Do not predict the wall; the counts of section 5 say which resource it exhausts there.
- Report each rung with its counts and its measurement. Optimized variants climb the same ladder and show how much further they reach.

**The experiment definition is the experiment's identity.** Workload, data, parameters, inputs and outputs stay identical across systems and datasets unless the user decides otherwise. Never change one without saying so: not for speed, not for memory, not "temporarily". A silent change invalidates every comparison made since. If a parameter looks wrong or inconsistent, raise it with the user before any run. State in every record the definition it ran under.

**Controlled experiments isolate one variable.** Sweep it on the simplest setup in which only that variable changes, so you can read the trend directly. Keep a large or messy dataset for experiments in which size itself is the point. Do not repeat a controlled sweep on every dataset "for coverage".

## 7. One correctness gate per step, then move on

Correctness checking is a gate, not a loop. Repeatedly checking results that are already established takes time away from the step's hypothesis.

- Choose the cheapest check that catches the failure you are guarding against: a checksum of the output against a reference result, equality on a small fixture, or a mutation check (a deliberately broken version must fail the gate) where one exists.
- Run it once per step. When it passes, move on to the measurement the step is about. Do not widen it, repeat it, or add fixture families unless a result is suspicious. Then say what is suspicious.
- After a fix, rerun only the gate items the fix touches.
- Keep verifier agents focused on the claims a decision depends on.
- Side findings (a harness quirk, a nondeterministic run) become open items with a one-line note. They block the step only if they invalidate its gate.

The retrospective link in section 4 checks the hypothesis against the evidence. It is not another correctness pass.

## 8. Measure what you claim

- **Significance needs repetitions.** Give the count, the median and the spread. One run is not significant; say so. A difference inside the noise yardstick is not a result, in either direction.
- **Compare like with like.** Noise between campaigns is larger than noise within one. Compare versions interleaved in one batch, or against a band at least as wide as the cross-campaign spread. Before calling a regression, diff the two plans or configurations: identical plans mean noise.
- **Pick the measure that matches the goal:** wall time, OS CPU, peak memory or spill, bytes. Read once what each counter actually counts. Summed operator time is not wall time and is not OS CPU.
- **Cost per unit is wall divided by units.** A wall-time slope across sizes is not a per-unit cost.
- **Utilization is a result; cost is a measure.** More cores used with lower latency is scalability in terms of cores, not overhead. Report two columns: cores used (with speedup and parallel efficiency) and CPU-seconds per unit of work against the baseline. If CPU-seconds rise, say what they buy and where the extra work goes. One thread count shows nothing about scaling in cores.
- **Instruments change what they measure.** A sampler or profiler can slow the measured process (walking a process's memory maps takes its locks). Compare any new instrument against an uninstrumented run before trusting it.
- **Check units and clocks.** Check the unit before every "per X" sentence. Read log timestamps in the time zone they were written in.

## 9. Report concisely, quantified, with full context

The reader pastes these numbers into slides and decisions, and may read the chat on a phone. Use two places and two lengths:

- **The step record** (section 4, all six links) is a file: the campaign README or a step note. Write it in full there.
- **The chat reply** is the decision or the report table, plus at most five short lines: what changed, what it means, what comes next. Link the record instead of repeating it. If the reply needs a second screen, it is too long. Cut explanation before cutting numbers.

Every step report has five parts, ideally in one compact table:

| Part | What to state |
| --- | --- |
| Hypothesis | The claim and its mechanism, from section 5. |
| Work of both schemes | The formal work of the existing scheme and of yours, with the counted values, and the condition under which the sharing holds. |
| Measured | What was measured, with the unit and the number of runs. |
| Supports the hypothesis? | Yes, no or in part, and why: which condition held, which did not. If the cause of a disagreement is not yet known, say so and name the one measurement that would decide it. |
| Against the baseline | Absolute improvement (seconds, GiB, bytes per unit of work) and relative improvement (×, %). Whether the difference is significant against the noise yardstick. |

Each item in a report carries its full context: what the thing is, which component it changes and where that sits in the pipeline, which research question it answers, how the experiment was designed, the result, and the takeaway. Report new numbers only; older figures are context, labeled as such. How to word all of it is in `research-writing` (section 10).

## 10. Write it up with research-writing

All text this method produces (step records, reports, chat replies, paper, slide and note text) follows the `research-writing` skill in this plugin: the logician test, quantified comparisons, labeled numbers, descriptive variant names, no codes or internal jargon, chat replies of one screen that link the record. Read it before writing or tightening any of that text.

## 11. Working with the user

- **Stay on the approved plan.** An experiment or control the plan does not contain is a proposal, not a step. This applies even when a result suggests it. Bring the proposal with its evidence, the question it answers, its hypothesis with the work of both schemes, and its cost (template in `references/templates.md`). Keep executing the plan meanwhile.
- **Bring decisions, not status.** Worth the user's attention: which experiments answer a research question next; a path that turned out to be wrong; a refuted assumption that changes the design. Not worth it: "X gives only 1.2×, run it or not?" Whether to run something follows from the research question it answers and from section 5.
- **Ask only what is the user's to decide:** goals, research questions, the experiment definition, scope, deleting records, protocol changes. Settle interpretation questions from the project's documents or with a reviewer before asking.

## 12. Before ending a step

- For a step that opens a new problem: the problem is typed (functional or performance), its symptom is measured, its boundary is stated, the bottleneck's behavior under the core variable is swept or named as the next measurement, the causal chain has no unlabeled link, and the bound is computed with the gap split into redundant work, slow work and waiting. Any other step cites the characterization record that holds these.
- The step record has all six links, the goal it serves, the research question and the paper sentence. The extension dimension, if any, is named and only one changed.
- The hypothesis, the formal work of both schemes and the condition under which the sharing holds were written before the run; no outcome of the run was predicted.
- The run took minutes, on a sample whose characteristics were counted against the full data.
- One gate ran, once.
- The report table has the hypothesis, the work of both schemes, the measurement, whether it supports the hypothesis, baseline, significance.
- Every claim is labeled measured, counted or inferred, and each scalability claim names its dimension.
- The experiment definition is unchanged, or the user changed it.
- Open items are listed, not pursued; the next step's evidence is named.
- The chat reply fits on one screen and links the record.
- The text passes the final check of `research-writing`.
