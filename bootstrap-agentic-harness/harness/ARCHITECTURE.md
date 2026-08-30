# {{PROJECT_NAME}} — Architecture

Technical system of record: business domains, layer model, providers, and the
canonical data flows. Stack: **{{PRIMARY_STACK}}**.

Status: **bootstrap** · Last updated: {{DATE}}

## Overview

<!-- FILL: 2–3 sentences on the shape of the system (client/server, monorepo,
     library, data stores, external integrations). Add a diagram if useful. -->

## Business domains

Each domain is a bounded context with a clear owner. "Owns" = source of truth;
"Does not own" = must call another domain/provider.

| Domain | Owns | Does not own |
|--------|------|--------------|
<!-- FILL: one row per domain from AGENTS.md domain map -->

## Layer model

Imports flow **downward only**. See [`docs/design-docs/module-boundaries.md`](docs/design-docs/module-boundaries.md).

```
Types  → data shapes, no logic
Config → constants, feature flags, tunables
Repo   → IO + parse-at-boundary (validate external/platform data here)
Service→ pure domain logic, testable, no IO
Runtime→ orchestration, state, lifecycle
UI     → presentation only
```
<!-- FILL: rename layers to fit the stack (e.g. library: types→core→adapters→api).
     Keep the "parse at boundary" + "pure core" ideas. -->

## Providers (cross-cutting)

Shared abstractions used across domains instead of ad-hoc calls in domain code.

| Provider | Purpose |
|----------|---------|
| Clock | Injectable time (no direct system clock in Service) |
| Telemetry | Logging / analytics behind one interface |
| Config | Runtime configuration + flags |
<!-- FILL: add project providers (Auth, Storage, Http, FeatureFlags...) -->

## Module layout

```
<!-- FILL: package/folder tree once code exists -->
```

## Key data flows

<!-- FILL: 1–2 canonical flows end to end (e.g. "user action → runtime → service
     → repo → store"), as a numbered list or diagram. -->

## Related

- Domains summary: [`AGENTS.md`](AGENTS.md)
- Layer rules: [`docs/design-docs/module-boundaries.md`](docs/design-docs/module-boundaries.md)
- Specs: [`docs/product-specs/index.md`](docs/product-specs/index.md)
- Doc maintenance: [`docs/DOC_MAINTENANCE.md`](docs/DOC_MAINTENANCE.md)
