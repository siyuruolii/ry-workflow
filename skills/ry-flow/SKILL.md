---
name: ry-flow
description: "Route multi-stage dev workflows, playbooks, and human gates across ry-* skills. / 统筹完整开发工作流、按任务路由阶段、继续未完成任务。"
metadata:
  collection: ry-workflow
---

# ry-flow

Optional coordinator for the `ry-workflow` skill suite. It sizes the task, routes to the right stages, carries confirmed context and engineering principles across stages, and enforces human gates. Each stage's detailed method lives in its own `ry-*` skill.

Match the user's language in replies and deliverables unless they ask for another language.

## Stage Catalog (Pipeline & Utility — 13 Skills)

| Stage | Skill | Owner |
| --- | --- | --- |
| Requirement alignment & inline decision docs | `ry-grill` | Parent (talks with user) |
| Internal codebase & git/PR/ADR history | `ry-investigate` | Parent (small) or read-only subagents (broad) |
| External official docs, SDKs, specs | `ry-research` | Networked subagent (or parent fallback) |
| Tech stack & architecture/interface design | `ry-design` | Parent (direct) or 2+ blind candidates converged by parent |
| Spec, GitHub Issue dedup, vertical slices | `ry-plan` | Parent |
| Scoped coding on branch / parallel worktrees | `ry-implement` | Parent or implementation subagents |
| Bugs & performance regressions | `ry-debug` | Parent or dedicated debugger |
| Acceptance check against real surface | `ry-verify` | Parent owns verdict (report only, no edits) |
| Benchmarks, perf, algorithm & AI agent eval/tuning | `ry-eval` | Parent owns metric/trace loop & report; delegates edits |
| Independent defect/security/spec/standards review | `ry-review` | Independent finder(s) + separate verifier |
| PR, CI, authorized merge, safe cleanup | `ry-ship` | Parent |
| Human- and agent-facing technical documents | `ry-write` | Whoever is writing (when doc is the deliverable) |
| Cross-session handoff (`handoff/`) & recall | `ry-handoff` | Parent |

### User-Invoked Specialist Skills (6 Skills — Never Auto-Trigger)

Do **not** insert these into a workflow automatically; run them only when the user explicitly asks:
- `ry-deslop` — UI visual subtraction pass (aesthetic taste belongs to the user)
- `ry-verify-create` — Generate a project-local `.agents/skills/verify-<app>/` skill & feature map
- `ry-verify-maintain` — Audit and sync an existing project-local verification skill & feature map
- `ry-tidy` — Repo spring-cleaning, 5,000-token hook proposal, `AGENTS.md` slimming
- `ry-correct` — Escalate recurring agent mistakes into deterministic guardrails
- `ry-retro` — Post-session retrospective to improve repo guardrails and skills

Read each active stage's `SKILL.md` before running it and pass its path to delegated workers. If a needed `ry-*` skill is missing, report which one is missing and stop that stage rather than improvising. If another skill shares a name, prefer the one with `metadata.collection: ry-workflow`.

## Size First (Avoid Over-Ceremony)

Pick the smallest tier that matches real risk before routing:
- **`S` (Trivial / localized):** single file, `<= ~30` changed lines, clear behavior, reversible `two-way`, no auth/persistence/schema/external-write impact → edit directly and run focused verification; skip formal planning, design bakeoff, independent multi-finder review, and full Delivery Receipt unless requested.
- **`M` (Standard slice / bug / PR):** `<= ~150` changed lines and `<= 5` files, reversible `two-way` → single task branch, direct `ry-design` (if needed), `ry-verify`, and **1 independent finder** in `ry-review` before `ry-ship`.
- **`L` (0→1, multi-slice, `> ~150` lines / `> 5` files, or `one-way` / high-risk):** full playbook, 2+ blind `ry-design` candidates on contested forks, parallel worktrees for unblocked `AFK` slices, parallel `ry-review` finders + `deep-review.md`, and `ry-handoff` boundaries between heavy phases to guard context.

## Route the Request

State briefly the tier (`S/M/L`), where you start, which playbook applies, and where you will stop. Load references **only when needed**:
- [playbooks.md](references/playbooks.md) — step-by-step stage orchestrations (including `AFK`, Agent Eval, prototypes, stacked PRs).
- [principles.md](references/principles.md) — 18 steering principles (cite only principles that changed an actual decision).
- [coordination.md](references/coordination.md) — parent/worker ownership, worktree integration, Codex vs. Antigravity host fallbacks, and cross-model second opinions.
- [execution.md](references/execution.md) — `SPEC READY` markers, optional execution contracts, `.scratch/decisions.tsv`, and Delivery Receipt.

| Request type | Route | Default stop |
| --- | --- | --- |
| Unsettled feature or 0→1 project | `ry-grill` (or `ry-plan` Decision Map first if foggy) → `ry-design` → `ry-plan` | Behavior agreed and breakdown approved, before coding or publishing |
| Approved spec / ticket(s) | `ry-implement` (branch, or DAG worktrees → integration branch) → `ry-verify` | Behavior accepted, or earlier stop set by user |
| Autonomous / overnight `AFK` batch | Playbook 8 (`ry-implement` in worktrees → `ry-verify` → `ry-review` → `ry-ship` PR stack, `pause-safely`) | Verified PR stack awaiting Gate 3 merge confirmation |
| Novel UX / unfamiliar SDK / design spike | Playbook 9 (disposable `.scratch/prototypes/` → record takeaway → discard spike) | Hypothesis proven/falsified and takeaway logged |
| Multi-phase / stacked PRs | Playbook 10 (`ry-plan` phases → stacked branches → sequential Gate 3 merges + rebases) | Active phase/PR verified and awaiting Gate 3 |
| Clear, bounded small edit (`S`/`M`) | `ry-implement` → `ry-verify` (skip ceremony for `S`) | Verified local edit |
| Bug or perf regression | `ry-debug` → `ry-verify` | Root-cause fix verified |
| General perf / algorithm / benchmark tuning | Playbook 6a (`ry-eval` with `benchmark.md`) | Before/After benchmark report reviewed by user |
| AI agent / tool / prompt / RAG / harness eval & tuning | Playbook 6b (`ry-investigate` → bootstrap trace/eval set if missing → `ry-eval` with `agent-trace.md`) | Before/After trace report reviewed by user |
| Review / design interrogation only | `ry-review` | Verified findings, blast radius, and minimal repair directions |
| Existing branch to deliver | `ry-ship` | PR, CI, or authorized merge as requested |
| Documentation or skill deliverable | `ry-write` (Playbook 11 for authoring/iterating a `SKILL.md`) | Drafted/validated document or skill |
| Session switch or resume | `ry-handoff` | Saved brief in `handoff/` or live current-state + blocker summary |

Skip stages whose outputs are already settled: agreed requirements, approved designs, existing tickets, and valid approvals carry forward.

## Non-Negotiable Gates

1. **Three human approvals.** Only the user confirms: (a) requirements & scope, (b) ticket/plan breakdown (combined with requirements for single-slice work), and (c) merging a specific PR head. Silence, green CI, or passing tests never count as approval.
2. **Separate verification from review.** `ry-verify` checks whether agreed behavior works; `ry-review` hunts for where it can still fail. Report them separately; neither replaces the other.
3. **Product vs. technical ownership.** Take product decisions (user-visible behavior, kept data, safety boundaries, compatibility, cost, scope) to the user. Make internal technical decisions yourself unless the user wants to choose.
4. **Honest status reporting.** Keep `merged`, `ready-for-merge`, `partial`, `blocked`, and `unverified` distinct. Never present unverified work as done.
5. **Stay within the requested stop.** A request to discuss, plan, edit locally, or open a PR stops there unless the user authorizes the next gate.

To resume interrupted work, inspect live Git, tracker, PR state, and the latest `handoff/` or `docs/decisions-*.md` notes, then continue from the first unmet gate. A new commit head invalidates prior CI, review, and merge approval for the changed behavior.
