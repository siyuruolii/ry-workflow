# Deep Review: Adversarial Interrogation & Code-Smell Baseline

Read this reference **only** when reviewing **high-risk code paths** (auth, payments, persistence, migrations, destructive tools), **large/complex diffs (> ~150 lines or > 5 files)**, or **pre-implementation design docs (`docs/design/*.md`)**.

## 1. High-Risk Adversarial Interrogation (`interrogate`)

Run an explicit red-team pass (ideally using a different model family or host) whose sole job is trying to break the change or design:
- **For critical code:** every high-severity critique must be backed by a concrete failing reproduction or scratch probe (outside the implementation tree), not speculative "what-ifs".
- **For design docs (`docs/design/<topic>.md`):** trace concrete failure scenarios — concurrency races, partial failures, migration/rollback hazards, credential/injection abuse, and contract mismatches — against the stated data shapes and module boundaries; cite the exact section that breaks.

## 2. High-Signal Fowler Code-Smell Checklist (Judgment Calls Only)

Repo standards (`CODING_STANDARDS.md`, `AGENTS.md`) always override these heuristics, and automated linter/formatter checks are skipped. Raise these only as **judgment calls** (never hard merge blockers):
- *Mysterious Name* — identifiers obscure intent or conflict with `GLOSSARY.md`
- *Duplicated Code* — identical business logic split across multiple owners
- *Feature Envy* — function spends most lines reaching into another module's internals
- *Data Clumps* — same group of parameters passed together everywhere instead of a typed record
- *Primitive Obsession* — untyped strings/numbers encoding domain invariants across boundaries
- *Repeated Switches* — parallel `if/else` or `switch` trees branching on the same discriminant
- *Shotgun Surgery* / *Divergent Change* — one change touches many unrelated files, or one file changes for unrelated reasons
- *Speculative Generality* — unused hooks, flags, or abstractions built for hypothetical callers
- *Message Chains* / *Middle Man* — deep `a.b().c().d()` chains or thin pass-through wrappers adding no depth
- *Refused Bequest* — subtype or adapter ignoring/throwing on part of its inherited contract
