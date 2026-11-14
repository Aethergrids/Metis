# dias-kit

Three method skills for experimental systems research (query engines and data
systems, storage, runtimes, distributed and ML systems). They are
project-independent: each project supplies its own goals, research questions,
experiment definition and noise level in its own documents.

| Skill | Use it to |
| --- | --- |
| `think-sharp` | Think and run research steps: first-principles decomposition, top-down problem characterization, bottom-up solution one dimension at a time, and a fast assumption-implementation-evaluation loop with hypotheses stated as formal work expressions (no predicted run outcomes), one correctness gate per step and quantified reports. |
| `benchmark-design` | Design, extend or critique an evaluation workload or benchmark, following Jim Gray's *The Benchmark Handbook for Database and Transaction Systems* (relevant, portable, scaleable, simple). |
| `research-writing` | Word every research text precisely: paper and slide text, records, reports and chat summaries of results. |

The skills point to each other: a benchmark spec from `benchmark-design` is the
input to `think-sharp` steps, and both write their text by `research-writing`.

This directory is the English Metis plugin. Install it from the repository
marketplace as `dias-kit`, or copy its skills with `scripts/install-metis.sh
--plugin dias-kit`. The Chinese counterpart is `plugins/dias-kit-zh`. Skill
names are the same in both plugins. Each skill keeps its test cases in
`skills/<skill>/evals/`.
