# Benchmark specification template

Copy this structure. Every section stays; scale it to the scenario. A section
may be one line ("No updates in this domain; see tradeoff T3"), but a reader
must be able to see that the question was considered. Replace every `<...>`.
Numbers carry units. Define each term once and use it everywhere.

```markdown
# <Benchmark name> — specification v<0.1>

## 0. Summary card
| | |
| --- | --- |
| Decision it informs | <who decides what, with these results> |
| Use (Gray) | <different systems / software on same hardware / hardware family / releases or ablation> |
| Systems under test | <system + version + configuration name, one per row if needed> |
| Primary metric | <work per time, unit> subject to <pNN latency ≤ X ms> |
| Cost normalization | <$/hour, per core, per GiB, energy> |
| Scale points | <SF list or sizes>; comparisons only at equal scale |
| Tests | <single-stream / multi-stream / mixed with updates / cold and warm> |
| One full run takes | <wall time>; reduced configuration: <...> |

## 1. Purpose and scope
- What we want to learn: <...>
- What we are prepared to invest: <people-days, machine-hours>
- What we are prepared to give up: <...>
- Claim the benchmark can refute: <falsifiable statement with a number>
- What this benchmark will not tell us: <future performance, functionality, operability, ...>

## 2. Assumptions and open questions
| # | Assumption | Given or assumed | Effect if wrong |
| --- | --- | --- | --- |

## 3. Domain characterization (relevance evidence)
Typical operations of the domain, and where the numbers come from (logs,
surveys, production traces, papers, the user's estimate).

| Operation | Question it answers | Share or rate | Data-access pattern |
| --- | --- | --- | --- |

Access-pattern grid (Sawyer): rows = operations, columns = tables or data
structures, cells = R (random read) / U (update) / F (sequential fetch) counts.
Note which operations were merged and why.

Existing benchmarks considered and why each is or is not used.

## 4. Data
- Schema (logical; physical design is governed by section 9).
- Generator: seeded and deterministic; every system loads identical data.

| Knob | Property it controls | Default | Range swept | Why it matters for this domain |
| --- | --- | --- | --- | --- |

- Scaling rule: <one scale factor → every size; formula>.
- Generator checks: <row counts per table at SF 1, first N rows or a checksum,
  measured skew / selectivity / locality on the generated data>.

## 5. Workload
For each operation: exact definition (query text or operation semantics),
parameters and their run-time distribution, expected result size, share of mix.

Semantics and edge cases:
| Edge case | Required result | Planted by the generator as |
| --- | --- | --- |
(ties, boundaries, NULL/missing, duplicates, empty input, precision; for
time-dependent data: late-arriving and out-of-order records)

- Tests: <single-stream (power) test; multi-stream (throughput) test; updates
  concurrent with reads; cold and warm>
- Concurrency: <clients × per-client rate; think time; open or closed load>
- Interference control (if reads and writes mix): <read operations over data
  the writes never touch, run with and without the write load>
- Duration: <warm-up, measurement interval>

## 6. Metrics
- Primary: <definition, unit, constraint>.
- Price/performance: <formula>.
- Per-operation results reported: <latency percentiles, throughput, CPU, I/O,
  peak memory, spill>.
- Composite (if any): <formula>; known pathologies: <...>.
- Secondary: <load and preparation time, storage / raw-data ratio, ...>.
- Measurement point: <where the clock starts and stops>.

## 7. Execution rules
- Environment: <hardware, OS, isolation, what else runs>.
- Warm-up and steady-state criterion: <...>.
- Cold protocol: <how DB caches and OS file cache are cleared>; warm protocol:
  <iterations; which one is reported>.
- Repetitions: <n>, with the same parameter set; repeatability criterion:
  <e.g. rerun within 5 %, report the worse>. Parameter variation is measured
  separately: <across streams / sensitivity run>.
- Data between runs: <evolve or reset>.
- Timeouts and failures: <deadline; a failure at a scale point is reported as such>.

## 8. Correctness and validation
- Reference answers or checksums per operation: <how produced>.
- Consistency tests when there are updates: <...>.
- Verifiable outputs (counts, totals) each run emits: <...>.

## 9. Implementation and fairness rules
- Fixed (logical): <schema, operation text, result format>.
- Free (physical), and how it is costed or disclosed: <indexes, partitioning,
  sort order, memory settings>.
- Forbidden: <hints, rewrites, shortcuts that exploit generator artifacts, ...>.
- Tuning budget per system, fixed in advance: <...>.
- Rerun policy: <single trial / n trials, decided before the first run>.

## 10. Calibration
- Driver and network saturation test (echo or no-op operation, zero think
  time): <procedure>; required headroom: <e.g. benchmark peak ≤ 50 % of
  saturation rate>.
- Monitoring during runs: <driver CPU, SUT CPU/IO/memory>.

## 11. Experiment matrix
### 11.1 Core (must run)
| Experiment | Question | Factor varied (levels) | Held fixed | Metric | Systems |
| --- | --- | --- | --- | --- | --- |
Include only what the decision needs: the main comparison at each scale point;
a sweep of the few knobs that can change the ranking; the failure point per
system; one experiment that explains the headline difference (ablation,
per-phase breakdown, or cost-model cross-check). Wall time of one full core
run: <hours> (target: fits in a working day). Order runs cheapest first.

### 11.2 Extensions (optional, each independent)
| Extension | Question it answers | Extra cost | Run if |
| --- | --- | --- | --- |

## 12. Full disclosure checklist
Versions, configuration files, hardware, generator version and seed, operation
text, query plans, tuning applied per system, deviations from this spec, raw
per-run results.

## 13. Tradeoff log
| # | Decision | Realism lost | Simplicity or portability gained | Effect on fairness or relevance |
| --- | --- | --- | --- | --- |

## 14. Audit
| Criterion (Gray) | Evidence it holds | Where it is weakened | Conflict with |
| --- | --- | --- | --- |
| Relevant | | | |
| Portable | | | |
| Scaleable | | | |
| Simple | | | |

Benchmarketing check: <where the favoured system would lose; whether those
operations and data properties are present at real frequency; equal tuning;
whether the conclusion survives the sensitivity sweep>.

Lifecycle risks: <over-tuning to a fixed operation set; refresh plan>.

## 15. Cost of the benchmark
People-days to implement, machine-hours for the core and for each extension,
wall time per core run, and the reduced configuration used while iterating.

## Appendices
Long query text, generator details, per-system notes (native formulation,
settings, known limits, each marked "verify at version pin").
```
