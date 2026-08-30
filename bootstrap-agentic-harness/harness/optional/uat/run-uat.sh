#!/usr/bin/env bash
# Run product-flow UAT. Emits "UAT <id> PASS|FAIL|SKIP".
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FLOWS_DIR="$ROOT/uat/flows"
FAILED=0

if [[ ! -d "$FLOWS_DIR" ]] || [[ -z "$(ls -A "$FLOWS_DIR" 2>/dev/null)" ]]; then
  echo "UAT all SKIP (no flows defined yet in uat/flows/)"
  exit 0
fi

# FILL: invoke your E2E runner per flow (Playwright, Maestro, Cypress...).
# Example scaffold:
for flow in "$FLOWS_DIR"/*; do
  id="$(basename "$flow")"
  echo "UAT $id SKIP (wire your E2E runner in uat/scripts/run-uat.sh)"
done

exit "$FAILED"
