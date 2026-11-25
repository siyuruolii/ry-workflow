---
name: ry-verify-maintain
description: "User-invoked upkeep pass to sync .agents/skills/verify-<app>/ without editing product code. / 维护项目验证 skill 与 feature map（仅手动）。"
disable-model-invocation: true
metadata:
  collection: ry-workflow
---

# Maintain Project Verification Skill

**User-invoked only.** Feature maps rot as soon as product code changes. Keep an existing project-local `.agents/skills/verify-<app>/` honest without silently hiding real product regressions. Match the user's language.

## Strict Edit Scope

Edit **only** inside `.agents/skills/verify-<app>/` (`SKILL.md`, `features/`, and its own helper scripts). **Never edit product code** during a maintenance pass: if the app no longer behaves as mapped, classify it honestly as either **doc drift** (intentional behavior change → update the map) or a **product regression** (broken app → report it to the user, never paper over it in the map).

## 1. Locate & Check Index Hygiene

1. Find the project-local verification skill under `.agents/skills/verify-*/` (if multiple exist, ask which; if none exists, stop and point to **`ry-verify-create`**).
2. Reconcile `features/README.md` against actual files in `features/` — fix missing, dead, or duplicate entries.

## 2. Parallel Source Wave (Read-Only)

Launch one read-only subagent per feature file concurrently (or run serially and note the limitation if subagents are unavailable). Each reader checks current source code and returns:
- Current user-facing behavior summary + source entrypoints (`file:line`)
- Likely doc drift vs. the feature file (or `none`)
- One concise live-verification recipe

Also sweep recent git churn for new user-facing surfaces missing from the feature map (require concrete source paths before adding candidates).

## 3. Live Pass (Required Even When Source Looks Clean)

The parent coordinator owns all live driving, following the verification skill's own `Launch` model (long-lived server/UI instance vs. fresh isolated session per CLI drive). Exercise every mapped feature at least once while holding three invariants:
1. **Doctor before trusting:** run `Doctor` before the first drive, on each fresh CLI session, and after any failed drive (reset or relaunch wedged state instead of hoping).
2. **Evidence survives cleanup:** verify captured artifacts still exist at their named paths after teardown.
3. **Zero leaked residue:** clean up processes and scratch state after failed iterations too, stopping only what this run started.

If a feature cannot be reached due to a real external prerequisite (missing OAuth token, OS, paid quota), mark it `verified-unreachable` with the attempted command and missing prerequisite (and add that prerequisite to `Gotchas` if the map omitted it).

## 4. Triage & Outcome

- **Doc drift** (outdated user-POV entrypoints/behavior) → update the feature file.
- **Harness gap** (working app behavior the driver/helper failed to exercise) → fix the helper/instructions and **re-drive it live** to prove the fix works.
- **Product regression** (app actually broken) → report to the user with reproduction steps; do not touch product code or weaken the map.

Report one explicit outcome:
- **`clean`:** all features checked against source and live runs; no changes needed.
- **`changed`:** proven verification skill / feature map corrections ready to review or ship (keep run notes in git-excluded `.scratch/`, ensuring `.scratch/` is in `.git/info/exclude` if not in `.gitignore`).
- **`blocked`:** coverage or a fix could not finish; state the exact blocker.
