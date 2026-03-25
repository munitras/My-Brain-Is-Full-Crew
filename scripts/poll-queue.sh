#!/bin/bash

# Enforce strict error handling
set -e

# Target directory for the distributed queues
QUEUE_DIR="Meta/queues"
AGENT_NAME=$1

# 1. Pre-flight checks
if ! command -v jq &> /dev/null; then
    echo '{"error": "jq is missing. The Projection Engine requires jq."}'
    exit 1
fi

if [ -z "$AGENT_NAME" ]; then
    echo '{"error": "Agent name parameter required (e.g., ./poll-queue.sh architect)"}'
    exit 1
fi

# Ensure the queues directory exists and has files
if [ ! -d "$QUEUE_DIR" ] || [ -z "$(ls -A $QUEUE_DIR/*-outbox.jsonl 2>/dev/null)" ]; then
    # Return nothing if no queues exist yet
    exit 0
fi

# 2. The jq Projection Logic
# We cat all outbox files together, slurp them into a single array (-s),
# extract the resolved IDs, and filter the pending requests.
cat $QUEUE_DIR/*-outbox.jsonl | jq -c -s --arg target_agent "$AGENT_NAME" '
  # Step A: Build an array of all IDs that have been resolved
  ( [ .[] | select(.resolves_id != null) | .resolves_id ] ) as $resolved_ids |
  
  # Step B: Iterate over all objects again
  .[] |
  
  # Step C: Keep only requests addressed to this agent
  select(.to == $target_agent and .message_id != null and .status == "pending") |
  
  # Step D: Reject it if its message_id is found in the $resolved_ids array
  select(.message_id as $id | $resolved_ids | index($id) | not)
' || echo '{"error": "Failed to parse JSONL."}'