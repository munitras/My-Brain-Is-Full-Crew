# Tasks & Bugs

Active issues and improvements for the OpenCode Crew project.

---

## 🔴 BUG: Inter-Agent Messaging Not Happening

**Status**: Triaging  
**Reported**: 2026-03-24  
**Source**: Field operator report — agent-messages.md empty

### Problem

Field deployments report that `Meta/agent-messages.md` remains empty — no inter-agent coordination happening.

### Root Cause Analysis

The messaging protocol exists in documentation, but agents are not instructed to proactively check for pending messages.

#### Subagents (architect, scribe, seeker)

Subagent files DO mention messaging but:
- Only `architect.md` has a Task Checklist (lines 168-176) with "Check Meta/agent-messages.md" as step 2
- `scribe.md` and `seeker.md` mention checking messages but lack a formal checklist
- When Task tool spawns a subagent, it gets a fresh context — it must have explicit instructions

#### In-Context Agents (sorter, connector, librarian, transcriber)

**Critical gap**: AGENTS.md defines these agents (lines 99-170) but NONE of them have:
- "Check Meta/agent-messages.md" in their Behavior steps
- Any mention of reading pending messages before starting work

This means when the main agent handles an in-context task, it doesn't check for pending messages.

### Evidence

```
In AGENTS.md:
- Sorter (lines 99-116): No message check
- Connector (lines 118-133): No message check  
- Librarian (lines 135-153): Archives messages but doesn't CHECK them first
- Transcriber (lines 155-171): No message check

Only Architect.md has a proper Task Checklist with message checking.
```

### Fix Required

1. **AGENTS.md**: Add "Check Meta/agent-messages.md first" to ALL in-context agent behaviors
2. **Subagent files**: Add Task Checklist section to scribe.md and seeker.md (matching architect.md format)
3. **In-Context agent stubs**: Add explicit pre-task message check instruction
4. **References**: Update `.opencode/references/agents.md` with Pre-Task notes

### Fix Status

✅ **PATCHED** in source (2026-03-24):
- AGENTS.md: Added Pre-Task Checklist to all 4 in-context agents (Sorter, Connector, Librarian, Transcriber)
- Added message-leaving instructions where missing (Sorter → Architect, Connector → Architect)
- `.opencode/agents/scribe.md`: Added Quick Reference Task Checklist
- `.opencode/agents/seeker.md`: Added Quick Reference Task Checklist
- `.opencode/references/agents.md`: Added Pre-Task notes for all 7 agents

### Deployment Notes

Existing snapshots will need to:
1. Pull latest from source
2. Run `bash scripts/update-opencode.sh` (copies updated files to vault)
3. Or manually re-run `bash scripts/install-opencode.sh`

### Test Plan

1. Install in fresh vault
2. Trigger one agent that should leave a message (e.g., Scribe finding missing structure)
3. Verify message appears in Meta/agent-messages.md
4. Trigger recipient agent (e.g., Architect)
5. Verify agent reads and processes pending message

---

## 🟡 FIXED: Update Script Vault Path Detection

**Status**: Fixed (2026-03-24)  
**Reported**: Field operator during testing

### Problem

`scripts/update-opencode.sh` failed with:
```
Error: No .opencode/agents/ found in /home/mun/w/m/domains/beta/projects — run install-opencode.sh first
```

### Root Cause

Script assumed repo was cloned as a subdirectory inside the vault:
```
VAULT_DIR="$(cd "$REPO_DIR/.." && pwd)"
```

This worked for `Vault/My-Brain-Is-Full-Crew/` layout but failed for standalone repos.

### Fix

1. `install-opencode.sh` now stores vault path in `$REPO_DIR/.mbifc-vault-path`
2. `update-opencode.sh` reads stored path; prompts interactively if missing or invalid