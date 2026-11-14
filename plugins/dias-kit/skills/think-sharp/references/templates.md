# Templates

Contents: project research profile · problem characterization (top-down) ·
bottom-up extension plan · step record · work accounting and bound ·
representative-sample check · report table · experiment proposal · doubling
ladder · problem × system matrix.

## Project research profile

Write this once per project, where the project keeps its documents (AGENTS.md,
CLAUDE.md or a research README), and keep it current. Goals, research questions,
the experiment definition and the run rules are the user's decisions;
mark every entry the user has not confirmed as a draft.

```markdown
# Research profile: <project>

## Goals (the quantities we want to improve)
- <name>: <metric, unit, direction>, e.g. "lower tail latency: p99 per request, ms"
- ...

## Research questions and paper sections
| Section | Research question | Sub-questions |
| --- | --- | --- |
| <subject, e.g. characterization> | <question> | <...> |

## Experiment definition (changes only by user decision)
- Workload: <operations, mix, parameters>
- Data: <sources, sizes, generator and seed>
- Inputs and outputs: <formats, sink>
- Hardware and limits: <machine, cores, memory, spill, deadline>

## Systems under test
| System | Version (pinned) | Baseline configuration | Variants |
| --- | --- | --- | --- |

## Noise yardstick
<repetitions per setting; measured spread, within one batch and across campaigns>

## Run rules (they keep the iteration fast; ask the user before breaking one)
<deadline per run, thread count, repetitions, ladder protocol>
```

## Problem characterization (top-down)

One per essential problem; it is the input to the bottom-up plan.

```markdown
# Problem: <descriptive name, stated for the workload class>

Type: <functional (fails / wrong / out of memory / cannot express) | performance (time / memory / cost)>
Symptom (measured): <number, unit, setup, source>

## Boundary and conditions
| Variable | Problem appears | Problem absent | Threshold |
| --- | --- | --- | --- |
| <data size> | <≥ 2^21 keys> | <≤ 2^20 keys> | <between; why> |

## One-variable sweeps and the bottleneck
| Variable swept (others fixed) | Range | Bottleneck per regime (resource or stage, share) | Shift at | What the shift reveals |
| --- | --- | --- | --- | --- |

## Essence (causal chain, every link labeled)
<property of workload or data> (counted) → <mechanism in the system> (inferred / measured)
→ <resource consumed> (measured) → <symptom> (measured)
Missing link, if any, and the measurement that would close it: <...>

## Design constraints
- Any solution must: <...>
- Any solution must avoid: <...>
- Regimes it must work in: <...>
```

## Bottom-up extension plan

Written once from the characterization; revised when a step changes what is
known. Each row is one or more steps; only one dimension changes per row.

```markdown
| Order | Setup | Dimension extended | New problem it introduces | Claim it adds | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | one thread, sample, offline, one node | (base) | the essential problem itself | mechanism | |
| 2 | many threads | threads | contention, memory bandwidth | scales in terms of cores | |
| 3 | full data | data size | spilling, skew | scales in terms of data size | |
| ... | | | | | |
```

## Step record

One record per step, written before the implementation starts (links 1–4) and
completed after it (links 5–6).

```markdown
# Step: <descriptive name, e.g. "shared scan for per-key histories">

Goal served (by name): <one of the project's goals>
Research question: <the question, by name>
Paper sentence: <the one sentence this step would add, and its section>
General claim: <stated for the workload class; this project's tables are instances>
Experiment definition: <the one it runs under, unchanged>

## 1. Evidence
- <number or artifact> (<measured / counted>), from <file / table / campaign>
- ...

## 2. Question
<One question whose answer could be wrong.>

## 3. Analysis
<Mechanism that links the evidence to a candidate explanation.>

## 4. Hypothesis
Claim: <a statement about the workload class and its mechanism; no predicted number of the run>
Work of the existing scheme: <complexity and work over the workload's variables; state held>
Work of our scheme: <the same, over the same variables>
When the sharing holds, and when it fails: <constraints on the variables>
Work accounting: <link or table, see below: the counted values of the variables>
What would contradict it: <in words: which observation, under which condition>

## 5. Implementation and test
Change: <smallest change that tests the hypothesis>
Correctness gate (run once): <checksum against a reference / fixture equality / mutation check>
Gate result: <pass / fail + what was suspicious>

## 6. Retrospective
Does the result support the hypothesis: <yes / no / in part; see report table>
Which links held, which did not: <...>
Missing link, if any: <...>
Open items (parked): <...>
Next step's evidence: <...>
```

## Work accounting and bound

Counted on the actual inputs before the run, once checked against a recorded
value as the gate. The hardware rows turn required work into a bound (first
principles, section 1 of SKILL.md).

```markdown
| Symbol | Meaning | Count | How counted |
| --- | --- | ---: | --- |
| N | <input units read> | | <query / CLI> |
| D | <distinct keys> | | |
| P | <output elements> | | |
| w | <bytes per output element> | | |
| s_max | <largest partition's share of the work> | | |

| Derived quantity | Formula | Value |
| --- | --- | ---: |
| Work any correct plan must do | <...> | |
| Work done by <design A> / <design B> | <...> | |
| Redundancy factor | <work done / required work> | |
| Lower bound on state | <e.g. P × w for a blocking aggregation> | |
| Parallelism bound | 1 / s_max | |
| First resource exhausted, and at what size | <counts vs limits> | |

| Resource | Capacity (measured or spec) | Required work on it | Bound = work / capacity |
| --- | --- | ---: | ---: |
| Memory bandwidth | <GB/s> | <bytes moved> | <s> |
| Storage / network | <GB/s> | <bytes> | <s> |
| Compute | <ops/s> | <ops> | <s> |
| Memory capacity | <GiB> | <lower bound on state> | fits / does not fit |

Bound on time: <max of the bounds>. Measured: <s>. Gap: <×>, split into
redundant work <share>, necessary work done slowly <share>, waiting <share>.
```

## Representative-sample check

Run once per sample, before the sample carries any conclusion.

```markdown
Full data: <source, size>. Sample: <rule (e.g. entity hash), fraction, seed, stored at>.
Resource limits scaled with the data: <e.g. memory limit × fraction, or "not needed because ...">

| Characteristic the hypothesis depends on | Full | Sample | Match? |
| --- | --- | --- | --- |
| <events per entity, median / p99> | | | |
| <key skew: largest key's share> | | | |
| <selectivity of the filter> | | | |
| <working set / memory limit> | | | |

| Stage breakdown (share of wall) | Sample | Anchor at <larger size> | Same dominant stage? |
| --- | --- | --- | --- |

Run time: sample <min> vs full <h>: <n> iterations per full run.
```

## Report table

One table per step. Keep the prose to a few lines around it.

```markdown
| | Value |
| --- | --- |
| Hypothesis | <claim and mechanism> |
| Work of both schemes | <formal work of the existing scheme and of ours, counted values, the sharing condition> |
| Measured | <number, unit, n runs, median ± spread> |
| Supports the hypothesis? | <yes / no / in part; which condition held; if unknown, the one measurement that would decide> |
| vs <System> Vanilla, absolute | <seconds / GiB / bytes per unit of work> |
| vs <System> Vanilla, relative | <× or %> |
| Significant? | <yes/no, with n, spread and the noise yardstick; "single run, not significant"> |
```

## Experiment proposal

For anything the approved plan does not contain. It goes to the user before it
runs.

```markdown
# Proposal: <descriptive name>

Research question it answers: <question>; paper sentence it would add: <...>
Evidence that motivates it: <numbers with their kind and source>
What it can prove or refute: <...>
Hypothesis: <claim>; work of the existing scheme and of ours: <formal expressions, counted values>; when the sharing holds: <condition>
Cost: <machine hours, engineering days, disk>
Decision needed from the user: <one sentence>
```

## Doubling ladder

```markdown
Source: <dataset>; dimension: <what is doubled>; rung k = ceil(N / 2^k) <units>, sliced by <rule>.
Property the hypothesis needs, counted per rung: <e.g. events per entity>.
Limits: <memory, spill, deadline>; repetitions: <n>.
Run configuration: <fixed parameters>.

| Rung k | Units | Property count | Work (from counts) | Measured (median, n) | Status |
| --- | ---: | ---: | --- | --- | --- |
| 17 | ... | ... | ... | ... | ok |
| ... | | | | | |
| 14 | ... | ... | ... | ... | wall: spill cap / OOM / timeout |
```

The wall is the first failing rung. Write the scalability claim as "as
<dimension> grows over <range>, <design> keeps <metric> at <cost per unit>, on
<fixed hardware>; it fails at <rung> when <resource> is exhausted".

## Problem × system matrix

```markdown
| Essential problem | Mechanism | <System A> | <System B> | <System C> |
| --- | --- | --- | --- | --- |
| <name> | <why every system pays it> | observed: <symptom> | latent | avoided by <design> |
```

Mark each cell as **observed** (with the symptom), **latent** (the design would
pay it at a larger scale), or **avoided** (with the design feature).
