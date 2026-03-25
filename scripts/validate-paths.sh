#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: Path Validator
# =============================================================================
# Validates that paths are within the vault root.
# Usage: bash scripts/validate-paths.sh <vault_dir> <path_to_check>
# =============================================================================

set -eo pipefail

VAULT_DIR="$(cd "$1" && pwd)"
PATH_TO_CHECK="$2"

# 1. Reject paths containing ../
if [[ "$PATH_TO_CHECK" == *"../"* ]]; then
    echo "ERROR: Path contains '..'" >&2
    exit 1
fi

# 2. Resolve the path (if it's absolute, use it; if relative, prepend vault_dir)
if [[ "$PATH_TO_CHECK" == /* ]]; then
    FULL_PATH="$(readlink -m "$PATH_TO_CHECK" || echo "$PATH_TO_CHECK")"
else
    FULL_PATH="$(readlink -m "$VAULT_DIR/$PATH_TO_CHECK" || echo "$VAULT_DIR/$PATH_TO_CHECK")"
fi

# 3. Check if FULL_PATH starts with VAULT_DIR
if [[ "$FULL_PATH" != "$VAULT_DIR"* ]]; then
    echo "ERROR: Path escapes vault boundary: $PATH_TO_CHECK" >&2
    exit 1
fi

echo "Path OK: $PATH_TO_CHECK"
exit 0
