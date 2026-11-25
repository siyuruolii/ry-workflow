---
name: ry-investigate
description: "Trace internal codebase behavior and git/PR/ADR history with primary evidence. Read-only. / 调研已有代码行为、追踪调用链、查历史原因。"
metadata:
  collection: ry-workflow
---

# Investigate

Explain how the current codebase behaves and why, backed by primary evidence. This skill is strictly read-only and scoped to the repository's own code and history (use `ry-research` for external docs, libraries, or APIs). Match the user's language.

## 1. Execution & Subagent Policy

- **Small targeted lookups** (1–2 known files, a single call chain, or a quick `git blame`): run directly in the main thread.
- **Broad or multi-subsystem searches** (spanning many directories, deep git history, or parallel questions): dispatch read-only subagents with fresh context windows so bulk file reads stay out of the main thread. If subagents are unavailable, run in the parent.

## 2. Trace Behavior & History

1. Read `GLOSSARY.md` and relevant ADRs first (if present) so terms match the project's domain model.
2. Trace the real execution chain in code: entrypoints, callers, data shapes, state ownership, failure paths, and existing protections. Record the exact branch and commit SHA read.
3. Check available history (`git log`, `git blame`, commit messages, linked PRs/issues, ADRs, incident notes) to find why constraints exist, and state whether each old constraint still applies.

## 3. Evidence Discipline & Output

Return a concise report directly in chat (or to the parent coordinator) — **do not** save summary files into the repo, since the codebase and git history remain the single source of truth.

Strictly separate four categories; missing history is an **unknown**, never room to invent a rationale:
- **Documented:** recorded in commits, PRs, issues, or ADRs (cite path/ID).
- **Observed:** directly verified in current code or output (`file:line`, commit SHA).
- **Inferred:** reasoned conclusion drawn from observed facts (state the premise).
- **Unknown:** missing code or history, plus how to verify it if needed.

```text
Question: Why does save retry at most 3 times?
Read at: main@a1b2c3d
Observed: SaveButton.onClick -> api/save.ts saveDoc -> retry.ts withRetry(max=3) -> POST /docs/:id.
  Server dedupes on Idempotency-Key (server/docs.go:88).
State ownership: client owns pendingSave (store/doc.ts); server owns document version.
Documented: PR #212 capped retries after duplicate writes on flaky networks.
Inferred: retries stay safe only while withRetry reuses the same key (retry.ts:41).
Unknown: whether mobile clients send Idempotency-Key (repo not present locally).
```
