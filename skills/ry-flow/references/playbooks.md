# Task Playbooks

Pick the playbook matching the request, state tier (`S/M/L`), start, and stop, and skip settled stages. Stage-internal details live in each `ry-*` skill — follow each active stage's `SKILL.md`. Never auto-trigger user-invoked specialist skills (`ry-deslop`, `ry-verify-create`, `ry-verify-maintain`, `ry-tidy`, `ry-correct`, `ry-retro`).

## 1. New Feature or 0→1 Project (Unsettled Behavior)

1. `ry-grill` *(or `ry-plan` Decision Map first if too large/foggy for one session)*: align on product decisions and MVP scope; pull in `ry-investigate` (existing code) and/or `ry-research` (external docs) on factual questions. *(Gate 1: user confirms requirements.)*
2. `ry-design`: tech stack (`references/tech-stack.md` if greenfield/new infra) + module architecture (direct for routine; 2+ blind candidates for high-stakes/contested forks).
3. `ry-plan`: What-focused spec linking decision/design docs, GitHub Issue dedup, and vertical slices annotated with `Blocked by`, `Parallel with`, and `Mode: AFK / HITL`. *(Gate 2: user confirms breakdown before publishing or coding.)*
4. *(Recommended for `L` tasks)* Save a clean `ry-handoff` checkpoint or delegate slices to fresh workers so implementation starts with a clean context window.
5. `ry-implement` → `ry-verify` → `ry-review` (send confirmed defects back to `ry-implement` and re-verify) → `ry-ship` *(Gate 3: explicit merge confirmation)*.

## 2. Bug Fix or Performance Regression

1. `ry-debug` (fast root-cause path for obvious single-point errors; five-phase loop for unclear, flaky, perf regressions, or failed first fixes).
2. `ry-verify` against the real user surface.
3. `ry-review` → `ry-ship` (if opening/merging a PR). If this mistake class recurred, mention that the user can invoke `ry-correct`.

## 3. Bounded Small Change (`S` / `M`, Behavior Clear)

1. Clarify any single missing product edge case briefly.
2. `ry-implement` → `ry-verify`.
3. For `S` tier local edits, stop here with concise proof. For `M` tier or PR delivery, add `ry-review` (1 independent finder) → `ry-ship`.

## 4. Refactoring (Behavior-Preserving)

1. `ry-investigate`: map callers, invariants, and existing test coverage first.
2. Delete dead code and obsolete paths first (*Subtract Before You Add*).
3. For non-trivial boundary changes, run `ry-design` before `ry-implement` in small verifiable steps.
4. `ry-verify` (observable behavior preserved) → `ry-review` → `ry-ship`.

## 5. PR Babysit and Delivery

1. Inspect live Git, PR, CI, and review threads before acting.
2. `ry-ship`: drive missing CI, diagnose failures before rerunning, judge review comments via `ry-review`'s necessity gate.
3. After any repair commit, collect fresh CI and re-review the changed behavior on the new head.
4. Request Gate 3 merge confirmation on the pinned head SHA, merge, and clean up safely.

## 6a. General Benchmark & Optimization (`ry-eval` + `benchmark.md`)

Use for general software latency, throughput, build speed, memory, algorithm accuracy, or library swaps:
1. `ry-eval` (load `references/benchmark.md`): audit or bootstrap a realistic deterministic benchmark harness, freeze it, and capture Baseline + regression gate.
2. Run single-variable controlled iterations logged in `.scratch/eval/decision.tsv` and produce the Markdown report.
3. Once the user approves promoting the winning change: `ry-review` → `ry-ship`.

## 6b. AI Agent, Tool, Prompt & Harness Eval & Tuning (`ry-eval` + `agent-trace.md`)

Use when building, debugging, or optimizing an AI agent project (tool schemas/descriptions, system prompts, RAG/memory retrieval, planner/loop harness):
1. **Audit observability (`ry-investigate`):** inspect whether the repo already has (a) structured queryable run **Traces** (inputs, tool calls/args/results, errors, steps, tokens/latency) and (b) a repeatable **Eval Set** covering core tasks and past failure modes.
2. **Bootstrap if missing (stop before tuning):** propose to the user and build the minimal foundation first via lightweight `ry-design` → `ry-implement`:
   - Instrument lightweight local trace logging (JSONL/SQLite, secrets redacted).
   - Seed an initial frozen eval set from real tasks + past failures and prove it separates good runs from broken ones.
   - Capture Baseline traces and metrics on the frozen eval set (plus safety/confirmation regression checks).
3. **Run controlled tuning (`ry-eval` with `references/agent-trace.md`):**
   - Lock target metrics (task pass rate, tool-selection accuracy, retry/error rate, steps, tokens/latency), repeat count `n`, and safety gates.
   - Change **one** harness/prompt/tool variable per iteration, log every kept/reverted trial in `.scratch/eval/decision.tsv`, verify behavior from real traces (never self-report), and enforce strict A/B blinding for any LLM-as-a-judge grading.
   - Deliver a human-reviewable Markdown report (plus standalone single-file HTML side-by-side trace report for 10+ cases or deep tool chains) showing representative wins **and** every regressed/failing case.
4. **Promote after user review:** once approved, run `ry-review` (check tool safety/confirmation boundaries & blast radius) → `ry-ship`.

## 7. Cross-Session Handoff or Resume

1. **Handoff:** `ry-handoff` Mode 1 → secret-redacted brief in `handoff/<YYYY-MM-DD>-<topic>.md` linking existing artifacts + suggested next `ry-*` skills.
2. **Resume:** `ry-handoff` Mode 2 → live Git/PR/worktree state + latest `handoff/` & `docs/decisions-*.md` → surface human-blocking items upfront and resume from first unmet gate.

## 8. Autonomous / Overnight `AFK` Run & Safe Pause

Use only for approved slices marked `Mode: AFK` with objective, machine-checkable completion criteria (never auto-merge — stop at Gate 3):
1. **Lock run contract upfront:** base SHA, approved slices, exact check commands, isolated worktree per concurrent slice, circuit-breaker limit (stop a slice after 2–3 failed repair attempts on the same root cause), and hard prohibitions (no merge, no destructive external writes, no scope expansion).
2. **Per-slice pipeline:** `ry-implement` (isolated worktree) → `ry-verify` → `ry-review` → `ry-ship` (open PR + check CI; stop before Gate 3).
3. **Audit trail:** append non-trivial technical choices to `.scratch/decisions.tsv`.
4. **Pause Safely (`pause-safely`):** whenever context nears limits, a circuit breaker trips, or an unexpected product decision surfaces, leave every worktree in a clean Git state (no half-merges or dangling processes) and write a `ry-handoff` brief recording verified PRs, exact failing check/question, and next unmet gate.

## 9. Disposable Prototype / Spike

Use for novel UX, unfamiliar SDKs, or contested forks where running code settles the question faster than debate:
1. State 1–2 hypotheses to prove/falsify and what success looks like.
2. Build 1–3 minimal throwaway prototypes in `.scratch/prototypes/` (ensure `.scratch/` is in `.git/info/exclude`) or a disposable spike branch — never mix spike code into production paths.
3. Run the real interaction/benchmark and capture concrete observations.
4. Log the takeaway in `docs/decisions-<topic>.md` or `docs/design/<topic>.md` (or chat if external repo), then **discard/isolate the spike** before implementing cleanly via `ry-plan` → `ry-implement`.

## 10. Multi-Phase Program & Stacked PRs

1. `ry-plan`: start with a Decision Map (`wayfinder`) if the destination is foggy; once clear, group slices into deployable, independently verifiable, reversible phases.
2. **Topology:** converge tightly coupled slices of a phase onto one feature integration branch (DAG ready-frontier parallel worktrees → single PR), or stack dependent PRs (`B` off `A`, document `Base: <branch-A> / PR #A`, diff scoped to Slice B).
3. **Stacked rebase order:** once PR A merges (after Gate 3), rebase PR B onto updated default branch, re-run `ry-verify` + fresh CI/review on PR B's new head, then request Gate 3.

## 11. Authoring or Iterating a Skill (`SKILL.md`)

1. Draft/edit via `ry-write` (Section 3: *Writing for Agents* — tight descriptions, true branch-only progressive disclosure, positive checkable criteria).
2. Trial the skill on a realistic task prompt to catch trigger gaps or over-ceremony.
3. Run repo validation (`.\scripts\validate-skills.ps1`) to verify frontmatter, description budget, size limits, and links before shipping.
