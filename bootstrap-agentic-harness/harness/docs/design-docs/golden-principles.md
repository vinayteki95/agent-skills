# Golden Principles

Mechanical rules that keep the codebase legible for future agent runs. Encode in
lint where possible; until then, treat as review blockers.

## Code structure

1. **Layer direction is law** — see [`module-boundaries.md`](module-boundaries.md). No upward imports.
2. **Parse at boundaries** — validate external/platform/network data in the Repo layer before it reaches core logic.
3. **No guessing external shapes** — use typed mappers + tests, not field-probing.
4. **Prefer shared providers** over ad-hoc cross-cutting calls in domain code.
5. **File size** — soft cap ~400 lines; split files that mix layers or unrelated concerns.

## Domain logic

6. **Core logic is pure** — Service functions take typed inputs, return typed outputs; no IO.
7. **Behavior is data-driven** — thresholds/variants live in Config, not scattered conditionals.
8. **Time is injectable** — use the Clock provider; never call the system clock in tested paths.

## UI & copy

9. **No magic values in views** — use semantic tokens/constants, not inline literals.
10. **Copy review** — new user-facing strings pass the product-tone checklist (see [`../PRODUCT_SENSE.md`](../PRODUCT_SENSE.md)).

## Testing

11. **Core tests required** — any change to domain decision logic includes unit tests.
12. **Regression tests for bugs** — reproduce with a failing test before fixing.

## Documentation

13. **Same-PR doc updates** — behavior change → leaf spec + QUALITY_SCORE if grade affected.
14. **Cross-link new specs** — register in [`../product-specs/index.md`](../product-specs/index.md).

<!-- FILL: add stack-specific rules (e.g. null-safety, error handling, async) -->

## Lint remediation template

Custom lint messages should name the rule and the fix:

```
[{{PROJECT_SLUG}}-layers] UI must not import Service directly.
Fix: expose data via Runtime/ViewModel. See docs/design-docs/module-boundaries.md
```

## Doc maintenance

| When | How |
|------|-----|
| Same review comment twice | Add a numbered rule here |
| Sensor fails on a repeatable mistake | Add rule + extend a `scripts/check-*.sh` or lint |
| Rule enforced in lint | Reference the rule ID in the lint remediation text |

Full matrix: [`../DOC_MAINTENANCE.md`](../DOC_MAINTENANCE.md).
