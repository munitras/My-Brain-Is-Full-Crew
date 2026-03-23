# Contributing to My Brain Is Full - Crew (OpenCode Edition)

Thank you for your interest in making the Crew better. This project was born from personal need, and it grows through shared ones.

---

## Ways to contribute

### Improve an existing agent

Found that an agent behaves weirdly, gives poor results, or misses edge cases?

1. Open an issue describing the problem with a concrete example
2. Or submit a PR with the improvement

Agent files live in `.opencode/agents/<agent-name>.md` for subagents. In-context agents are defined in `AGENTS.md`. All agents are written in English, and they automatically respond in the user's language.

To test your changes locally:
```bash
cd /path/to/your-vault
opencode
```

Then say something like "Initialize my vault" to test the Architect.

### Propose a new crew member

Have an idea for a new agent? Open an issue with:

- **Name**: both a descriptive English name and a short codename
- **Role**: what problem does it solve?
- **Type**: subagent (Task tool) or in-context (AGENTS.md)
- **Triggers**: when should it activate? (include phrases in multiple languages)
- **Tool permissions**: what permissions does it need?
- **Vault integration**: which folders does it read/write?
- **Inter-agent coordination**: which other agents should it suggest chaining to?
- **Why it matters**: what gap in the current crew does it fill?

### Add usage examples

Real-world examples of how you use the Crew help everyone. Add them to `docs/examples.md` or share them in an issue.

### Report a bug

Open an issue with:
- What you asked the agent to do
- What it actually did
- What you expected
- Your vault structure (roughly) if relevant

### Security improvements

This project takes security seriously. If you find vulnerabilities:

1. **Report privately** via GitHub Security Advisory
2. Review [SECURITY.md](SECURITY.md) for current practices
3. Contributions to hardening are welcome

---

## Agent file structure

### Subagent format (Architect, Scribe, Seeker)

Subagents are standalone `.md` files in `.opencode/agents/` with OpenCode frontmatter:

```yaml
---
name: <agent-codename>
description: >
  One paragraph description used for auto-triggering.
  Include trigger phrases in multiple languages.
mode: subagent
permission:
  edit: allow
  write: allow
  bash: deny
  webfetch: deny
---

# <Display Name> — <Subtitle>

[Agent instructions in English]

## CRITICAL: Path Boundary Security

**You are RESTRICTED to the vault root directory.**
[Security constraints specific to this agent]
```

### In-context agents (Sorter, Connector, Librarian, Transcriber)

Defined directly in `AGENTS.md` with inline instructions. No separate file needed.

### Key rules for agent files

1. **Write in English.** All agent instructions are in English. Agents respond in the user's language automatically.
2. **Multilingual triggers.** The `description` field should include natural trigger phrases in at least English and Italian, ideally more languages.
3. **Read user profile.** Agents should read `Meta/user-profile.md` for personalization. Never hardcode personal data.
4. **Path boundary.** Every agent MUST include the path boundary security constraint. No operations outside the vault.
5. **Conservative by default.** Agents never delete, always archive. They ask before making structural decisions.
6. **Minimal permissions.** Only grant the permissions the agent actually needs.

---

## OpenCode frontmatter fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Lowercase, hyphens only (e.g., `scribe`) |
| `description` | Yes | When OpenCode should invoke this agent |
| `mode` | Yes | `subagent` for Task tool invocation |
| `permission` | No | Tool permissions (`edit`, `write`, `bash`, `webfetch`) |
| `hidden` | No | `true` to hide from @mention autocomplete |
| `model` | No | Model override (default: inherits from primary) |

---

## Inter-agent coordination

Agents coordinate through the `AGENTS.md` dispatcher and `Meta/agent-messages.md`. When an agent detects work for another agent, it includes a `### Suggested next agent` section in its output or leaves a message in the message board. See `.opencode/references/inter-agent-messaging.md` for the protocol.

---

## Agent directory

| File | Agent name | Type | Role | Permissions |
|------|-------------|------|------|-------------|
| `architect.md` | Architect | Subagent | Vault Structure | Read, Write, Edit, Bash (ask) |
| `scribe.md` | Scribe | Subagent | Text Capture | Read, Write, Edit |
| `seeker.md` | Seeker | Subagent | Search (READ-ONLY) | Read, WebFetch (ask) |
| AGENTS.md | Sorter | In-Context | Inbox Triage | Read, Write, Edit |
| AGENTS.md | Connector | In-Context | Knowledge Graph | Read, Write, Edit |
| AGENTS.md | Librarian | In-Context | Vault Maintenance | Read, Write, Edit, Bash (ask) |
| AGENTS.md | Transcriber | In-Context | Audio & Meetings | Read, Write, Edit |

---

## Updating the manifest

If you modify agent files, regenerate the integrity manifest:

```bash
bash scripts/generate-manifest.sh
```

This creates `Meta/agent-manifest.json` with SHA256 hashes.

---

## Philosophy

This project is built for people who are already overwhelmed. Contributions should make things **simpler**, not more complex.

When in doubt, ask: *"Does this make life easier for someone who's barely keeping it together?"*

If yes, it belongs here.

---

## Security checklist for contributors

Before submitting a PR, verify:

- [ ] No file paths outside the vault root
- [ ] No network calls (`curl`, `wget`, `fetch`, etc.) in agent prompts
- [ ] No `eval`, `exec`, `subprocess`, or similar execution patterns
- [ ] All new agent files include the path boundary security constraint
- [ ] Permissions are minimal for the agent's role
- [ ] No hardcoded secrets or API keys

---

## Code of conduct

Be kind. Treat contributors and users with the same care you'd want when you're not at your best.