# Quality Score

Domain health grades for agent navigation. Update in the **same PR** as any
meaningful code or spec change.

**Grading:** A (solid) · B (functional gaps) · C (stub / spec only) · F (broken / misleading docs)

Last updated: **{{DATE}}** (bootstrap)

## Product domains

| Domain | Grade | Code | Spec | Tests | Notes |
|--------|-------|------|------|-------|-------|
<!-- FILL: one row per domain, all starting at C (spec only) -->

## Architecture & harness

| Capability | Grade | Notes |
|------------|-------|-------|
| Progressive-disclosure docs | A | AGENTS.md map + linked depth |
| Golden principles | B | documented; lint pending |
| Module-boundary enforcement | C | documented; no lint yet |
| Doc sensors | A | doc-links, copy, secrets, freshness, index-sync, verify-harness |
| Stack lint/test sensors | C | wire once toolchain lands |
| CI | B | standard tier on PR |
<!-- FILL: adjust as capabilities land -->

## Improvement priorities

<!-- FILL: ordered list of the next few things to raise grades -->

## How to update

1. Adjust the affected domain row(s).
2. Bump **Last updated** at the top.
3. If a grade improves, explain in Notes; if it drops, add a
   [`exec-plans/tech-debt-tracker.md`](exec-plans/tech-debt-tracker.md) entry.

**Who:** the agent, in the same PR as the change — never defer.

Full matrix: [`DOC_MAINTENANCE.md`](DOC_MAINTENANCE.md).
