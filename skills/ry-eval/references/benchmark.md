# General Eval Method: Benchmark Checklist & Report Schema

Read this reference when tuning **general software performance, throughput, build speed, memory, algorithms, or library swaps**.

## 1. Seven-Point Benchmark Sanity Checklist

Vet every measurement harness and claimed number against these seven checks before reporting:

1. **Why not double? (Limiter):** profile in a separate non-reported run (CPU profiler, query plan, I/O wait, memory/GC counters) and map the hot spot to source. If you cannot name what bounds the number, you do not yet understand it.
2. **Was it tuned?** Run both sides under realistic production-equivalent settings (release builds, matching flags, warm/cold cache parity, realistic dataset sizes) so you compare implementations, not mismatched defaults.
3. **Did it break physical/math limits?** Sanity-check the delta against bandwidth, core count, and Amdahl's law (removing a 10% step cannot speed up the whole run by 40% unless something else was skipped or cached).
4. **Did it error?** Count failures, timeouts, and non-success results, and verify output correctness — fast failures fake low latency.
5. **Does it reproduce?** Run multiple trials (`>= 5` for noisy workloads), alternating Baseline and Candidate (`A, B, A, B...`) to cancel drift and warmup bias. Report median + range; a gap smaller than run-to-run spread is noise.
6. **Does it matter end-to-end?** Pair any micro-benchmark with its share of the real user-facing path.
7. **Did the work actually happen?** Confirm real work executed inside the timed window (rows written, bytes parsed, promises awaited, results consumed — not lazy/DCE'd code).

Call the verdict **`inconclusive`** whenever errors or real-work checks were skipped, one side ran untuned, or no limiter was identified.

## 2. Experiment Log (`.scratch/eval/decision.tsv`)

Keep a local git-excluded TSV trail (one row per attempt, kept or reverted):

```text
id	hypothesis	change	before	after	delta	errors	regression	verdict	note
01	batch index writes instead of per-row fsync	edit store/index.ts	p50 182ms (175-194, n=7)	p50 44ms (41-48, n=7)	-75.8%	0	pass	kept	now CPU-bound on JSON parse
02	custom string parser	edit store/parse.ts	p50 44ms (41-48, n=7)	p50 43ms (40-49, n=7)	-2.3%	0	pass	reverted	within noise spread
```

## 3. Review Report Structure (`.scratch/eval/<YYYY-MM-DD>-<topic>.md`)

1. **Verdict & Scope:** `promote` | `revert` | `inconclusive`, exact Baseline vs. Candidate refs, and what changed.
2. **Metrics Table:** metric + unit, Baseline (median, range, `n`), Candidate (median, range, `n`), delta, error count, real limiter, regression status.
3. **Evidence & Profiles:** key profiler/case comparisons or charts proving both improvement and correctness.
4. **Limits & Next Hypothesis:** what was not measured, link to `decision.tsv`, and the strongest next lever if pushing further.
