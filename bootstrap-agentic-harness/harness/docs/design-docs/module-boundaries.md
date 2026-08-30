# Module Boundaries

The import/dependency law for {{PROJECT_NAME}}. Keeps domains decoupled and core
logic testable.

## Layer stack

```
Types  → Config → Repo → Service → Runtime → UI
```
<!-- FILL: rename to fit the stack. Keep the direction + boundary + purity ideas. -->

## Allowed imports

A layer may import only from layers **below** it.

| Layer | May import | Must NOT import |
|-------|-----------|-----------------|
| Types | (nothing) | anything with logic |
| Config | Types | Repo/Service/Runtime/UI |
| Repo | Types, Config, providers | Service/Runtime/UI |
| Service | Types, Config | Repo, Runtime, UI, IO |
| Runtime | Types, Config, Service, Repo | UI |
| UI | Runtime (view models), Types | Service, Repo directly |

## Cross-domain rules

- Domains talk through **Service interfaces or providers**, never by reaching
  into another domain's Repo/internal types.
- Shared concerns (time, logging, config, auth) go through **providers**.
- **Parse at the boundary**: external/platform/network payloads become typed
  domain data in the Repo layer, with validation + tests.

## Examples

**Good**
```
// UI reads a view-model exposed by Runtime; Service stays pure.
```
<!-- FILL: replace with a real good example in {{PRIMARY_STACK}} -->

**Bad**
```
// UI imports Service and calls domain logic directly — layer violation.
```
<!-- FILL: replace with a real bad example in {{PRIMARY_STACK}} -->

## Enforcement

- Document the rule here (status `draft`).
- Add a lint/architecture test that fails on upward imports; then set this doc
  `verified` in [`index.md`](index.md).

## Related

- Golden principles: [`golden-principles.md`](golden-principles.md)
- Architecture: [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md)
