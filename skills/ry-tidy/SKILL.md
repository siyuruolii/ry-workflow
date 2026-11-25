---
name: ry-tidy
description: "User-invoked repo spring-cleaning: consolidate rules, cut dead code/noise, slim AGENTS.md. / 项目大扫除、清死代码、瘦身 AGENTS.md（仅手动）。"
disable-model-invocation: true
metadata:
  collection: ry-workflow
---

# Tidy

**User-invoked only.** Agents degrade as a repo accumulates duplicated rules, dead files, oversized modules, and bloated steering docs. This pass **only subtracts, consolidates, and hardens** — never adds product features. Match the user's language.

**Safety gate:** present the full proposed cleanup list (deletions, rule consolidations, hook setup, `AGENTS.md` edits) and wait for user approval before modifying files.

## 1. Consolidate Scattered Business Rules

Find business rules (permissions, pricing, state transitions, validation policies) duplicated across files. Consolidate each into one authoritative module and update callers. Leave look-alike code separate if it governs genuinely different concepts.

## 2. Strip Dead Weight

- **Dead code:** remove unreferenced files, functions, and exports after verifying zero callers.
- **Comments:** delete comments that merely restate what the code does; keep genuine *why* comments (and fix any that drifted from the code). For warning/constraint comments (e.g., `// DO NOT reorder` or `// must stay in sync`), check first whether the constraint can be **promoted into a type, runtime assertion, or lint rule** — if yes, enforce it structurally and delete the comment (see `ry-correct`).
- **Stale docs:** remove completed drafts, obsolete plans, and superseded guides (check `.scratch/` leftovers too).

## 3. File-Size Pre-Commit Hook (Default Recommendation)

Propose installing a pre-commit check (integrating into existing husky/lefthook/pre-commit if present) that rejects staged source files exceeding ~5,000 tokens (`bytes / 4`, ~20 KB) with an error instructing the author/agent to split by responsibility. Skip lockfiles, generated code, and build artifacts.

If approved, prove the hook rejects an oversized test file and passes once split; list existing oversized files for the user without splitting them unsolicited.

## 4. Slim `AGENTS.md` / `CLAUDE.md` (~100 Lines)

Keep only what the repo does, repo-specific traps, and navigation pointers to `docs/`. Remove anything obvious from directory layout, `package.json`, or `--help`; move long procedures into `docs/` or skills. Note unused global tools/MCPs for the user to toggle off manually.

## 5. Escalate Recurring Mistakes & Optional Architecture Survey

- **Recurring mistakes:** if recent commits, reverts, or `AGENTS.md` reveal mistakes agents have made twice or more, invoke **`ry-correct`** (or apply the guardrail ladder Architecture → Types/Lint/Hook → Behavioral Test → `AGENTS.md` rule table directly if `ry-correct` is not installed).
- **Optional deep-module survey:** if requested, flag shallow pass-through wrappers or tangled modules that can be deepened behind cleaner seams, and hand chosen candidates to `ry-design` (or summarize refactoring proposals directly if standalone).

## Report Format

```text
Consolidated rules: <rule> -> <path> (was N places)
Removed: N files, N lines (dead code / stale docs / redundant comments)
File-size hook: <installed location & proof, or skipped by user>
AGENTS.md: N -> N lines
Guardrails escalated via ry-correct: <summary or "none">
Existing oversized files left for user: <list or "none">
```
