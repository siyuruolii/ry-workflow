# AGENTS.md

Maintenance rules and non-obvious design invariants for editing `ry-workflow` itself. Read before refactoring or merging skills.

## Deliberate Design Invariants (Do Not "Simplify" Away)

- **Keep `ry-verify-create` and `ry-verify-maintain` separate:** they are intentionally distinct despite touching `.agents/skills/verify-<app>/`. `ry-verify-create` is one-time greenfield scaffolding (may flag/fix a broken build base); `ry-verify-maintain` is periodic drift upkeep with a hard boundary that **never edits product code** and must separate doc/harness drift from real product regressions. Do not merge them.
- **Keep the 6 user-invoked specialist skills manual-only:** `ry-deslop`, `ry-verify-create`, `ry-verify-maintain`, `ry-tidy`, `ry-correct`, and `ry-retro` carry `disable-model-invocation: true` and must never be auto-inserted into `ry-flow` playbooks or default routes.
- **Keep `ry-eval` unified with branch references:** general software benchmarks (`references/benchmark.md`) and AI agent/harness trace evals (`references/agent-trace.md`) share one skill (`ry-eval`) and are orchestrated by Playbooks 6a/6b in `ry-flow/references/playbooks.md`.
- **Keep every atomic `ry-*` skill standalone-installable:** any reference to a sibling `ry-*` skill must degrade gracefully if the user installed only that single skill.

## Context Economy & Progressive Disclosure Rules

- **Tight `description` budget:** frontmatter `description` is always loaded across every session (and not all hosts hide `disable-model-invocation: true` entries). Keep each description to a crisp trigger line (`<= 200` chars; total suite `<= 3,500` chars) — never dump full procedures into frontmatter.
- **True branch-only `references/`:** never split out a `references/*.md` file that every invocation must read unconditionally (that adds a round-trip without saving tokens). Only move infrequent or branch-specific material into `references/` (e.g., `ry-ship/references/worktree-cleanup.md`, `ry-review/references/deep-review.md`, `ry-design/references/tech-stack.md`, `ry-eval/references/{benchmark,agent-trace}.md`).
- **Protect target repos from scratch pollution:** any skill writing to `.scratch/` or `handoff/` must ensure those paths are ignored locally via `.git/info/exclude` (when missing from the target repo's `.gitignore`) instead of polluting shared `.gitignore` or `git status`. Do not create unsolicited `GLOSSARY.md` / `docs/decisions-*` / `DESIGN.md` files in external or team repos without consent.

## Sync & Validation Rules

| Rule | Enforced by |
| --- | --- |
| Valid YAML frontmatter, folder == `name`, `metadata.collection: ry-workflow`, `SKILL.md <= 20 KB` | `.\scripts\validate-skills.ps1` |
| Every skill `description <= 200` chars and total suite descriptions `<= 3,500` chars | `.\scripts\validate-skills.ps1` |
| Zero broken relative links in skills, `references/`, and `README.md` | `.\scripts\validate-skills.ps1` |
| Skill set stays in sync across `skills/`, `README.md`, `upstream-lock.json`, and `skills/ry-flow/SKILL.md` | `.\scripts\validate-skills.ps1` |
| Windows worktree cleanup removes reparse points/junctions before `git worktree remove` | Manual check (`skills/ry-ship/references/worktree-cleanup.md`) |

Always run `.\scripts\validate-skills.ps1` after adding, renaming, merging, or editing any skill or doc.
