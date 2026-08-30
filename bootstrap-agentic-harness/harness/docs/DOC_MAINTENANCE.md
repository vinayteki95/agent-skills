# Documentation Maintenance

The **single source of truth** for how and when to update each doc category.
Every other doc links here instead of copying these rules. **Doc drift is a
harness failure — treat stale specs like failing tests.**

## Rules for every iteration

Applies to every PR/agent run that touches behavior, architecture, or tooling:

1. **Same change, same PR** — code + doc updates merge together. Never "doc follow-up."
2. **Touch the leaf first** — update the specific spec/reference, then roll the summary up to index/grade docs.
3. **Log decisions** — non-obvious choices go in the active exec plan `Decisions` table.
4. **Run sensors** — doc-only PRs run the `doc` tier; code PRs run the tier matching scope.
5. **Date stamps** — bump "Last updated" on any master doc whose guidance changed.

## Maintenance matrix

| Category | Master doc(s) | Update when | How | Drift signals |
|----------|---------------|-------------|-----|---------------|
| **Agent map** | [`AGENTS.md`](../AGENTS.md) | New doc category, domain, or workflow step | Add one row; keep it a map (< ~140 lines); link, don't paste | Agents ask "where is X?"; duplicated instructions |
| **Architecture** | [`ARCHITECTURE.md`](../ARCHITECTURE.md) | New domain, module split, data flow, or provider | Update domain/layer table + link package paths | Cross-domain imports; folder with no owner |
| **Product sense** | [`PRODUCT_SENSE.md`](PRODUCT_SENSE.md) | Tone/philosophy change | Edit principles/voice; **human review** for tone shifts | User-facing copy violates tone |
| **Feature specs** | [`product-specs/index.md`](product-specs/index.md) + leaf specs | Any user-visible behavior or scope change | Edit leaf spec → update index status → link from ARCHITECTURE if new domain | Code shipped without spec; spec `draft` but code live |
| **Design docs** | [`design-docs/index.md`](design-docs/index.md) | New invariant, lint rule, or principle | Add indexed doc; `draft`→`verified` when enforced | Beliefs contradict code; lint undocumented |
| **Golden principles** | [`design-docs/golden-principles.md`](design-docs/golden-principles.md) | Repeated review feedback; new lint | Add numbered rule; wire to a sensor if mechanical | Same review comment twice |
| **Module boundaries** | [`design-docs/module-boundaries.md`](design-docs/module-boundaries.md) | Layer/import rule change | Update matrix + example; add lint | Upward imports appear |
| **Exec plans** | [`exec-plans/active/`](exec-plans/active/) | Start/pause/finish multi-step work | Create from [`PLANS.md`](PLANS.md); append Progress log **each session**; move to `completed/` when done | Active plan with no log; work done, plan still active |
| **Tech debt** | [`exec-plans/tech-debt-tracker.md`](exec-plans/tech-debt-tracker.md) | Discover or pay down debt | Add `- [ ]` with area + link; move to Resolved with date | Known gaps only in chat |
| **Quality grades** | [`QUALITY_SCORE.md`](QUALITY_SCORE.md) | Domain code/tests/docs materially change | Adjust grade + Notes; bump Last updated | Grade says A but no tests |
| **References** | [`references/`](references/) | Dense external/platform fact changes | Edit the condensed reference | Master doc duplicates a big table |
| **Sensors/CI** | [`SENSORS.md`](SENSORS.md) | New sensor, tier, or hook | Update catalog + tiers; sync `run-sensors.sh` | CI runs a check not in the catalog |
| **README** | [`README.md`](../README.md) | Build/run instructions change | Update status + commands; link AGENTS.md for depth | README duplicates spec text |
<!-- FILL: add rows for optional modules you scaffolded (DESIGN, SECURITY, RELIABILITY, DELIVERY, BACKEND, uat) -->

## Per-iteration checklist (agents)

Copy into the exec plan Progress log or PR description:

```
Doc maintenance:
- [ ] Leaf spec(s) updated: ___
- [ ] Index / ARCHITECTURE cross-links updated
- [ ] QUALITY_SCORE row(s) adjusted
- [ ] Tech debt added or resolved: ___
- [ ] Exec plan log + status updated
- [ ] Sensors run (tier: quick | doc | standard | full)
- [ ] Feedback encoded (lint / golden principle / spec) if a sensor failed: ___
```

## When *not* to update

| Situation | Action |
|-----------|--------|
| Refactor with zero behavior change | No spec edit; adjust QUALITY_SCORE only if structure improved |
| Typo in a code comment | No doc |
| Experimental spike on a branch | Exec plan note only; don't mark spec `verified` |
| "Docs later" | Block merge unless explicitly waived in the exec plan |

## Gardening cadence

| Cadence | Task |
|---------|------|
| Every PR | Leaf spec + sensors + QUALITY_SCORE if affected |
| Weekly | Scan active plans; close stale; run `run-sensors.sh doc` |
| After major feature | Full sensor tier; review index statuses draft→verified |
| Monthly | Cross-link audit; trim AGENTS.md; archive completed plans |

## Related

- Sensors: [`SENSORS.md`](SENSORS.md) · Planning: [`PLANS.md`](PLANS.md) · Map: [`../AGENTS.md`](../AGENTS.md)
