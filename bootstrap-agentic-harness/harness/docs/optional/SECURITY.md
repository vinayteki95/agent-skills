# Security & Privacy

Data classification, threat model, and the agent security checklist for
{{PROJECT_NAME}}.

## Data classification

| Data | Sensitivity | Where it lives | Notes |
|------|-------------|----------------|-------|
<!-- FILL: every meaningful data field + sensitivity + storage/egress -->

## Permissions / access

<!-- FILL: each permission/scope + justification -->

## Threat model

<!-- FILL: who/what we defend against and the top risks -->

## Engineering rules

- No secrets in the repo — enforced by `scripts/check-secrets.sh` (patterns in `harness.conf`).
- Parse and validate untrusted input at the boundary.
- <!-- FILL: auth, encryption, logging (no PII in logs), third-party SDK review -->

## Agent security checklist

- [ ] New data field classified above
- [ ] New network call / dependency reviewed
- [ ] No secret material committed
- [ ] Input validated at boundary

## Maintenance

New data/permission/dependency → update tables + checklist (human review for
third-party SDKs). Full rules: [`DOC_MAINTENANCE.md`](DOC_MAINTENANCE.md).
