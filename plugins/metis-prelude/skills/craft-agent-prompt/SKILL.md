---
name: craft-agent-prompt
description: >-
  Create, audit, simplify, or migrate system prompts, developer prompts, agent
  instructions, and prompt stacks using outcome-first contracts and measured
  evals. Use when defining an agent's goal, personality, autonomy, success
  criteria, output shape, or stop rules; removing contradictions or redundant
  scaffolding; or adapting a working prompt stack to GPT-5.6 Sol or the GPT-5.6
  family. Do not use for ordinary end-user prompt rewriting.
---

# Craft Agent Prompt

Build the smallest prompt contract that changes behavior reliably. For
GPT-5.6-specific work, re-open the current official
[prompting guide](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6)
before editing; do not rely on remembered settings or availability.

## Establish the baseline

1. Inventory the active prompt layers in precedence order, exposed tools,
   output schema, model, reasoning effort, and representative eval cases.
2. Run the existing evals before changing the prompt. Record correctness,
   completeness, tokens, latency, cost, tool calls, turns, and retries when the
   harness exposes them.
3. Name the observed failure mode. Do not rewrite a prompt merely because it is
   long or stylistically untidy.

## Write an outcome contract

Use only sections that change behavior:

```text
Role: the model's function and essential context
Personality: short user-experience choices
Goal: the user-visible outcome
Success criteria: facts that must be true before completion
Constraints: safety, evidence, permission, and side-effect limits
Tools: routing rules and prerequisites
Output: required shape, content, and task-specific length
Stop rules: retry, fallback, abstention, clarification, and completion rules
```

- Describe the destination and completion bar instead of prescribing routine
  reasoning steps.
- Preserve explicit user values. Supply decision criteria only where the value
  must be inferred.
- Reserve `always`, `never`, `must`, and `only` for genuine invariants. Express
  judgment calls as decision rules.
- Keep personality and collaboration style short and separate. Personality
  controls tone; collaboration controls assumptions, initiative, questions,
  tradeoffs, validation, and uncertainty.
- Define autonomy once: safe in-scope local actions may proceed; external,
  destructive, costly, or scope-expanding actions require confirmation.
- For editing tasks, state which facts, structure, length, genre, and tone must
  be preserved before asking for improvement.

## Simplify surgically

Remove one category at a time, then rerun the same evals:

- repeated versions of the same rule;
- style or process instructions that do not change measured behavior;
- examples that do not affect results;
- scaffolding for behavior the model already performs reliably;
- unrelated tools and tool descriptions.

Check the remaining stack for contradictions across system, developer, skill,
tool, and user layers. Prefer one authoritative statement over several nuanced
duplicates. Do not combine model, reasoning, prompt, tool-set, and runtime
changes in one experiment.

## Migrate to GPT-5.6

1. Change the model while preserving the current reasoning effort and prompt.
2. Run the baseline cases before altering instructions.
3. Remove obsolete scaffolding in isolated groups.
4. Add the smallest targeted instruction that fixes a reproduced regression.
5. Test the same reasoning effort and one level lower. Increase effort only
   after checking for a missing success criterion, dependency rule, tool rule,
   or verification loop.

Treat lower resource use as an improvement only when the output still passes
the existing acceptance checks.

## Deliver and verify

Return the revised prompt or minimal diff, the failure each change addresses,
what was removed, eval results before and after, and unresolved risks. If evals
cannot run, say so and keep the result as a proposal rather than a validated
migration.
