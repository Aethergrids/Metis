---
name: research-writing
description: "Rules for precise, quantified scientific writing about systems and their measurements: paper sections, abstracts, slides, captions, research notes, experiment READMEs, step records and chat summaries of results. Use it whenever the task is to write, tighten, review or translate research text, report numbers in prose, name variants of a system, or summarize results for the user, including 'tighten this paragraph', 'write the evaluation section', 'make this slide text precise', 'summarize the results', 'is this claim well supported'. Also use it when text drifts into vague adjectives, hyperbole, anthropomorphism, undefined symbols, experiment codes or internal jargon. The rules hold in every language the text is written in."
---

# Research writing

Research text is scientific writing, not poetry. The test: a hostile, careful
reader (a logician, a reviewer) reads the sentence, can derive exactly one
meaning from it, and can check that meaning. The idea in the writer's head does
not count; only the written text does. Use fewer words and more examples.

The rules below hold in every language. In Chinese, for example, 显著, 大幅,
明显 and 远超 need a number and a basis just as "significant" and "much faster"
do.

## 1. The rules

| Rule | Instead of | Write |
| --- | --- | --- |
| **Be precise.** Name the component, the dataset, the size, the measure. | "The join is slow on the bigger data." | "At scale factor 100, the hash join's build phase takes 58% of summed operator time." |
| **Quantify.** Every comparative word needs a number and a unit. | "Much faster, with lower memory." | "1.24× lower latency (212.4 → 171.3 s, median of 3); peak memory 41.2 → 38.9 GiB." |
| **Use the active voice.** Name the actor, so the reader knows who did it and who is accountable for the claim. | "The data was filtered and a speedup was observed." | "The rewrite filters rows before the join; latency drops 19%." |
| **No anthropomorphism.** Systems, optimizers, operators and plans do not want, think, try, know, decide, prefer, see, struggle or suffer. Describe what the component does, with the mechanism. | "The optimizer wants to sort first." / "The engine doesn't know the input is sorted." / "The window operator struggles with skew." | "The optimizer places the sort below the join." / "The plan carries no sortedness property for this input, so the engine sorts again." / "With skewed keys, one partition holds 40% of the window's rows." |
| **No hyperbole.** Superlatives and intensifiers are claims without evidence. | "A dramatic, massive improvement that solves the memory wall." | "Peak memory falls 6%; the largest input that completes grows from 2^20 to 2^21 keys." |
| **Be consistent.** One term per concept, defined once, used everywhere: in prose, tables, figures and code. A second word for the same thing reads as a second thing. | "lookup point" in one paragraph, "probe" in the next, "query point" in the table. | "lookup point" throughout, defined at first use. |
| **Objective arguments.** Every "therefore" must follow from stated evidence; say "we infer" or "assuming" where it does not. | "So the bottleneck is clearly the merge phase." | "The merge phase is 39% of operator time after the change (inferred: the optimized run was not profiled)." |
| **Define symbols where they appear.** In chat and slides, every time; in a paper or record, at first use and in a symbol table. | "P grows faster than D." | "P (output positions) grows 4× faster than D (distinct keys)." |
| **State the boundary of a claim.** A result holds on the setup that produced it. | "The rewrite removes the memory problem." | "On one node with a 64 GiB limit, the rewrite completes up to 2^22 keys; larger inputs were not run." |
| **Name the regime.** A bottleneck belongs to a range of some variable. | "The system is memory-bandwidth bound." | "From 8 threads upward, the scan is memory-bandwidth bound (38 of 41 GB/s used); below 8 threads it is compute bound." |
| **Claim for the class, cite the instance.** A paper's claim must hold for the class of workloads or systems; this project's tables and datasets are examples of it. | "Our rule speeds up the price lookup." | "For lookups into versioned tables, the rule removes the per-request sort (in our workload, the price-history table: 1.4× lower latency)." |

## 2. Numbers in text

- Put the number in the same sentence as the claim it supports. A topic sentence
  with an adjective and the evidence two sentences later reads as an unsupported
  claim.
- Say in the same sentence when a number is an estimate, an inference or a
  single run. "About", "roughly" and "significant" each need their basis
  (significant: the number of runs and the spread against the noise).
- Give both the absolute and the relative difference ("212.4 → 171.3 s, 1.24×").
- Keep the unit with the number. Check the unit before every "per X" sentence:
  cost per unit is the total divided by the units, not the slope of a total.
- Name what a counter measures: "share of summed operator time" is not wall time
  and not OS CPU.
- Report new numbers; older figures appear only as context, and are labeled
  as such.

## 3. Names and labels

- **Variants are named by what they are:** `<System> Vanilla` for the stock
  default, then `<System> + <optimization>`. A build is not a version.
- **No experiment or question codes** (J1, S2, RQ3, H1, E8) anywhere a reader
  will see them. Name the thing ("the padded-versions experiment", "the stage
  breakdown"). If a cross-reference to a file needs a code, put it in parentheses
  after the description, once. Before sending, search the text for `\b[A-Z]\d\b`
  and `RQ\d`.
- **No internal jargon.** Labels that agents, panels or scripts coin ("arm",
  "gate", "lane", "track B") mean nothing to the reader. Describe the version by
  what it changes ("filters versions before the join instead of after it") and
  the check by what it checks ("output checksums equal").

## 4. Chat replies and records

Two places, two lengths. The reader pastes numbers into slides and decisions
and may read the chat on a phone.

- **The record** (a step note, a campaign README, a report) is a file and holds
  everything: setup, numbers, derivations, caveats.
- **The chat reply** is the decision or one table, plus at most five short
  lines: what changed, what it means, what comes next. Link the record instead
  of repeating it. If the reply needs a second screen, it is too long; cut
  explanation before cutting numbers.
- **Short does not mean cryptic.** For each item, say what the thing is, which
  component it changes and where that sits in the pipeline, which question it
  answers, how the experiment was designed, the result, and the takeaway. A
  reader who missed the last three sessions should understand it.

## 5. Deliver text that can be sent as is

When a fact is uncertain, write the most defensible version and flag the
uncertainty after the text, rather than leaving a blank, a placeholder or a TODO
inside it. When tightening someone's text, keep its claims and numbers; change a
claim only to make it match its evidence, and say which claims you changed.

## 6. Before sending

Reread the text once as a logician:

- every comparative word has a number, a unit and a basis;
- every actor is named, and nothing anthropomorphizes a machine;
- every symbol is defined where it appears;
- one term per concept;
- no codes, no internal jargon;
- every claim states its boundary, and every "therefore" follows from stated
  evidence;
- the chat reply fits on one screen and links the record.
