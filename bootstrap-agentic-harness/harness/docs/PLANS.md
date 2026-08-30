# Planning Workflow

How work is specified, tracked, and completed in an agent-first repository.

## Plan types

| Type | When | Location |
|------|------|----------|
| **Lightweight plan** | Single-domain change, < ~1 day | PR description |
| **Exec plan** | Cross-domain, new feature, algorithm work | [`exec-plans/active/`](exec-plans/active/) |
| **Tech debt item** | Known gap or cleanup | [`exec-plans/tech-debt-tracker.md`](exec-plans/tech-debt-tracker.md) |

## Exec plan template

Copy [`exec-plans/_TEMPLATE.md`](exec-plans/_TEMPLATE.md) to
`exec-plans/active/YYYY-MM-DD-short-name.md`. When done, move it to
`exec-plans/completed/` and set the status header.

## Workflow for agents

```
1. Read AGENTS.md map → spec → architecture
2. For large work, create an exec plan FIRST
3. Build depth-first: Types → Config → Repo → Service (+tests) → Runtime → UI
4. Update docs per DOC_MAINTENANCE.md + run sensors per SENSORS.md
5. Append a Progress log entry (each session); mark plan completed when done
```

## Depth-first building

Unlock complexity in order — do not scaffold all UI before the core logic exists:

1. Types + Config
2. Repo + fake providers
3. Service + unit tests
4. Runtime / state
5. UI last

## Review loop

Before requesting human review:

1. Self-review against spec acceptance criteria
2. Run tests / lint (`run-sensors.sh standard`)
3. Verify product tone on all new user-facing strings
4. Check module-boundary imports

## Merge philosophy

Short-lived branches. Prefer follow-up PRs over blocking on perfection when the
remaining work is non-critical polish or environmental flake.

Do **not** merge if: layer rules violated · product-tone regression · unvalidated
external-data parsing · spec marked "not verified" without human sign-off.

## Sensors before merge

| Change size | Run |
|-------------|-----|
| Doc-only | `./scripts/run-sensors.sh doc` |
| Normal PR | `./scripts/run-sensors.sh standard` |
| Major (new domain, algorithm, dependency, migration) | `./scripts/run-sensors.sh full` |

## Related

- [`../AGENTS.md`](../AGENTS.md) · [`exec-plans/tech-debt-tracker.md`](exec-plans/tech-debt-tracker.md) · [`QUALITY_SCORE.md`](QUALITY_SCORE.md)
