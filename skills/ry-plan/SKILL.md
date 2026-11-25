---
name: ry-plan
description: "Turn settled requirements into a What-focused spec, GitHub Issue dedup, and vertical slices. / 写 Spec、任务拆解、Issue 去重、拆 ticket。"
metadata:
  collection: ry-workflow
---

# Plan

Produce a verifiable spec, a slice-by-slice breakdown, or both. Defaults to **GitHub Issues** when the repository has a GitHub remote/tracker; falls back cleanly to local Markdown (`docs/plans/<topic>.md`) when offline, unhosted, or requested. Match the user's language.

## Choose Storage Mode

- **GitHub Issues (default):** use whenever the repo is backed by GitHub and issue access is available.
- **Local Markdown (`docs/plans/<topic>.md`):** use when no remote tracker is configured, when drafting offline, or when the user asks for a local-only plan.

## 0. Fog-of-War Initiatives: Decision Map First (`wayfinder`)

If the initiative is too large for a single session **and** the core path or architecture is still unclear, **plan decisions — do not write a build spec or production code yet**:
- Create a tracked **Decision Map** (parent issue or `docs/plans/<topic>-map.md`) whose child tickets are bounded decision units (`research`, `prototype`, `grill`, or `design`) — each ticket outputs a confirmed decision, not implementation code.
- Clear decision tickets one by one until the fog lifts, then transition cleanly into Section 1 (Spec + Vertical Slices).

## 1. Write the Spec

Focus strictly on **What** (behavior and verification), sized to the change:
- Problem statement and confirmed goal
- Observable behavior and acceptance criteria
- Explicit exclusions (non-goals)
- Links to `docs/decisions-<topic>.md` and `docs/design/<topic>.md` (do **not** duplicate design rationale or rejected alternatives)
- Verification strategy (what proves each criterion)

Mark `SPEC READY` once settled, or `SPEC NOT READY` naming any missing product decision.

## 2. Check Issue Overlap Once (GitHub Mode)

Before publishing a new spec or ticket, search the repository's open and closed issues once for overlapping behavior:
- If plausible overlaps exist, show candidates and your recommendation so the user decides whether to reuse, extend, create separately, or drop.
- If search was incomplete (permissions/offline), state so plainly — never claim "no duplicates" without searching.
- Skip overlap check when implementing a user-supplied existing issue or writing a local-only draft.

## 3. Break Down Into Vertical Slices

Split work into **tracer-bullet vertical slices** — each slice delivers an independently verifiable piece of behavior, not an isolated horizontal layer ("all schemas", "all tests"). For large multi-session programs, group slices into explicit phases with blocking edges.

Annotate each slice with its **blocking dependencies**, **parallelizability**, and **execution mode** (`AFK` = safe for autonomous/background implementation; `HITL` = needs human-in-the-loop steering, credentials, UX judgment, or high-risk confirmation):

```text
Slice 2: Local Markdown memory read/write across restarts
Spec: #12   Design: docs/design/personal-agent-core.md
Blocked by: Slice 1 (#13)   Parallel with: Slice 3 (#15)   Mode: AFK
Behavior: user preferences saved during a session persist in local Markdown and reload on next CLI startup.
Acceptance:
- Saving a preference writes a readable Markdown entry under memory/.
- Restarting the CLI loads that preference into the next prompt context.
Excludes: vector search and automatic memory compaction (Phase 2).
```

## 4. Human Gate & Publish

Show the spec and slice breakdown and obtain explicit user approval before publishing tickets or starting implementation:
- For a single-slice change, present requirements and the slice together so the user confirms once.
- Changing scope or splitting requires renewed agreement.
- In GitHub mode, publish the spec issue first, then approved slice tickets in dependency order (a small change may combine spec and ticket into one issue). A blocker clears when its behavior exists, not merely when an issue is closed.

Return what was drafted/published, the overlap result, and approvals on record. Stop here unless execution was also requested.
