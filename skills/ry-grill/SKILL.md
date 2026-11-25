---
name: ry-grill
description: "Align unsettled requirements via decision-tree rounds, prompt calibration, and inline decision docs. / 需求追问、复述校准、打磨需求、grill me。"
metadata:
  collection: ry-workflow
---

# Grill

Align with the user until behavior, acceptance criteria, scope, and key tradeoffs are crystal clear, while persisting settled decisions inline so downstream stages inherit them cleanly. Finishing an interview or prompt calibration does **not** authorize coding or publishing. Match the user's language.

## Lightweight Upfront Calibration (Before or Instead of a Full Interview)

Match the entry mode to what the user actually handed you:
- **Restate & calibrate (`in-your-own-words`):** when given a long, noisy issue thread, PRD, or rambling note, first restate the core goal, constraints, boundaries, and apparent contradictions in plain language for quick confirmation before asking follow-up questions.
- **Sharpen without executing (`sharpen`):** when the user asks to tighten a rough task or prompt (especially before launching an `AFK` run), make it *deeper, not bigger* — fill in expert edge cases, primary sources to check, explicit exclusions, and checkable acceptance criteria — and return the sharpened brief without starting implementation.
- **Reframe when stuck (`reframe`):** when a discussion loops or rests on a cramped framing, name the hidden premise and offer 1–2 cleaner domain framings or analogies before continuing the decision tree.

## 1. Ground Yourself First

Read existing investigation notes, `GLOSSARY.md`, relevant ADRs, and code before asking.
- **Ask only product decisions:** user-visible behavior, stored data, safety/confirmation boundaries, compatibility, cost, scope, and MVP cutlines.
- **Never ask facts you can check:** look up code, configs, or environment facts yourself (dispatch a read-only subagent if broad) and state what you found. Do not block unrelated frontier questions while a lookup runs.
- **Own technical details:** decide pure internal implementation details yourself unless the user wants to weigh in.

## 2. Work the Decision-Tree Frontier

Do not ask the user to pick an intensity level — judge depth and pacing yourself from the task's complexity and risk.

Work in **rounds**. Each round, ask the current **frontier** — questions whose prerequisites are already settled — and hold dependent questions for later rounds:
- Give a concise **recommended answer + reason** for each question, worded so replying "yes" accepts your recommendation.
- Challenge fuzzy or overloaded terms immediately (e.g., *"You said 'memory' — do you mean cross-session long-term facts, or current thread context?"*) and stress-test boundaries with concrete scenarios.
- Flag contradictions between what the user says and what existing code or `GLOSSARY.md` defines.

```text
Settled: local CLI personal agent; MVP focuses on note search and calendar scheduling.

Q1 | Confirmation boundary for external actions
Should creating/editing calendar events require explicit confirmation before executing?
  -> Recommend yes: calendar writes affect external state and are easy to misfire early on.

Q2 | Memory scope for MVP
Should MVP keep long-term memory as plain Markdown files under a local folder rather than a vector DB?
  -> Recommend yes: inspectable, editable by hand, and enough to validate retrieval first.

Holding for next round (depends on Q1): how pending confirmations are shown in CLI.
Checking in code/docs (not asking): Google Calendar OAuth local loopback flow requirements.
```

## 3. Persist Decisions Inline (`grill-with-docs`)

Capture decisions lazily as they crystallize rather than waiting until context gets long. **Respect target-repo conventions:** in external or team repositories with strict doc layouts, do **not** create unsolicited tracked files at the repo root (`GLOSSARY.md`, `docs/decisions-*`) without user consent — keep notes in chat, issue comments, or git-excluded `.scratch/` instead. When tracked docs are appropriate:
- **Decision log (`docs/decisions-<topic>.md`):** create on the first settled decision (stamped with `Verified against: <branch>@<sha> (<YYYY-MM-DD>)`) and append confirmed choices, reasons, exclusions, and remaining open questions as rounds progress.
- **Domain glossary (`GLOSSARY.md`):** create or update inline whenever a domain term is defined or sharpened. Keep `GLOSSARY.md` strictly pure domain vocabulary — no implementation details or spec prose. When one word means different things across sub-domains (**Bounded Contexts**, e.g., auth `Account` vs. billing `Account`), split the name or tag its owning context explicitly rather than overloading one entry.
- **ADRs (`docs/adr/NNNN-<slug>.md`):** create sparingly, **only** when a decision is all three: (1) hard to reverse, (2) surprising without context, and (3) a real tradeoff among genuine alternatives.

## 4. When to Stop

Stop on your own judgment as soon as the decision frontier is empty — i.e., remaining unknowns will no longer materially change the next step (design, planning, or coding) and nothing important is silently assumed.

Close with a concise summary linking the updated docs:
- **Confirmed behavior & acceptance criteria**
- **Explicit exclusions (non-goals)**
- **Saved artifacts** (`docs/decisions-<topic>.md`, `GLOSSARY.md`, ADRs if any)
- **Proposed next step**

Wait for explicit user confirmation before dependent work begins.
