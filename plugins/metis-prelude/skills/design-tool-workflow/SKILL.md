---
name: design-tool-workflow
description: >-
  Design or audit agent tool sets, function tools, MCP tools, retrieval routes,
  and Programmatic Tool Calling stages. Use when deciding which tools to expose,
  writing tool descriptions, sequencing prerequisites, choosing direct versus
  programmatic calls, bounding retries and fallbacks, defining citation or
  evidence requirements, or reducing large tool results to a compact schema.
---

# Design Tool Workflow

Design the route from evidence to action before polishing tool descriptions.
Use the current official
[GPT-5.6 prompt guidance](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6)
and [Programmatic Tool Calling guide](https://developers.openai.com/api/docs/guides/tools-programmatic-tool-calling)
for model- or API-specific details.

## Define the contract

Capture:

- the user-visible outcome and required evidence;
- allowed reads, writes, and approval boundaries;
- prerequisite discovery and validation steps;
- the final output schema and citation requirements;
- retry, fallback, handoff, and stop conditions.

Expose only tools relevant to that contract. Each description must state what
the tool does, when to use it, important inputs and return fields, side effects,
and meaningful error behavior. Remove generic encouragement to use tools
"efficiently."

## Route calls

- Complete required retrieval and validation before an action even when the
  intended final state seems obvious.
- Run independent reads in parallel. Keep dependent calls sequential and
  synthesize parallel results before acting.
- On empty, partial, or suspiciously narrow results, try one or two meaningful
  fallbacks. Do not loop through cosmetic query variants.
- Keep approval, semantic judgment, citations, and final validation in direct
  model control.

## Choose direct or programmatic calling

Use direct tool calls when one call is enough, intermediate results are small,
each result can change the next decision, approval is involved, citations or
native artifacts must be preserved, or semantic judgment is required between
calls.

Use Programmatic Tool Calling only for a bounded deterministic reduction stage,
such as filtering, joining, sorting, ranking, deduplication, aggregation,
batching similar records, repeated validation, or shrinking large structured
results. Define all of:

- eligible tools, normally read-only;
- exact result schema including evidence fields;
- retry limit, normally no more than two transient retries;
- stop condition and resource budget;
- one handoff back to direct model judgment.

Do not let the workflow switch routes repeatedly or redo completed work.

## Set a retrieval budget

Start ordinary grounded Q&A with one broad search using short discriminative
terms. Retrieve again only when a required fact, source, date, owner, identifier,
or citation is missing; exhaustive comparison was requested; a named artifact
must be read; or a material claim remains unsupported. Do not search again only
to improve wording or add nonessential detail.

Require citations only from retrieved sources, attach them to supported claims,
label inference, surface source conflicts, and narrow the answer when evidence
is missing. Lack of evidence is not automatically evidence of absence.

## Verify both contracts

Test the structured tool or `program_output` result and the final assistant
message separately. The reduction can be correct while the final response drops
a required field, citation, or caveat. Compare direct and programmatic routes on
the same cases; accept resource savings only when both outputs satisfy the
contract.
