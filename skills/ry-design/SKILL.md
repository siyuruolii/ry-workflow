---
name: ry-design
description: "Design module interfaces, data shapes, tradeoffs, or tech stacks before coding. / 架构设计、方案对比、技术选型、接口与数据结构设计。"
metadata:
  collection: ry-workflow
---

# Design

Compare genuinely distinct approaches when the stakes warrant it, then converge on a proportional design contract. Output is a design decision — not production code or published tickets. Match the user's language.

Start from confirmed requirements (`docs/decisions-*.md`, `GLOSSARY.md`), internal code evidence (`ry-investigate`, or direct codebase reads if standalone), and external facts (`ry-research`, or primary-source web/doc checks if standalone). If a product decision is still open, take it back to the user (`ry-grill` or direct clarification) instead of designing around guesswork.

> **Branch reference:** When choosing frameworks, databases, hosting, or third-party services (greenfield or new infrastructure), read [references/tech-stack.md](references/tech-stack.md) for the maintainable tech-stack comparison method and operator-responsibility checklist.

## 1. Direct Convergence vs. Independent Bakeoff

- **Routine / bounded modules** (reversible two-way choices, single-subsystem scope): converge directly without spawning competing agents.
- **High-stakes, hard-to-reverse (`one-way`), cross-subsystem, or strongly contested architectures** (or when the user asks for options): spawn **2 or more** independent candidate subagents (prefer distinct model families when supported), each given the exact same brief and kept blind to the others' work. Write candidate drafts under `.scratch/design/` (ensure `.scratch/` is listed in `.git/info/exclude` if not in `.gitignore`).

Each candidate returns: caller usage, core data shapes and state ownership, module boundaries/seams, failure handling, tradeoffs, assumptions, and the cheapest check that settles each uncertain claim.

If subagents are unavailable, state that the comparison is serial/limited. If a fork is cheaper to settle by running a quick throwaway prototype (`.scratch/prototypes/`) than debating, build one outside production paths and report the result.

## 2. Converge in the Owner

The parent that understands the requirements selects a base, borrows compatible strengths from other candidates, and writes the final design contract covering:
- **Why this design & tradeoffs** (alternatives considered, why this won, accepted costs/risks)
- **Core data shapes & state ownership** (*Foundational Thinking* — nail data before logic)
- **Public interfaces & deep-module seams** (small interface hiding complexity; clear validation boundaries)
- **Error handling, compatibility, and migration/rollback plan** (explicit backup/rollback strategy for `one-way` migrations; migrate callers and delete legacy paths cleanly)
- **Verification plan** (what tests or live checks prove each requirement)

Keep the contract proportional to the task — never invent layers or abstractions without a current need (*Laziness Protocol*).

### Shared Architectural Vocabulary
Prefer exact terms over vague labels ("component", "service", "layer"):
- **Module / Interface / Depth:** hidden complexity behind a small, honest public contract; deep > shallow.
- **Seam / Adapter:** a clean boundary where behavior can be tested or swapped without leaking internals, with thin adapters at external edges.
- **Leverage / Locality:** maximize behavior controlled per line of interface and keep tightly coupled decisions close together.

## 3. Persistence (Respect Repo Conventions)

- **Substantial architecture or non-trivial tradeoffs:** in personal repos or repos with an established `docs/` convention (or with user approval), save to `docs/design/<topic>.md` stamped with `Verified against: <branch>@<sha> (<YYYY-MM-DD>)` so downstream `ry-plan` specs can link to it without repeating rationale. Record hard-to-reverse system-wide choices as an ADR if warranted.
- **External / team repos with strict doc structures, or small localized designs:** do **not** create unsolicited root/docs files; keep inline in chat (or `.scratch/design/` if long) and hand straight to `ry-plan` or `ry-implement`.

Reuse an approved design while it holds; reopen it only when new evidence contradicts it.
