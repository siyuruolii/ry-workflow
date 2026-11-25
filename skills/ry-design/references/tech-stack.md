# Tech-Stack & Hosting Selection (Greenfield or New Infrastructure)

Read this reference **only** when choosing frameworks, databases, hosting providers, or third-party services.

## Selection Procedure

1. **Check constraints first:** gather target region/network, platform & scale, auth/sync/data model, what the user can realistically maintain, and budget/compliance from prior decisions. Ask **one focused round** only for missing constraints that would actually change the recommendation.
2. **Verify live facts from primary sources:** check current pricing, free tiers, region availability, licenses, and maintenance health from official sources (`ry-research`, or direct official docs if standalone) — never rely on stale memory. Prefer mature, well-backed libraries over hand-rolling or obscure packages.
3. **Present 2–3 options sorted by boring, maintainable technology** (Option A = simplest stack the user can operate reliably):
   - **Stack & why it fits**
   - **Dev effort & ongoing maintenance cost**
   - **Target region accessibility**
   - **What you must operate yourself** (keys, permissions, servers, billing — or "None")
   - **Main risks & exit/migration cost**
4. **Converge clearly:** end with one clear recommendation, the decisive reason, and any remaining question that would flip it. Append the confirmed choice to `docs/decisions-<topic>.md` or `docs/design/<topic>.md` (when repo conventions allow; otherwise keep inline or in `.scratch/`).
