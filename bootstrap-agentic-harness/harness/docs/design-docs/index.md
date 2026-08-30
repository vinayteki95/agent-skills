# Design Docs Index

Catalog of engineering design documents. Each entry links to specs/code and
notes verification status.

| Doc | Status | Summary |
|-----|--------|---------|
| [core-beliefs.md](core-beliefs.md) | verified | Agent-first operating principles |
| [golden-principles.md](golden-principles.md) | verified | Mechanical code rules / taste invariants |
| [module-boundaries.md](module-boundaries.md) | draft | Layer & import dependency rules |

## Adding a design doc

1. Create `docs/design-docs/your-topic.md`
2. Add a row to this index with status: `draft` | `verified` | `deprecated`
3. Link from [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) or the relevant spec
4. If it encodes enforceable rules, wire a lint/sensor and reference it

## Verification status

- **draft** — written, not yet reflected in code
- **verified** — matches implemented behavior
- **deprecated** — superseded; link to replacement

## Doc maintenance

Full matrix: [`../DOC_MAINTENANCE.md`](../DOC_MAINTENANCE.md).
