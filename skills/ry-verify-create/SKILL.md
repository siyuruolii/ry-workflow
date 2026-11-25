---
name: ry-verify-create
description: "User-invoked generator for .agents/skills/verify-<app>/ and user-POV feature map. / 创建项目本地验证能力与 feature map（仅手动）。"
disable-model-invocation: true
metadata:
  collection: ry-workflow
---

# Create Project Verification Skill

**User-invoked only.** Give a repository without repeatable E2E verification a project-local verification skill under `.agents/skills/verify-<app>/` (discovered natively by Codex and Antigravity) plus a user-POV feature map. Write it for a future agent reading it cold mid-task. Match the user's language.

## 1. Interview the Repo First

Discover as much as possible from code, scripts, and configs; ask the user only what cannot be observed:
- **Surface:** what users actually touch (CLI/TUI, Web UI, API/service, desktop app, library — name primary and secondary surfaces).
- **Launch:** exact command to build/start from a clean disposable data dir (including migrations/seeds) and how to prove it is genuinely *ready* (not just port-open). For short-lived CLIs, launch = build once, then run each drive in an isolated working/data dir or PTY.
- **Drive:** programmatic driver using existing repo harnesses first (Playwright, CLI binary, HTTP/curl, PTY), preferring stable handles (ARIA labels, data attributes, explicit flags/prompts) over fragile coordinates.
- **Observe:** concrete artifacts to capture (stdout/stderr/exit code, screenshots + ARIA/DOM checks, response bodies, logs, and underlying file/DB side effects).
- **Isolate:** confirm whether verification runs can use separate ports/data dirs so they never corrupt live user sessions; if not, state the single-instance lock rule explicitly.

If the repo does not build or start cleanly yet, fix or report that first — never author a verification skill against a broken base.

## 2. Generate `.agents/skills/verify-<app>/SKILL.md`

Create `.agents/skills/verify-<app>/SKILL.md` with valid YAML frontmatter (`name: verify-<app>`, concrete `description` naming the app and surface) and these grounded sections (no placeholders):
- **Launch:** exact startup/build command, isolated data dir/port setup, readiness signal, and teardown.
- **Doctor:** one read-only check proving the target instance is worth driving (process up, right build/version, isolated data dir/port owned by this run, auth valid).
- **Drive:** exact repo commands/selectors for each surface.
- **Evidence:** what proof to save and where; must exercise real user paths (not test-only backdoors), capture action + resulting state + real side effects, and verify what any `--dry-run` actually skips.
- **Cleanup:** stop only processes and scratch state this run created (never kill by generic process name); **never delete captured proof artifacts**.
- **Helpers:** any helper script shipped under `scripts/` must be executable and its exact invocation shown in `SKILL.md`.

## 3. Seed the Feature Map (`features/`)

Create `.agents/skills/verify-<app>/features/README.md` plus 3–5 initial feature files covering the app's core user-facing capabilities, following [references/feature-map-template.md](references/feature-map-template.md). Keep implementation internals out of the map — only user entry points, preconditions, commands, observable proof, and gotchas.

## 4. Prove It End-to-End Before Handing Over

Execute the newly created skill verbatim at least once: **Launch → Doctor → Drive 1 mapped feature → Capture evidence → Cleanup → Confirm proof artifacts still exist on disk**. Fix anything that breaks (and clean up failed iterations too). A generated verification skill that has never been executed end-to-end is a draft, not a deliverable.

If verified in a stand-in environment rather than the real target, list every difference as unverified. Remind the user they can run **`ry-verify-maintain`** periodically as the app evolves.
