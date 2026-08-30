#!/usr/bin/env bash
# Scaffold an agent-first engineering harness into a target repository.
# Copies the payload from <skill>/harness into --target, substitutes global
# tokens, selects optional modules, and makes scripts executable.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PAYLOAD="$SKILL_DIR/harness"

TARGET="" NAME="" TAGLINE="" STACK="" MODULES="" FORCE=0 INSTALL_HOOKS=0

usage() {
  cat <<'EOF'
Usage: bootstrap.sh --target <path> --name <name> [options]

Required:
  --target <path>     Absolute path to the repo to scaffold (created if missing)
  --name <name>       Project name

Options:
  --tagline <text>    One-line promise                    (default: "")
  --stack <text>      Primary stack, e.g. "TypeScript/Node" (default: "")
  --modules <list>    Comma list of optional modules to include:
                        design,security,reliability,delivery,backend,uat
  --install-hooks     Run: git config core.hooksPath scripts/hooks
  --force             Overwrite existing harness files
  -h, --help          Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2;;
    --name) NAME="$2"; shift 2;;
    --tagline) TAGLINE="$2"; shift 2;;
    --stack) STACK="$2"; shift 2;;
    --modules) MODULES="$2"; shift 2;;
    --install-hooks) INSTALL_HOOKS=1; shift;;
    --force) FORCE=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

[[ -z "$TARGET" || -z "$NAME" ]] && { echo "ERROR: --target and --name are required" >&2; usage; exit 2; }
[[ -d "$PAYLOAD" ]] || { echo "ERROR: payload not found at $PAYLOAD" >&2; exit 1; }

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

DATE="$(date +%Y-%m-%d)"
SLUG="$(echo "$NAME" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-' | sed -E 's/-+/-/g; s/^-|-$//g')"
[[ -z "$SLUG" ]] && SLUG="project"
STRICT_ENV="$(echo "$SLUG" | tr '[:lower:]-' '[:upper:]_')_STRICT"

echo "=== bootstrap-agentic-harness ==="
echo "target : $TARGET"
echo "name   : $NAME  (slug: $SLUG)"
echo "stack  : ${STACK:-<unset>}"
echo "modules: ${MODULES:-<core only>}"

# --- copy core payload (everything except docs/optional and optional/) --------
copied=0 skipped=0
while IFS= read -r -d '' src; do
  rel="${src#"$PAYLOAD"/}"
  case "$rel" in
    docs/optional/*|optional/*) continue;;
  esac
  dest="$TARGET/$rel"
  if [[ -e "$dest" && "$FORCE" -ne 1 ]]; then
    echo "  skip (exists): $rel"; skipped=$((skipped+1)); continue
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  copied=$((copied+1))
done < <(find "$PAYLOAD" -type f -print0)

# --- optional modules ---------------------------------------------------------
copy_optional() {
  local relsrc="$1" reldest="$2"
  local src="$PAYLOAD/$relsrc" dest="$TARGET/$reldest"
  [[ -e "$src" ]] || { echo "  (no template for $relsrc)"; return; }
  if [[ -e "$dest" && "$FORCE" -ne 1 ]]; then echo "  skip (exists): $reldest"; return; fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"; echo "  module: $reldest"; copied=$((copied+1))
}

IFS=',' read -ra MODS <<< "${MODULES:-}"
for m in "${MODS[@]}"; do
  m="$(echo "$m" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
  case "$m" in
    "") ;;
    design)      copy_optional "docs/optional/DESIGN.md" "docs/DESIGN.md"
                 copy_optional "docs/optional/design-system-reference.md" "docs/references/design-system-reference.md";;
    security)    copy_optional "docs/optional/SECURITY.md" "docs/SECURITY.md";;
    reliability) copy_optional "docs/optional/RELIABILITY.md" "docs/RELIABILITY.md";;
    delivery)    copy_optional "docs/optional/DELIVERY.md" "docs/DELIVERY.md";;
    backend)     copy_optional "docs/optional/BACKEND.md" "docs/BACKEND.md";;
    uat)         copy_optional "optional/uat/README.md" "uat/README.md"
                 copy_optional "optional/uat/run-uat.sh" "uat/scripts/run-uat.sh";;
    *) echo "  WARN unknown module: $m" >&2;;
  esac
done

# --- token substitution -------------------------------------------------------
subst() {
  # portable in-place edit via perl (macOS + Linux)
  perl -0777 -pi -e "
    s/\Q{{PROJECT_NAME}}\E/\$ENV{H_NAME}/g;
    s/\Q{{TAGLINE}}\E/\$ENV{H_TAGLINE}/g;
    s/\Q{{PRIMARY_STACK}}\E/\$ENV{H_STACK}/g;
    s/\Q{{DATE}}\E/\$ENV{H_DATE}/g;
    s/\Q{{STRICT_ENV}}\E/\$ENV{H_STRICT}/g;
    s/\Q{{PROJECT_SLUG}}\E/\$ENV{H_SLUG}/g;
  " "$1"
}
export H_NAME="$NAME" H_TAGLINE="$TAGLINE" H_STACK="$STACK" H_DATE="$DATE" H_STRICT="$STRICT_ENV" H_SLUG="$SLUG"
while IFS= read -r -d '' f; do subst "$f"; done < <(
  find "$TARGET" -type f \( -name '*.md' -o -name '*.sh' -o -name '*.yml' -o -name '*.conf' -o -name 'pre-commit' -o -name 'pre-push' -o -name 'commit-msg' \) ! -path '*/.git/*' -print0
)

# --- permissions & hooks ------------------------------------------------------
find "$TARGET/scripts" -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
[[ -d "$TARGET/scripts/hooks" ]] && chmod +x "$TARGET"/scripts/hooks/* 2>/dev/null || true
[[ -d "$TARGET/uat/scripts" ]] && chmod +x "$TARGET"/uat/scripts/*.sh 2>/dev/null || true

if [[ "$INSTALL_HOOKS" -eq 1 ]]; then
  if git -C "$TARGET" rev-parse --is-inside-work-tree &>/dev/null; then
    git -C "$TARGET" config core.hooksPath scripts/hooks && echo "  hooks: installed (core.hooksPath=scripts/hooks)"
  else
    echo "  hooks: skipped — $TARGET is not a git repo yet (run: git init)"
  fi
fi

echo "=== done: $copied file(s) written, $skipped skipped ==="
echo "Next: fill {{TOKENS}} and <!-- FILL --> markers, then run scripts/verify-harness.sh"
