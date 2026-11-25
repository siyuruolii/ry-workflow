---
name: ry-write
description: "Write or edit human- and agent-facing docs (README, ADR, AGENTS.md, SKILL.md) with zero AI slop. / 写技术文档、润色 README、去文档 AI 味。"
metadata:
  collection: ry-workflow
---

# Write

Write for the named reader's concrete task while preserving exact meaning, evidence, and uncertainty. Use when the document itself is the deliverable. Match the user's language.

## 1. Pick the Document's Job (Diátaxis)

- **Tutorial:** walk a first-time user to a visible working result.
- **How-to:** concrete steps and preconditions for a specific task.
- **Reference:** scannable facts organized where readers expect them.
- **Explanation:** bounded rationale, tradeoffs, mechanisms, and evidence.

Lead with what the reader can do or understand. For a README, show a concrete first command or prompt and real example before internal rules; link deeper reference docs instead of bloating the front page.

## 2. Cut AI Slop, Keep Precision

- Use real project symbols, file paths, commands, and observed outputs. Replace vague adjectives with mechanisms, numbers, examples, or decisions.
- Cut zero-information filler: canned openings ("In today's fast-paced..."), generic praise ("significantly improves robustness"), filler conclusions, forced metaphors, synonym cycling, decorative emphasis, and unnecessary contrast setups ("Not just X, it's Y").
- Write clear, active, declarative sentences. Concision must never erase the preconditions that make a statement true.
- Use bullet lists for parallel items and numbered lists for sequences; state conditions before dependent actions.

```text
Before: This PR significantly enhances the resilience and reliability of the sync layer.
After:  Queued edits now reuse one Idempotency-Key across retries, so a 503 followed
        by a retry no longer inserts duplicate rows (verified in queue.test.ts).
```

## 3. Writing for Agents (`AGENTS.md`, `SKILL.md`, Steering Docs)

When the reader is an AI agent rather than a human:
- **Guard always-loaded context:** keep `SKILL.md` descriptions tight (~120–180 chars of trigger signal, not procedure summaries). Push **only branch-specific or infrequent procedures** into `references/` behind sharp pointers (*what it contains* and *when to read it*) — never split a file that every invocation must read unconditionally.
- **Do not duplicate the environment:** skip directory trees, `package.json` scripts, or `--help` output that an agent can read directly; capture only unwritten conventions, traps, and navigation pointers.
- **Checkable completion & positive framing:** end procedures on concrete, observable completion criteria; state what *to do* rather than relying on bare prohibitions, and cut no-op advice the model already obeys by default.
- **Test skills like code:** when authoring or editing a `SKILL.md`, trial it against a realistic task prompt to catch trigger gaps or instruction ambiguity, and run any repo skill validator (e.g., `.\scripts\validate-skills.ps1`) before finishing.

## 4. Respect Evidence & Scope

- For specs and designs: separate confirmed behavior, decisions + reasons, assumptions, exclusions, and acceptance criteria. Link primary sources instead of copying whole files.
- For PRs and reports: state the problem, resulting behavior, verification evidence, and known limits. Never turn tentative observations into certainty or describe planned work as completed.
- Check every file path, command, and claim against the real codebase in the same pass. Writing never authorizes publishing, committing, or expanding scope.
