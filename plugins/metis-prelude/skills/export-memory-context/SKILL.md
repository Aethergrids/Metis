---
name: export-memory-context
description: >-
  Export durable context from a long session into a directory laid out like a
  Claude memory store — one fact per file with memory-tool frontmatter, an
  appendable MEMORY.md index, and bulky material in assets/. Use whenever the
  user asks to export, hand off, archive, or "write down" what was learned so
  another session or teammate can pick it up; whenever they mention memory
  layout, the memory tool, or want context organized so it can be merged into a
  project's memory directory; and whenever a long investigation produced facts
  that would be expensive to rediscover. Prefer this over a single long handoff
  document whenever the receiving side is an agent rather than a human reader.
---

# Export memory-aligned context

A long session accumulates two very different things: a narrative of what
happened, and a set of durable facts that changed what anyone should do next.
A single handoff document mixes them, which is fine for a human skimming once
and poor for an agent that needs to recall one fact six weeks later.

This skill produces the second form: a directory shaped like a Claude memory
store, so it can be merged into a project's memory directory without reshaping,
while the narrative and bulky evidence stay beside it as assets.

## Read the destination before writing anything

The export is only useful if its files can be dropped into the target memory
directory with no editing. So derive the conventions from that directory rather
than from this skill: open `~/.claude/projects/<project-slug>/memory/`, read its
`MEMORY.md` and two or three of the fact files, and match exactly what you find —
the filename pattern, the frontmatter fields, the index line format, the body
structure.

This matters because conventions carry details a skill cannot know: a type
prefix on filenames, a provenance field like `originSessionId`, a `modified`
timestamp, whether index links are bare filenames or paths. In testing, agents
given only a template produced files that looked subtly foreign beside the real
ones and dropped provenance entirely, while agents who read the destination
first matched it. A schema written into a skill also goes stale the moment the
tool changes, and differs between projects.

If you genuinely cannot see the destination — you are in a subagent, or the
target project has not been named — say so plainly in the README, use the shape
below as a fallback, and tell the receiving reader to reconcile before copying.
Do not silently normalise toward either convention.

## The layout

```
<export-name>/
├── MEMORY.md     index lines, ready to append to the project's MEMORY.md
├── memory/       one fact per file, matching the destination's conventions
└── assets/       bulky material the memory files point at
```

The shape below is the fallback when no destination is visible. Where it
disagrees with the destination, the destination wins:

```markdown
---
name: <short-kebab-case-slug>
description: <one line, written so a future agent can judge relevance from it alone>
metadata:
  node_type: memory
  type: project | reference | feedback | user
---

<the fact, stated up front>

**Why:** <what made this true — only for project/feedback>
**How to apply:** <what a future agent should do differently — only for project/feedback>

Related: [[other-memory-name]]
```

`MEMORY.md` holds one line per file in the index format the destination uses —
commonly `- [Title](file.md) — hook`. Note that the real index usually lives
*inside* the memory directory as a sibling of the fact files, so its links are
bare filenames rather than `memory/`-prefixed paths; check, because an index
whose links don't resolve after copying defeats the purpose. The hook should
carry the fact, not just a topic, so recall works from the index alone.

## Choosing what becomes a memory

The test is not "was this important during the session" but **"would a future
agent make a worse decision without it, and would rediscovering it be
expensive?"** Most of a session fails that test.

Strong candidates:

- **Measurements that overturned an assumption.** These are the highest-value
  memories, because the wrong assumption is the one a fresh agent will re-derive
  by default. Record the number and the thing it refuted.
- **Designs that were tried and refuted.** Without these, the next session
  proposes them again. Say what was measured, not just that it failed.
- **Constraints discovered the hard way** — a consumer that can't supply a
  required predicate, an API whose tag appears only after a run starts, a
  library that accepts a form in tests and rejects it in production.
- **Decisions with a rationale that isn't visible in the code.**
- **State a fresh agent could damage by acting on a stale belief** — e.g. a
  completed backfill it might restart.

Weak candidates, usually skip: narrative of what happened, anything the repo
already records, transient status, and your own reasoning process.

**One fact per file.** The temptation is to write a chapter per topic. Resist it:
recall pulls whole files, so a file covering five facts wastes context on four of
them every time it matches. If a file needs a second heading, it is two memories.

This applies hardest to *sets* — three ruled-out theories, four rejected designs,
five failed configurations. Bundling them feels tidy and is usually wrong. The
test is the question that retrieves them: an agent asks "was the retry-storm
theory ever checked", not "recite the dead ends", so each theory is its own file
with its own evidence. Bundle only when the members are genuinely inseparable —
when knowing one without the others would mislead.

## Writing the description line

The description is the only thing a future agent sees when deciding relevance,
so write it as a claim, not a label. `"Join pruning notes"` is a label.
`"Joining the task profile by id costs 0.90 GB with a date hint and 76 GB
without; behavioral events cannot supply the date, so a key-derived band is
required"` is a claim — an agent can act on it without opening the file.

## Linking, and not duplicating

Use `[[other-name]]` freely between the exported memories, and also to memories
that already exist in the target project. A link to a name that doesn't exist
yet is fine — it marks something worth writing later.

Before writing a file, check whether the target project's memory already covers
it. If it does, **link to it and do not restate it.** A divergent copy of a
memory that has since been corrected is worse than no copy, because both will
surface at recall time and the reader has no way to tell which is current. Say
so explicitly in the README: name the memory you deliberately did not duplicate.

## What belongs in assets/

Anything too large or too structural to be a fact: schema dumps, SQL, the
narrative handoff, plan documents, ledger extracts, benchmark output. Memory
files reference them by relative path (`assets/current-schema.sql`).

Prefer copying these in rather than referencing paths inside a repository that
may move or change. The export should still make sense if the repo is at a
different commit.

## The README

Write a short `README.md` covering: the layout, three-step integration
instructions, a table of what each asset is, any memory deliberately not
duplicated, and a one-line summary of the situation. Put a reading order in it —
a receiving agent should not have to guess which file establishes the problem
and which one records the state.

## Before finishing

- **Scan for credentials.** Grep the whole export for keys, passwords, tokens,
  and connection strings. Name the credential's source (`the pixai_… key in
  .env`) instead of its value, and say plainly that it must not be copied into
  documents.
- **Check every fact is verified, not inferred.** Anything you believe but did
  not confirm belongs in the README as an open question, not in `memory/` as a
  fact. Exported memories get trusted precisely because they are exported.
- **Re-read each description in isolation.** If it does not convey the fact
  without the body, rewrite it.
- **Count the files.** More than a dozen or so usually means facts were split
  too finely or narrative crept in.

## Portability to other agents

The content is portable — plain Markdown with YAML frontmatter, and `[[links]]`
degrade to literal text. The *loading* is not: Claude Code recalls from the
memory directory automatically, while Codex, OpenCode and Cursor read
`AGENTS.md` files found by walking up from the working directory and will not
discover a `memory/` folder on their own.

If the export needs to serve those agents, add an `AGENTS.md` at the export root
listing each memory file with its one-line description and an instruction to
read the relevant one before acting. That keeps the one-fact-per-file structure
and its selective recall, which concatenating everything into a single file
would lose.

## Worked shape

For a database table redesign that spanned days of investigation, the export came
out as roughly a dozen memories plus assets holding the DDL, the write-path SQL,
the narrative and a ledger extract. Each memory answered a different question a
future agent would arrive with: what is the objective, why is the layout wrong,
what did the normalization measurement show, what is the storage hazard, what do
joins cost, which precedence rule must be preserved, what is the state of the
backfill, what remains open.

Three separate memories recorded three refuted designs — one each — because the
question that retrieves them is "was approach X already tried", not "list
everything we rejected". Splitting them is what makes the answer arrive without
the other two attached.
