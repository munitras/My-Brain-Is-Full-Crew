<p align="center">
  <img src="https://img.shields.io/badge/Agents-10-blueviolet?style=for-the-badge" alt="10 Agents" />
  <img src="https://img.shields.io/badge/Language-Any-success?style=for-the-badge" alt="Any Language" />
  <img src="https://img.shields.io/badge/Platform-Obsidian%20%2B%20OpenCode-blue?style=for-the-badge" alt="Obsidian + OpenCode" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="MIT License" />
</p>

# My Brain Is Full - Crew (OpenCode Edition)

### A team of 10 AI agents that manage your Obsidian vault so your brain doesn't have to.

You talk. They organize, file, connect, search, and triage. In any language.

> **This is the OpenCode Edition** — adapted from [My-Brain-Is-Full-Crew](https://github.com/gnekt/My-Brain-Is-Full-Crew) for the OpenCode CLI. The original project targets Claude Code. This fork is OpenCode-native.

---

## What makes this different

Most "AI + Obsidian" tools are built for **people who already have their life together** and want to optimize. This one is for people who are **drowning** and need a lifeline.

**1. The chat IS the interface.**
You don't browse Obsidian. You don't drag files around. You don't maintain complex folder structures manually. You just talk. Everything else happens automatically.

**2. It speaks your language, literally.**
The system works in any language. You shouldn't need to think in English to manage your brain. Just talk in Italian, French, German, Spanish, Japanese, whatever feels natural. The agents match you.

**3. The agents coordinate through a dispatcher.**
When the transcription agent processes a meeting and discovers a new project, the dispatcher automatically chains the Architect to create the folder structure. It's a crew, not a collection of isolated tools.

---

## The Crew (10 Agents)

| # | Agent | Role | Type | Superpower |
|---|-------|------|------|------------|
| 1 | **Architect** | Vault Structure & Setup | Subagent | Designs your entire vault, runs onboarding, sets the rules everyone follows |
| 2 | **Scribe** | Text Capture | Subagent | Transforms your messy, typo-filled, stream-of-consciousness dumps into clean notes |
| 3 | **Sorter** | Inbox Triage | In-Context | Empties your inbox every evening and routes every note to its perfect home |
| 4 | **Seeker** | Search & Intelligence | Subagent | Finds anything in your vault, synthesizes answers across notes with citations |
| 5 | **Connector** | Knowledge Graph | In-Context | Discovers hidden links between your notes, even ones you'd never think of |
| 6 | **Librarian** | Vault Maintenance | In-Context | Weekly health checks, deduplication, broken link repair, growth analytics |
| 7 | **Transcriber** | Audio & Meetings | In-Context | Turns recordings and transcripts into rich, structured meeting notes |
| 8 | **Reader** | Web Ingestion | Subagent | Captures external URLs, removes ads, and synthesizes the core thesis into your vault |
| 9 | **Synthesizer** | Delegation & Planning | Subagent | Transforms your raw notes into actionable project plans and structured delegation maps |
| 10 | **Archaeologist** | Deep-Dive Research | Subagent | Runs multi-mode surface scans and deep data mining across external urls and files |

**Architecture**: 6 subagents (Architect, Scribe, Seeker, Reader, Synthesizer, Archaeologist) run as isolated subagent processes via OpenCode's Task tool. 4 in-context agents (Sorter, Connector, Librarian, Transcriber) handle simpler tasks directly in AGENTS.md.

---

## Works in any language

The Crew is built in English but **responds in whatever language you write in**. Italian, French, Spanish, German, Portuguese, Japanese: just talk, and the agents match you.

```
"Salva questa nota veloce..."       → Scribe responds in Italian
"Was habe ich diese Woche geplant?" → Seeker responds in German
"Check my inbox"                    → Sorter responds in English
```

No translations to install. No language packs. It just works.

---

## Quick start

> **Prerequisites**: [OpenCode CLI](https://opencode.ai) and [Obsidian](https://obsidian.md) (free).

### 1. Create your Obsidian vault

Open Obsidian and create a new vault (or use an existing one).

### 2. Clone the repo inside your vault

```bash
cd /path/to/your-vault
git clone https://github.com/munitras/My-Brain-Is-Full-Crew.git
cd My-Brain-Is-Full-Crew
```

### 3. Run the installer

You can use the provided `Makefile` for a guided experience:

```bash
make install
```

Alternatively, run the script directly:

```bash
bash scripts/install-opencode.sh
```

The script will:
- Verify file integrity (security check)
- Copy agents into your vault's `.opencode/` directory
- Create the vault folder structure
- Ask a few questions to personalize your setup

### 4. Initialize

Open OpenCode **inside your vault folder**:

```bash
cd /path/to/your-vault
opencode
```

Then say:

> **"Initialize my vault"**

The **Architect** agent will guide you through onboarding and create your entire vault structure.

### 5. Start using it

| You say | What happens |
|---------|-------------|
| *"Save this: meeting with Marco about the Q3 budget"* | **Scribe** captures it with clean formatting and tasks |
| *"Triage my inbox"* | **Sorter** files everything, updates MOCs |
| *"What did we decide about pricing?"* | **Seeker** searches your vault, synthesizes the answer with citations |
| *"Weekly review"* | **Librarian** audits broken links, duplicates, health score |
| *"Find connections for my latest note"* | **Connector** discovers hidden links in your vault |
| *"Read this article https://..."* | **Reader** ingests it and creates a summary note |
| *"Draft a proposal from my notes on Project X"* | **Synthesizer** generates a complete document in Drafts |
| *"Deep mine this list of URLs"* | **Archaeologist** runs a comprehensive scan into the Scratchpad |

### 6. Evening Shutdown Macro

To seamlessly trigger the evening wind-down workflow, you can add this alias to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
alias brainsleep="opencode --prompt 'Execute ON_CLOSE.md...'"
```

Running `brainsleep` will automatically empty your inbox, perform a health check, and ask for a daily reflection to park thoughts for tomorrow.

### 7. Time-Keeping (Chronos)

Use explicit command-bussed context switching to track what you're working on.
Type `@now --switch -to "Research X"` to start a task. The system logs it into a ledger, which can be summarized later for productivity metrics via `scripts/chronos-reporter.py`.

### 8. The Foreman & HUD

Every morning, the boot sequence triggers the **Foreman** sweep, which extracts open checkboxes and urgent tasks across your vault, prioritizing them directly into your **Dashboard HUD** (`Meta/Dashboard.md`).

---

## Vault structure

```
00-Inbox/          ← Capture everything here first
01-Projects/       ← Active projects with deadlines
02-Areas/          ← Ongoing responsibilities
03-Resources/      ← Reference material, guides, how-tos
04-Archive/        ← Completed or historical content
05-People/         ← Your personal CRM
06-Meetings/       ← Timestamped meeting notes
07-Daily/          ← Daily notes and journals
MOC/               ← Maps of Content (thematic indexes)
Templates/         ← Obsidian note templates
Meta/              ← Vault config, agent logs, health reports
```

---

## Security

### Path Boundary Protection

**All agents are RESTRICTED to the vault root directory.** They cannot:

- Write to paths containing `../`
- Write to absolute paths outside the vault
- Access system directories (`/etc`, `/usr`, etc.)
- Read environment variables or secrets
- Follow symlinks that escape the vault

Agents use `scripts/validate-paths.sh` for runtime path validation before performing any file operations.

### Integrity Verification

After cloning and after updates, verify file integrity:

```bash
bash scripts/verify-integrity.sh
```

This checks SHA256 hashes of all agent files against the manifest. If verification fails, **do not proceed** — this may indicate tampering.

### Upstream Merge Safety

Before merging changes from upstream:

```bash
bash scripts/verify-upstream-merge.sh
```

This scans for suspicious patterns (network calls, eval/exec) in changed files.

See [SECURITY.md](SECURITY.md) for full details.

---

## Development & Testing

This project uses [bats-core](https://github.com/bats-core/bats-core) for shell script testing.

### Running Tests

```bash
bats tests/scripts.bats
```

The test suite covers:
- Manifest generation and integrity verification
- Installer behavior
- Path validation logic

---

## Upstream tracking

This fork tracks the original [My-Brain-Is-Full-Crew](https://github.com/gnekt/My-Brain-Is-Full-Crew) repository:

```bash
# Check for upstream updates
git fetch fork-from
bash scripts/verify-upstream-merge.sh

# If clean, merge
git checkout upstream
git merge fork-from/main
git checkout main
git merge upstream
bash scripts/generate-manifest.sh
```

---

## Architecture

```
OpenCode CLI
     │
     ▼ reads AGENTS.md
┌────────────────────┐
│  AGENTS.md         │  ← Dispatcher with routing rules
│  (main dispatcher) │
└────────────────────┘
     │
     ├── Task tool ──► Architect (subagent)
     ├── Task tool ──► Scribe (subagent)
     ├── Task tool ──► Seeker (subagent)
     │
     └── Handle in-context:
         ├─ Sorter
         ├─ Connector
         ├─ Librarian
         └─ Transcriber
```

Each agent has specific tool permissions:

| Agent | Read | Write | Edit | Bash | WebFetch |
|-------|------|-------|------|------|----------|
| Architect | ✓ | ✓ | ✓ | ask | ✗ |
| Scribe | ✓ | ✓ | ✓ | ✗ | ✗ |
| Sorter | ✓ | ✓ | ✓ | ✗ | ✗ |
| Seeker | ✓ | ✗ | ✗ | ✗ | ask |
| Connector | ✓ | ✓ | ✓ | ✗ | ✗ |
| Librarian | ✓ | ✓ | ✓ | ask | ✗ |
| Transcriber | ✓ | ✓ | ✓ | ✗ | ✗ |

---

## Files

| File | Purpose |
|------|---------|
| `Makefile` | High-level SDLC and installation automation |
| `AGENTS.md` | Main dispatcher with routing logic |
| `.opencode/agents/*.md` | Subagent definitions (Architect, Scribe, Seeker) |
| `.opencode/references/*.md` | Shared documentation for all agents |
| `scripts/install-opencode.sh` | Initial setup |
| `scripts/update-opencode.sh` | Update after pulling changes |
| `scripts/verify-integrity.sh` | Verify file hashes |
| `scripts/generate-manifest.sh` | Regenerate integrity manifest |
| `scripts/generate-context.sh` | Generate dated project-context.txt |
 | `scripts/validate-paths.sh` | Runtime path boundary validator |
 | `SECURITY.md` | Security policy and practices |
 | `tests/scripts.bats` | Shell script test suite |

---

## Recommended Obsidian plugins

**Essential:** Templater, Dataview, Calendar, Tasks

**Recommended:** QuickAdd, Folder Notes, Tag Wrangler, Natural Language Dates, Periodic Notes, Omnisearch, Linter

---

## Updating

After pulling changes from the repo, you can use the Makefile to verify and update:

```bash
make update
```

Alternatively, run the scripts manually:

```bash
cd /path/to/your-vault/My-Brain-Is-Full-Crew
git pull
bash scripts/verify-integrity.sh
bash scripts/update-opencode.sh
```

Only changed files are updated. Your vault notes are never touched.

---

## Contributing

PRs are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

Areas where help is especially welcome:
- Improving agent prompts for better coordination
- Adding new agent capabilities
- Fixing edge cases
- Documentation improvements
- Security hardening

---

## Differences from Claude Version

| Claude Version | OpenCode Version |
|----------------|------------------|
| `CLAUDE.md` dispatcher | `AGENTS.md` dispatcher |
| `.claude/agents/` with YAML frontmatter | `.opencode/agents/` with OpenCode frontmatter |
| 8 agents (including Postman) | 7 agents (Postman removed) |
| MCP for Gmail/Calendar | No external integrations |
| Subagent `Agent` tool | Subagent `Task` tool |
| `.claude/skills/` | In-context agent definitions |

---

## Philosophy

> *"The best organizational system is the one you actually use."*

The Crew is designed for people who are overwhelmed, not for people who enjoy organizing. Every design decision prioritizes **minimum friction**:

- **Chat is the interface**: no manual file management
- **Agents handle the boring stuff**: filing, linking, maintaining
- **Any language, any time**: your brain shouldn't have to switch languages
- **Conservative by default**: agents never delete, always archive

---

## Star this repo

If the Crew helps you, consider starring this repo. It helps others find it.

---

## Credits

Adapted from [My-Brain-Is-Full-Crew](https://github.com/gnekt/My-Brain-Is-Full-Crew) by **Christian Di Maio (@gnekt)**.

Original project designed for Claude Code. This fork is OpenCode-native with security hardening.

---

## License

MIT: use it, modify it, share it. Keep the attribution.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.** See [LICENSE](LICENSE) for full terms.