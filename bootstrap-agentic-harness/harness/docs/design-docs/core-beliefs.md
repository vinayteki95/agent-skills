# Core Beliefs

Agent-first operating principles for the {{PROJECT_NAME}} repository. These apply
to humans and agents equally. (Pattern: [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/).)

## 1. Repository knowledge is the system of record

If it isn't in the repo (code, markdown, schemas, exec plans), it doesn't exist
for agents. Slack decisions and mental notes must be **promoted** into `docs/`.

## 2. Progressive disclosure over monoliths

[`AGENTS.md`](../../AGENTS.md) is a map, not an encyclopedia. Agents load depth on
demand from linked docs. Never duplicate long spec text upward.

## 3. Humans steer, agents execute

Human leverage: prioritization, acceptance criteria, product judgment, and
validating outcomes. When an agent struggles, fix the **environment** (docs,
tests, lint, providers) — not "try harder."

## 4. Legibility beats cleverness

Optimize for the next agent run: predictable layout, explicit types at
boundaries, testable pure functions for core logic, remediation hints in lint.

## 5. Enforce boundaries, allow local freedom

Central rules: layer direction, parse-at-boundary, product tone, security.
Local freedom: implementation style inside a module — as long as output is
correct and maintainable.

## 6. Docs compound; stale docs decay

Update specs in the same PR as behavior changes. Mark outdated docs
`deprecated` — don't leave traps.

## 7. Continuous garbage collection

Prefer small, frequent refactors. Encode taste once in
[`golden-principles.md`](golden-principles.md) and enforce it mechanically.

## 8. Depth-first delivery

Build Types → Core/Service (+ tests) before UI/polish. Surfaces built on top of
incorrect logic mislead users and reviewers.

## 9. Failures are inputs

Every repeatable sensor or review failure produces a harness update (a golden
principle, a lint rule, or a spec clarification), not just a one-off patch.

<!-- FILL: add product-/stack-specific beliefs (e.g. "device reality first",
     "privacy by default", "offline first") -->

## Related

- Golden principles: [`golden-principles.md`](golden-principles.md)
- Product sense: [`../PRODUCT_SENSE.md`](../PRODUCT_SENSE.md)
