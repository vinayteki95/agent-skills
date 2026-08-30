#!/usr/bin/env bash
# Prevent committing secrets/keystores (globs + content patterns from harness.conf).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
[[ -f "$ROOT/scripts/harness.conf" ]] && . "$ROOT/scripts/harness.conf"
BLOCK_GLOBS="${SECRET_BLOCK_GLOBS:-*.jks *.keystore .env .env.*}"
CONTENT="${SECRET_CONTENT_PATTERNS:-AKIA[0-9A-Z]{16}|sk_live_|-----BEGIN (RSA |EC )?PRIVATE KEY-----}"
ERR=0

git -C "$ROOT" rev-parse --is-inside-work-tree &>/dev/null || { exit 0; }
STAGED="$(git -C "$ROOT" diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)"
# Fall back to whole tree if nothing staged (e.g. CI on full checkout).
[[ -z "$STAGED" ]] && STAGED="$(git -C "$ROOT" ls-files 2>/dev/null || true)"

for f in $STAGED; do
  [[ -z "$f" ]] && continue
  for g in $BLOCK_GLOBS; do
    # shellcheck disable=SC2053
    case "$(basename "$f")" in $g) echo "  blocked file: $f"; ERR=1;; esac
  done
  if [[ -f "$ROOT/$f" ]] && grep -qE "$CONTENT" "$ROOT/$f" 2>/dev/null; then
    echo "  possible secret in: $f"; ERR=1
  fi
done

[[ "$ERR" -ne 0 ]] && echo "REMEDIATION See docs/SECURITY.md — remove secrets; use local config, env, or a secret manager."
exit "$ERR"
