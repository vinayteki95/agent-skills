# Backend / Service Contract

What the server/API/telemetry surface is — and, importantly, what it is **not**
allowed to do (scope guard).

## Surface

<!-- FILL: services, endpoints, datastores, external integrations -->

## API contract

| Endpoint | Method | Purpose | Auth |
|----------|--------|---------|------|
<!-- FILL -->

## Telemetry / data egress

| Event / data | Sent where | Why | PII? |
|--------------|-----------|-----|------|
<!-- FILL: keep aligned with SECURITY.md and any privacy policy -->

## Non-goals

<!-- FILL: explicit scope limits to prevent creep -->

## Maintenance

New endpoint/event → update tables + SECURITY.md. Full rules:
[`DOC_MAINTENANCE.md`](DOC_MAINTENANCE.md).
