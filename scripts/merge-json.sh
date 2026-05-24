#!/usr/bin/env bash
# Deep-merge two JSON files using jq and write the result to a destination.
#
# Usage:
#   merge-json.sh <overlay.json> <target.json>
#
# Semantics:
#   - If <target.json> does not exist, <overlay.json> is copied to it.
#   - Otherwise, the two are deep-merged using jq's `*` operator with
#     recursive object merge. Arrays are concatenated and deduplicated to
#     keep the operation idempotent (re-running yields the same output).
#   - Honors $DRY_RUN=1 (prints intent without writing).

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

if [ "$#" -ne 2 ]; then
  die "usage: merge-json.sh <overlay.json> <target.json>"
fi

OVERLAY="$1"
TARGET="$2"

require_cmd jq "Install via 'brew install jq' or your package manager."

if [ ! -f "$OVERLAY" ]; then
  die "overlay not found: $OVERLAY"
fi

if [ "${DRY_RUN:-0}" = "1" ]; then
  log_step "merge $TARGET (json deep-merge from $OVERLAY)"
  exit 0
fi

mkdir -p "$(dirname "$TARGET")"

if [ ! -f "$TARGET" ]; then
  cp "$OVERLAY" "$TARGET"
  log_step "write $TARGET (from $OVERLAY)"
  exit 0
fi

# Recursive deep-merge: objects merged key-wise, arrays concatenated+uniqued.
# jq's `*` only goes one level deep on nested objects without the helper below.
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

jq -n \
  --slurpfile a "$TARGET" \
  --slurpfile b "$OVERLAY" \
  '
  def deepmerge(x; y):
    if (x | type) == "object" and (y | type) == "object" then
      reduce ((x|keys_unsorted) + (y|keys_unsorted) | unique)[] as $k
        ({}; .[$k] = (
          if (x|has($k)) and (y|has($k)) then deepmerge(x[$k]; y[$k])
          elif (y|has($k)) then y[$k]
          else x[$k]
          end))
    elif (x | type) == "array" and (y | type) == "array" then
      (x + y) | unique
    else
      y
    end;
  deepmerge($a[0]; $b[0])
  ' >"$TMP"

mv "$TMP" "$TARGET"
trap - EXIT
log_step "merge $TARGET (deep-merged with $OVERLAY)"
