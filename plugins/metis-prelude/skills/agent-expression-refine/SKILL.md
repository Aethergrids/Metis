---
name: agent-expression-refine
description: >-
  Refine English agent output, especially technical explanations, experiment reports, status updates, tables, and conclusions, into clear, standard, neutral, and evidence-calibrated language. Use when drafting, rewriting, or reviewing English agent text that contains nonstandard terminology, invented metaphors, colloquialisms, anthropomorphism, loaded headings or status labels, “X, not Y” contrast constructions, unsupported causal explanations, or forced numbers and conclusions in every table row. Also use for plain-language rewrites of an assistant message to a user.
---

# Refine Agent Expression

Rewrite English agent output as direct, precise technical prose. Preserve the facts, numbers, strength of conclusions, confirmation status, and scope.

## Workflow

1. Identify nonstandard terms, metaphors, colloquialisms, anthropomorphism, contrast constructions, and loaded labels.
2. Apply the rules below without adding analysis, numbers, causes, or conclusions that the source does not provide.
3. Check terminology, section status labels, and uncertainty statements for consistency.
4. Follow the output format requested by the user. When the user requests only a rewrite, return only the revised text.

## Core constraints

- Preserve technical meaning, causal strength, and evidence boundaries.
- Prefer established domain terminology. When an example in this skill conflicts with a standard term in the relevant domain, use the domain-standard term.
- When a cause has not been confirmed, write “Cause not established” or “The cause has not been established.” Do not add a speculative explanation.
- Do not require every table row to contain a number, comparison, or conclusion. Stop when the information is complete.
- When rewriting an assistant message into plain language, keep its facts, code, and point of view unchanged. See Rule 9.

## Rule 1: Use standard terminology

Use an established term whenever one exists.

| Source expression | Revision |
| --- | --- |
| over-length | truncation |
| whether it is over-length | whether the output reached the length limit |
| Ray's port collides with itself | Multiple Ray tasks compete for the same port. |
| arm, when it is not an established domain term | approach |
| only look at the length line | length-heuristic baseline |
| farm the reward | The reward increased while the evaluation metric did not improve. |
| archive, when referring to saved model state | checkpoint |

## Rule 2: Do not invent metaphors as terminology

When wording requires the reader to infer its referent, state the object, change, and result directly.

| Source expression | Revision |
| --- | --- |
| lineage | base-model origin |
| eight different lineages | models based on eight different base models |
| That is a size difference, not a lineage difference. | The original range comprised Qwen 14B, 32B, and 72B models. The difference came from parameter count rather than the base model. |
| It has already consumed half the space. | It already covers half of the interval. |
| It became a retriever that recognizes the question. | It degenerated into question recognition, which was unrelated to learning value. |
| The selected questions look much healthier. | The selected questions had a lower truncation rate. |
| The error range still covers the baseline. | The confidence interval overlaps the baseline. |

## Rule 3: Use neutral headings, category names, and status labels

Name the content type or factual status.

| Source expression | Revision |
| --- | --- |
| pitfalls | issues |
| costs and lessons | impact |
| how sure are we? | confirmation level |
| how it was done | experimental setup |
| how much overlap remains after picking again | overlap rate after resampling |
| how many different values | number of distinct values |
| still running | in progress |
| a switch that must be turned off | filter to disable |

Keep section status labels consistent. When an earlier section uses the following labels, continue using the same set:

- Completed
- Confirmed
- Below baseline
- Conclusion pending

When later sections use ad hoc labels such as “Got it working,” “Unexpected finding,” “Needs fixing,” or “Did not obtain the intended result,” select an existing neutral label based on the stated facts. Do not introduce another status taxonomy.

## Rule 4: Avoid “X, not Y” contrast constructions

State the check result, metric relationship, or observed difference directly.

| Source expression | Revision |
| --- | --- |
| Gradient alignment: noise, not signal. | Gradient alignment: All three checks fell within the noise range. |
| We obtained lineage diversity, but not capability diversity. | The added models covered more base-model families. Their accuracy remained below the lower bound of the original range. |
| The test does not match the way the system is used. | The evaluation used pairwise comparison, which was inconsistent with actual use. |
| Stability came from coarseness. | Metrics with fewer distinct values had higher overlap rates. |
| The more stable a metric is, the less it can select; the more it can select, the less stable it is. | Overlap rate and number of distinct values were inversely related. |

## Rule 5: Allow an entry to report only what happened

Do not add a number, comparison, or conclusion solely to make rows structurally symmetrical.

Example:

> The control group consisted of 32 randomly selected questions.

This entry is complete. It does not need an additional statement about its relationship to the other approaches.

## Rule 6: Mark an unestablished cause directly

When the cause has not been verified, write “Cause not established.” If the source has already established that boundary, do not add an unverified explanation later.

| Source expression | Revision |
| --- | --- |
| This may also explain the earlier phenomenon. | The relationship between the phenomenon and truncation has not been verified. |

Retain explanations that the source explicitly marks as confirmed. For example, retain confirmed material after a Chapter 10 section titled “The mechanism was later established.”

## Rule 7: Avoid colloquial wording

Use directly verifiable numbers, statistical concepts, and experiment descriptions.

| Source expression | Revision |
| --- | --- |
| It won decisively. | The difference was 0.030. |
| measured more accurately / more crudely | higher / lower estimation precision |
| There was very little room to choose. | The candidate range was small. |
| It was basically a lottery. | The result was close to random selection. |
| They could not be told apart anyway. | The true difference was below the resolvable range. |
| wasted run / occupied for nothing | invalid run / idle resource allocation |
| It was not free. | It required 79 GPU-hours. |
| a fatal issue | the primary issue |
| It looks like post-hoc patching. | The split was defined after the results were observed. |
| The reason is not complicated. | Remove the sentence. |
| Since prediction did not work, take a step back. | Remove the sentence and begin with the experimental setup. |

## Rule 8: Avoid anthropomorphic wording

Name the metric, process, condition, and change directly.

| Source expression | Revision |
| --- | --- |
| The signal naturally needs hundreds to thousands of samples. | Estimating the signal requires hundreds to thousands of samples. |
| Once it overflows, it creates unevenness. | Truncation increases reward variance. |
| Twenty-four training steps moved it by only 0.05. | After 24 training steps, accuracy changed by 0.05. |
| The further it exceeds the limit, the more stable it becomes. | Higher truncation rates corresponded to lower reward variance. |
| The answer content itself was uneven in quality. | Answer quality varied. |

## Rule 9: Rewrite contract for agent output

Applies when the task is a plain-language rewrite of a message an assistant wrote to a user.

- Preserve every fact, name, number, file path, command, identifier, and quoted output exactly. Simpler wording never changes content.
- Reproduce fenced code blocks byte for byte. Do not rewrite code, identifiers, paths, commands, or quoted tool output, even when the surrounding prose changes language.
- Use short sentences and everyday words. Keep established domain terms (Rule 1).
- The text is one turn the assistant wrote to the user. "I" is the assistant; "you" is the user. Keep that point of view. Do not swap roles, address the assistant, or speak as the rewriter.
- If the user's original question is supplied for context, use it only to understand the message. Do not answer, rewrite, or repeat it.
- Output only the rewritten text. No preamble, labels, or commentary.
- Language: Chinese (简体中文) and English are in scope. When a target language is named, write all prose in it, including headings, list items, and table cells, whatever the source language; code, identifiers, paths, commands, and quoted output stay as they are. When none is named, keep the source language.
- A summary, when requested, is clearly shorter than the source. It keeps key facts, decisions, numbers, and paths and drops repetition, hedging, and secondary detail. It is a simplification, not a translation.

| Source expression | Revision |
| --- | --- |
| Here is a simpler version of what the assistant said: … | Remove the preamble. |
| You (the assistant) changed the file. | I changed the file. |
| The assistant recommends running the tests. | I recommend running the tests. |
| About your timeout question, the answer is 30 s. (question supplied as context only) | Output only the rewritten message. Do not answer the context question. |
| Run the tests with `pytest -q`. (target language: Chinese) | 用 `pytest -q` 运行测试。 |

## Completion check

- Use established terminology for the relevant domain.
- State referents, metrics, and relationships directly.
- Keep headings, category names, and status labels neutral and consistent.
- Remove invented metaphors, colloquialisms, anthropomorphism, and “X, not Y” contrast constructions.
- Keep unestablished causes explicitly unestablished.
- Add no unsupported numbers, comparisons, causes, or conclusions.
- Preserve the source's facts, conclusion strength, and confirmation level.
- For a plain-language rewrite: facts, code blocks, and identifiers are unchanged; the point of view is the assistant's; the output has no preamble; prose is in the target language when one was named.
