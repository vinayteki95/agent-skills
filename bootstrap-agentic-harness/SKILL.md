---
name: bootstrap-agentic-harness
description: >-
  Bootstrap a brand-new repository with a complete agent-first engineering
  harness (AGENTS.md map, product/architecture/spec docs, exec plans, tiered
  quality sensors, git hooks, and CI) derived from a PRD, tech doc, or a short
  vision prompt. Use when starting a new project/repo, scaffolding agentic
  harness engineering, setting up AGENTS.md + docs/ + sensors, or "jump-start
  this repo" requests.
disable-model-invocation: true
---

# Bootstrap Agentic Harness

Turn a PRD / tech doc / one-paragraph vision into a fully-wired **agent-first
repository**: a short `AGENTS.md` map, a `docs/` system of record, living exec
plans, tiered quality sensors, git hooks, and CI — all stack-agnostic and
self-verifying.

The philosophy (progressive disclosure + same-PR doc sync + failures encoded
back into the harness) is distilled from [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/).
Full anatomy and the improvements this skill makes over a naive copy live in
[reference.md](reference.md).

## What gets created

```
<repo>/
├── AGENTS.md                  # short map — workflow, doc index, domains, non-negotiables
├── ARCHITECTURE.md            # domains, layers, providers, data flows
├── README.md                  # human intro → points to AGENTS.md
├── docs/
│   ├── PRODUCT_SENSE.md       # product/tone constitution
│   ├── QUALITY_SCORE.md       # per-domain health grades
│   ├── DOC_MAINTENANCE.md     # single anti-drift matrix (source of truth)
│   ├── SENSORS.md             # sensor catalog + tiers + feedback loop
│   ├── PLANS.md               # planning workflow + exec-plan template
│   ├── design-docs/           # core-beliefs, golden-principles, module-boundaries
│   ├── product-specs/         # index + leaf spec template (WHAT you build)
│   ├── exec-plans/            # active/, completed/, tech-debt-tracker.md
│   └── references/            # dense agent-scannable lookup facts
├── scripts/
│   ├── run-sensors.sh         # tiered orchestrator (quick|doc|standard|full)
│   ├── verify-harness.sh      # meta-sensor: is the harness still true?
│   ├── check-*.sh             # doc-links, doc-freshness, index-sync, copy, secrets, branch
│   ├── harness.conf           # central config (patterns, paths, prefixes)
│   └── hooks/                 # pre-commit, commit-msg, pre-push
└── .github/workflows/ci.yml   # runs standard tier + commit lint
```

Optional modules (added only when the project needs them — see Phase 2):
`docs/DESIGN.md`, `docs/SECURITY.md`, `docs/RELIABILITY.md`, `docs/DELIVERY.md`
(branching + release + CI depth), `docs/BACKEND.md`, and `uat/`.

## Workflow

Copy this checklist and track progress:

```
- [ ] Phase 0: Intake — extract structured facts from the PRD/vision
- [ ] Phase 1: Confirm essentials (name, stack, domains, optional modules)
- [ ] Phase 2: Scaffold — run scripts/bootstrap.sh into the target repo
- [ ] Phase 3: Populate — fill docs from the PRD (product → architecture → specs)
- [ ] Phase 4: Wire — point sensors/CI at the real stack; seed first exec plan
- [ ] Phase 5: Verify — run verify-harness.sh + sensors; fix drift; git init/commit
```

### Phase 0 — Intake

Read the user's PRD / tech doc / prompt and extract this **intake block**. If a
field is missing, infer a sensible default and mark it `(assumed)`; only ask
about fields that materially change scaffolding (Phase 1).

```
PROJECT_NAME:   short name (repo/package friendly)
TAGLINE:        one line — the promise
ONE_LINER:      1–2 sentence pitch (problem it solves + for whom)
USERS:          primary persona(s)
PLATFORM:       e.g. web / mobile-android / cli / service / library / monorepo
STACK:          language(s) + framework(s) + datastore  (drives sensors + CI)
DOMAINS:        3–10 business domains (bounded contexts), one line each
NON_NEGOTIABLES: 3–6 hard product/eng rules (tone, privacy, safety, perf...)
MVP_IN:         what ships in v1
MVP_OUT:        explicitly deferred
OPTIONAL_MODULES: which of {design, security, reliability, delivery, backend, uat} apply
```

### Phase 1 — Confirm essentials

Only surface decisions you cannot safely infer. Use `AskQuestion` for these when
genuinely ambiguous; otherwise proceed and state your assumptions:

- **Stack** (if the PRD is vague) — it drives which lint/test/build commands the
  sensors invoke and the CI matrix.
- **Domains** — the initial bounded contexts become the `ARCHITECTURE.md` domain
  map, `QUALITY_SCORE.md` rows, and spec seeds. Wrong granularity is expensive
  later, so confirm the list.
- **Optional modules** — recommend based on PLATFORM (see reference.md → "Module
  selection guide").

Do not ask about naming, formatting, or defaults — decide and note them.

### Phase 2 — Scaffold

Run the bootstrap scaffolder against the target repo. It creates the tree,
substitutes global tokens, makes scripts executable, and (optionally) installs
git hooks.

```bash
bash <SKILL_DIR>/scripts/bootstrap.sh \
  --target "<absolute-path-to-repo>" \
  --name "PROJECT_NAME" \
  --tagline "TAGLINE" \
  --stack "STACK" \
  --modules "design,security,delivery" \   # comma list; omit for core-only
  --install-hooks                          # optional
```

`<SKILL_DIR>` is the directory containing this SKILL.md. The script is
idempotent and refuses to overwrite existing tracked files unless `--force`.
Read [scripts/bootstrap.sh](scripts/bootstrap.sh) if you need to adjust flags.

### Phase 3 — Populate from the PRD

The payload ships with `{{TOKENS}}` and `<!-- FILL: ... -->` markers. Replace
every marker with real content drawn from the intake block. Work in this order
(depth-first — same order agents will build code):

1. **`docs/PRODUCT_SENSE.md`** — pitch, persona, principles, voice do/don't,
   success vs failure, metrics + anti-metrics, conflict priority order.
2. **`ARCHITECTURE.md`** — domain map (from DOMAINS), layer stack, providers,
   1–2 canonical data flows. Keep diagrams; edit ownership tables.
3. **`AGENTS.md`** — fill the doc-index table, domain map summary, and
   non-negotiables. **Keep it under ~120 lines** — it is a map, not an
   encyclopedia. Link out; never paste spec bodies.
4. **`docs/product-specs/`** — for each MVP_IN feature, copy `_TEMPLATE.md` to a
   leaf spec and fill Goal + body + **Acceptance criteria**; register it in
   `index.md` with status `draft`. Put MVP_IN/MVP_OUT in the index scope lists.
5. **`docs/design-docs/`** — tailor `core-beliefs.md`, `golden-principles.md`,
   and `module-boundaries.md` to the stack (layer names, lint rules, taste).
6. **`docs/QUALITY_SCORE.md`** — one row per domain, all starting `C` (spec
   only) with today's date.
7. Optional modules — fill only the ones you scaffolded.

Search the repo for remaining `{{` and `FILL:` markers before finishing.

### Phase 4 — Wire to the real stack

- Edit `scripts/harness.conf` — set `PROJECT_SLUG`, the `STRICT` env prefix,
  copy/secret patterns, and spec/string scan paths for this project.
- In `scripts/run-sensors.sh` the stack blocks auto-detect gradle/npm/python/
  go/cargo. Confirm the detected commands match the project; adjust if needed.
- Edit `.github/workflows/ci.yml` if the stack needs a specific toolchain
  (SDK, node version, etc.).
- Seed the **first exec plan** in `docs/exec-plans/active/` from `_TEMPLATE.md`
  describing the initial build (e.g. "MVP scaffold"), with a dated Progress log
  entry. Add first real items to `tech-debt-tracker.md`.

### Phase 5 — Verify

```bash
cd <repo>
scripts/verify-harness.sh          # meta invariants (map size, index sync, logs)
scripts/run-sensors.sh doc         # doc-links + freshness + index-sync
scripts/run-sensors.sh standard    # full tier once code/toolchain exists
```

Fix every `FAIL`. `verify-harness.sh` must be green — it is the self-check that
the harness is internally consistent (no README/folder drift, every spec
linked, every design-doc indexed, AGENTS.md within size budget,
QUALITY_SCORE dated, no stray `{{TOKENS}}`).

If the repo is not yet a git repo and the user wants one: `git init`, install
hooks (`git config core.hooksPath scripts/hooks`), then make the first commit
only if the user asked you to commit.

## Non-negotiable harness behaviors to preserve

These are the invariants that make the harness work. Encode them; don't dilute:

1. `AGENTS.md` stays a **map** (< ~120 lines). Link for depth.
2. **Same PR** for code + docs. Doc drift is a harness failure, like a failing test.
3. Every behavior change updates its **leaf spec + QUALITY_SCORE** row.
4. **Sensor failures are inputs**: repeatable ones get encoded back into a golden
   principle, a lint rule, or a spec — not just patched.
5. Exec plans get a **Progress log entry every session**.
6. Tiered sensors: **quick** (commit) → **standard** (PR) → **full** (release).
7. **One maintenance matrix** (`DOC_MAINTENANCE.md`). Leaf docs link to it — they
   do not duplicate it. (This is a deliberate tightening; see reference.md.)
8. **Indexes must match their folders** — enforced by `check-index-sync.sh`.

## Token map

`bootstrap.sh` substitutes these globally; the agent fills the rest by hand:

| Token | Source |
|-------|--------|
| `{{PROJECT_NAME}}` | intake PROJECT_NAME |
| `{{TAGLINE}}` | intake TAGLINE |
| `{{PRIMARY_STACK}}` | intake STACK |
| `{{DATE}}` | bootstrap date (YYYY-MM-DD) |
| `{{STRICT_ENV}}` | `<SLUG>_STRICT` (uppercased slug) |

## Additional resources

- [reference.md](reference.md) — full harness anatomy, per-doc purpose, module
  selection guide, and the specific gaps this skill fixes vs a naive copy.
- [scripts/bootstrap.sh](scripts/bootstrap.sh) — the scaffolder; read it to see
  every flag and exactly what lands in the repo.
- `harness/` (next to this SKILL.md) — the payload templates copied into repos.
