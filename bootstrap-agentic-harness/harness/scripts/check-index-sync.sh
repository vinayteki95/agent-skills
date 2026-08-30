#!/usr/bin/env bash
# Ensure index/README files stay in sync with the folders they describe.
# Fixes the classic drift where "No plans yet" lingers while files exist.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERR=0
warn() { echo "  $*"; ERR=1; }

# 1. Every leaf spec is linked from product-specs/index.md
if [[ -f "$ROOT/docs/product-specs/index.md" ]]; then
  for spec in "$ROOT"/docs/product-specs/*.md; do
    [[ -f "$spec" ]] || continue
    base="$(basename "$spec")"
    case "$base" in index.md|_TEMPLATE.md) continue;; esac
    grep -q "$base" "$ROOT/docs/product-specs/index.md" || warn "product-specs/$base not linked from index.md"
  done
fi

# 2. Every design doc is listed in design-docs/index.md
if [[ -f "$ROOT/docs/design-docs/index.md" ]]; then
  for d in "$ROOT"/docs/design-docs/*.md; do
    [[ -f "$d" ]] || continue
    base="$(basename "$d")"
    [[ "$base" == "index.md" ]] && continue
    grep -q "$base" "$ROOT/docs/design-docs/index.md" || warn "design-docs/$base not listed in index.md"
  done
fi

# 3. active/completed READMEs must not claim emptiness while plans exist
check_folder_readme() {
  local dir="$1" empty_phrase="$2"
  local readme="$dir/README.md"
  [[ -f "$readme" ]] || return 0
  local count
  count="$(find "$dir" -maxdepth 1 -name '*.md' ! -name 'README.md' | wc -l | tr -d ' ')"
  if [[ "$count" -gt 0 ]] && grep -qi "$empty_phrase" "$readme"; then
    warn "$(basename "$dir")/README.md says '$empty_phrase' but $count plan file(s) exist"
  fi
}
check_folder_readme "$ROOT/docs/exec-plans/active" "no active plans"
check_folder_readme "$ROOT/docs/exec-plans/completed" "no completed plans"

[[ "$ERR" -ne 0 ]] && echo "REMEDIATION Sync the index/README with its folder — see docs/DOC_MAINTENANCE.md."
exit "$ERR"
