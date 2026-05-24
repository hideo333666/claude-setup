#!/usr/bin/env bash
# Apply one overlay directory (base/ or languages/<lang>/) to a target .claude dir.
#
# Usage:
#   apply-overlay.sh <overlay_dir> <target_dir> <label>
#
# Behavior:
#   - <overlay_dir>/skills/**     -> copied into <target_dir>/skills/ (overwrites).
#   - <overlay_dir>/agents/**     -> copied into <target_dir>/agents/ (overwrites).
#   - <overlay_dir>/commands/**   -> copied into <target_dir>/commands/ (overwrites).
#   - <overlay_dir>/CLAUDE.md     -> appended to <target_dir>/CLAUDE.md
#                                    (with <!-- claude-setup:<label> --> marker).
#   - <overlay_dir>/settings.json -> deep-merged into <target_dir>/settings.json.
#
# Honors $DRY_RUN.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

if [ "$#" -ne 3 ]; then
  die "usage: apply-overlay.sh <overlay_dir> <target_dir> <label>"
fi

OVERLAY="$1"
TARGET="$2"
LABEL="$3"

if [ ! -d "$OVERLAY" ]; then
  die "overlay dir not found: $OVERLAY"
fi

log_info "applying overlay '$LABEL' -> $TARGET"

# Copy a whole subdirectory of files from overlay into target, preserving paths.
copy_subdir() {
  local sub="$1"
  local src="$OVERLAY/$sub"
  [ -d "$src" ] || return 0
  # find -print0 not available everywhere; use a portable approach.
  ( cd "$src" && find . -type f ) | while IFS= read -r rel; do
    rel="${rel#./}"
    cs_copy_file "$src/$rel" "$TARGET/$sub/$rel"
  done
}

copy_subdir skills
copy_subdir agents
copy_subdir commands

# CLAUDE.md is appended with a marker so language sections stack cleanly
# and re-running is idempotent (cs_append_file checks the marker).
if [ -f "$OVERLAY/CLAUDE.md" ]; then
  cs_append_file "$OVERLAY/CLAUDE.md" "$TARGET/CLAUDE.md" "$LABEL"
fi

# settings.json is deep-merged.
if [ -f "$OVERLAY/settings.json" ]; then
  "$SCRIPT_DIR/merge-json.sh" "$OVERLAY/settings.json" "$TARGET/settings.json"
fi
