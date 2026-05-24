#!/usr/bin/env bash
# Shared helpers for claude-setup install scripts.
# Sourced by install.sh and other scripts.

set -euo pipefail

# --- logging ---------------------------------------------------------------

if [ -t 1 ]; then
  CS_C_RESET=$'\033[0m'
  CS_C_DIM=$'\033[2m'
  CS_C_RED=$'\033[31m'
  CS_C_YLW=$'\033[33m'
  CS_C_GRN=$'\033[32m'
  CS_C_CYN=$'\033[36m'
else
  CS_C_RESET=""; CS_C_DIM=""; CS_C_RED=""; CS_C_YLW=""; CS_C_GRN=""; CS_C_CYN=""
fi

log_info()  { printf '%s[claude-setup]%s %s\n' "$CS_C_CYN" "$CS_C_RESET" "$*"; }
log_ok()    { printf '%s[claude-setup]%s %s%s%s\n' "$CS_C_CYN" "$CS_C_RESET" "$CS_C_GRN" "$*" "$CS_C_RESET"; }
log_warn()  { printf '%s[claude-setup]%s %s%s%s\n' "$CS_C_CYN" "$CS_C_RESET" "$CS_C_YLW" "$*" "$CS_C_RESET" >&2; }
log_error() { printf '%s[claude-setup]%s %s%s%s\n' "$CS_C_CYN" "$CS_C_RESET" "$CS_C_RED" "$*" "$CS_C_RESET" >&2; }
log_step()  { printf '%s  • %s%s\n' "$CS_C_DIM" "$*" "$CS_C_RESET"; }

die() { log_error "$*"; exit 1; }

# --- requirements ----------------------------------------------------------

require_cmd() {
  local cmd="$1" hint="${2:-}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    if [ -n "$hint" ]; then
      die "'$cmd' is required but not found. $hint"
    else
      die "'$cmd' is required but not found."
    fi
  fi
}

# --- scope -----------------------------------------------------------------

# Resolve target .claude directory from --scope value.
# user    -> $HOME/.claude
# project -> $PWD/.claude
resolve_target_dir() {
  local scope="$1"
  case "$scope" in
    user)    printf '%s/.claude\n' "$HOME" ;;
    project) printf '%s/.claude\n' "$PWD" ;;
    *) die "Unknown scope: $scope (expected: user|project)" ;;
  esac
}

# --- file ops --------------------------------------------------------------

# Copy a file, creating parent dirs. Honors $DRY_RUN.
cs_copy_file() {
  local src="$1" dst="$2"
  if [ "${DRY_RUN:-0}" = "1" ]; then
    log_step "copy  $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  log_step "copy  $dst"
}

# Append source to destination, creating destination if missing.
# Adds a separating header so language sections are easy to spot.
cs_append_file() {
  local src="$1" dst="$2" label="$3"
  if [ "${DRY_RUN:-0}" = "1" ]; then
    log_step "merge $dst (append: $label)"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ] && grep -q "<!-- claude-setup:$label -->" "$dst" 2>/dev/null; then
    # Already contains this language section — skip to keep idempotent.
    log_step "skip  $dst (already contains '$label')"
    return 0
  fi
  local exists=0
  [ -f "$dst" ] && exists=1
  {
    [ "$exists" = "1" ] && printf '\n\n'
    printf '<!-- claude-setup:%s -->\n' "$label"
    cat "$src"
  } >>"$dst"
  log_step "merge $dst (append: $label)"
}

# Backup existing target dir to .claude.bak.<timestamp>.
cs_backup_target() {
  local target="$1"
  if [ ! -d "$target" ]; then
    return 0
  fi
  if [ "${FORCE:-0}" = "1" ]; then
    log_warn "--force set; skipping backup of $target"
    return 0
  fi
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  local backup="${target}.bak.${ts}"
  if [ "${DRY_RUN:-0}" = "1" ]; then
    log_step "backup $target -> $backup"
    return 0
  fi
  cp -R "$target" "$backup"
  log_info "backed up existing $target -> $backup"
}
