# Git hooks

Install once per clone:

```bash
git config core.hooksPath scripts/hooks
```

| Hook | Runs |
|------|------|
| `pre-commit` | `run-sensors.sh quick` (doc-links, copy, secrets) — blocks on failure |
| `commit-msg` | Conventional-commit format check (no Node dependency) |
| `pre-push` | branch name check + `run-sensors.sh standard` (warn-only unless `{{STRICT_ENV}}=1`) |

Hooks are intentionally fast at commit time and deeper at push time. Make push
blocking in CI-like local setups with `export {{STRICT_ENV}}=1`.
