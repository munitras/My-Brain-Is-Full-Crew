# MBIFC(1) User Manual

## NAME
mbifc - My Brain Is Full Crew (OpenCode Edition) - AI agent team for Obsidian vault management

## SYNOPSIS
Talk naturally to your AI agents to manage your vault.
**Agents:** architect, scribe, seeker, sorter, connector, librarian, transcriber, reader, synthesizer, archaeologist

## DESCRIPTION
**My Brain Is Full Crew (MBIFC)** is a team of 10 AI agents that autonomously manage your Obsidian vault. They can transcribe meetings, sort your inbox, build maps of content, mine data, and more. All agents operate strictly within the vault root directory boundaries, ensuring your knowledge base is organized securely.

## INSTALLATION
1. **Clone the repository** into your Obsidian vault's root directory.
2. **Verify Integrity (MANDATORY)**
   Run the verification script to ensure no agent files have been tampered with:
   ```bash
   bash scripts/verify-integrity.sh
   ```
3. **Initialize the Vault**
   Ask the **Architect** agent to set up the default structure:
   "initialize vault"

## USAGE SCENARIOS

### 1. Note Capture & Routing
**Scenario:** You have a quick thought or a raw text dump to save.
**Action:** Trigger the **Scribe** agent.
**Command:** "quick note" or "save this"
**Result:** Scribe saves the formatted note to `00-Inbox/`.

**Scenario:** You need to organize your messy inbox.
**Action:** Trigger the **Sorter** agent.
**Command:** "triage inbox"
**Result:** Sorter scans frontmatter, formulates a filing plan, and moves notes to appropriate project/area folders upon your approval.

### 2. Information Retrieval & Connection
**Scenario:** You are looking for specific information across your vault.
**Action:** Trigger the **Seeker** agent.
**Command:** "find my notes on X"
**Result:** Seeker retrieves relevant information without modifying any files.

**Scenario:** You want to discover hidden links between your notes.
**Action:** Trigger the **Connector** agent.
**Command:** "connect related notes"
**Result:** Connector suggests and adds `[[wikilinks]]` between related concepts and updates MOCs.

### 3. Audio & Meeting Processing
**Scenario:** You have a raw meeting transcript that needs processing.
**Action:** Trigger the **Transcriber** agent.
**Command:** "transcribe meeting"
**Result:** Transcriber extracts key points, action items, and creates a structured note with valid YAML frontmatter containing a summary.

### 4. Vault Maintenance
**Scenario:** It's time for your weekly vault review.
**Action:** Trigger the **Librarian** agent.
**Command:** "weekly review" or "check vault health"
**Result:** Librarian checks for duplicates, broken links, and generates a health report in `Meta/health-reports/`.

## ROLE-BASED WORKFLOWS

### Project Manager
**Daily:**
- "triage inbox" (Sorter) to organize daily notes and updates.
- "transcribe meeting" (Transcriber) for daily stand-ups and syncs.
**Weekly:**
- "draft a proposal based on this week's notes" (Synthesizer) to prepare weekly reports.
- "connect related notes" (Connector) to link project updates with broader goals.
**Ad-Hoc:**
- "find my notes on [Project X]" (Seeker) for sudden inquiries.
- "new project" (Architect) to initialize structures for upcoming initiatives.

### Software Developer
**Daily:**
- "quick note" (Scribe) to capture bug findings or architecture ideas.
- "search for [API endpoint]" (Seeker) to find previously documented technical details.
**Weekly:**
- "read this link" (Reader) to process and summarize weekly technical readings/docs.
- "connect related notes" (Connector) to tie isolated code snippets or concepts to main architecture notes.
**Ad-Hoc:**
- "mine this url" (Archaeologist) to deep-dive into new frameworks or external documentation.
- "write a technical design doc based on [Notes]" (Synthesizer) for new feature planning.

### Reporting
**Daily:**
- Use Scribe to log daily metrics or updates into `07-Daily/`.
**Weekly:**
- Use Synthesizer to compile weekly achievements or blockers from daily notes.
**Ad-Hoc:**
- Use Seeker to pull specific historical data for impromptu stakeholder reports.

### Maintenance Cycles
**Daily:**
- Run Sorter to ensure `00-Inbox/` remains clean and notes are filed correctly.
**Weekly:**
- Trigger "weekly review" (Librarian) to check vault health, find broken links, and remove duplicates.

## UPDATE
1. Pull the latest changes from the official repository.
2. Re-run the integrity verification script:
   ```bash
   bash scripts/verify-integrity.sh
   ```
3. Review any changes to `Meta/vault-structure.json` or `Meta/tag-taxonomy.json` for new organizational structures.

## SEE ALSO
AGENTS.md, README.md
