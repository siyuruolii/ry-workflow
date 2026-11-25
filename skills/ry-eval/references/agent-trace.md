# Agent Eval Method: Trace Verification, Blinding & Reports

Read this reference when evaluating or tuning **AI agents, tool schemas/descriptions, prompts, RAG/memory retrieval, or agent harnesses**.

## 1. Minimum Trace Schema (When Bootstrapping Tracing)

Keep traces lightweight, local, and queryable (e.g., JSONL or SQLite under `.scratch/traces/` or the project's trace dir, with secrets redacted as `<REDACTED>`):
- Run metadata: `run_id`, `case_id`, `variant` (commit SHA/tag), `model`, `timestamp`
- Input & final output: `user_prompt`, `final_response`, `status` (`ok` | `error` | `timeout` | `max_steps`)
- Ordered step events: `step`, `tool_name`, `tool_args`, `tool_result_summary`, `tool_error`, `duration_ms`, `tokens_in`, `tokens_out`

## 2. Blinding Rules (For Subjective / LLM-as-a-Judge Grading)

- Never expose evaluation meta-words (`eval`, `judge`, `rubric`, `benchmark`, `candidate`, `score`) in prompts, paths, or filenames seen by the agent under test.
- Feed organic user prompts only — never ask the agent to self-report which tools or instructions it followed; verify tool selection and policy adherence directly from the recorded trace and side effects.
- Have one judge grade Baseline and Candidate outputs in a single pass using anonymous labels (`Variant A`, `Variant B`) with no model, branch, or variant hints.
- Manually inspect a sample of raw traces alongside the judge's scores; disagreement indicates judge bias or an underspecified rubric.

## 3. Measurement Sanity (Explain the Number)

- Print error/timeout/max-step counts and confirm tasks actually completed (a variant that gives up early can look cheaper and faster while failing the task).
- Because LLM runs are stochastic, run repeated trials across the frozen eval set and report pass rate / median + run-to-run spread alongside sample size `n`. A delta smaller than stochastic spread is noise.
- Never alter eval cases or rubrics mid-tuning; if a grading flaw is discovered, fix and re-freeze the eval set, then re-establish Baseline before comparing.
- Correctness and safety gates (e.g., tool confirmation boundaries) outrank score or latency improvements.

## 4. Experiment Log (`.scratch/eval/decision.tsv`)

```text
id	hypothesis	change	before	after	delta	errors	regression	verdict	note
01	clarify calendar tool date format in schema	edit tools/calendar.ts	70% (n=20)	90% (n=20)	+20%	0	pass	kept	eliminated 4 invalid-date retries
02	trim tool output to 400 chars	edit loop/context.ts	90% (n=20)	80% (n=20)	-10%	2	fail	reverted	dropped pagination token
```

## 5. Review Report Formats

### Markdown Report (`.scratch/eval/<YYYY-MM-DD>-<topic>.md`)
1. **Verdict & Change:** `promote` | `revert` | `inconclusive`, Baseline vs. Candidate refs, and exact harness/tool diff summary.
2. **Metrics Table:** task pass rate, tool-call accuracy, avg steps, error/retry count, latency/tokens (Baseline vs. Candidate, `n`, spread, regression gate).
3. **Paired Before/After Trace Excerpts:** 2–5 representative improved cases plus **every** regressed or still-failing case, showing exact tool-call sequence (`tool(args) -> result/error`) and why behavior changed.
4. **Limits & Next Idea:** uncovered scenarios, link to `decision.tsv`, and the strongest next tuning hypothesis.

### Single-File HTML Report (`.scratch/eval/<YYYY-MM-DD>-<topic>.html`)
For 10+ cases or deep traces, emit one standalone zero-dependency HTML file with:
- Summary KPI cards (pass rate, tool accuracy, avg steps, errors, token/latency deltas)
- Filter tabs (`All` / `Improved` / `Regressed` / `Unchanged` / `Failed`)
- Collapsible per-case cards showing side-by-side Before vs. After tool-call traces, final outputs, and rubric verdicts.
