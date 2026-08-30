# Delivery — Branching, CI, Release

Consolidated delivery policy for {{PROJECT_NAME}} (branching + CI + release).

## Branching

- Long-lived branch: `main` only.
- Work branches: `<type>/<slug>` where type ∈
  `feature|fix|hotfix|release|chore|docs|refactor|test` (enforced by
  `scripts/check-branch-name.sh`).
- Short-lived; merge via PR.

## CI

| Workflow | Trigger | Runs |
|----------|---------|------|
| `ci.yml` | PR + push `main` | `run-sensors.sh standard` + detected stack lint/test |
<!-- FILL: add release/UAT workflows if used -->

## Release

Production ships from **tags**, never from `main` directly.

```
main (continuous integration)  →  tag vX.Y.Z  →  release build/deploy
```

- Versioning: SemVer.
- Pre-tag: `run-sensors.sh full` green; changelog updated.
- Hotfix: `hotfix/<slug>` → PR → patch tag.

<!-- FILL: real build/publish/deploy commands for this stack -->

## Maintenance

New workflow/secret/gate → update this doc + the workflow. Full rules:
[`DOC_MAINTENANCE.md`](DOC_MAINTENANCE.md).
