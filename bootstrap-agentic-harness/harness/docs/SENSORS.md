# Quality Sensors

Automated and agent-driven checks that observe repo health and **feed failures
back** into code, lint, and docs. Sensors answer: *is the harness still true?*

Run via [`../scripts/run-sensors.sh`](../scripts/run-sensors.sh). Install git
hooks: [`../scripts/hooks/README.md`](../scripts/hooks/README.md).

## Philosophy

1. **Fast by default** — pre-commit runs only quick sensors (< ~30s).
2. **Tiered depth** — bigger changes trigger standard/full tiers before merge.
3. **Failures are inputs** — every repeatable failure produces a fix *and* a
   harness update (lint rule, spec clarification, golden principle).
4. **Agent-readable output** — scripts print `SENSOR <id> PASS|FAIL|SKIP` and
   `REMEDIATION ...` lines agents can grep.
5. **Stack-agnostic** — lint/test/build sensors auto-detect the toolchain and
   `SKIP` (never hard-fail) when it is absent, so the harness works from day one.

## Sensor catalog

| ID | Checks | Source |
|----|--------|--------|
| `doc-links` | Internal markdown links resolve | `scripts/check-doc-links.sh` |
| `lint-copy` | Forbidden user-facing copy (from `harness.conf`) | `scripts/check-copy.sh` |
| `security-secrets` | No keys/keystores/secrets in diff | `scripts/check-secrets.sh` |
| `doc-freshness` | Active plans logged; grades dated | `scripts/check-doc-freshness.sh` |
| `index-sync` | Indexes match their folders | `scripts/check-index-sync.sh` |
| `verify-harness` | Harness self-consistency | `scripts/verify-harness.sh` |
| `branch-name` | Branch naming convention | `scripts/check-branch-name.sh` |
| stack lint/test | Auto-detected: node/gradle/python/go/cargo | `run-sensors.sh` |
| `pr-self-review` | Changed files vs spec acceptance criteria | agent checklist below |
| `bug-hunt` | Regressions, boundary cases, platform risks | agent pass below |

## Tiers — when to run

| Tier | When | Sensors |
|------|------|---------|
| **quick** | Every commit (pre-commit) | `doc-links`, `lint-copy`, `security-secrets` |
| **doc** | Doc-only PR | quick + `doc-freshness`, `index-sync`, `verify-harness` |
| **standard** | Every PR; pre-push (strict) | doc tier + `branch-name` + detected stack lint/test + `pr-self-review` |
| **full** | Release; major change | standard + build/structural + `uat` + `bug-hunt` |

### What counts as a "major change"

- New domain or cross-domain data flow
- Core algorithm / decision-logic change
- New external dependency, permission, or network surface
- Schema/data migration

→ Run **full** before merge and update SECURITY/RELIABILITY if present.

## Git hook integration

```
pre-commit  →  run-sensors.sh quick
commit-msg  →  conventional-commit format check
pre-push    →  branch-name + run-sensors.sh standard (warn unless {{STRICT_ENV}}=1)
```

Install: `git config core.hooksPath scripts/hooks`

## Feedback loop — failure → harness fix

| Failure | Fix code | Also update harness |
|---------|----------|---------------------|
| Boundary/layer violation | move import | `module-boundaries.md` example + lint |
| Forbidden copy | reword | `PRODUCT_SENSE.md` bad example + `harness.conf` pattern |
| Missing input validation | add parser | `golden-principles.md` + test template |
| Spec vs code mismatch | code or spec | acceptance criterion + `QUALITY_SCORE` |
| Repeated bug | fix + regression test | spec bullet (+ RELIABILITY note) |
| Secret in diff | remove | `SECURITY.md` checklist + `harness.conf` pattern |

### Encoding feedback (agent workflow)

1. Fix the immediate issue.
2. If repeatable → add a golden principle or extend a sensor script.
3. If a knowledge gap → update the leaf spec or an architecture doc.
4. Log in the exec plan: `Sensor X failed → fixed Y → encoded in Z`.
5. Re-run the tier until green.

## PR self-review sensor (agent)

```markdown
## Self-review (pr-self-review)
Spec: docs/product-specs/___
Acceptance criteria met:
- [ ] ...
Files changed vs spec scope: OK / drift (explain)
Boundary check: no upward-layer imports
Copy check: no forbidden terms
Tests: added/updated for core-logic changes
Docs: leaf spec + QUALITY_SCORE + exec plan log updated
Sensors: ./scripts/run-sensors.sh standard → PASS
```

## Bug-finding sensor (agent)

```
Domain: [...]
Spec: [link]
Task: find regressions, boundary cases, failure/permission paths.
Output per finding: severity · repro/test · suggested fix · harness update
```

## Output format

```
SENSOR doc-links PASS
SENSOR gradle-test SKIP (gradlew missing)
SENSOR lint-copy FAIL docs/product-specs/foo.md:42 matched forbidden copy
REMEDIATION See docs/PRODUCT_SENSE.md — remove forbidden language
```

Agents: grep `FAIL` and `REMEDIATION` before declaring done.

## Related

- Doc rules: [`DOC_MAINTENANCE.md`](DOC_MAINTENANCE.md)
- Golden principles: [`design-docs/golden-principles.md`](design-docs/golden-principles.md)
- Quality grades: [`QUALITY_SCORE.md`](QUALITY_SCORE.md)
