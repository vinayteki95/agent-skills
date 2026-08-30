# Product Specs Index

Feature specifications — the system of record for **what** {{PROJECT_NAME}} builds.

| Spec | Status | Domain |
|------|--------|--------|
<!-- FILL: one row per leaf spec. Status: draft | implemented | verified -->

## MVP scope (v1)

**In:**

<!-- FILL: MVP_IN bullets -->

**Out / later:**

<!-- FILL: MVP_OUT bullets -->

## Adding a spec

1. Copy [`_TEMPLATE.md`](_TEMPLATE.md) to `docs/product-specs/<feature>.md`
2. Add a row to the table above (status `draft`)
3. Link from [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) if it's a new domain
4. Cross-link related specs
5. End every leaf spec with **Acceptance criteria**; update them when behavior
   changes (same PR) — this list is what the `pr-self-review` sensor checks.

## Related

- Agent map: [`../../AGENTS.md`](../../AGENTS.md)
- Product tone: [`../PRODUCT_SENSE.md`](../PRODUCT_SENSE.md)
- Doc maintenance: [`../DOC_MAINTENANCE.md`](../DOC_MAINTENANCE.md)
