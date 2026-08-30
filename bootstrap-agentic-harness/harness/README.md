# {{PROJECT_NAME}}

> {{TAGLINE}}

<!-- FILL: 1–2 sentence human-facing description -->

**Stack:** {{PRIMARY_STACK}}
**Status:** bootstrap

## For agents

Start at [`AGENTS.md`](AGENTS.md) — the map for how to work in this repo.

## Quick start

```bash
# install git hooks (quick sensors on commit)
git config core.hooksPath scripts/hooks

# run quality sensors
scripts/run-sensors.sh quick       # fast (doc-links, copy, secrets)
scripts/run-sensors.sh standard    # PR tier (adds stack lint/test + self-check)
scripts/verify-harness.sh          # harness self-consistency check
```
<!-- FILL: add real build/run/test commands once the stack is set up -->

## Layout

```
docs/               product sense, specs, process, references
scripts/            quality sensors + git hooks
.github/workflows/  CI
```

## Docs

| Topic | Doc |
|-------|-----|
| Agent map | [`AGENTS.md`](AGENTS.md) |
| Architecture | [`ARCHITECTURE.md`](ARCHITECTURE.md) |
| Product sense | [`docs/PRODUCT_SENSE.md`](docs/PRODUCT_SENSE.md) |
| Specs | [`docs/product-specs/index.md`](docs/product-specs/index.md) |
| Quality grades | [`docs/QUALITY_SCORE.md`](docs/QUALITY_SCORE.md) |
