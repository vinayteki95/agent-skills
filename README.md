# agent-skills

Public home for Cursor Agent Skills. This repository currently ships one skill:

**[`bootstrap-agentic-harness`](./bootstrap-agentic-harness/)** — turn a PRD, tech doc, or one-paragraph vision into a fully wired **agent-first repository**: a short `AGENTS.md` map, a `docs/` system of record, living exec plans, tiered quality sensors, git hooks, and CI.

The harness is stack-agnostic and **self-verifying**. Agents do not just generate files and leave. They populate product truth from your PRD, wire sensors to the real toolchain, then prove the harness is internally consistent before they stop.

Philosophy is distilled from [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/): progressive disclosure, same-PR doc sync, and **failures encoded back into the harness**. Depth on *why* each file exists lives in [`bootstrap-agentic-harness/reference.md`](./bootstrap-agentic-harness/reference.md). The agent procedure lives in [`bootstrap-agentic-harness/SKILL.md`](./bootstrap-agentic-harness/SKILL.md).

---

## Table of contents

1. [What problem this solves](#what-problem-this-solves)
2. [Mental model](#mental-model)
3. [Install the skill](#install-the-skill)
4. [How to use it](#how-to-use-it)
5. [What the agent does (phases 0–5)](#what-the-agent-does-phases-0–5)
6. [Folder structure this repo uses](#folder-structure-this-repo-uses)
7. [Folder structure the skill creates in a target repo](#folder-structure-the-skill-creates-in-a-target-repo)
8. [What each created file is for](#what-each-created-file-is-for)
9. [How the agent stays self-learning](#how-the-agent-stays-self-learning)
10. [How the agent stays self-healing](#how-the-agent-stays-self-healing)
11. [Sensor tiers and the quality loop](#sensor-tiers-and-the-quality-loop)
12. [Optional modules](#optional-modules)
13. [Invariants the skill refuses to dilute](#invariants-the-skill-refuses-to-dilute)
14. [After bootstrap — day-to-day agent workflow](#after-bootstrap--day-to-day-agent-workflow)
15. [Manual scaffold (no agent)](#manual-scaffold-no-agent)
16. [Publishing and contributing](#publishing-and-contributing)

---

## What problem this solves

Most “agent-ready” repos fail in the same ways:

- Knowledge lives in Slack, someone’s head, or a 2,000-line `AGENTS.md` that no model can hold in context.
- Specs and code diverge after the first week. The next agent trusts the stale spec.
- Lint and tests are hardcoded to last quarter’s stack. After a pivot they become vestigial or they hard-fail on day one.
- Review comments repeat (“don’t import Service from UI”, “don’t say *just* in user copy”) and never become a rule.
- Indexes lie: a README says “no plans” while `docs/exec-plans/active/` is full.

This skill bootstraps the opposite: a **small map**, a **system of record**, **mechanical sensors**, and a **feedback loop** that turns every repeatable failure into a principle, a lint rule, or a spec.

It is not a product template. It does not pick React vs Rails for you. It installs the *operating system* an agent needs to build *your* product without drifting.

---

## Mental model

```
Agent entry        →  AGENTS.md, ARCHITECTURE.md, README.md
System of record   →  docs/PRODUCT_SENSE.md, product-specs/, design-docs/, references/
Work tracking      →  docs/PLANS.md, exec-plans/active|completed, tech-debt-tracker, QUALITY_SCORE
Quality loop       →  docs/DOC_MAINTENANCE.md, SENSORS.md, scripts/*.sh, hooks/, CI
```

The loop an agent runs on every real task:

```
read map
  → find the leaf spec
    → build depth-first (types → core → adapters → UI)
      → update docs + quality grade + exec-plan log (same PR)
        → run sensors
          → encode repeatable failures back into the harness
```

If it is not in the repo (code, markdown, schemas, exec plans), it does not exist for the next agent. Chat decisions must be **promoted** into `docs/`.

---

## Install the skill

Cursor loads skills from `~/.cursor/skills/<skill-name>/SKILL.md` (user skills) or from a project’s `.cursor/skills/`.

### Option A — clone this repo and symlink (recommended)

Keeps the published skill in sync with `git pull`.

```bash
git clone git@github.com:vinayteki95/agent-skills.git ~/Projects/agent-skills

mkdir -p ~/.cursor/skills
ln -sfn ~/Projects/agent-skills/bootstrap-agentic-harness \
        ~/.cursor/skills/bootstrap-agentic-harness
```

Confirm Cursor can see `SKILL.md`:

```bash
ls ~/.cursor/skills/bootstrap-agentic-harness/SKILL.md
```

### Option B — copy into user skills

```bash
cp -R bootstrap-agentic-harness ~/.cursor/skills/bootstrap-agentic-harness
```

### Option C — project-local skill

Copy `bootstrap-agentic-harness/` into a product repo as `.cursor/skills/bootstrap-agentic-harness/` so only that workspace gets the skill.

Restart Cursor or start a new agent chat after installing. Mention the skill by name, or attach it, when you want a new repo harnessed.

---

## How to use it

### 1. Give the agent something to harness

Any of these is enough:

- A PRD or tech spec (paste or point at a file).
- A one-paragraph vision (“a CLI that reviews PRs for copy tone”).
- An existing empty or half-started repo you want brought under the harness.

The agent extracts an **intake block** (name, users, stack, domains, MVP in/out, optional modules). Missing fields get a marked `(assumed)` default. It only asks when a choice would change scaffolding — usually **stack**, **domain granularity**, and **optional modules**.

### 2. Point at a target repo

The skill scaffolds **into a product repository**, not into this skills repo.

Examples of prompts:

```
Use bootstrap-agentic-harness on ~/Projects/acme-billing.

PRD: we are building a web app for freelance accountants to send invoices
and collect Stripe payments. TypeScript, Next.js, Postgres.

MVP in: auth, invoice CRUD, Stripe Checkout, PDF export.
MVP out: payroll, multi-entity, mobile.
```

```
/bootstrap-agentic-harness

Here's the tech doc. Create the harness in this repo. I want design +
security + delivery modules. Stack is Go + Postgres.
```

```
Bootstrap an agentic harness for this vision: a Python library that
normalizes bank CSVs. No UI. Core-only modules.
```

### 3. Let the agent run the five phases

You should see it:

1. Extract intake facts.
2. Confirm only the decisions that change the tree.
3. Run `scripts/bootstrap.sh` into the **target** repo.
4. Replace every `{{TOKEN}}` and `<!-- FILL: ... -->` from the PRD.
5. Wire `harness.conf`, sensors, CI, and the first exec plan.
6. Run `verify-harness.sh` and `run-sensors.sh` until green.

### 4. What you review

The interesting review is **not** “did files appear.” It is:

- Are the **domains** the real bounded contexts (3–10, each with owns / does not own)?
- Is `PRODUCT_SENSE.md` a constitution you would actually enforce (voice, anti-metrics, conflict priority)?
- Does every **MVP_IN** feature have a leaf spec with **acceptance criteria**?
- Did optional modules match the platform (UI → design, auth/payments → security, and so on)?

Grades start at **C** (spec only). That is correct. They rise when code and tests land.

---

## What the agent does (phases 0–5)

Copied from the skill so you know the contract. The agent tracks this checklist.

### Phase 0 — Intake

Read the PRD / vision and extract:

| Field | Meaning |
|-------|---------|
| `PROJECT_NAME` | Short, repo-friendly name |
| `TAGLINE` | One-line promise |
| `ONE_LINER` | Problem + for whom |
| `USERS` | Primary persona(s) |
| `PLATFORM` | web / mobile / cli / service / library / monorepo |
| `STACK` | Languages + frameworks + datastore (drives sensors + CI) |
| `DOMAINS` | 3–10 bounded contexts, one line each |
| `NON_NEGOTIABLES` | 3–6 hard product/eng rules |
| `MVP_IN` / `MVP_OUT` | Ships in v1 vs explicitly deferred |
| `OPTIONAL_MODULES` | Subset of `{design, security, reliability, delivery, backend, uat}` |

### Phase 1 — Confirm essentials

Only surface decisions that cannot be safely inferred: stack (if vague), domain list (wrong granularity is expensive), optional modules. Naming, formatting, and defaults are decided and noted — not dumped on you as a questionnaire.

### Phase 2 — Scaffold

```bash
bash bootstrap-agentic-harness/scripts/bootstrap.sh \
  --target "<absolute-path-to-repo>" \
  --name "PROJECT_NAME" \
  --tagline "TAGLINE" \
  --stack "STACK" \
  --modules "design,security,delivery" \
  --install-hooks
```

The script is **idempotent**. It refuses to overwrite existing tracked files unless `--force`. It substitutes `{{PROJECT_NAME}}`, `{{TAGLINE}}`, `{{PRIMARY_STACK}}`, `{{DATE}}`, `{{STRICT_ENV}}`, `{{PROJECT_SLUG}}`.

### Phase 3 — Populate from the PRD

Depth-first, same order agents will later build code:

1. `docs/PRODUCT_SENSE.md` — pitch, persona, principles, voice do/don’t, success vs failure, metrics + anti-metrics, conflict priority.
2. `ARCHITECTURE.md` — domain map, layer stack, providers, 1–2 canonical data flows.
3. `AGENTS.md` — doc-index table, domain summary, non-negotiables. **Stay under ~120 lines.** Link out; never paste spec bodies.
4. `docs/product-specs/` — one leaf spec per MVP_IN feature, registered in `index.md` as `draft`.
5. `docs/design-docs/` — core beliefs, golden principles, module boundaries tailored to the stack.
6. `docs/QUALITY_SCORE.md` — one row per domain, all starting `C`, dated today.
7. Optional modules — only the ones scaffolded.

Then the agent searches the target repo for leftover `{{` and `FILL:` markers.

### Phase 4 — Wire to the real stack

- `scripts/harness.conf` — project slug, strict env prefix, copy/secret patterns, scan paths.
- `scripts/run-sensors.sh` — confirm auto-detected gradle / npm / python / go / cargo commands.
- `.github/workflows/ci.yml` — toolchain versions if the stack needs them.
- First exec plan in `docs/exec-plans/active/` from the template, with a dated Progress log.
- First real items in `tech-debt-tracker.md`.

### Phase 5 — Verify

```bash
cd <target-repo>
scripts/verify-harness.sh        # meta invariants
scripts/run-sensors.sh doc       # links, freshness, index sync
scripts/run-sensors.sh standard  # once a toolchain exists
```

Every `FAIL` is fixed before the agent stops. `verify-harness.sh` must be green: map size, index sync, dated grades, every spec linked, every design-doc indexed, no stray tokens.

---

## Folder structure this repo uses

```
agent-skills/
├── README.md                          ← you are here
├── LICENSE
├── .gitignore
└── bootstrap-agentic-harness/         ← Cursor skill (symlink this folder)
    ├── SKILL.md                       ← agent procedure (phases, invariants, tokens)
    ├── reference.md                   ← anatomy, module guide, why vs a naive copy
    ├── scripts/
    │   └── bootstrap.sh               ← scaffolder: copy payload, tokens, modules, hooks
    └── harness/                       ← payload copied into the *target* product repo
        ├── AGENTS.md
        ├── ARCHITECTURE.md
        ├── README.md
        ├── .github/workflows/ci.yml
        ├── docs/                      ← templates + FILL markers
        ├── scripts/                   ← sensors, harness.conf, git hooks
        └── optional/                  ← uat runner (only if --modules includes uat)
```

`SKILL.md` is the instruction the agent follows. `harness/` is the **payload**, not a product. Do not treat `harness/AGENTS.md` as a finished map — it is full of tokens until Phase 3 runs against a real PRD.

---

## Folder structure the skill creates in a target repo

After `bootstrap.sh` (core only):

```
<target-repo>/
├── AGENTS.md                          # short map — workflow, doc index, domains, non-negotiables
├── ARCHITECTURE.md                    # domains, layers, providers, data flows
├── README.md                          # human intro → points to AGENTS.md
├── docs/
│   ├── PRODUCT_SENSE.md               # product / tone constitution
│   ├── QUALITY_SCORE.md               # per-domain health grades
│   ├── DOC_MAINTENANCE.md             # single anti-drift matrix (source of truth)
│   ├── SENSORS.md                     # sensor catalog + tiers + feedback loop
│   ├── PLANS.md                       # planning workflow + exec-plan template
│   ├── design-docs/
│   │   ├── index.md
│   │   ├── core-beliefs.md            # agent-first operating principles
│   │   ├── golden-principles.md       # mechanical, lint-able code rules
│   │   └── module-boundaries.md       # import / dependency law
│   ├── product-specs/
│   │   ├── index.md                   # catalog + MVP in/out
│   │   └── _TEMPLATE.md               # leaf spec ending in acceptance criteria
│   ├── exec-plans/
│   │   ├── _TEMPLATE.md
│   │   ├── tech-debt-tracker.md
│   │   ├── active/                    # living session logs
│   │   └── completed/                 # never delete decision history
│   └── references/                    # dense, agent-scannable lookup facts
├── scripts/
│   ├── harness.conf                   # slug, patterns, scan paths
│   ├── run-sensors.sh                 # tiered orchestrator: quick | doc | standard | full
│   ├── verify-harness.sh              # meta-sensor: is the harness still true?
│   ├── check-doc-links.sh
│   ├── check-doc-freshness.sh
│   ├── check-index-sync.sh
│   ├── check-copy.sh
│   ├── check-secrets.sh
│   ├── check-branch-name.sh
│   └── hooks/
│       ├── pre-commit                 # quick tier
│       ├── commit-msg                 # conventional commits
│       └── pre-push                   # standard tier (warn unless STRICT=1)
└── .github/workflows/ci.yml           # standard tier + commit lint
```

Optional files land only when requested via `--modules`:

| Module | Files added |
|--------|-------------|
| `design` | `docs/DESIGN.md`, `docs/references/design-system-reference.md` |
| `security` | `docs/SECURITY.md` |
| `reliability` | `docs/RELIABILITY.md` |
| `delivery` | `docs/DELIVERY.md` |
| `backend` | `docs/BACKEND.md` |
| `uat` | `uat/README.md`, `uat/scripts/run-uat.sh` |

Default layer model the architecture doc starts from (rename to match the stack):

```
Types → Config → Repo → Service → Controls → UI
```

Imports flow **downward only**. External/platform data is parsed at the Repo boundary. Domain logic is pure. Cross-cutting concerns go through providers (Clock, Telemetry, Config), not ad-hoc calls.

---

## What each created file is for

| File | Role |
|------|------|
| `AGENTS.md` | The map. Workflow, doc index, domain summary, non-negotiables, PR checklist. **< ~120 lines.** |
| `ARCHITECTURE.md` | Domains + ownership, layer model, providers, canonical data flows, module tree. |
| `README.md` | Human intro. Delegates agent depth to `AGENTS.md`. |
| `docs/PRODUCT_SENSE.md` | Pitch, persona, principles, voice, success/failure, metrics + anti-metrics, conflict priority. |
| `docs/product-specs/` | Leaf specs. Acceptance criteria are the source of truth for PR self-review. |
| `docs/design-docs/core-beliefs.md` | Agent-first operating principles. |
| `docs/design-docs/golden-principles.md` | Mechanical code rules. Review blockers until encoded in lint. |
| `docs/design-docs/module-boundaries.md` | Import law + allowed-import matrix + good/bad examples. |
| `docs/PLANS.md` | Plan types, depth-first order, merge philosophy, sensor tier by change size. |
| `docs/DOC_MAINTENANCE.md` | **The only anti-drift matrix.** Leaf docs link here; they do not copy it. |
| `docs/SENSORS.md` | Catalog, tiers, hook/CI wiring, failure → harness loop, review templates. |
| `docs/QUALITY_SCORE.md` | Per-domain letter grades (Code / Spec / Tests / Notes) + harness maturity. Dated. |
| `docs/exec-plans/` | Living session logs + tech-debt checkbox list. |
| `docs/references/` | Dense facts (tokens, APIs, forms). Master docs link here; do not duplicate tables. |
| `scripts/verify-harness.sh` | Meta-sensor: required files, map size, leftover tokens, FILL markers, dated grades, index sync. |
| `scripts/run-sensors.sh` | Emits grep-able `SENSOR <id> PASS\|FAIL\|SKIP` and `REMEDIATION ...` lines. |

---

## How the agent stays self-learning

“Self-learning” here does **not** mean the model fine-tunes itself. It means the **repository becomes smarter than the last run**, so the next agent (or a different model) inherits the lesson.

The mechanism is: **promote ephemeral knowledge into durable, enforceable artifacts.**

### 1. Progressive disclosure

`AGENTS.md` stays a map. Agents load depth on demand. That keeps context small and lets knowledge grow without turning the entry file into sludge. New docs get **one row in the index**, not a paste of the spec.

### 2. Same PR for code + docs

Every behavior change updates the **leaf spec** and the **QUALITY_SCORE** row in the same change. Doc drift is defined as a harness failure — the same class of bug as a failing test. The next agent cannot “learn” a lie if the spec is not allowed to rot.

### 3. Exec plans are session memory

Multi-step work lives in `docs/exec-plans/active/`. Every session **must** append a Progress log entry (what ran, what failed, what was decided). Completed plans move to `completed/` — decision history is never deleted. The next agent reads the log instead of rediscovering a dead end.

### 4. Failures become curriculum

A one-off bug gets a fix. A **repeatable** bug gets encoded:

| Repeatable failure | What the agent writes back |
|--------------------|----------------------------|
| Same review comment twice | New numbered rule in `golden-principles.md` + lint if mechanical |
| Layer / import violation | Example in `module-boundaries.md` + import lint |
| Forbidden user-facing copy | Bad example in `PRODUCT_SENSE.md` + pattern in `harness.conf` |
| Spec vs code mismatch | Acceptance criterion + grade note |
| Platform-specific outage | Spec bullet and, if present, `RELIABILITY.md` |
| Secret in a diff | `SECURITY.md` checklist + secret pattern |

After that, the *sensor* fails next time — the agent does not need to remember the chat.

### 5. Quality grades are a learning signal

Domains start at **C** (spec only). As code and tests land, the grade moves. A grade that says **A** with no tests is a drift signal (`check-doc-freshness` / human review). Agents treat the scoreboard as “what is still weak,” not vanity.

### 6. Indexes must match folders

`check-index-sync.sh` fails when `product-specs/index.md` or `design-docs/index.md` disagrees with the files on disk. The catalog cannot silently forget a spec. That is how the system learns *what exists*.

### 7. Humans steer; agents execute

When an agent struggles, the prescribed move is to fix the **environment** (a missing spec, a missing sensor, a fuzzy boundary) — not “try harder.” That is the learning step: upgrade the harness so the next run does not need heroics.

---

## How the agent stays self-healing

“Self-healing” means the harness **detects its own inconsistency and will not stay green until repaired.**

### Meta-sensor: `verify-harness.sh`

This is the immune system for the harness itself. It fails when:

- Required core files are missing.
- `AGENTS.md` exceeded the line budget (map became an encyclopedia).
- Unfilled `{{TOKENS}}` remain in markdown / yaml.
- `<!-- FILL: -->` markers were left in the living docs.
- `QUALITY_SCORE.md` has no `Last updated:` date.
- An index file and its folder disagree.

Other sensors assume this structure. If the meta-sensor is red, the rest of the loop is not trustworthy.

### Tiered sensors that refuse silent rot

```
pre-commit   →  run-sensors.sh quick      (links, forbidden copy, secrets)
doc-only PR  →  run-sensors.sh doc        (quick + freshness + index-sync + verify-harness)
PR / CI      →  run-sensors.sh standard   (doc + branch name + stack lint/test)
release      →  run-sensors.sh full       (standard + build + UAT + bug-hunt)
```

Output is agent-parseable:

```
SENSOR doc-links PASS
SENSOR index-sync FAIL
REMEDIATION add docs/product-specs/invoices.md to product-specs/index.md
```

The agent greps `FAIL`, applies the remediation, **and** if the failure is repeatable, encodes it (see above). Then it re-runs the tier until green.

### Stack auto-detect (no vestigial sensors)

`run-sensors.sh` looks for `gradlew` / `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml`. Missing toolchain → `SKIP`, never a hard fail. The harness is useful from commit #1, and a stack pivot does not leave dead backend sensors failing forever.

### Central config instead of hardcoded paths

Copy patterns, secret patterns, spec scan paths, and the strict-mode env var live in `scripts/harness.conf`. When a path moves, you fix one file. Sensors do not rot because someone renamed `src/` to `app/`.

### Git hooks + CI as the backstop

Hooks are installed with:

```bash
git config core.hooksPath scripts/hooks
```

- `pre-commit` — quick tier, so broken links and secrets never enter history.
- `commit-msg` — conventional commit shape.
- `pre-push` — standard tier; warns unless `<SLUG>_STRICT=1`.
- GitHub Actions `.github/workflows/ci.yml` — standard tier on the PR, so a laptop with hooks disabled cannot merge a broken harness.

### Same-PR rule as healing, not ceremony

If code lands and the spec does not, the next agent will “heal” in the wrong direction — it will implement the stale spec or invent a third behavior. Forcing the update in the same PR is how the system heals **toward truth**.

### Continuous garbage collection

`core-beliefs.md` tells agents to prefer small, frequent refactors and to mark outdated docs `deprecated` instead of leaving traps. Stale docs are treated as defects. That is healing the knowledge graph, not just the build.

---

## Sensor tiers and the quality loop

```
                    ┌─────────────┐
                    │  Agent work │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ Run sensors │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
           PASS          SKIP          FAIL
              │            │            │
              │         (no toolchain   │
              │          / not in tier) │
              │                         ▼
              │              fix code or docs
              │                         │
              │                         ▼
              │              repeatable?
              │                    │
              │           no       │ yes
              │            │       ▼
              │            │  encode into
              │            │  golden principle /
              │            │  lint / spec /
              │            │  harness.conf
              │            │       │
              └────────────┴───────┘
                           │
                           ▼
                    re-run until green
                           │
                           ▼
              update QUALITY_SCORE + exec-plan log
```

| Tier | When | What runs |
|------|------|-----------|
| **quick** | Every commit | `doc-links`, `lint-copy`, `security-secrets` |
| **doc** | Doc-only PR | quick + `doc-freshness`, `index-sync`, `verify-harness` |
| **standard** | Every PR; strict pre-push; CI | doc + `branch-name` + detected stack lint/test + PR self-review |
| **full** | Release or major change | standard + build/structural + UAT + bug-hunt |

A **major change** means a new domain, a core algorithm change, a new external dependency or permission, or a schema migration. Full tier, then update SECURITY / RELIABILITY if those modules exist.

---

## Optional modules

Recommend from platform. Core-only is correct for libraries and small CLIs.

| Module | Add when | Provides |
|--------|----------|----------|
| `design` | Any UI (web / mobile) | Tokens, components, motion, a11y |
| `security` | User data, auth, payments, permissions | Data classification, threat model, checklist |
| `reliability` | Background jobs, device/OEM variance, SLOs | Risk / mitigation matrix, failure copy |
| `delivery` | Release discipline | Branching, tag-based release, CI depth |
| `backend` | Server / API / telemetry | Endpoint + telemetry + data-egress contract |
| `uat` | User-facing flows worth E2E proof | Flow runner emitting `UAT id PASS/FAIL` |

Pass them as a comma list:

```bash
--modules "design,security,reliability,delivery,backend,uat"
```

---

## Invariants the skill refuses to dilute

These are what make the harness work. Encode them; do not “simplify” them away.

1. `AGENTS.md` stays a **map** (< ~120 lines). Link for depth.
2. **Same PR** for code + docs. Doc drift is a harness failure.
3. Every behavior change updates its **leaf spec + QUALITY_SCORE** row.
4. **Sensor failures are inputs**: repeatable ones get a golden principle, a lint rule, or a spec — not just a patch.
5. Exec plans get a **Progress log entry every session**.
6. Tiered sensors: **quick** (commit) → **standard** (PR) → **full** (release).
7. **One** maintenance matrix (`DOC_MAINTENANCE.md`). Leaf docs link to it.
8. **Indexes must match their folders** — enforced by `check-index-sync.sh`.

What this skill fixes versus a naive copy of a mature harness is spelled out in [`reference.md`](./bootstrap-agentic-harness/reference.md): index/folder drift, vestigial stack sensors, hardcoded scan paths, duplicated maintenance tables, no self-check, and project-specific coupling.

---

## After bootstrap — day-to-day agent workflow

Once the target repo is harnessed, you do **not** re-run this skill on every feature. You work *inside* the harness:

1. Read the task. Identify domain(s).
2. Start with `docs/PRODUCT_SENSE.md` and `docs/design-docs/core-beliefs.md`.
3. Check `ARCHITECTURE.md` before adding dependencies.
4. Find or create the leaf spec under `docs/product-specs/`.
5. For multi-step work, create or follow an exec plan in `docs/exec-plans/active/`.
6. Build depth-first.
7. Before finishing: update docs per `DOC_MAINTENANCE.md`, run the matching sensor tier, adjust grades, encode any repeatable failure.

Re-invoke **bootstrap-agentic-harness** only when you need to:

- Harness a **new** repository.
- Add an optional module that was skipped (`bootstrap.sh` is idempotent; use `--force` only if you intend to overwrite).
- Repair a repo whose harness files were deleted or diverged from this skill’s payload.

---

## Manual scaffold (no agent)

You can run the scaffolder yourself, then fill tokens by hand:

```bash
bash bootstrap-agentic-harness/scripts/bootstrap.sh \
  --target /absolute/path/to/your-repo \
  --name "your-project" \
  --tagline "one-line promise" \
  --stack "TypeScript / Next.js / Postgres" \
  --modules "design,security" \
  --install-hooks
```

| Flag | Purpose |
|------|---------|
| `--target` | Absolute path (created if missing) |
| `--name` | Project name (required) |
| `--tagline` | One-line promise |
| `--stack` | Shown in docs; also guides later sensor wiring |
| `--modules` | `design,security,reliability,delivery,backend,uat` |
| `--install-hooks` | `git config core.hooksPath scripts/hooks` |
| `--force` | Overwrite existing harness files |
| `-h` | Help |

Then search the target for `{{` and `FILL:` and replace them. Run:

```bash
cd /absolute/path/to/your-repo
scripts/verify-harness.sh
scripts/run-sensors.sh doc
```

---

## Publishing and contributing

This repository is public at [github.com/vinayteki95/agent-skills](https://github.com/vinayteki95/agent-skills).

### Add another skill later

```
agent-skills/
├── README.md
├── bootstrap-agentic-harness/
└── your-new-skill/
    └── SKILL.md
```

Keep each skill in its own folder with a `SKILL.md` at that folder’s root so it can be symlinked into `~/.cursor/skills/`.

### Change the harness payload

Edit files under `bootstrap-agentic-harness/harness/`. Keep `{{TOKENS}}` for values `bootstrap.sh` substitutes. Keep `<!-- FILL: -->` for values the **agent** must write from a PRD. If you add a required file, update `harness/scripts/verify-harness.sh` and the inventory in `SKILL.md` / `reference.md` in the same change.

### License

MIT. See [`LICENSE`](./LICENSE).
