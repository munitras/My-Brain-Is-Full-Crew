# My Brain Is Full — Crew Agent Directory

This reference is shared across all agents. Every agent knows the others, their responsibilities, and when to contact them.

---

## Security Note

**All agents are RESTRICTED to the vault root directory.** They cannot access files outside the vault, system directories, or follow symlinks that escape the vault. This is enforced at multiple levels.

---

## Language Rule

**All agents respond in the user's language.** Match the language the user writes in.

---

## User Profile

All agents read `Meta/user-profile.md` for personalization. Contains name, language, role, and preferences.

---

## The Seven Agents

### 1. Architect (Subagent)
**Role**: Vault Structure & Governance
**Trigger**: Vault structure, areas, templates, MOCs, onboarding, defrag
**Invoke**: `Task tool with subagent_type: "architect"`
**Pre-Task**: Check `Meta/agent-messages.md` for pending messages
**Contact when**: New folder/area needed, vault structure seems wrong, tag taxonomy needs updating, another agent doesn't know where a note should live.

---

### 2. Scribe (Subagent)
**Role**: Text Capture & Refinement
**Trigger**: Raw text, quick thoughts, ideas, to-dos, unstructured information
**Invoke**: `Task tool with subagent_type: "scribe"`
**Pre-Task**: Check `Meta/agent-messages.md` for pending messages
**Contact when**: A note needs cleanup or reformatting, raw text needs structuring.

---

### 3. Sorter (In-Context)
**Role**: Inbox Triage & Filing
**Trigger**: Inbox triage, filing notes, organizing
**Pre-Task**: Check `Meta/agent-messages.md` for pending messages addressed to Sorter
**Contact when**: Notes piling up in inbox, note filed incorrectly, MOCs out of date.

---

### 4. Seeker (Subagent)
**Role**: Search & Intelligence (READ-ONLY)
**Trigger**: Search, find, questions about notes, "where did I put"
**Invoke**: `Task tool with subagent_type: "seeker"`
**Pre-Task**: Check `Meta/agent-messages.md` for pending messages
**Contact when**: Information needs finding before acting, note location unknown, cross-reference needed.

---

### 5. Connector (In-Context)
**Role**: Knowledge Graph & Link Analysis
**Trigger**: Connections between notes, graph, relationships, cross-linking
**Pre-Task**: Check `Meta/agent-messages.md` for pending messages addressed to Connector
**Contact when**: Notes feel isolated, after batch filing, MOC coverage low.

---

### 6. Librarian (In-Context)
**Role**: Vault Health & Quality Assurance
**Trigger**: Weekly review, maintenance, duplicates, broken links, audit
**Pre-Task**: Check `Meta/agent-messages.md` for pending messages addressed to Librarian
**Contact when**: Vault-wide quality issues, duplicates, broken links, inconsistent tags.

---

### 7. Transcriber (In-Context)
**Role**: Audio & Meeting Intelligence
**Trigger**: Audio, recordings, transcriptions, meetings
**Pre-Task**: Check `Meta/agent-messages.md` for pending messages addressed to Transcriber
**Contact when**: Meeting recording or transcript needs structuring, note from audio source.

---

## Quick Reference: Who to Message for What

| Problem | Message to |
|---------|-----------|
| "Don't know where to file this note" | Architect |
| "This area/folder doesn't exist" | Architect |
| "Tag doesn't exist in taxonomy" | Architect |
| "Template is missing or wrong" | Architect |
| "User wants to update their profile" | Architect |
| "Found a duplicate note" | Librarian |
| "Found a broken link" | Librarian |
| "Note has wrong frontmatter" | Librarian |
| "Vault structure seems inconsistent" | Librarian |
| "This note should link to others" | Connector |
| "Found related but unlinked notes" | Connector |
| "Need to find an existing note" | Seeker |
| "This came from a meeting recording" | Transcriber |