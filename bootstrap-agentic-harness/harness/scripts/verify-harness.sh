#!/usr/bin/env bash
# Meta-sensor: is the harness itself still internally consistent?
# Checks structure the other sensors assume. Run standalone or via run-sensors.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
[[ -f "$ROOT/scripts/harness.conf" ]] && . "$ROOT/scripts/harness.conf"
MAX="${AGENTS_MAX_LINES:-140}"
ERR=0
warn() { echo "  $*"; ERR=1; }

# 1. Required core files present
REQUIRED=(
  AGENTS.md ARCHITECTURE.md README.md
  docs/PRODUCT_SENSE.md docs/QUALITY_SCORE.md docs/DOC_MAINTENANCE.md
  docs/SENSORS.md docs/PLANS.md
  docs/product-specs/index.md docs/design-docs/index.md
  docs/exec-plans/tech-debt-tracker.md
  scripts/run-sensors.sh
)
for f in "${REQUIRED[@]}"; do
  [[ -e "$ROOT/$f" ]] || warn "missing required file: $f"
done

# 2. AGENTS.md is a map, not an encyclopedia
if [[ -f "$ROOT/AGENTS.md" ]]; then
  lines="$(wc -l < "$ROOT/AGENTS.md" | tr -d ' ')"
  [[ "$lines" -le "$MAX" ]] || warn "AGENTS.md is $lines lines (budget $MAX) — trim; link out for depth"
fi

# 3. No unfilled template tokens left behind
while IFS= read -r -d '' f; do
  if grep -qE '\{\{[A-Z_]+\}\}' "$f"; then
    warn "unfilled token in ${f#"$ROOT"/}"
  fi
done < <(find "$ROOT" -type f \( -name '*.md' -o -name '*.yml' \) ! -path '*/.git/*' ! -path '*/node_modules/*' -print0)

# 4. Unresolved FILL markers (warning surfaced as failure so they aren't forgotten)
fills="$(grep -rlE 'FILL:' "$ROOT/docs" "$ROOT/AGENTS.md" "$ROOT/ARCHITECTURE.md" 2>/dev/null || true)"
[[ -n "$fills" ]] && warn "unresolved FILL markers in: $(echo "$fills" | sed "s#$ROOT/##g" | tr '\n' ' ')"

# 5. QUALITY_SCORE dated
grep -q 'Last updated:' "$ROOT/docs/QUALITY_SCORE.md" 2>/dev/null || warn "QUALITY_SCORE.md missing 'Last updated'"

# 6. Delegate index/folder sync
[[ -x "$ROOT/scripts/check-index-sync.sh" ]] && { "$ROOT/scripts/check-index-sync.sh" || ERR=1; }

if [[ "$ERR" -ne 0 ]]; then
  echo "REMEDIATION Harness self-check failed — fix above before relying on other sensors."
  exit 1
fi
echo "harness self-check OK"
exit 0
