#!/bin/bash

# Enforce strict error handling
set -e

# Target file
QUEUE_FILE="Meta/agent-messages.jsonl"

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo '{"error": "jq is not installed on the host system."}'
    exit 1
fi

# Validate input
AGENT_NAME=$1
if [ -z "$AGENT_NAME" ]; then
    echo '{"error": "Agent name parameter is required."}'
    exit 1
fi

# Check if queue exists
if [ ! -f "$QUEUE_FILE" ]; then
    echo '{"error": "Queue file not found at '$QUEUE_FILE'."}'
    exit 1
fi

# Extract and output ONLY pending messages for the requested agent
# The -c flag ensures output remains compact JSONL format
jq -c -M "select(.to == \"$AGENT_NAME\" and .status == \"pending\")" "$QUEUE_FILE" || echo '{"error": "Failed to parse JSONL."}'