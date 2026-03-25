#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: Foreman Sweep
# =============================================================================
# Finds all open markdown checkboxes (- [ ]) across 01-Projects/ and 00-Inbox/
# Usage: bash scripts/foreman-sweep.sh <vault_dir>
# =============================================================================

set -e

VAULT_DIR="${1:-.}"

cd "$VAULT_DIR" || exit 1

# Check if directories exist to avoid grep errors
DIRS=()
for dir in "00-Inbox" "01-Projects"; do
    if [ -d "$dir" ]; then
        DIRS+=("$dir")
    fi
done

if [ ${#DIRS[@]} -eq 0 ]; then
    exit 0
fi

# Find all open checkboxes and format output with file source link
# regex matches optional spaces, dash, optional spaces, open bracket, space, close bracket
grep -rnE '^[[:space:]]*-[[:space:]]*\[[[:space:]]\]' "${DIRS[@]}" 2>/dev/null | awk -F':' '{
    file = $1
    line_num = $2
    
    # Reconstruct content in case there are colons in the task
    # Remove file:line_num: prefix
    prefix_len = length(file) + length(line_num) + 2
    content = substr($0, prefix_len + 1)
    
    # Remove leading spaces
    sub(/^[[:space:]]+/, "", content)
    
    # Strip .md extension for obsidian links
    link = file
    sub(/\.md$/, "", link)
    
    # Output the clean task and the link
    print content " [[" link "]]"
}'
