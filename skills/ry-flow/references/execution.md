# Execution Records

Lightweight records that mark settled requirements, enable clean handoffs/resumptions, and back completion claims with evidence. Records never grant new authorizations or substitute for human checkpoints.

For a single small slice (`S`/`M`), a compact status block in the reply is enough:

```text
Slice: local Markdown memory read/write (spec #12)
State: implemented and verified; PR #18 CI green (or: no CI configured); independent review clean
Next: awaiting your confirmation to merge PR #18 at 9f8e7d6
```

## SPEC READY Marker

Once requirements are confirmed and the spec is saved (GitHub Issue or local `docs/plans/<topic>.md`), mark it clearly so earlier drafts cannot be confused with the settled version:
- Spec location (issue URL or file path) + links to `docs/decisions-*.md` and `docs/design/*.md`
- Agreed behavior and explicit exclusions
- Verification plan (how each criterion will be proved)
- Issue overlap check result (in GitHub mode)
- Approvals currently on record

`SPEC READY` means requirements are settled — it does **not** authorize coding or merging. If any product decision remains open, mark `SPEC NOT READY` and name the exact missing decision.

## Execution Contract (Optional)

Write one (typically inside `handoff/<YYYY-MM-DD>-<topic>.md` via `ry-handoff`) when handing work to another agent/session or saving a durable checkpoint across multi-slice work:
- Completed items with direct evidence
- Remaining items stated as observable acceptance conditions
- Current branch, head SHA, worktree path (if any), and uncommitted changes to preserve
- Required checks to run and explicit scope exclusions
- Authorizations already on record (never invent new ones)

Always verify criteria against actual code and command output, not prior claims or issue labels.

## Auditable Decision Trail (Optional — `.scratch/decisions.tsv`)

For complex migrations, multi-slice refactors, or autonomous `AFK` runs where many non-trivial technical choices happen without live supervision, append one row per meaningful judgment call to `.scratch/decisions.tsv` (ensure `.scratch/` is listed in `.git/info/exclude` if not already in `.gitignore`) so the user can audit the reasoning chain in seconds:

```text
id	slice	decision	alternatives_considered	evidence	risk	reversibility
01	slice-2	reuse single Idempotency-Key on retry	server-side content hash	retry.ts:41 + server/docs.go:88	low	two-way
```

## Delivery Receipt

Use this structure in the final reply for `M`/`L` tasks when handing off, requesting merge confirmation, or closing a task:
- **State:** `merged` | `ready-for-merge` | `partial` | `blocked`
- **Target:** branch, head SHA, PR URL (if any)
- **Acceptance:** each criterion as `met`, `unmet`, or `unverified` with evidence (commands, outputs, side effects, screenshot/transcript paths)
- **Checks:** CI/local checks tied to this exact head (or `CI: none configured`), plus anything **not** run and why
- **Review:** independent review verdict (or explicit note if independent review did not run)
- **Approvals on record:** what the user has confirmed so far
- **Principles applied:** only principles that changed an actual decision (omit if none)
- **Next / Remaining:** exact next gate or open limitation
