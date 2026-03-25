#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: Ralph (Mining Utility)
# =============================================================================
# Multi-mode mining (Vault, FS, Web) into Meta/Scratchpad/
# Usage: bash scripts/ralph.sh --mode <local|augmented|deepweb> --target <query_or_url> [vault_dir]
# =============================================================================

set -e

MODE=""
TARGET=""
VAULT_DIR="."

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --mode) MODE="$2"; shift 2 ;;
        --target) TARGET="$2"; shift 2 ;;
        *) VAULT_DIR="$1"; shift 1 ;;
    esac
done

if [[ -z "$MODE" || -z "$TARGET" ]]; then
    echo "Usage: bash scripts/ralph.sh --mode <local|augmented|deepweb> --target <query_or_url> [vault_dir]"
    exit 1
fi

cd "$VAULT_DIR" || exit 1

SCRATCHPAD_DIR="Meta/Scratchpad"
mkdir -p "$SCRATCHPAD_DIR"

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
# Create a safe target string
SAFE_TARGET=$(echo "$TARGET" | tr -dc '[:alnum:]' | head -c 15)
if [[ -z "$SAFE_TARGET" ]]; then
    SAFE_TARGET="query"
fi

OUT_FILE="$SCRATCHPAD_DIR/mine-${MODE}-${SAFE_TARGET}-${TIMESTAMP}.md"

cat <<EOF > "$OUT_FILE"
---
type: mining-result
mode: $MODE
target: "$TARGET"
date: $(date -Iseconds)
---

# Mining Results: $TARGET ($MODE mode)

EOF

case $MODE in
    local)
        echo "## Local Vault Scan" >> "$OUT_FILE"
        echo '```' >> "$OUT_FILE"
        # Search primary vault folders for target string
        grep -rni "$TARGET" "00-Inbox" "01-Projects" "02-Areas" "03-Resources" 2>/dev/null | head -n 50 >> "$OUT_FILE" || echo "No local results found." >> "$OUT_FILE"
        echo '```' >> "$OUT_FILE"
        ;;
    augmented)
        echo "## Augmented FS Scan" >> "$OUT_FILE"
        echo '```' >> "$OUT_FILE"
        find . -type f -iname "*${TARGET}*" 2>/dev/null | head -n 50 >> "$OUT_FILE" || echo "No files found matching target." >> "$OUT_FILE"
        echo '```' >> "$OUT_FILE"
        ;;
    deepweb)
        echo "## Deep-Web Mining" >> "$OUT_FILE"
        echo "Captured external data from: $TARGET" >> "$OUT_FILE"
        echo '```' >> "$OUT_FILE"
        if command -v curl >/dev/null 2>&1; then
            curl -sL "$TARGET" | head -n 100 >> "$OUT_FILE" || echo "Failed to fetch." >> "$OUT_FILE"
        else
            echo "cURL not available." >> "$OUT_FILE"
        fi
        echo '```' >> "$OUT_FILE"
        ;;
    *)
        echo "Unknown mode: $MODE"
        exit 1
        ;;
esac

echo "Mining complete. Results saved to $OUT_FILE"
