# Third-Party Notices

`ry-workflow` is an original synthesis and adaptation inspired by the following MIT-licensed open-source agent skill collections. All skills in this repository were newly composed and adapted for a unified Codex + Antigravity workflow, while preserving attribution to the upstream ideas and methods.

## Upstream Projects

1. **YinFengWindy/windflow**
   - Repository: https://github.com/YinFengWindy/windflow
   - License: MIT
   - Adapted ideas: Coordinator + prefixed standalone stage architecture, three explicit human checkpoints, verification vs. independent review separation, issue overlap check, Windows-safe junction-aware worktree cleanup, and lightweight execution records.

2. **mattpocock/skills**
   - Repository: https://github.com/mattpocock/skills
   - License: MIT
   - Adapted ideas: Design-tree grilling (`grilling`), inline domain modeling with bounded contexts & decision docs (`grill-with-docs`, `domain-modeling`), fog-of-war decision maps (`wayfinder`), background primary-source research (`research`), DAG ready-frontier integration-branch orchestration (`implement-spec`), disciplined bug diagnosis loop with seam/probe checks (`diagnosing-bugs`), vertical-slice seam-based TDD (`tdd`), Standards × Spec two-axis review with Fowler code-smell heuristics (`code-review`), PR summary & merge-danger structure (`pr`), writing for agents (`writing-for-agents`), handoff (`handoff`), retrospective (`retro`), and shared architectural vocabulary (`codebase-design`).

3. **cursor/plugins — pstack (Lauren Tan / poteto)**
   - Repository: https://github.com/cursor/plugins/tree/main/pstack
   - License: MIT
   - Adapted ideas: Task playbook routing (`poteto-mode`, `autopilot-stack`, `pause-safely`, `prototype`, `multi-phase-plan`, `authoring-a-skill`), named steering engineering principles (`08-principles`, `principle-explain-the-number`), prompt calibration (`in-your-own-words`, `sharpen`, `reframe`), independent design bakeoffs (`arena`, `architect`), empirical blast-radius & adversarial interrogation (`blast-radius`, `interrogate`), cross-model second opinions (`advisor`), auditable decision logs (`show-me-your-work`), surface-aware real verification and project-local verification skill generation/upkeep (`principle-prove-it-works`, `create-verification-skill`, `maintain-verification-skill`), controlled eval/hillclimb experiment loops (`playbooks/eval`, `playbooks/hillclimb`, `benchmark-checklist`), parent/worker coordination (`swarm`), mistake-to-guardrail escalation & constraint-comment promotion (`correct`, `no-comments`), prose anti-slop (`unslop`, `technical-writing`), and context recall/catch-up (`recall`, `ketchup`, `reflect`).

4. **nagi-studio/skills**
   - Repository: https://github.com/nagi-studio/skills
   - License: MIT
   - Adapted ideas: Maintainable tech-stack comparison with operator responsibility callouts (`architect`), 3 junk-test patterns (`prove-it`), user-invoked UI subtraction checklist with `DESIGN.md` (`de-slop`), and repo spring-cleaning with 5,000-token pre-commit hook and `AGENTS.md` slimming (`tidy`).

Pinned commit hashes retrieved during design are recorded in [upstream-lock.json](upstream-lock.json).
