---
name: ry-ship
description: "Deliver changes via visual PR, current-head CI, review gate, authorized merge, and safe cleanup. / 提交 PR、盯 CI、安全合并与清理。"
metadata:
  collection: ry-workflow
---

# Ship

Drive an implemented change only as far as the user asked: commit, open/update PR, drive CI, collect review, or merge and clean up. Start from live Git, PR, and CI state and reuse what already exists. Match the user's language.

## Non-Negotiable Rules

1. **Approval is explicit.** Silence, green CI, or passing commands never authorize merging. Merge only after the user confirms the exact PR and head SHA.
2. **Acceptance and review are separate gates.** Acceptance (`ry-verify`) checks agreed behavior; review (`ry-review`) checks failure modes and necessity. Neither replaces the other.
3. **Stop at the requested gate.** Never disable checks, bypass branch protection (`--admin`), force-push shared branches, enable carry-forward auto-merge, or run production deploys to push a change through.

## 1. Commit & PR

Deliver the task branch produced by implementation. If task changes are still uncommitted, a ship request authorizes committing them on the task branch (move off the default branch first if needed). Stage only this task's files (never stage `.scratch/` or `handoff/`), run repo pre-commit checks, and stop to ask if task edits cannot be cleanly separated from unrelated edits.

Prefer one slice/ticket per PR unless slices cannot land separately; use `Closes #123` only for fully completed issues. Write a scannable PR body:

```markdown
## Summary
<minimal diagram, diff-sketch, call tree, or file tree + 1–2 sentences on why>

## Evidence
- **Before:** <failing test / output / screenshot>
- **After:** <passing test / output / screenshot>

## Merge Danger
- **Door:** one-way | two-way (for one-way migrations/destructive changes, state backup/rollback plan)
- **Blast Radius:** <verified scope of potential impact outside the diff>
```

## 2. CI Gate

CI counts only on the **current PR head** (or merge candidate for that head). Missing, pending, cancelled, or failed expected checks do not pass. Diagnose every failure before rerunning; rerun only clearly transient failures.

If no CI workflows or required status checks exist, state plainly `CI: none configured (relying on local verification and independent review)` — never block indefinitely and never claim CI passed.

## 3. Review Gate

Every PR undergoes independent review on the pinned head before merge (run `ry-review`, or the repo's standard review process if absent):
- Judge bot and human review comments on their merits (necessity gate) rather than blindly adding defensive guards.
- Send confirmed defects back to `ry-implement` (or fix locally if standalone). Any new repair commit requires fresh CI and re-review of the changed behavior.
- Agent review never replaces required human or Code Owner approvals. If independent review cannot run, report it as pending and hold merge.

## 4. Explicit Merge Confirmation

Once acceptance passes, current-head CI is green, review is complete, and repo rules are satisfied, present PR URL, source → target branches, exact head SHA, CI/review verdicts, merge danger, and limitations. Wait for explicit user confirmation naming this PR and head (confirm each PR separately).

Re-read live head SHA and gate status immediately before merging (a new head invalidates prior approval). Merge with expected-head protection when supported (`gh pr merge --match-head-commit <sha>`) using the repo's standard merge method, and confirm the provider reports `MERGED`.

## 5. Post-Merge Cleanup & Remote Idempotency

- **Cleanup (only after `MERGED`):** for a normal task branch with no extra worktree, delete the remote/local branch only when its tip equals the merged head and it is not default, protected, integration, or used by another open PR. **If removing a task worktree (especially on Windows), read [references/worktree-cleanup.md](references/worktree-cleanup.md) first** to guard junctions/symlinks against wiping main checkout targets.
- **Timeouts / retries:** if creating an issue/PR or merging times out, query live remote state before retrying so duplicates are never created.
