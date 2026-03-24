# Inter-Agent Messaging Protocol

All agents communicate asynchronously via `Meta/agent-messages.md`. This creates a lightweight coordination layer without direct agent-to-agent calls.

---

## Message Format

```markdown
## ⏳ [YYYY-MM-DD HH:MM] FROM: AgentName → TO: AgentName

**Subject**: Brief subject line

**Context**: What you were doing when you discovered this

**Problem**: What needs attention

**Proposed Solution**: What you suggest

**Impact if unresolved**: What happened meanwhile (optional)

---

**Resolution**: (Filled in by recipient when resolved)
- Change `⏳` to `✅` when resolved
- Add this section with what you did
```

---

## Workflow

### For the Sender

1. **Identify the need** — you can't handle something, or another agent should know
2. **Append a message** to `Meta/agent-messages.md`
3. **Continue your task** — don't wait for a response
4. **If critical**, mention the message in your response to the user

### For the Recipient

1. **Before each task**, open `Meta/agent-messages.md`
2. **Look for `⏳` messages addressed to you**
3. **Process each one**: read, act, resolve
4. **Mark resolved**: change `⏳` to `✅`, add resolution

---

## Example Messages

### Scribe → Architect (Missing Structure)

```markdown
## ⏳ [2026-03-21 14:32] FROM: Scribe → TO: Architect

**Subject**: Missing area for "Gardening" notes

**Context**: User captured 3 notes about garden planning, plant care, and seed ordering

**Problem**: No "Gardening" or "Home/Garden" area exists in the vault structure. I placed notes in Inbox.

**Proposed Solution**: Create `02-Areas/Personal/Gardening/` with sub-folders for Plants, Planning, Resources. Create corresponding MOC.

**Impact**: Notes are sitting in Inbox, unorganized.

---

**Resolution**:
- ✅ Created `02-Areas/Personal/Gardening/` with Plants/, Planning/, Resources/
- ✅ Created `_index.md` and `MOC/Gardening.md`
- ✅ Updated Master MOC and `vault-structure.md`
- ✅ Notified Sorter to move the 3 notes from Inbox
```

### Transcriber → Sorter (Action Items Extracted)

```markdown
## ⏳ [2026-03-21 10:15] FROM: Transcriber → TO: Sorter

**Subject**: 5 action items from Sprint Planning meeting

**Context**: Processed meeting recording from 2026-03-21 Sprint Planning

**Problem**: 5 action items were extracted and need filing

**Proposed Solution**: Tasks are in `00-Inbox/` — please file to appropriate project folders

---

**Resolution**:
- ✅ Filed 3 tasks to `01-Projects/Alpha/`
- ✅ Filed 2 tasks to `01-Projects/Beta/`
- ✅ Updated MOCs
```

### Librarian → Architect (Structural Inconsistency)

```markdown
## ⏳ [2026-03-21 09:00] FROM: Librarian → TO: Architect

**Subject**: Orphan notes in 03-Resources/

**Context**: Weekly vault audit found 12 notes in `03-Resources/` that clearly belong to `02-Areas/Work/`

**Problem**: `03-Resources/` is for reference material, not active work notes

**Proposed Solution**: Review and move to appropriate Work sub-folders, or create new sub-folders if needed

---

**Resolution**: (Architect fills in)
```

---

## Priority Levels

| Priority | Marker | Meaning |
|----------|--------|---------|
| Normal | `⏳` | Process when convenient |
| High | `⏳‼️` | Process before next user interaction |
| Urgent | `⏳🔥` | Structural issue blocking other agents — address immediately |

---

## When to Send Messages

### Scribe → Architect
- New topic mentioned that has no area
- Note destination unclear

### Sorter → Architect
- Note doesn't fit anywhere in existing structure

### Connector → Architect
- Cluster of notes needs a new MOC

### Librarian → Architect
- Structural inconsistency found during audit

### Transcriber → Sorter
- Action items extracted from meeting

### Transcriber → Architect
- New project/area mentioned in meeting

### Transcriber → Architect
- New project/area mentioned in meeting

---

##

## Cleanup

The Librarian archives resolved messages older than 7 days by moving them to `Meta/agent-message-archive/YYYY/MM/`.