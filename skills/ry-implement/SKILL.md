---
name: ry-implement
description: "Implement an approved slice or bounded edit on a task branch/worktree with pragmatic TDD. / 编写代码、隔离分支开发、TDD 实现。"
metadata:
  collection: ry-workflow
---

# Implement

Turn an agreed behavior and design into a clean, minimal code change. Works standalone from a spec, ticket, or clear instruction. Match the user's language.

Ask the user only about **product intent** (user-visible behavior, stored data, compatibility, cost, scope). Decide technical details yourself. Check `GLOSSARY.md` and relevant ADRs if present.

## 1. Workspace Isolation

Work on a task branch, never directly on the default/target branch unless explicitly assigned:
- **Assigned by a coordinator:** use the branch (and worktree, if running parallel writers) given in your brief.
- **Named by the user:** use that workspace/branch.
- **Single-agent sequential work:** continue on the current task branch, or create and switch to a new task branch in the current checkout.
- **Parallel writers (or explicitly requested):** create an isolated worktree + task branch per writer so concurrent edits never collide (`ry-ship` cleans up task worktrees safely after merge).

Leave unrelated uncommitted edits alone; if your change depends on them, report that clearly.

## 2. Change & Test Discipline

- **Subtract before you add:** delete dead code and obsolete paths in the touched area before adding new logic.
- **Data shapes first:** settle types, boundaries, and state ownership before writing control flow; keep diffs minimal (*Laziness Protocol*).
- **Pragmatic TDD:** use vertical red → green slices at public seams when the user requests TDD, for bug fixes with a cheap local target, or when public interfaces are clear. Skip mechanical test-first when the test seam is unclear or integration-heavy — still verify behavior before finishing.
- **No junk tests:** assert user-observable behavior at public seams. Never write tests that mock away the target under test, recompute expected values using the code's own logic (tautological), or break on internal renames (implementation-coupled).
- **Bug fixes:** confirm the failure before editing, fix the root cause (not a masking fallback), and add a regression test at a real seam. For stubborn or non-deterministic bugs, switch to `ry-debug` (or a disciplined repro → hypothesis → root-cause loop if standalone).
- **Dependencies & irreversible changes:** before adding a new third-party package, check whether the repo already provides the capability and verify license/maintenance fit. For `one-way` schema migrations or destructive scripts, dry-run or confirm a backup/rollback path first.
- **Strip diff noise before finishing:** remove redundant comments that merely restate the code (keep only *why* comments), unused imports/helpers, and any temporary debug logs inside your diff. (For repo-wide cleanup, the user can run `ry-tidy`.)
- **Broken design contract:** if the agreed design fails in practice, stop and report what broke and why instead of quietly hacking around it.

Run focused checks covering what you touched and its callers. Never weaken, skip, or delete an existing test to force a green run.

## 3. Commit Rules

- **Delegated by a coordinator:** do **not** commit; leave diff inspection and committing to the parent.
- **Direct invocation:** commit only if the user asked for a commit, PR, or delivery; otherwise leave changes uncommitted and say so. When committing, stage only this task's files and run the repo's pre-commit checks.

## 4. Return Report

```text
Workspace: ../wt/offline-queue (branch feat/offline-queue, base main@a1b2c3d)
Changed: src/sync/queue.ts, src/store/doc.ts, test/sync/queue.test.ts
Acceptance:
- Offline edit survives reload: met (queue.test.ts "persists across reload" passed)
- Queued edits flush once in order: met (queue.test.ts "flushes in order" passed)
Commands: npm test -- sync/queue (12 passed); npm run typecheck (ok)
Not run: e2e suite (requires staging credentials)
Deviations from design: none
Commit: none (handed to coordinator)
```

Stop at the requested outcome. Finished code does not authorize opening a PR or merging.
