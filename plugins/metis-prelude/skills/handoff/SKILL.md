---
name: handoff
description: >-
  Create a compact, artifact-first transfer of the current task for another
  agent or a fresh task. Use when explicitly asked to prepare a handoff,
  continue in a fresh context, branch with a fork, or delegate the next bounded
  phase, including a lightweight background assignment. Capture verified state,
  decisions, next actions, and suggested skills; redact sensitive data; and
  write a portable Markdown fallback to the OS temporary directory.
---

# Handoff

Transfer durable task state without carrying forward a noisy transcript. Treat
using roughly two-thirds of a context window as a proactive handoff heuristic,
not a proven quality boundary. When the surface reports context usage, inspect
that value instead of estimating from transcript length.

## Choose the transfer mode

Treat text following the skill invocation as the next task's focus. Preserve it
verbatim as an input, then tailor the handoff around it.

Use the narrowest mode the user requested:

- **Portable document (default):** Write the handoff and return its path. Do
  not create another task or agent when the user did not request one.
- **Fresh task:** Prefer this when the goal is to reclaim context. Create a new
  task only when the user explicitly asks for one, and seed it with the handoff
  rather than the full transcript.
- **Fork:** Use a native fork control when the user wants an alternate branch
  that retains the source history. A fork copies history, so it does not by
  itself reclaim context.
- **Background sub-agent:** Use only for explicitly requested, bounded
  delegation, especially a lightweight background assignment. Send the handoff
  plus a concrete deliverable and stop condition, not the transcript.
- **Same task:** When the user wants more room without transferring ownership,
  use or recommend the surface's native compaction control. Keep the handoff
  document as a recovery point when useful.

Do not confuse a context transfer with a product control that merely moves the
same task between a local checkout and a worktree.

## Gather ground truth

Inspect only the evidence needed to resume safely:

1. Capture the user's objective, the optional next-session focus, current plan,
   completed work, decisions, blockers, and unresolved questions.
2. Inspect repository or system state when relevant: repository root, branch,
   commit, working-tree status, changed files, verification results, and active
   background work.
3. Locate authoritative artifacts such as specs, plans, ADRs, issues, commits,
   diffs, logs, and generated outputs.
4. Separate observed state from inference. Do not convert an unverified claim
   from the conversation into a fact.

Keep command output bounded. Do not load large diffs, logs, or datasets into
context merely to make the handoff exhaustive.

## Write the document

Resolve the operating system's temporary directory and write a uniquely named
file such as `handoff-YYYYMMDD-HHMMSS.md` there. Never place the generated
handoff in the current workspace. If policy prevents writing to the OS temporary
directory, return the document inline and report that it was not saved; do not
silently choose a workspace path.

Use this structure, omitting empty sections:

```markdown
# Handoff: <next focus or current objective>

Generated: <UTC timestamp>
Next focus: <user-supplied focus or "Continue the current objective">

## Objective
<desired outcome and acceptance criteria>

## Current state
<what is complete, in progress, and not started>

## Decisions and constraints
<decisions that must survive the transfer, with brief rationale>

## Artifacts and ground truth
- Repository: <portable repository reference>
- Branch / commit: <branch and commit>
- Working tree: <clean, or concise changed-file summary>
- <path or URL>: <why it matters>

## Verification
- <command or check>: <result and timestamp when relevant>

## Next actions
1. <highest-value next step and its verification>

## Risks, blockers, and open questions
- <item, owner or required decision, and impact>

## Suggested skills
- `$skill-name`: <why and when the next agent should invoke it>

## Resume prompt
<short imperative prompt telling a fresh agent what to read, do, and verify>
```

Reference existing artifacts instead of reproducing them. Summarize why an
artifact matters, not its contents. Prefer repository-relative paths for files
inside the repository, `~` for the home directory, and stable URLs or identifiers
for remote artifacts. List changed files and a diff command instead of embedding
the diff.

In **Suggested skills**, name only skills known to be available, use their exact
invocation names, and explain their relevance. Put them in intended invocation
order when order matters. Write `None identified` instead of inventing a skill.

## Redact before transfer

- Never include secret values, credentials, tokens, cookies, private keys,
  passwords, or sensitive environment-variable contents. Name the required
  secret or configuration source without its value.
- Remove unnecessary personal data. Replace names, email addresses, phone
  numbers, account identifiers, and user-specific home-directory prefixes with
  neutral labels when they are not essential to resumption.
- Do not inspect credential stores or dump the environment for the handoff.
- Scan the completed draft for common credential forms and accidental log or
  clipboard content before saving or sending it.

## Complete the transfer

Always create and verify the document before opening a destination.

- For a **fresh task**, send a concise prompt that points to the document, names
  the next focus, asks the agent to verify ground truth, and tells it to invoke
  the suggested skills. If the destination is remote, containerized, or otherwise
  lacks access to the local temporary directory, or if access cannot be confirmed,
  send the redacted handoff body directly through the supported prompt or
  attachment channel. Do not paste the prior transcript.
- For a **fork**, create the fork only after the document exists. Forks may copy
  completed history but omit the active handoff turn, so send the destination a
  follow-up containing the handoff path and next focus. State that the fork
  preserves history and is not a context reset.
- For a **background sub-agent**, provide one bounded objective, allowed scope,
  acceptance checks, output contract, stop condition, and the handoff path. Keep
  the source agent responsible for integrating and verifying the result.
- For a **portable-only handoff**, return the verified path and a one-sentence
  description of the intended next focus.

Do not archive, delete, commit, stash, or otherwise mutate the source task or
working tree unless the user explicitly requests it. Report the document path,
the chosen transfer mode, and any destination task or agent identifier.
