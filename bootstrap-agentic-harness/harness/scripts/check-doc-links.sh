#!/usr/bin/env bash
# Verify internal markdown links resolve relative to each source file.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERR=0

check_link() {
  local from="$1" raw="$2"
  local link="${raw%%#*}"
  [[ -z "$link" ]] && return 0
  [[ "$link" =~ ^https?:// ]] && return 0
  [[ "$link" =~ ^mailto: ]] && return 0
  local from_dir="$ROOT/$(dirname "$from")" target
  if [[ "$link" == /* ]]; then
    target="$ROOT$link"
  else
    if ! target="$(python3 -c "import os,sys; print(os.path.normpath(os.path.join(sys.argv[1], sys.argv[2])))" "$from_dir" "$link" 2>/dev/null)"; then
      echo "  broken: $from -> $raw (unresolved)"; ERR=1; return
    fi
  fi
  [[ -e "$target" ]] && return 0
  echo "  broken: $from -> $raw"; ERR=1
}

while IFS= read -r -d '' file; do
  rel="${file#"$ROOT"/}"
  while IFS= read -r link; do
    [[ -z "$link" ]] && continue
    check_link "$rel" "$link"
  done < <(grep -oE '\[[^]]+\]\([^)]+\)' "$file" | sed -E 's/\[[^]]+\]\(([^)]+)\)/\1/' || true)
done < <(find "$ROOT" -name '*.md' ! -path '*/.git/*' ! -path '*/node_modules/*' ! -path '*/build/*' ! -path '*/dist/*' -print0)

[[ "$ERR" -ne 0 ]] && echo "REMEDIATION Fix or remove broken internal links."
exit "$ERR"
