# {{PROJECT_NAME}} — Agent Map

**Tagline:** {{TAGLINE}}

This file is the table of contents for agent work in this repository. It is
intentionally short. Do not treat it as an encyclopedia — follow links into
`docs/` for depth.

## How to work here

1. **Read the task** and identify which domain(s) it touches.
2. **Start with product sense** — [`docs/PRODUCT_SENSE.md`](docs/PRODUCT_SENSE.md) and [`docs/design-docs/core-beliefs.md`](docs/design-docs/core-beliefs.md).
3. **Check architecture boundaries** — [`ARCHITECTURE.md`](ARCHITECTURE.md) before adding dependencies or modules.
4. **Find the spec** — [`docs/product-specs/index.md`](docs/product-specs/index.md).
5. **For multi-step work** — create/follow an exec plan in [`docs/exec-plans/active/`](docs/exec-plans/active/).
6. **Before finishing** — update docs per [`docs/DOC_MAINTENANCE.md`](docs/DOC_MAINTENANCE.md), run sensors per [`docs/SENSORS.md`](docs/SENSORS.md), adjust quality grades.

Every iteration updates docs in the **same PR** as code — no doc drift.

Humans steer. Agents execute. When stuck, ask: *what capability or doc is
missing, and how do we make it legible and enforceable?*

## Product at a glance

<!-- FILL: one paragraph — what this product is, for whom, why it wins -->

Core differentiators:

<!-- FILL: 3–5 bullets of what makes this distinct -->

## Repository layout

```
{{PROJECT_SLUG}}/
├── AGENTS.md          ← you are here
├── ARCHITECTURE.md    ← domains, layers, providers, data flows
├── docs/              ← product sense + specs + process + references
├── scripts/           ← quality sensors + git hooks
└── .github/workflows/ ← CI
```
<!-- FILL: add source dirs (src/, app/, etc.) once code lands -->

## Doc index

| Topic | Document |
|-------|----------|
| Product principles & tone | [`docs/PRODUCT_SENSE.md`](docs/PRODUCT_SENSE.md) |
| Feature specs | [`docs/product-specs/index.md`](docs/product-specs/index.md) |
| Architecture & domains | [`ARCHITECTURE.md`](ARCHITECTURE.md) |
| Module boundaries & layers | [`docs/design-docs/module-boundaries.md`](docs/design-docs/module-boundaries.md) |
| Agent operating principles | [`docs/design-docs/core-beliefs.md`](docs/design-docs/core-beliefs.md) |
| Golden code principles | [`docs/design-docs/golden-principles.md`](docs/design-docs/golden-principles.md) |
| Planning workflow | [`docs/PLANS.md`](docs/PLANS.md) |
| Active work | [`docs/exec-plans/active/`](docs/exec-plans/active/) |
| Tech debt | [`docs/exec-plans/tech-debt-tracker.md`](docs/exec-plans/tech-debt-tracker.md) |
| Quality grades | [`docs/QUALITY_SCORE.md`](docs/QUALITY_SCORE.md) |
| Doc update rules (anti-drift) | [`docs/DOC_MAINTENANCE.md`](docs/DOC_MAINTENANCE.md) |
| Quality sensors & hooks | [`docs/SENSORS.md`](docs/SENSORS.md) |
<!-- FILL: add optional module rows if scaffolded: DESIGN, SECURITY, RELIABILITY, DELIVERY, BACKEND -->

## Domain map (summary)

| Domain | Responsibility |
|--------|----------------|
<!-- FILL: one row per bounded context, one-line responsibility each -->

Full detail: [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Non-negotiables

<!-- FILL: 3–6 hard rules for this product (tone, privacy, safety, perf...).
     Mechanical ones should also live in golden-principles.md + harness.conf. -->
- **Keep docs in sync.** If behavior changes, update the spec and quality grade in the same change.

## Verification checklist (before opening a PR)

- [ ] Leaf spec(s) updated for any behavior change
- [ ] `product-specs/index.md` / `ARCHITECTURE.md` cross-links if new surface area
- [ ] Exec plan Progress log + status updated
- [ ] `QUALITY_SCORE.md` row(s) adjusted
- [ ] Tech debt added or resolved in `tech-debt-tracker.md`
- [ ] `./scripts/run-sensors.sh standard` passes (or `full` after major change)
- [ ] Sensor failures encoded back (golden principle / lint / spec) if repeatable

Install hooks: `git config core.hooksPath scripts/hooks` — pre-commit runs the
**quick** tier automatically.
