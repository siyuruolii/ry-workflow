---
name: ry-retro
description: "User-invoked post-session retrospective to improve repo guardrails, docs, and ry-* skills. / 会话复盘、迭代 skill、改进工程环境（仅手动）。"
disable-model-invocation: true
metadata:
  collection: ry-workflow
---

# Retro

**User-invoked only.** After finishing a milestone or tricky session, audit the agent's working environment and workflow skills so the next run has less friction. Match the user's language.

## 1. Ground in Session Evidence

Review the current session (or the transcript/commits the user specifies) plus the repo's existing check scripts (`package.json`, Makefile, CI workflows, hooks) and steering files (`AGENTS.md`, `CODING_STANDARDS.md`, relevant `ry-*` skills).

## 2. Audit Six Leverage Areas

1. **Navigation:** files, modules, or hidden dependencies that took too long to locate → candidate one-line pointer in `AGENTS.md`.
2. **Automated checks & guardrails:** mistakes a lint, typecheck, pre-commit hook, or CI check could have caught (check existing unwired scripts before inventing new ones). Hand recurring mechanical mistakes to **`ry-correct`** (or propose a deterministic check directly if standalone).
3. **Standards vs. checks:** separate mechanical rules (build a deterministic check) from genuine judgment calls (record in `CODING_STANDARDS.md` for `ry-review`, not `AGENTS.md`).
4. **Steering-file bloat & no-ops:** oversized `AGENTS.md` or rules that never changed agent behavior → prune or move behind pointers (follow `ry-write`'s agent-doc rules, or call `ry-tidy` if installed for a full cleanup).
5. **Tool & context economy:** expensive or noisy tool calls that can be streamlined or delegated to subagents.
6. **Skill tuning:** concrete, minimal wording edits to any `ry-*` skill whose instructions caused ambiguity, premature stopping, or unnecessary ceremony.

## 3. Present Ranked Candidates & Apply Only Approved Edits

Report findings ordered from highest to lowest severity, each with: observed friction, concrete proposed edit, and target file. Wait for user approval before modifying repo files or skills.
