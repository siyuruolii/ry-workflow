# Agent Ownership and Coordination

The coordinator (parent) owns user intent, confirmed decisions, design coherence, integration, and every external or irreversible action. Delegating to workers hands out bounded tasks, never product authority or extra permissions. All Non-Negotiable Gates in `ry-flow/SKILL.md` apply to every delegated run.

## Roles

| Role | Responsibility | Boundaries |
| --- | --- | --- |
| **Parent** | Talks to user, runs `ry-grill`, converges `ry-design`, owns `ry-plan` / `ry-verify` / `ry-ship`, reviews worker diffs, commits and manages Git/CI. | Never rubber-stamps worker claims without checking actual diffs and evidence. |
| **Investigator** | Traces internal repo code and git/PR/ADR history (`ry-investigate`). | Read-only; no summary files written into the repo. |
| **Researcher** | Checks external official docs, SDKs, specs (`ry-research`). | Pure facts + links + retrieval date; writes long notes only to `.scratch/research/`, never permanent `docs/`. |
| **Design candidate** | Proposes a complete approach independently during a 2+ candidate bakeoff (`ry-design`). | Blind to other candidates; writes only to `.scratch/design/`. |
| **Implementer** | Executes one approved slice in its assigned branch/worktree (`ry-implement`). | Does not talk to user, widen scope, commit, push, or merge unless explicitly assigned. |
| **Finder / Verifier** | Independently hunts defects/security/spec/standards issues; a separate verifier seeks counterevidence (`ry-review`). | Read-only on repo code; scratch repros stay outside the implementation tree. |

## Handoff Briefs & Context Hygiene

Give every worker a self-contained brief so it never guesses:
- User goal, confirmed acceptance criteria, and explicit exclusions.
- Exact baseline (branch/commit SHA) and writable area (branch/worktree path or scratch file).
- Primary sources (`docs/decisions-*.md`, `docs/design/*.md`, `GLOSSARY.md`, ADRs, `file:line`, commit SHAs) rather than vague paraphrases.
- Rejected directions, known unknowns, and the path to the stage `SKILL.md` it must follow.

**Guard the context window across phases:** offload broad searches, external reading, blind candidates, and parallel coding to fresh subagents. On `L` multi-phase work (e.g., after `ry-plan` or every 1–2 slices), prefer fresh workers or a `ry-handoff` session boundary instead of stacking every stage's instructions and diffs into one thread.

When confirmed context changes, tell affected workers explicitly what changed. Workers bring contradictions, missing facts, or broken design contracts back to the parent instead of silently working around them.

## Branching, Parallel Writers & Integration

- **Single-agent sequential work:** use a normal task branch in the main checkout (no unnecessary worktree overhead).
- **Parallel writers — choose the delivery topology:** never let two writers edit the same file or branch concurrently; give each concurrent `Parallel` + `AFK` implementer its own isolated worktree and task branch:
  - **Single integration branch (DAG ready-frontier):** dispatch the unblocked ready frontier to isolated worktrees, verify and integrate each completed slice into one shared feature integration branch, advance the frontier until done, then run full-branch `ry-verify` + `ry-review` and open one PR via `ry-ship`.
  - **Independent or stacked PRs:** ship each verified slice as its own PR (stacking dependent branches explicitly per Playbooks 8 & 10).
- **Fresh workers by default:** give follow-ups, retries, or new slices to a fresh worker with the updated brief and prior evidence; reuse an existing worker only when its live checkout or running process is costly to move.
- **Verify before integrating:** wait for active writers to finish before staging, switching branches, or reviewing. Inspect the real diff and check outputs before committing.

## Cross-Model / Cross-Host Second Opinion (`advisor`)

Single-model runs share blind spots. At high-stakes checkpoints — contested architecture (`ry-design` blind candidates), stuck debugging (`ry-debug`), or high-risk code/design review (`ry-review`) — prefer soliciting a second opinion from a **different model family or host** (e.g., drafting in Codex and reviewing in Antigravity via `ry-handoff`, or assigning distinct models to independent subagents when supported):
- Hand the advisor primary sources, the pinned diff/design, and the exact question — never lead it toward a preferred conclusion.
- Judge advisor feedback on its merits and real evidence (same necessity gate as `ry-review`).

## Host Capabilities & Fallbacks (Codex vs. Antigravity)

Adapt execution primitives to the active host rather than forcing mismatched tools:
- **External research (`ry-research`):** Antigravity's built-in `research` subagent runs in an **offline read-only sandbox** (no network access; web search may still exist, or parent holds `search_web`). Do not dispatch an offline subagent expecting live URL/repo fetches — use a networked worker when supported, or run directly in the parent and state the fallback.
- **Browser verification (`ry-verify`):** prefer Antigravity's built-in `browser` subagent for live web UI flows when available; in Codex/CLI hosts, use Playwright or repo browser harnesses.
- **Parallel workspaces (`ry-implement`):** use host-native isolated workspaces (`Workspace: "share" | "branch"` in Antigravity) when available, or explicit `git worktree` on CLI hosts.
- **Interactive grilling (`ry-grill`):** use structured multi-choice prompt tools when available; otherwise use concise numbered rounds in chat.
- **When subagents are unavailable:** state the limitation plainly and run in the parent. Label serial design as limited, report independent review as incomplete rather than disguising self-review as independent, and never skip verification gates.
