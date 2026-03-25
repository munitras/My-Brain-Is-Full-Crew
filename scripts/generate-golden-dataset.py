#!/usr/bin/env python3
import os
import json
import random
from datetime import datetime, timedelta

VAULT_DIR = "tests/fixtures/golden-vault"
INBOX_DIR = os.path.join(VAULT_DIR, "00-Inbox")

# Categories for the 50 test notes
CATEGORIES = {
    "clear": 20,
    "ambiguous": 20,
    "noise": 10
}

# Dummy vault structure to mimic production
FOLDERS = [
    "00-Inbox",
    "01-Projects/Alpha",
    "01-Projects/Beta",
    "02-Areas/Health",
    "02-Areas/Finance",
    "03-Resources/Articles",
    "04-Archive/2026",
    "06-Meetings/2026/03",
    "Meta"
]

def setup_vault():
    for f in FOLDERS:
        os.makedirs(os.path.join(VAULT_DIR, f), exist_ok=True)
    
    # Copy Meta configs if possible, or just create dummy ones
    meta_dir = os.path.join(VAULT_DIR, "Meta")
    with open(os.path.join(meta_dir, "vault-structure.json"), "w") as f:
        json.dump({"01-Projects": {"subfolders": ["Alpha", "Beta"]}}, f)

def generate_notes():
    note_id = 1
    
    # Generate CLEAR notes
    for i in range(CATEGORIES["clear"]):
        title = f"Clear_Note_{note_id}.md"
        content = f"""---
type: idea
date: 2026-03-25
status: inbox
tags: [[Alpha]]
summary: "This is a clear idea about Project Alpha."
source: text
category_test: clear
---

# Clear Idea {note_id}
This note clearly belongs in 01-Projects/Alpha because it mentions Alpha and has the tag.
"""
        with open(os.path.join(INBOX_DIR, title), "w") as f:
            f.write(content)
        note_id += 1

    # Generate AMBIGUOUS notes
    for i in range(CATEGORIES["ambiguous"]):
        title = f"Ambiguous_Note_{note_id}.md"
        content = f"""---
type: meeting
date: 2026-03-25
status: inbox
tags: [[sync], [Alpha], [Finance]]
summary: "Sync call regarding Alpha budgets."
source: voice
category_test: ambiguous
---

# Ambiguous Sync {note_id}
This note could go to 01-Projects/Alpha or 02-Areas/Finance or 06-Meetings.
"""
        with open(os.path.join(INBOX_DIR, title), "w") as f:
            f.write(content)
        note_id += 1

    # Generate NOISE notes
    for i in range(CATEGORIES["noise"]):
        title = f"Noise_Note_{note_id}.md"
        content = f"""---
type: journal
date: 2026-03-25
status: inbox
tags: [[random]]
summary: "Just some random thoughts that do not map to any existing folder."
source: text
category_test: noise
---

# Noise Entry {note_id}
Random grocery list. Needs a new folder or stays in inbox.
"""
        with open(os.path.join(INBOX_DIR, title), "w") as f:
            f.write(content)
        note_id += 1

if __name__ == "__main__":
    setup_vault()
    generate_notes()
    print("Golden dataset vault generated with 50 notes.")
