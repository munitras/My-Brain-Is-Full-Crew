# Changelog

All notable changes to this project will be documented in this file.

---

## [Unreleased] — 2026-03-26
### Added
- Added interactive prompt in `install-opencode.sh` and `update-opencode.sh` to allow users to automatically append or update CLI aliases (`now` and `ralph`) in their `.zshrc` or `.bashrc`.
- Added comprehensive `docs/USER_GUIDE.md` detailing installation, usage scenarios, role-based workflows, and agent overviews.
### Removed
- Removed `tasks-bugs.md` (cleaned up working storage).

### Added
- Updated `README.md` and `AGENTS.md` to include documentation for the new Stream 2 capabilities (Reader, Synthesizer, Archaeologist, Foreman, and Chronos) expanding the Crew to 10 agents.
- Created standalone user guides for `reader`, `synthesizer`, and `archaeologist` under `docs/agents/`.
- Created `.opencode/agents/archaeologist.md` configuring the Archaeologist subagent with Local, Augmented, and Deep-Web mining scopes (ARC-1105).
- Instructed Archaeologist to prioritize a "Surface Scan" before deep mining (ARC-1107).
- Created `scripts/ralph.sh` utility to orchestrate multi-mode mining operations saving raw outputs directly to `Meta/Scratchpad/` (ARC-1101).
- Added `scripts.bats` test logic to verify Archaeologist agent configuration and `ralph.sh` execution.
- Created `scripts/chronos-reporter.py` to parse `07-Daily/chronos-ledger.jsonl` and calculate time spent per task (SYS-1006).
- Added tests in `scripts.bats` to ensure `chronos-reporter.py` calculates time deltas correctly.
- Taught Scribe to recognize `@now` as a high-priority system interrupt to explicitly invoke the `context-switch.sh` tool for time-tracking (SYS-1003).
- Added `bash: allow` permission to Scribe to execute the context switch script.
- Added tests in `scripts.bats` to ensure Scribe is properly configured for the `@now` system interrupt command.
- Implemented Chronos Ledger appending logic in `scripts/context-switch.sh` to track context switching events in `07-Daily/chronos-ledger.jsonl` (SYS-1002).
- Added test coverage in `scripts.bats` to ensure `context-switch.sh` writes correct JSONL entries to the Chronos Ledger.
- Created `scripts/context-switch.sh` to update `current_focus` in `Meta/user-profile.md` for the Chronos system (SYS-1001).
- Added test cases in `scripts.bats` to verify `context-switch.sh` correctly updates focus and status.
- Created `.opencode/ON_CLOSE.md` defining the Evening Shutdown Macro to enforce Inbox Zero programmatically via Sorter and Librarian (WRK-901).
- Integrated a daily reflection interactive prompt into `ON_CLOSE.md` routing directly to the Scribe (WRK-902).
- Documented `brainsleep` shell alias in `README.md` to trigger the shutdown macro seamlessly (WRK-903).
- Created `.opencode/agents/synthesizer.md` defining the Synthesizer subagent for document generation, configured with `mode: subagent` and massive context requirements (WRK-801, WRK-802).
- Added `Drafts` to `01-Projects` in `Meta/vault-structure.json` to store AI-generated drafts (WRK-803).
- Updated `AGENTS.md` to include Synthesizer in the dispatcher routing rules and priority table.
- Added tests in `scripts.bats` to verify Synthesizer subagent routing, configuration, and Drafts folder addition.
- Created `.opencode/agents/reader.md` defining the Reader subagent, configured with `webfetch: allow` and instructions for formatting summaries (WRK-701, WRK-702).
- Updated `AGENTS.md` to include Reader in the dispatcher routing rules and priority table (WRK-703).
- Added tests in `scripts.bats` to verify Reader subagent routing and configuration.
- Updated `.opencode/ON_START.md` to trigger the Foreman task sweep script on startup and advise the user to check the HUD (WRK-603).
- Added test coverage in `scripts.bats` to ensure `ON_START.md` accurately includes the Foreman sweep execution and HUD notice.
- Updated `Meta/Dashboard.md` to embed Foreman's output and added a Dataview query to render `#urgent` or tasks due today at the top of the HUD (WRK-602).
- Added test coverage in `scripts.bats` to ensure Dashboard Dataview queries and embeds exist.
- Created `scripts/foreman-sweep.sh` to extract open markdown tasks from the vault (WRK-601).
- Added test cases in `scripts.bats` to verify `foreman-sweep.sh` correctly parses and formats open tasks.
- Implemented Lock-Free CQRS Message Bus (Epic 5) with distributed agent outboxes in `Meta/queues/`.
- Modified `poll-queue.sh` to act as a CQRS Projection Engine, dynamically resolving pending tasks without locks.
- Updated `Meta/schemas/message-schema.json` to enforce `message_id` on requests and `resolves_id` on Resolution Events.
- Finalized Stream 1 Alpha Core: All tasks verified, documentation and Makefile updated. Project is rollout-ready.
- Created `scripts/benchmark-connector.py` to evaluate valid wikilinks and dead link rate (TST-404).
- Added `scripts.bats` test logic to verify Connector integrity script executes accurately.
- Created `scripts/benchmark-transcriber.py` to evaluate Transcriber extraction performance (TST-403).
- Added Golden dataset transcript fixture, expected answer key, and mock predictions for Transcriber benchmarking.
- Created a benchmark evaluation script `scripts/benchmark-sorter.py` and modified `generate-golden-dataset.py` to output a baseline answer key for the Sorter Routing Benchmark (TST-402).
- Added test coverage in `scripts.bats` to ensure the benchmark script accurately calculates baseline accuracy against mock predictions.
- Created Golden Dataset vault benchmarking setup with a python generation script (`scripts/generate-golden-dataset.py`) generating 50 pre-categorized test notes (TST-401).
- Added `scripts.bats` test logic to verify Golden Dataset vault generation script executes accurately (TST-401).
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
- Fixed failing integrity check by updating the expected SHA256 hash for `AGENTS.md` in `Meta/agent-manifest.json`.
- Updated the help message for the `context` target in the `Makefile` to reflect the correct generated file name (`project-context-<date>.txt`).

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