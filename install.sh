#!/usr/bin/env bash
# claude-setup installer.
#
# Usage:
#   # Install base only into ./.claude
#   bash install.sh
#
#   # Install base + TypeScript overlay into ./.claude
#   bash install.sh --lang typescript
#
#   # Install base into ~/.claude
#   bash install.sh --scope user
#
#   # Preview without writing
#   bash install.sh --lang python --dry-run
#
# Remote invocation:
#   curl -fsSL https://raw.githubusercontent.com/<owner>/claude-setup/main/install.sh \
#     | bash -s -- --lang typescript --scope project
#
# When piped from curl, the script clones itself into a temp dir so that
# scripts/ and base/ etc. are available.

set -euo pipefail

# --- defaults --------------------------------------------------------------

REPO_URL="${CLAUDE_SETUP_REPO:-https://github.com/REPLACE_ME/claude-setup.git}"
REPO_BRANCH="${CLAUDE_SETUP_BRANCH:-main}"

LANG=""
SCOPE="project"
DRY_RUN=0
FORCE=0

SUPPORTED_LANGS=(typescript python go rust react nextjs)

# --- arg parsing -----------------------------------------------------------

usage() {
  cat <<'EOF'
claude-setup installer

Usage: install.sh [options]

Options:
  --lang <name>     Language overlay to apply on top of base.
                    One of: typescript | python | go | rust | react | nextjs
  --scope <name>    Install target. user => ~/.claude, project => ./.claude
                    (default: project)
  --dry-run         Print what would be done without writing.
  --force           Skip backup of existing .claude/ directory.
  -h, --help        Show this help.

Environment overrides:
  CLAUDE_SETUP_REPO     git URL to clone (defaults to upstream).
  CLAUDE_SETUP_BRANCH   branch/ref to use (default: main).
  CLAUDE_SETUP_SRC      local checkout to use instead of cloning.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --lang)    LANG="${2:-}"; shift 2 ;;
    --scope)   SCOPE="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --force)   FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

export DRY_RUN FORCE

# --- resolve source dir ----------------------------------------------------

# If $CLAUDE_SETUP_SRC is set and points at a checkout containing scripts/lib.sh,
# use it. Else, if this script lives next to scripts/lib.sh, use its dir.
# Else, clone from $REPO_URL into a temp dir (curl|bash case).

resolve_src_dir() {
  if [ -n "${CLAUDE_SETUP_SRC:-}" ] && [ -f "$CLAUDE_SETUP_SRC/scripts/lib.sh" ]; then
    printf '%s\n' "$CLAUDE_SETUP_SRC"
    return 0
  fi

  local self_dir
  # BASH_SOURCE may be empty when piped through stdin (curl | bash).
  if [ -n "${BASH_SOURCE[0]:-}" ]; then
    self_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$self_dir/scripts/lib.sh" ]; then
      printf '%s\n' "$self_dir"
      return 0
    fi
  fi

  # Fallback: clone.
  if ! command -v git >/dev/null 2>&1; then
    echo "[claude-setup] git is required to fetch the repo. Install git and retry." >&2
    exit 1
  fi
  local tmp
  tmp="$(mktemp -d -t claude-setup.XXXXXX)"
  echo "[claude-setup] cloning $REPO_URL ($REPO_BRANCH) into $tmp"
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$tmp" >/dev/null
  # Caller is responsible for cleanup; we register a trap below.
  CS_CLEANUP_DIR="$tmp"
  printf '%s\n' "$tmp"
}

cleanup() {
  if [ -n "${CS_CLEANUP_DIR:-}" ] && [ -d "$CS_CLEANUP_DIR" ]; then
    rm -rf "$CS_CLEANUP_DIR"
  fi
}
trap cleanup EXIT

SRC_DIR="$(resolve_src_dir)"

# shellcheck source=scripts/lib.sh
. "$SRC_DIR/scripts/lib.sh"

# --- validation ------------------------------------------------------------

case "$SCOPE" in
  user|project) ;;
  *) die "--scope must be 'user' or 'project' (got: $SCOPE)" ;;
esac

if [ -n "$LANG" ]; then
  found=0
  for s in "${SUPPORTED_LANGS[@]}"; do
    if [ "$s" = "$LANG" ]; then found=1; break; fi
  done
  if [ "$found" -ne 1 ]; then
    die "--lang must be one of: ${SUPPORTED_LANGS[*]} (got: $LANG)"
  fi
  if [ ! -d "$SRC_DIR/languages/$LANG" ]; then
    die "language overlay missing in repo: languages/$LANG"
  fi
fi

require_cmd jq "Install via 'brew install jq' or your package manager."

TARGET="$(resolve_target_dir "$SCOPE")"
log_info "scope=$SCOPE  target=$TARGET  lang=${LANG:-<none>}  dry-run=${DRY_RUN}  force=${FORCE}"

# --- apply -----------------------------------------------------------------

cs_backup_target "$TARGET"

"$SRC_DIR/scripts/apply-overlay.sh" "$SRC_DIR/base" "$TARGET" "base"

if [ -n "$LANG" ]; then
  "$SRC_DIR/scripts/apply-overlay.sh" "$SRC_DIR/languages/$LANG" "$TARGET" "lang:$LANG"
fi

if [ "$DRY_RUN" = "1" ]; then
  log_ok "dry-run complete. no files were written."
else
  log_ok "done. target: $TARGET"
fi
