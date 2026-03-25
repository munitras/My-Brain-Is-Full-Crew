#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: Context Switch
# =============================================================================
# Updates current_focus in Meta/user-profile.md
# Usage: bash scripts/context-switch.sh [--switch "Focus Name"] [--pause] [--resume] [vault_dir]
# =============================================================================

set -e

ACTION=""
FOCUS_NAME=""
VAULT_DIR="."

while [[ $# -gt 0 ]]; do
    case "$1" in
        --switch)
            ACTION="switch"
            FOCUS_NAME="$2"
            shift 2
            ;;
        --pause)
            ACTION="pause"
            shift
            ;;
        --resume)
            ACTION="resume"
            shift
            ;;
        *)
            if [[ -d "$1" ]]; then
                VAULT_DIR="$1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$ACTION" ]]; then
    echo "Usage: $0 [--switch \"Focus Name\"] [--pause] [--resume] [vault_dir]"
    exit 1
fi

PROFILE_FILE="$VAULT_DIR/Meta/user-profile.md"
mkdir -p "$VAULT_DIR/Meta"

if [[ ! -f "$PROFILE_FILE" ]]; then
    cat << 'EOF' > "$PROFILE_FILE"
---
current_focus: ""
focus_status: "active"
---
# User Profile
EOF
fi

update_yaml() {
    local key="$1"
    local value="$2"
    if grep -q "^${key}:" "$PROFILE_FILE"; then
        # Update existing key
        # using sed with cross-platform compatible syntax
        sed -i.bak -e "s/^${key}:.*/${key}: \"${value}\"/" "$PROFILE_FILE"
    else
        # Insert after the first ---
        sed -i.bak -e "1,/^---/!b" -e "/^---/a\\
${key}: \"${value}\"" "$PROFILE_FILE"
    fi
    rm -f "${PROFILE_FILE}.bak"
}

log_chronos_event() {
    local action="$1"
    local focus="$2"
    local ledger_dir="$VAULT_DIR/07-Daily"
    local ledger_file="$ledger_dir/chronos-ledger.jsonl"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    mkdir -p "$ledger_dir"
    
    # Escape quotes in focus name for JSON
    local safe_focus="${focus//\"/\\\"}"
    
    printf '{"timestamp": "%s", "action": "%s", "task": "%s"}\n' "$timestamp" "$action" "$safe_focus" >> "$ledger_file"
}

case "$ACTION" in
    switch)
        update_yaml "current_focus" "$FOCUS_NAME"
        update_yaml "focus_status" "active"
        log_chronos_event "switch" "$FOCUS_NAME"
        echo "Switched focus to: $FOCUS_NAME"
        ;;
    pause)
        # Extract current focus to log it
        CURRENT_FOCUS=$(grep "^current_focus:" "$PROFILE_FILE" | sed 's/^current_focus: "\(.*\)"/\1/')
        update_yaml "focus_status" "paused"
        log_chronos_event "pause" "$CURRENT_FOCUS"
        echo "Paused current focus"
        ;;
    resume)
        CURRENT_FOCUS=$(grep "^current_focus:" "$PROFILE_FILE" | sed 's/^current_focus: "\(.*\)"/\1/')
        update_yaml "focus_status" "active"
        log_chronos_event "resume" "$CURRENT_FOCUS"
        echo "Resumed current focus"
        ;;
esac
