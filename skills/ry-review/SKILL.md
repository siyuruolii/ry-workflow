---
name: ry-review
description: "Independently review diffs, PRs, or designs for defects, blast radius, standards, and spec compliance. Read-only. / 代码审查、PR Review、找缺陷。"
metadata:
  collection: ry-workflow
---

# Review

Hunt for where the current change (or proposed design) can still fail, what outside the diff it might break, whether it violates repo standards, and whether it matches the spec. Acceptance (`ry-verify`) checks whether agreed behavior works — an acceptance pass is **not** a review. Match the user's language.

**Read-only:** report verified findings, empirical blast radius, and minimal repair directions. Do not edit code, post PR comments, or merge unless explicitly asked.

> **Branch reference:** For **high-risk code paths** (auth, payments, persistence, migrations, destructive tools), **large diffs (> ~150 changed lines or > 5 files)**, or **Design Doc Interrogation (`docs/design/*.md`)**, also read [references/deep-review.md](references/deep-review.md) for red-team interrogation and the Fowler smell checklist.

## 1. Pin Target & Gather Context

1. Resolve an exact base and head (`git diff <base>...<head>` and `git log <base>..HEAD --oneline`), snapshot uncommitted changes, or pin the exact design doc. Fail early if the ref is invalid or empty.
2. Locate the originating spec/ticket (if any — a missing spec never blocks reviewing clear behavior) and repo standards (`CODING_STANDARDS.md`, `CONTRIBUTING.md`, `AGENTS.md`).

## 2. Independent Discovery

Use a finder that did **not** write the change (prefer a different model family/host when available). If independent subagents are unavailable, state plainly that independent review is incomplete — never label a self-review as independent. Keep scratch probes outside the implementation tree (ensure `.scratch/` is in `.git/info/exclude`).

Scale effort to diff size: **1 independent finder** for small/bounded diffs (`<= ~150` lines, non-critical paths); **parallel independent finders** (by lens or risk area) for larger or high-risk diffs.

- **A. Defects, Security & Failure Paths:** trace a real trigger through pinned code (`file:line` at SHA), broken invariant, existing protections checked, and separate severity from confidence. For tool-using, network, or file-handling code, check secret leakage, command/prompt injection, path traversal, and bypassed confirmation gates. Imagined future callers are not present defects; zero findings is valid.
- **B. Spec Compliance (when a spec exists):** flag missing/partial requirements, unrequested scope creep, or subtle divergence (quote the spec line).
- **C. Standards & Diff Hygiene:** repo standards always override heuristics; skip anything automated linters/formatters enforce. Flag obvious AI diff noise (comments restating code, dead helpers, leftover debug logs).
- **D. Empirical Blast Radius & Reversibility:** inspect **untouched** callers, shared schemas/configs, persisted state, and downstream consumers; run real caller/typecheck/migration checks instead of guessing. Classify `one-way` vs. `two-way` door (flag missing backup/rollback plans on `one-way` changes) to feed `ry-ship`'s `Merge Danger`.

## 3. Separate Counterevidence Verification

Merge findings sharing one root cause, then verify each defect candidate independently from the finder — actively seek **counterevidence**:
- Does the path exist at the pinned SHA and can supported callers reach it?
- Does an earlier validator, type invariant, lock, or transaction already prevent it?
- Does any reproduction truly prove the claimed mechanism?

Classify strictly: **Confirmed defect** | **Unresolved question** (name the settling check) | **Rejected** (cite counterevidence) | **Future suggestion** (do not turn into a required task).

## 4. Repair Necessity Gate

A confirmed issue does not automatically justify adding a guard, fallback, retry, shim, or abstraction:
- State what current behavior it protects and why it belongs here instead of the root source.
- Prefer fixing the root cause, reusing an existing mechanism, or deleting wrong logic over layering defensive guards. Escalate product/compatibility changes to the user.

## 5. Report Format

```text
Pinned diff: main@a1b2c3d ... feat/offline-queue@9f8e7d6

Confirmed defects (blocks ready-for-merge):
1. [High severity / High confidence] Duplicate write on retry
   Trigger & path: queue.flush -> saveDoc -> withRetry (src/sync/queue.ts:57 creates new Idempotency-Key per attempt).
   Violates: acceptance criterion 2 ("server receives each queued edit once").
   Protections checked: server dedupes on Idempotency-Key, so fresh keys bypass it.
   Evidence: scratch test returning one 503 produced 2 server inserts.
   Smallest repair: generate the key once on enqueue and reuse across retries.

Spec check: 0 missing / 0 scope creep
Blast radius & door: two-way (verified `test/sync/*` and 3 callers of `saveDoc` pass; schema untouched)
Standards & smells: 1 judgment call (unused backoffStrategy param in src/sync/retry.ts:12)
Unresolved questions: none
Rejected findings: 1 (null docId in flush — prevented by non-null parse at store/doc.ts:19)
Future suggestions: none
```

Only confirmed defects and real spec/hard-standard violations trigger repairs. An unresolved confirmed defect blocks `ready-for-merge`. When dispatched by a coordinator, report to it.
