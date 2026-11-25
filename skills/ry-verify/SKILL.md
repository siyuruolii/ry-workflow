---
name: ry-verify
description: "Prove agreed behavior works on the real surface (UI/CLI/API/lib) with evidence. Report-only. / 真机/CLI/浏览器验收、拿证据交差、prove it。"
metadata:
  collection: ry-workflow
---

# Verify

Verify against the **real artifact**, never a proxy (self-reports, cached output, file mtimes, unverified `--dry-run`, or "it compiles"). Acceptance checks whether agreed behavior works; it is **not** code review (`ry-review`) and **not** merge approval (`ry-ship`). Match the user's language.

**Report only — never edit implementation code here.** Send `unmet` criteria back to the owner with exact reproduction steps.

## 1. Pin Version & Pick the Real Surface

1. Pin the exact version under test (branch, commit SHA, or working tree). Reuse prior results only if they ran on this exact version.
2. If the repo already ships a project-local verification skill (e.g., `.agents/skills/verify-<app>/SKILL.md`), follow it first. (If the project grows and needs one built or refreshed, the user can invoke `ry-verify-create` or `ry-verify-maintain`.)
3. Otherwise, match the driver and proof to the **surface users actually touch**:
   - **Web / Desktop UI:** drive via real browser/Playwright on the user flow → capture action + resulting state screenshots and assert zero console errors.
   - **CLI / TUI:** run the real command/binary in an isolated working/data dir → capture exit code, terminal transcript, and real files/state written.
   - **API / Service:** verify the instance is genuinely *ready* (migrations/init done, right build), then send real requests → capture status, response body, logs, and storage side effects.
   - **Library:** invoke through public APIs with concrete inputs → verify return values, error types callers branch on, and external effects.

## 2. Proof Discipline

- **Exercise the real path + side effects:** avoid internal setters or test-only backdoors; verify both what is visible and resulting side effects (files written, rows stored, payloads sent). State the exact evidence level reached.
- **Suspect the harness first on failure:** before flagging a system defect, check whether you ran a stale build, wrong port, dirty data dir, or broken probe.
- **Script & isolate:** prefer a deterministic, rerunnable command/script in an isolated temp dir/port so you never corrupt the user's live data. If saving proof artifacts under `.scratch/verify/`, ensure `.scratch/` is listed in `.git/info/exclude` (when not in `.gitignore`). Tear down only processes/scratch dirs you started — **never delete the proof artifacts** during cleanup.
- **Reject junk tests as proof:** flag any test that mocks away the target under test, recomputes expected output from the implementation (tautological), or breaks on internal renames (implementation-coupled). *Litmus test:* breaking behavior must turn it red; renaming internals must keep it green.

## 3. Verdict Report

Classify every criterion strictly (if none were pre-defined, derive explicit checks from the user's request rather than inventing extra scope):
- **`met`:** directly observed passing on this exact version (command, output/side effects, screenshot/transcript path).
- **`unmet`:** ran and failed (exact command, observed failure, reproduction steps).
- **`unverified`:** unreachable environment/credentials/device — state why and what would settle it. Never call a failure `unverified` or an unreachable env a defect.

```text
Artifact: feat/memory-store @ 9f8e7d6 (isolated data dir)
1. Preference persists across CLI restart: met — ran `agent save-pref`, exited, restarted in same isolated dir; memory/prefs.md written and reloaded in next prompt.
2. Web settings panel updates preference: met — drove flow in browser, 0 console errors (screenshot: .scratch/verify/prefs.png).
3. Remote sync with Google Calendar: unverified — no OAuth token configured locally.
Junk-test issues: none
Failures: none
```
