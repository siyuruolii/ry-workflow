---
name: ry-eval
description: "Measure and tune software perf, algorithms, or AI agents/prompts/harnesses via frozen baselines and reports. / 性能基准、算法与 Agent 调优评估。"
metadata:
  collection: ry-workflow
---

# Eval (Benchmarks & Agent Harness Tuning)

Never claim an optimization, refactor, algorithm tweak, library swap, or AI agent/prompt/tool change is better from code inspection or one lucky run. Prove it with a frozen measurement harness and controlled before-vs-after numbers. Match the user's language.

## Choose Your Branch (Read Only the Matching Reference)

- **General software perf, throughput, build speed, memory, algorithm, or library tuning:** read [references/benchmark.md](references/benchmark.md) (7-point sanity checklist, profiling limiter, alternating A/B trials).
- **AI agent, tool schema/description, prompt, RAG/memory retrieval, or agent harness tuning:** read [references/agent-trace.md](references/agent-trace.md) (trace schema, LLM-as-a-judge blinding, paired Before/After trace Markdown & HTML reports).

## 1. Check Observability & Freeze Baseline First

Before editing target code, check whether repeatable measurement exists:
- **General software:** a realistic, deterministic benchmark or evaluation harness.
- **AI agent/harness:** structured queryable run **Traces** (inputs, tool calls/args/outputs, errors, steps, latency/tokens) **and** a representative **Eval Set** with deterministic checks and/or rubrics.

**If missing or unrealistic — stop before tuning.** Proactively propose bootstrapping the minimal harness (or trace instrumentation + eval set from real tasks and past failures), prove it separates good runs from broken ones, **freeze it** (never alter eval tasks mid-tuning to inflate scores), and capture a fresh **Baseline** on the starting commit plus a green functional regression gate.

## 2. Run Controlled Single-Variable Iterations

1. **Lock criteria upfront:** fix the primary metric, winning direction, noise floor, repeat count `n`, and mandatory regression/safety gates (correctness and safety boundaries always outrank speed or score).
2. **Keep `.scratch/` private:** before writing files under `.scratch/eval/`, ensure `.scratch/` is ignored locally (prefer `.git/info/exclude` in repos whose `.gitignore` lacks it).
3. **One variable per iteration:** test one grounded hypothesis at a time, measure before vs. after on the frozen harness, and log every attempt in `.scratch/eval/decision.tsv` (`kept` or `reverted`). Keep a change only when gains clear run-to-run noise/variance and all regressions stay green; otherwise revert in full.
4. **Explain the number:** identify the real limiter (or verify actual tool calls/side effects from traces — never self-report), print error/timeout counts, and confirm real work executed.

## 3. Deliver a Human-Reviewable Report

Save a concise Markdown report under `.scratch/eval/<YYYY-MM-DD>-<topic>.md` (and a standalone single-file `.html` report for 10+ cases or deep multi-step agent traces) per the selected reference, including:
- Verdict (`promote` | `revert` | `inconclusive`) and exact Baseline vs. Candidate refs
- Metrics table (median/rate, spread, `n`, delta, error/retry counts, real limiter, regression status)
- Representative profile/case or paired Before/After trace evidence, `decision.tsv` path, and limitations

Wait for explicit user review before promoting or shipping the tuned change.
