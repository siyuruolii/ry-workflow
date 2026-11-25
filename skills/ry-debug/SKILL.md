---
name: ry-debug
description: "Diagnose bugs, flaky failures, and perf regressions via fast root-cause path or 5-phase loop. / 疑难排错、Debug、偶现复现、性能退化。"
metadata:
  collection: ry-workflow
---

# Debug

A disciplined diagnosis loop for non-trivial bugs and performance regressions. Match the user's language.

**Fast path (obvious single-point errors):** when a stack trace or error message points unambiguously to a single clear defect (e.g., typo, missing parameter, obvious bad condition), skip the full five-phase ceremony — confirm the failure, fix the **root cause** (never a band-aid workaround or silencing guard), and verify. Escalate immediately to the full five-phase loop below if the cause is unclear, flaky, a performance regression, or a first fix does not resolve it.

**Redact secrets first:** mask tokens, passwords, and auth headers as `<REDACTED>` in every command, log snippet, or captured artifact you display.

## Phase 1: Build a Tight Red Feedback Loop

**Do not theorize or read code speculatively before a red repro command exists.** Build a fast, deterministic, agent-runnable command that goes red on the user's exact symptom:
1. Failing unit/integration/e2e test at the seam that reaches the bug
2. HTTP/curl or CLI invocation against a fixture or dev server
3. Headless browser script asserting on DOM, console, or network
4. Replayed trace/payload, throwaway harness, differential run, or `git bisect run`

**Tighten it:** make it fast (seconds, not minutes), sharp (asserts the exact symptom, not just "no crash"), and deterministic. For flaky bugs, increase the reproduction rate (loop 100×, stress concurrency, narrow timing windows) until it fails reliably.

If you genuinely cannot construct a loop, stop, list what you tried, and ask the user for environment access, a redacted artifact (HAR/log/dump), or permission to add temporary instrumentation.

## Phase 2: Reproduce & Minimize

Run the loop and confirm it reproduces the **exact** user-reported symptom. Then shrink inputs, config, callers, and steps one cut at a time until every remaining element is load-bearing (removing any one turns the loop green).

## Phase 3: Ranked Falsifiable Hypotheses

Generate **3–5 ranked hypotheses** before testing any of them. Each must state a falsifiable prediction:
> "If `<cause X>` is responsible, then `<intervention Y>` will make the symptom disappear (or `<Z>` will worsen it)."

Share the ranked list briefly in your progress update and proceed immediately to testing in rank order (do not block waiting for confirmation).

**Attack the Premise:** if two fixes sharing one assumption fail the same gate, stop patching — write that assumption down and test it directly.

## Phase 4: Targeted Instrumentation

Test one variable at a time against a specific hypothesis prediction:
- Prefer debugger/REPL inspection or pinpoint boundary logs over "log everything and grep".
- Tag every temporary log with a unique prefix like `[DEBUG-a4f2]` so cleanup is a single search.
- **Verify probe landing:** when temporarily editing code or fixtures to test a hypothesis, confirm the change actually executed in the running build/path before trusting a red or green result.
- **Performance regressions:** establish a repeatable baseline measurement first (timing harness, profiler, query plan), then bisect — measure before optimizing.

## Phase 5: Root-Cause Fix & Cleanup

1. **Check the test seam & watch it fail first:** turn the minimized reproduction into a regression test at a real seam that exercises the actual failure pattern (e.g., do not fake a multi-caller bug with a shallow single-caller unit test) and **watch it fail red before applying the fix**. If no valid seam exists, record that architectural gap explicitly rather than writing a misleading test.
2. Fix the **first place** the system went wrong (*Fix Root Causes*), not a downstream band-aid, and confirm the regression test turns green.
3. **Re-run the original Phase 1 un-minimized feedback loop** (not only the shrunk test) plus focused checks to prove the user's real symptom is gone.
4. Remove all `[DEBUG-*]` tags and temporary scratch harnesses.
5. Report: exact winning root-cause hypothesis (carry this into the commit/PR description for future engineers), evidence, minimal fix, regression test added (or missing-seam finding), and whether this mistake class has recurred (if yes, recommend `ry-correct` to encode a guardrail).
