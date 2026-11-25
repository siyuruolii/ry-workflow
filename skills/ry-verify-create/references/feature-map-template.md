# Feature Map Template

Use this minimal structure inside `.agents/skills/verify-<app>/features/` so `ry-verify` and `ry-verify-maintain` can drive features deterministically without guessing.

## `features/README.md`

```markdown
# <App> Verification Map

Maintained index of user-facing behaviors for `<app>`. Read this index before driving the app, then open the matching feature file.

## Baseline Preconditions
- Disposable data dir / isolated port: `<exact env vars or flags>`
- Seed state (if any): `<exact seed command or fixtures>`
- Health check: `<exact doctor command>`
- Never drive an instance not started by this verification run.

## Driving & Proof Conventions
- Prefer stable handles (CLI flags, ARIA roles/names, route paths) over brittle selectors.
- Capture both the user action and resulting state, plus underlying side effects (files/DB/outbound payload).
- Cleanup restores scratch state and stops only started processes; proof artifacts survive cleanup.

## Features
- [<Feature Name>](./<feature-slug>.md) — <one-line scope of surfaces covered>
```

## `features/<feature-slug>.md`

Every feature file uses **one short user-POV intro paragraph** followed by **four H2 sections in this exact order** (no internal code details):

```markdown
# <Feature Name>

<One paragraph describing the user-visible capability and how persistence/result is confirmed.>

## Sub-features
- `<id-1>`: <one-line observable behavior>
- `<id-2>`: <one-line observable behavior>

## How to get to it (user POV)
- <Every user-facing entry point: CLI command, button, shortcut, route>

## Driving it with <harness>
Preconditions:
- <Exact doctor/health/seed preconditions>

- **<Step name>.** <User action>. Run `<literal command>`. Expect `<exact observable output / side effect>`.
- **Proof.** Capture `<exact artifact path (screenshot / transcript / second-view read)>`.

## Gotchas
- <Real traps that invalidate runs, trimming/timing quirks, cleanup reminders>
```
