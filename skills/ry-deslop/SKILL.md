---
name: ry-deslop
description: "User-invoked UI visual subtraction pass guided by user taste and DESIGN.md. Never auto-invoke. / 界面去 AI 味、UI 减法清理（仅手动）。"
disable-model-invocation: true
metadata:
  collection: ry-workflow
---

# Deslop (UI)

**User-invoked only.** Aesthetic judgment belongs to the user — never trigger this skill automatically in a workflow. This pass only subtracts and refines; do not add new features. Match the user's language.

## 1. Ground in User Taste First

1. Read `DESIGN.md` at the repo root if it exists; user rules and `DESIGN.md` always override every heuristic below. If none exists, ask or follow the user's stated direction rather than imposing a house style.
2. Render the real UI and capture screenshots at both **desktop** and **mobile** widths.

## 2. Optional Subtraction Baseline (Apply Only Where Aligned With User Taste)

Inspect the screenshots and cut genuine visual clutter:
- **Deletion test:** remove helper subtitles, badges, eyebrow labels, or dividers that add no information or merely repeat the heading.
- **Unrequested effects:** drop gradients, glassmorphism, neon borders, and glows the user did not ask for.
- **Icons:** replace UI chrome emoji or ad-hoc hand-drawn SVGs with a consistent icon library (ask the user before picking a new library).
- **Hierarchy & cards:** flatten redundant nested cards; prefer whitespace over extra borders/dividers; remove decorative colored stripes that encode no status.
- **Typography & radii:** keep font-size levels restrained and readable (`>= 12px`); align nested border radii (`inner ≈ outer - padding`).
- **Copy & motion:** use direct action labels, avoid repetitive text, and strip decorative bounce/float animations on frequent controls.

## 3. Re-Verify & Persist Taste

1. Re-capture desktop and mobile screenshots after edits and confirm zero console errors.
2. Deliver before/after screenshots and a concise list of what changed.
3. **Persist corrections:** whenever the user states an aesthetic preference or rejects a change, append a short rule + reason to `DESIGN.md` (confirm before creating a new root `DESIGN.md` in external/team repos) so future passes follow their taste rather than generic defaults.
