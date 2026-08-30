#!/usr/bin/env bash
# Heuristic freshness checks for harness docs.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERR=0
warn() { echo "  $*"; ERR=1; }

# Active exec plans must have a Progress log with at least one dated row.
for plan in "$ROOT"/docs/exec-plans/active/*.md; do
  [[ -f "$plan" ]] || continue
  [[ "$(basename "$plan")" == "README.md" ]] && continue
  grep -q '| Date | Update |' "$plan" 2>/dev/null || warn "$(basename "$plan"): missing Progress log table"
  grep -qE '^\| [0-9]{4}-' "$plan" 2>/dev/null || warn "$(basename "$plan"): Progress log has no dated entries"
done

# QUALITY_SCORE must carry a Last updated stamp.
grep -q 'Last updated:' "$ROOT/docs/QUALITY_SCORE.md" 2>/dev/null || warn "QUALITY_SCORE.md: missing 'Last updated' line"

[[ "$ERR" -ne 0 ]] && echo "REMEDIATION See docs/DOC_MAINTENANCE.md — keep plans logged and grades dated."
exit "$ERR"
