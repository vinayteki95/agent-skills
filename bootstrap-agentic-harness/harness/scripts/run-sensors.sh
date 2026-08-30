#!/usr/bin/env bash
# {{PROJECT_NAME}} quality sensors — tiers: quick | doc | standard | full
# Emits grep-able "SENSOR <id> PASS|FAIL|SKIP" and "REMEDIATION ..." lines.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIER="${1:-quick}"
FAILED=0
# shellcheck disable=SC1091
[[ -f "$ROOT/scripts/harness.conf" ]] && . "$ROOT/scripts/harness.conf"

pass() { echo "SENSOR $1 PASS"; }
fail() { echo "SENSOR $1 FAIL ${2:-}"; FAILED=1; }
skip() { echo "SENSOR $1 SKIP ($2)"; }
remediation() { echo "REMEDIATION $*"; }

run() { local id="$1"; shift; if "$@"; then pass "$id"; else fail "$id" "see output above"; fi; }
run_or_skip() { local id="$1" reason="$2"; shift 2; if "$@"; then pass "$id"; else skip "$id" "$reason"; fi; }

echo "=== {{PROJECT_NAME}} sensors (tier: $TIER) ==="

# ---- always-on doc/quality sensors ------------------------------------------
run doc-links       "$ROOT/scripts/check-doc-links.sh"
run lint-copy       "$ROOT/scripts/check-copy.sh"
run security-secrets "$ROOT/scripts/check-secrets.sh"

if [[ "$TIER" == "quick" ]]; then
  : # fast path only
elif [[ "$TIER" == "doc" ]]; then
  run doc-freshness "$ROOT/scripts/check-doc-freshness.sh"
  run index-sync    "$ROOT/scripts/check-index-sync.sh"
  run verify-harness "$ROOT/scripts/verify-harness.sh"
elif [[ "$TIER" == "standard" || "$TIER" == "full" ]]; then
  run doc-freshness "$ROOT/scripts/check-doc-freshness.sh"
  run index-sync    "$ROOT/scripts/check-index-sync.sh"
  run verify-harness "$ROOT/scripts/verify-harness.sh"
  run branch-name   "$ROOT/scripts/check-branch-name.sh"

  # ---- stack-detected lint/test (SKIP when toolchain absent) ----------------
  if [[ -f "$ROOT/package.json" ]]; then
    if command -v npm >/dev/null 2>&1; then
      run_or_skip node-lint "no lint script" bash -c "cd '$ROOT' && npm run --silent lint"
      run_or_skip node-test "no test script" bash -c "cd '$ROOT' && npm test --silent"
    else skip node-lint "npm not installed"; skip node-test "npm not installed"; fi
  fi
  if [[ -f "$ROOT/build.gradle" || -f "$ROOT/build.gradle.kts" || -f "$ROOT/android/gradlew" || -f "$ROOT/gradlew" ]]; then
    GW="$ROOT/gradlew"; [[ -x "$ROOT/android/gradlew" ]] && GW="$ROOT/android/gradlew"
    GD="$(dirname "$GW")"
    if [[ -x "$GW" ]]; then
      run_or_skip gradle-test "test task missing" bash -c "cd '$GD' && ./gradlew test -q"
    else skip gradle-test "gradlew missing"; fi
  fi
  if [[ -f "$ROOT/pyproject.toml" || -f "$ROOT/setup.py" ]]; then
    if command -v pytest >/dev/null 2>&1; then
      run_or_skip py-test "pytest failed/none" bash -c "cd '$ROOT' && pytest -q"
    else skip py-test "pytest not installed"; fi
    command -v ruff >/dev/null 2>&1 && run_or_skip py-lint "ruff issues" bash -c "cd '$ROOT' && ruff check ." || skip py-lint "ruff not installed"
  fi
  if [[ -f "$ROOT/go.mod" ]] && command -v go >/dev/null 2>&1; then
    run_or_skip go-test "go test failed" bash -c "cd '$ROOT' && go test ./... "
    run_or_skip go-vet "go vet issues" bash -c "cd '$ROOT' && go vet ./..."
  fi
  if [[ -f "$ROOT/Cargo.toml" ]] && command -v cargo >/dev/null 2>&1; then
    run_or_skip cargo-test "cargo test failed" bash -c "cd '$ROOT' && cargo test -q"
    run_or_skip cargo-clippy "clippy issues" bash -c "cd '$ROOT' && cargo clippy -q -- -D warnings"
  fi

  echo "SENSOR pr-self-review MANUAL — complete checklist in docs/SENSORS.md"
else
  echo "Unknown tier: $TIER (use quick|doc|standard|full)" >&2
  exit 2
fi

if [[ "$TIER" == "full" ]]; then
  if [[ -x "$ROOT/uat/scripts/run-uat.sh" ]]; then
    echo "SENSOR uat MANUAL — run ./uat/scripts/run-uat.sh"
  fi
  echo "SENSOR bug-hunt MANUAL — run agent bug-finding pass per docs/SENSORS.md"
fi

if [[ "$FAILED" -ne 0 ]]; then
  remediation "Fix failures above; encode repeat issues in docs/design-docs/golden-principles.md — see docs/SENSORS.md"
  exit 1
fi

echo "=== All automated sensors passed ($TIER) ==="
exit 0
