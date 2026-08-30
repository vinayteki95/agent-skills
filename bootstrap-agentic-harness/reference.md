# Harness Anatomy & Design Reference

Depth for the `bootstrap-agentic-harness` skill. Read when you need the *why*
behind a file, how to choose optional modules, or what this skill deliberately
improves over a naive copy of an existing harness.

## Mental model

```
Agent entry        →  AGENTS.md, ARCHITECTURE.md, README.md
System of record   →  docs/PRODUCT_SENSE.md, product-specs/, design-docs/, references/
Work tracking      →  docs/PLANS.md, exec-plans/active|completed, tech-debt-tracker, QUALITY_SCORE
Quality loop       →  docs/DOC_MAINTENANCE.md, SENSORS.md, scripts/*.sh, hooks/, CI
```

Core loop an agent runs: **read map → find spec → build depth-first → update
docs + grade + exec plan (same PR) → run sensors → encode repeatable failures
back into the harness.**

## Layers, briefly

The default layer stack (rename per stack in `module-boundaries.md`):

```
Types → Config → Repo → Service → Runtime → UI
```

- Imports flow **downward only**; UI never imports Service directly.
- **Parse external/platform data at the Repo boundary** before it reaches Service.
- Domain logic (Service) is **pure and testable** — no IO, injectable clock.
- Cross-cutting concerns go through **providers** (Clock, Telemetry, Config…),
  not ad-hoc calls scattered in domain code.

For a library/CLI/service the same idea maps to `types → core → adapters →
entrypoints`; keep the names honest to the stack.

## Per-file purpose (core)

| File | Role |
|------|------|
| `AGENTS.md` | The map. Workflow steps, doc index table, domain summary, non-negotiables, PR checklist. **< ~120 lines.** |
| `ARCHITECTURE.md` | Domains + ownership, layer model, providers, canonical data flows, module tree. |
| `README.md` | Human intro; delegates agent depth to AGENTS.md. |
| `docs/PRODUCT_SENSE.md` | Product constitution: pitch, persona, principles, voice, success/failure, metrics + anti-metrics, conflict priority order. |
| `docs/product-specs/index.md` | Catalog of leaf specs + MVP in/out + "adding a spec" process. |
| `docs/product-specs/_TEMPLATE.md` | Leaf spec scaffold ending in **Acceptance criteria** (the pr-self-review source of truth). |
| `docs/design-docs/core-beliefs.md` | Agent-first operating principles (system of record, progressive disclosure, humans steer, enforce boundaries, docs compound…). |
| `docs/design-docs/golden-principles.md` | Mechanical, lint-able code rules. Review blockers until encoded in lint. |
| `docs/design-docs/module-boundaries.md` | Import/dependency law + allowed-import matrix + good/bad examples. |
| `docs/PLANS.md` | Plan types, exec-plan template, depth-first order, merge philosophy, sensor tier by change size. |
| `docs/DOC_MAINTENANCE.md` | **The single anti-drift matrix.** When/how/drift-signal for every doc category. |
| `docs/SENSORS.md` | Sensor catalog, tier definitions, git-hook/CI wiring, failure→harness feedback loop, PR self-review + bug-hunt templates. |
| `docs/QUALITY_SCORE.md` | Per-domain letter grades (Code/Spec/Tests/Notes) + harness maturity; dated. |
| `docs/exec-plans/tech-debt-tracker.md` | Checkbox debt list; move to Resolved with date. |
| `docs/exec-plans/active/` + `completed/` | Living session logs; never delete decision history. |
| `docs/references/` | Dense, agent-scannable facts (tokens, platform APIs, external forms). Master docs link here; don't duplicate tables. |

## Sensors & tiers

`scripts/run-sensors.sh <tier>` emits grep-able `SENSOR <id> PASS|FAIL|SKIP`
lines and `REMEDIATION ...` hints.

| Tier | When | Sensors |
|------|------|---------|
| `quick` | pre-commit | doc-links, lint-copy, security-secrets |
| `doc` | doc-only PR | quick + doc-freshness, index-sync, verify-harness |
| `standard` | PR, pre-push (strict), CI | doc tier + branch-name + **auto-detected stack lint/test** + manual pr-self-review |
| `full` | release / major change | standard + stack build/lint + structural test + manual uat + bug-hunt |

Stack detection (in `run-sensors.sh`): presence of `gradlew`/`build.gradle*`,
`package.json`, `pyproject.toml`/`setup.py`, `go.mod`, or `Cargo.toml` selects
the lint/test/build commands. Missing toolchain → `SKIP`, never a hard fail, so
the harness is useful from commit #1.

### Feedback loop (the point of sensors)

A sensor failure should produce a fix **and**, if repeatable, a harness update:

| Failure | Fix code | Also encode in |
|---------|----------|----------------|
| Boundary/layer violation | move import | `module-boundaries.md` example + lint rule |
| Shame/forbidden copy | reword | `PRODUCT_SENSE.md` bad example + `harness.conf` pattern |
| Missing input validation | add parser | `golden-principles.md` + Service test template |
| Spec vs code mismatch | code or spec | acceptance criterion + `QUALITY_SCORE` row |
| Repeated bug | fix + regression test | spec bullet (+ RELIABILITY note if platform-specific) |
| Secret in diff | remove | `SECURITY.md` checklist + `harness.conf` secret pattern |

## Module selection guide

Recommend optional modules by platform:

| Module | Add when | Provides |
|--------|----------|----------|
| `DESIGN.md` + `references/design-system-reference.md` | any UI (web/mobile) | tokens, components, motion, a11y |
| `SECURITY.md` | handles user data, auth, payments, permissions | data classification, threat model, checklist |
| `RELIABILITY.md` | background jobs, device/OEM variance, SLOs | risk/mitigation matrix, failure copy |
| `DELIVERY.md` | needs release discipline | branching + release-from-tags + CI depth (merges CI_CD/BRANCHING/RELEASE_STRATEGY) |
| `BACKEND.md` | has a server/API/telemetry | endpoint + telemetry + data-egress contract |
| `uat/` | user-facing flows worth E2E proof | Maestro/Playwright flow runner emitting `UAT id PASS/FAIL` |

Core-only is a legitimate choice for libraries and small CLIs.

## What this skill improves over a naive harness copy

Observed drift/anti-patterns in mature harnesses, and the fixes baked in here:

1. **Index/folder drift** (README says "no plans" while plans exist). → New
   `check-index-sync.sh` + `verify-harness.sh` fail when an index and its folder
   disagree.
2. **Vestigial sensors** after a stack pivot (dead backend sensors lingering). →
   `run-sensors.sh` **auto-detects** the stack instead of hardcoding it, and
   `SENSORS.md` catalogs only generic + detected sensors.
3. **Hardcoded scan paths** (copy-lint pointed at a path that moved). → Paths and
   patterns live in `scripts/harness.conf`, one place to update.
4. **Duplicated maintenance tables** across many docs. → `DOC_MAINTENANCE.md` is
   the single matrix; every leaf doc ends with a one-line pointer to it, not a
   copy.
5. **No self-check** that the harness is internally consistent. → `verify-harness.sh`
   is a first-class meta-sensor (map size, token leftovers, index sync, dated
   grades, spec/design-doc registration, exec-plan logs).
6. **Project-specific coupling** (env vars, prefixes, product names hardcoded in
   scripts). → Everything project-specific is a token or a `harness.conf` value,
   so the payload is truly reusable.

## Populate-from-PRD tips

- **Domains drive everything**: they seed the ARCHITECTURE domain map, the
  QUALITY_SCORE rows, and the initial spec list. Get the granularity right in
  Phase 1 (3–10 bounded contexts, each with a clear "owns / does not own").
- **Non-negotiables** in the PRD become both `AGENTS.md` non-negotiables and, if
  mechanical, `golden-principles.md` rules and `harness.conf` patterns (e.g. a
  tone rule → forbidden-copy patterns).
- **Every MVP_IN feature gets a leaf spec** with acceptance criteria before it
  gets code — that criteria list is what pr-self-review checks against.
- Start every domain at grade **C** (spec only). Grades rise as code + tests land.

## Prior art

- OpenAI Harness Engineering: https://openai.com/index/harness-engineering/
- The pattern originated in a production Android app repo; this skill generalizes
  it to any stack while keeping the invariants intact.
