#!/usr/bin/env python3
# =============================================================================
# My Brain Is Full - Crew :: Chronos Reporter
# =============================================================================
# Parses the chronos ledger and calculates time deltas per task.
# Usage: python3 scripts/chronos-reporter.py [vault_dir]
# =============================================================================

import sys
import os
import json
from datetime import datetime
from collections import defaultdict

def parse_time(ts_str):
    return datetime.strptime(ts_str, "%Y-%m-%dT%H:%M:%SZ")

def main():
    vault_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    ledger_path = os.path.join(vault_dir, "07-Daily", "chronos-ledger.jsonl")

    if not os.path.exists(ledger_path):
        print(f"No ledger found at {ledger_path}")
        sys.exit(0)

    task_durations = defaultdict(float)
    
    current_task = None
    last_time = None
    
    with open(ledger_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
                
            ts = parse_time(entry['timestamp'])
            action = entry['action']
            task = entry.get('task', 'Unknown')
            
            if action == 'switch':
                if current_task and last_time:
                    task_durations[current_task] += (ts - last_time).total_seconds()
                
                current_task = task
                last_time = ts
            
            elif action == 'pause':
                if current_task == task and last_time:
                    task_durations[current_task] += (ts - last_time).total_seconds()
                    last_time = None
                    
            elif action == 'resume':
                if current_task == task:
                    last_time = ts

    if current_task and last_time:
        now = datetime.utcnow()
        task_durations[current_task] += (now - last_time).total_seconds()

    print("Chronos Time Report:")
    print("-" * 40)
    
    if not task_durations:
        print("No time tracked yet.")
        return
        
    for task, seconds in sorted(task_durations.items(), key=lambda x: x[1], reverse=True):
        hours = int(seconds // 3600)
        minutes = int((seconds % 3600) // 60)
        print(f"{task:<30} | {hours}h {minutes}m")

if __name__ == "__main__":
    main()
