#!/usr/bin/env bash
# Block forbidden user-facing copy (patterns + scan paths from harness.conf).
# Skips meta lines that document the anti-pattern itself.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
[[ -f "$ROOT/scripts/harness.conf" ]] && . "$ROOT/scripts/harness.conf"
PATTERN="${COPY_FORBIDDEN_PATTERNS:-}"
GLOBS="${COPY_SCAN_GLOBS:-docs/product-specs/*.md}"
ERR=0

[[ -z "$PATTERN" ]] && { echo "  (no COPY_FORBIDDEN_PATTERNS configured — skipping)"; exit 0; }

is_meta_line() {
  local l="$1"
  [[ "$l" =~ [Dd]on\'t ]] && return 0
  [[ "$l" =~ [Dd]o\ not ]] && return 0
  [[ "$l" =~ [Bb]ad\ example ]] && return 0
  [[ "$l" =~ [Ff]orbidden ]] && return 0
  [[ "$l" =~ anti-pattern ]] && return 0
  [[ "$l" =~ matched\  ]] && return 0
  return 1
}

scan_file() {
  local file="$1" rel="${file#"$ROOT"/}" n=0 line
  while IFS= read -r line || [[ -n "$line" ]]; do
    n=$((n+1))
    is_meta_line "$line" && continue
    if echo "$line" | grep -qiE "$PATTERN"; then
      echo "  $rel:$n matched forbidden copy"; ERR=1
    fi
  done < "$file"
}

for glob in $GLOBS; do
  while IFS= read -r -d '' f; do scan_file "$f"; done < <(
    find "$ROOT" -path "$ROOT/${glob%/*}/*" -name "${glob##*/}" -print0 2>/dev/null || true
  )
done

[[ "$ERR" -ne 0 ]] && echo "REMEDIATION See docs/PRODUCT_SENSE.md — remove forbidden language from user-facing copy."
exit "$ERR"
