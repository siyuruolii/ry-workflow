---
name: ry-correct
description: "User-invoked escalation of recurring agent mistakes into deterministic code/lint/test guardrails. / 固化防呆规则、避免重复犯错（仅手动）。"
disable-model-invocation: true
metadata:
  collection: ry-workflow
---

# Correct

**User-invoked (or called from `ry-tidy`).** When an agent repeats the same mistake a second time, change the repository so future agents cannot make it again. Match the user's language.

Assume every future agent sees only the file it opens, copies the nearest example, and takes the shortest path that compiles. Design the repo so a change that looks right locally is right globally.

## 1. Identify Mistake Classes

Fix the immediate mistake first, then scan recent commits, reverts, review comments, workaround comments, and `AGENTS.md` to group related failures into classes. A class earns a structural guardrail once it has happened twice.

## 2. Escalate at the Highest Level That Works

Pick the **strongest** level that eliminates the mistake class (stop as soon as a higher level solves it):

1. **Architecture (make it impossible):** give each state one owner and each task one supported way; hide internals so wrong imports fail; merge hand-synced lists into a single source of truth; delete legacy patterns an agent would copy.
2. **Types, lint, or hook (fail fast with the fix):** make illegal states unrepresentable, or add a lint/CI/pre-commit check whose error message names the exact replacement file, type, or API to use.
3. **Behavioral test or visual proof:** add a seam-level test (never a junk test) or require screenshot/transcript evidence for qualities machines cannot judge.
4. **Rule table in `AGENTS.md` (last resort, judgment calls only):** agents can skip prose silently, so keep a paired table:

```markdown
| Rule | Enforced by |
| --- | --- |
| Every external write tool declares a confirmation policy | `npm run check:tools` (CI + pre-commit) |
```

If a rule already sits in the table with nothing enforcing it, that proves a repeat — escalate it up to level 1–3 now. Delete any rule once its mistake can no longer happen.

## 3. Prove Every New Check

Re-introduce the real past mistake and confirm the new check **fails**; restore the fix and confirm it **passes**. A check that has never failed on the mistake it guards is unproven. Exceptions require an inline reason, expiry/condition, and explicit human approval.

## Report Format

For each mistake class: evidence of recurrence, guardrail level chosen (and why a higher level didn't fit), verification proof (red on past mistake → green after fix), and updated rule-table entry.
