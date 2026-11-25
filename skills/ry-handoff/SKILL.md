---
name: ry-handoff
description: "Save a redacted handoff brief under handoff/ or reconstruct live git/PR context on resume. / 会话交接、跨工具续做、恢复现场、handoff。"
metadata:
  collection: ry-workflow
---

# Handoff & Recall

Keep multi-session and cross-tool work (e.g., switching between Codex and Antigravity) sharp without losing confirmed decisions or re-deriving state. Pick the mode that fits the request. Match the user's language.

## Mode 1: Handoff (Compress for Next Session)

Use when context grows long or work moves to a fresh session/tool:
1. Save a concise Markdown brief under `handoff/<YYYY-MM-DD>-<topic>.md` in the workspace. If `handoff/` is not in `.gitignore`, add `handoff/` to local `.git/info/exclude` (preferred so shared `.gitignore` stays untouched) or confirm with the user so transient handoff notes are never accidentally committed.
2. **Redact all secrets** (API keys, tokens, passwords, private URLs, PII) as `<REDACTED>` before writing.
3. Link existing artifacts (`docs/decisions-*.md`, `docs/design/*.md`, `docs/plans/*.md`, `GLOSSARY.md`, issues, PR URLs, commit SHAs, file paths) instead of duplicating their contents.
4. Include:
   - Goal, confirmed product decisions, and explicit exclusions
   - Live Git state (branch, head SHA, active worktree path if any, uncommitted edits to preserve)
   - Verified facts vs. open questions/blockers
   - Exact next gate/step and **Suggested Skills** (`ry-*` skills the next session should load first)
5. Return the saved file path and a 5-line summary in chat.

## Mode 2: Recall (Resume / Catch Up)

Use when returning to an in-progress task or multi-branch work ("where did I leave off?", "catch me up", "what needs my input?"):
1. Inspect live repository state (`git status`, recent commits, active branches/worktrees), open PRs/issues/CI (if applicable), and the latest files in `handoff/`, `.scratch/decisions.tsv`, and `docs/decisions-*.md`.
2. Return a tight current-state brief:
   - What is confirmed, verified, or landed since the last checkpoint (grouped by branch/worktree/PR if multiple are active)
   - **Action items needing your decision right now** (surface human-blocking gates, open product questions, or PRs awaiting Gate 3 merge confirmation upfront)
   - Exact next unmet gate to resume from.
