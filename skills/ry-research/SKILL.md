---
name: ry-research
description: "Verify external official docs, SDKs, specs, and pricing with citations into .scratch/research/. / 查外部官方文档、技术调研、一手资料。"
metadata:
  collection: ry-workflow
---

# Research

Gather accurate, up-to-date facts from authoritative **external primary sources** (official docs, upstream source code, RFCs/specs, release notes, first-party pricing pages). Use `ry-investigate` for the repository's own code and history. Match the user's language.

## 1. Execution & Subagent Policy

- **Default for non-trivial topics:** dispatch a **background subagent with network/web-search access** and a fresh context window so heavy page reading never bloats the main thread.
- **Quick single-fact lookups** (one parameter, one release note, one doc page): run directly in the main thread.
- **Host fallback:** if the host's subagents run in an offline sandbox (e.g., Antigravity's built-in `research` subagent has no network access) or subagents are unavailable, do not dispatch an offline subagent for live fetches — run via parent search/network tools directly and state the fallback.

## 2. Primary-Source Discipline

- Follow every claim back to the primary source that owns it; do not rely on memory or secondary blog summaries when official docs or source code exist.
- Record **pure verifiable facts, citations, versions/limits, and unknowns** — never sneak unapproved architecture decisions or recommendations into the research note as if they were settled project specs.

## 3. Storage Without Polluting Repo Docs

- **Short findings:** return directly in chat with links and retrieval date.
- **Long or background findings:** write a single Markdown note to `.scratch/research/<topic>.md` and return a short summary + path to the main thread. Before writing to `.scratch/` in a repo whose `.gitignore` does not ignore it, add `.scratch/` to `.git/info/exclude` so untracked scratch files never pollute `git status` or shared `.gitignore`. Do **not** save raw research into permanent `docs/` unless the user explicitly asks to archive it; once `ry-design` settles a decision, only the confirmed decision belongs in `docs/decisions-*.md` or an ADR.

Always start any saved research file with:

```markdown
> Status: External facts only — NOT an approved design or decision.
> Retrieved: YYYY-MM-DD
```
