# Engineering Principles (Steering Vocabulary)

Consult this list during multi-step work. The user can also invoke any principle by its English or Chinese short name mid-session to steer behavior immediately (e.g., *"apply Subtract Before You Add"* or *"用最小改动原则"*).

**Citation rule:** When a principle genuinely changes a decision, name the principle and state the concrete choice it changed. Never list a principle as decoration.

## Thinking & Scope

1. **Laziness Protocol / 最小改动**
   - *When:* Sizing a diff, refactoring, or tempted to add abstractions, flags, or layers.
   - *Rule:* Bias toward deletion and the smallest change that solves the actual problem. Do not build for hypothetical future callers.
2. **Subtract Before You Add / 先减后加**
   - *When:* Extending, refactoring, or rewriting existing code.
   - *Rule:* Remove dead code, obsolete adapters, and stale branches first, then build on the simpler base.
3. **Foundational Thinking / 先定数据形状**
   - *When:* Before writing non-trivial logic.
   - *Rule:* Nail down core types, data structures, state ownership, and concurrent access first; logic follows the data shape.
4. **Attack the Premise / 挑战前提**
   - *When:* Two or more fixes sharing one assumption fail the same gate.
   - *Rule:* Stop patching. Write the shared premise down explicitly and test it directly before writing another fix.
5. **First Principles / 第一性原理重设计**
   - *When:* Grafting a new requirement onto an existing design feels forced.
   - *Rule:* Redesign the affected area as if the new requirement had been foundational from day one, rather than bolting on special cases.
6. **Build the Lever / 先造杠杆**
   - *When:* Facing repetitive multi-file edits, migrations, bulk verification, or large-scale analysis.
   - *Rule:* Write a focused script, codemod, or deterministic checker to execute and prove the work rather than editing dozens of sites by hand.
7. **Outcome-Oriented Execution / 直奔终态、迁完删旧**
   - *When:* Executing planned rewrites, API replacements, or migrations.
   - *Rule:* Converge directly on the target architecture, migrate callers in the same wave, and delete legacy paths cleanly instead of keeping throwaway dual-track shims.

## Architecture & Boundaries

8. **Boundary Discipline / 边界校验、内部信任**
   - *When:* Writing validation, error handling, parsers, or adapters.
   - *Rule:* Validate and parse untrusted inputs at system boundaries into strong types that make illegal states unrepresentable; keep internal business logic pure and trusting.
9. **Model the Domain / 用结构消除散落分支**
   - *When:* Business rules or stateful transitions start sprawling across nested `if/else` chains or duplicated flags.
   - *Rule:* Encode the rules into an explicit state machine, typed domain model, lookup table, or reducer so valid transitions live in one place.
10. **Deep Modules / 深模块与低阅读负担**
    - *When:* Designing or reviewing module boundaries and call chains.
    - *Rule:* Hide substantial complexity behind a small, honest interface at a clean seam. Collapse single-caller wrappers, middle-men, and hidden mutable state.
11. **Make Operations Idempotent / 幂等收敛**
    - *When:* Designing CLI commands, migrations, tool calls, sync loops, or delivery/cleanup workflows.
    - *Rule:* Make operations safe to retry or resume after partial interruption so repeated runs converge cleanly on the same end state.
12. **Separate Before Serializing Shared State / 先隔离再加锁**
    - *When:* Multiple workers, jobs, or code paths contend on shared mutable state.
    - *Rule:* Split write targets first (isolated worktrees, temp dirs, per-task partitions); introduce locks or serialization only when isolation is genuinely impossible.

## Verification & Debugging

13. **Prove It Works / 真证据交付**
    - *When:* Before declaring any task done.
    - *Rule:* Verify against the real artifact and observable behavior (real test run, command output, or browser screenshot), never "it compiles", mocks of the target itself, or guesswork.
14. **Fix Root Causes / 修根因不糊创可贴**
    - *When:* Debugging failures or reviewing proposed defensive guards.
    - *Rule:* Trace each symptom back to the first place the system went wrong and fix it there. Add a guard or fallback only when the state it handles is genuinely legitimate.
15. **Test Behavior, Not Implementation / 测行为不测实现**
    - *When:* Writing, keeping, or pruning tests.
    - *Rule:* Assert through public seams on user-observable behavior. A test must fail when the behavior breaks and keep passing when only internals are renamed or refactored.
16. **Explain the Number / 解释数字**
    - *When:* Before measuring, trusting, or reporting any eval score, speedup, latency, or regression number.
    - *Rule:* State sample count, spread, error count, and the real limiter; verify the target work actually ran and the gap exceeds run-to-run noise.

## Delegation & Evolution

17. **Guard the Context Window / 守卫上下文窗口**
    - *When:* Facing large files, noisy logs, broad codebase scans, or independent comparisons.
    - *Rule:* Offload bulk exploration and parallel work to subagents; keep concise cited conclusions and decisions in the main thread.
18. **Encode Lessons in Structure / 把教训刻进结构**
    - *When:* Correcting the same mistake a second time.
    - *Rule:* Escalate along the guardrail ladder — architecture → types/lint/pre-commit hook → behavioral test → docs/AGENTS.md last — and verify the new check catches the past mistake.
