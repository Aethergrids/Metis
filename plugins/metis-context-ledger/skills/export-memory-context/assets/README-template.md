# <Export name>

Laid out to match the Claude memory tool so it can be merged into a project's
memory directory without reshaping.

## Layout

```
<export-name>/
├── MEMORY.md     index lines, ready to append to the project's MEMORY.md
├── memory/       one fact per file, memory-tool frontmatter schema
└── assets/       bulky reference material the memories point at
```

## Integrating

1. Copy `memory/*.md` into the project's memory directory
   (`~/.claude/projects/<project-slug>/memory/`).
2. Append the lines in `MEMORY.md` to that directory's `MEMORY.md` index.
3. Copy `assets/` somewhere durable and, if the path differs, update the
   `assets/...` references inside the memory files.

`[[<existing-memory>]]` is referenced but NOT included — it already exists in the
project's memory and covers <what>. Do not duplicate it.

## Reading order

1. `assets/<narrative>.md` — why this work exists.
2. `assets/<constraints>.md` — the constraints any solution must satisfy.
3. `assets/<schema-or-state>` — what exists today.
4. `assets/<handoff>.md` — state, next actions, resume prompt.

## Assets

| file | what it is |
|---|---|
| | |

## One-line summary

<the situation in two or three sentences, with the numbers that matter>
