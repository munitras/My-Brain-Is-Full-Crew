# Changelog

All notable changes to this project will be documented in this file.

---

## [Unreleased] — 2026-03-25

### Added
- Converted `vault-structure.md` and `tag-taxonomy.md` to JSON configurations (CTX-201, CTX-202).
- Tests in `scripts.bats` to ensure `vault-structure.json` and `tag-taxonomy.json` are valid JSON.
- Built Dataview Observability Dashboard at `Meta/Dashboard.md` (SYS-105).
- Added unit tests for `poll-queue.sh` in `tests/scripts.bats`.
- JSONL Schema for Message Queue (`Meta/schemas/message-schema.json`).
- `poll-queue.sh` Wrapper Script for efficient queue filtering.
- `.opencode/ON_START.md` file deployment support during installation and updates.
- Automatically copy `scripts/` directory utilities (`validate-paths.sh`, `verify-integrity.sh`, etc.) to the target vault environment.
- Vault structure recreation added to `scripts/update-opencode.sh` to handle accidentally missing directories.

### Changed
- Enforced Strict YAML Schema on Ingestion (OPT-301) by updating Scribe and Transcriber instructions to mandate standardized YAML frontmatter with a `summary` field.
- Optimized Sorter Triage Logic (OPT-302) by instructing Sorter to base routing decisions exclusively on frontmatter metadata to conserve tokens.
- Updated Agent Context Injection (Sorter, Librarian, Architect) to read from new JSON configurations (CTX-203).
- Updated manifest generation script to include `Meta/vault-structure.json` and `Meta/tag-taxonomy.json`.
- Modified install and update scripts to handle deploying JSON configurations to the vault.
- Updated `AGENTS.md` pre-task checklists for Sorter, Connector, Librarian, and Transcriber to invoke the `check_messages` tool and read from JSONL instead of markdown (SYS-103).
- Updated `AGENTS.md` and `CONTRIBUTING.md` Inter-Agent Messaging sections to specify strict JSON schema usage (SYS-104).
- Updated `scripts/install-opencode.sh` to initialize `.jsonl` message bus instead of `.md` format.
- Fixed ShellCheck warnings (SC2034, SC2317, SC2001) across `scripts/*.sh` to improve bash compliance.
- Switched `echo -e` formats to cleaner `printf` or single-parameter `echo -e` implementations where necessary.
- Simplified bash logic (e.g. replacing `cat file | tr` with `tr < file`).
- Updated `Meta/agent-manifest.json` generation logic to support the inclusion of scripts and `.opencode/ON_START.md`.

---

## [Unreleased] — 2026-03-24

### Fixed

**Inter-Agent Messaging Protocol Not Working** — Field operators reported `Meta/agent-messages.md` remaining empty with no inter-agent coordination happening.

**Root Cause**: In-context agents (Sorter, Connector, Librarian, Transcriber) defined in `AGENTS.md` had no pre-task instruction to check for pending messages. Subagent definitions (scribe, seeker) lacked formal task checklists.

**Changes**:
- `AGENTS.md`: Added **Pre-Task Checklist** to all 4 in-context agents requiring them to check `Meta/agent-messages.md` before starting work
- `AGENTS.md`: Added message-leaving instructions (Sorter → Architect for unknown destinations, Connector → Architect for new MOC needs)
- `.opencode/agents/scribe.md`: Added Quick Reference Task Checklist section
- `.opencode/agents/seeker.md`: Added Quick Reference Task Checklist section
- `.opencode/references/agents.md`: Added Pre-Task notes for all 7 agents

### Fixed (Security)

**Manifest Generation Script Corruption** — `scripts/generate-manifest.sh` was injecting success messages into the JSON output, producing invalid manifests.

**Changes**:
- `scripts/generate-manifest.sh`: Moved success message printing outside the JSON generation block

### Fixed (Deployment)

**Update Script Vault Path Detection** — `scripts/update-opencode.sh` failed when repo wasn't a subdirectory inside the vault.

**Changes**:
- `scripts/install-opencode.sh`: Now stores vault path in `.mbifc-vault-path` file
- `scripts/update-opencode.sh`: Reads stored vault path; prompts for path if not found

---

## Git Commit Plan

**Single atomic commit** (recommended):

```
fix: inter-agent messaging and update script vault detection

Inter-Agent Messaging:
- Add Pre-Task Checklist to all in-context agents in AGENTS.md
- Add Task Checklist sections to scribe.md and seeker.md
- Update agents.md reference with Pre-Task notes for all agents
- Fix manifest script success messages corrupting JSON output

Update Script:
- Store vault path during install for reliable updates
- Read stored path; prompt interactively if missing

Fixes: #field-1 agents not checking messages
Fixes: #field-2 update script failing outside vault
```

**Files to stage**:
- `AGENTS.md`
- `.opencode/agents/scribe.md`
- `.opencode/agents/seeker.md`
- `.opencode/references/agents.md`
- `Meta/agent-manifest.json`
- `scripts/generate-manifest.sh`
- `scripts/install-opencode.sh`
- `scripts/update-opencode.sh`
- `CHANGELOG.md` (new)

**Files to gitignore** (not committed):
- `.mbifc-vault-path` — local install path, user-specific
- `Meta/agent-messages.md` — runtime data
- `tasks-bugs.md` — internal notes