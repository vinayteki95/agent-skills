#!/usr/bin/env bash
# Enforce branch naming: <type>/<slug>. Types configured in harness.conf.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
[[ -f "$ROOT/scripts/harness.conf" ]] && . "$ROOT/scripts/harness.conf"
TYPES="${BRANCH_TYPES:-feature|fix|hotfix|release|chore|docs|refactor|test}"

git -C "$ROOT" rev-parse --is-inside-work-tree &>/dev/null || exit 0
# symbolic-ref resolves the branch even on an unborn HEAD; falls back to HEAD when detached.
BRANCH="$(git -C "$ROOT" symbolic-ref --short HEAD 2>/dev/null || echo HEAD)"

case "$BRANCH" in
  main|master|develop|HEAD) exit 0;;
esac

if echo "$BRANCH" | grep -qE "^($TYPES)/[a-z0-9._-]+$"; then
  exit 0
fi
echo "  invalid branch name: '$BRANCH'"
echo "REMEDIATION Use <type>/<slug> where type is one of: $TYPES  (see docs/DELIVERY.md if present)"
exit 1
