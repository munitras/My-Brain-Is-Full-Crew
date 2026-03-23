# Security Policy

**My Brain Is Full - Crew (OpenCode Edition)**

This document outlines the security measures, known risks, and reporting procedures for this project.

---

## Supply Chain Security

### Agent Integrity Verification

All agent files are cryptographically hashed. The manifest at `Meta/agent-manifest.json` contains SHA256 hashes for every agent and reference file.

**Verify integrity before and after updates:**

```bash
# After cloning
bash scripts/verify-integrity.sh

# After pulling updates
git pull
bash scripts/verify-integrity.sh

# Generate new manifest after changes
bash scripts/generate-manifest.sh
```

### What We Check

The integrity verification detects:

- **Tampering**: Modified agent prompts that could inject malicious commands
- **Corruption**: Damaged files from download or storage
- **Replacement**: Swapped files with different content

### Zero-Byte Attack Mitigation

This project mitigates zero-byte manipulation attacks through:

1. **SHA256 verification** — Every agent file is hashed
2. **No external network calls** — Agents never fetch remote content
3. **No eval/exec** — Agent prompts cannot execute arbitrary code
4. **Path boundary enforcement** — Agents cannot write outside vault root

### Upstream Merge Safety

When merging changes from the upstream project, always run:

```bash
# Check for suspicious changes before merging
bash scripts/verify-upstream-merge.sh
```

This script scans for:
- New `curl`, `wget`, or network commands in agent files
- `eval`, `exec`, `system()` calls in scripts
- Changes to executable scripts
- URLs that could exfiltrate data

---

## Agent Security Constraints

### Path Boundary

All agents must operate within the vault root. They cannot:

- Write to parent directories (`../`, absolute paths outside vault)
- Access system directories (`/etc`, `/usr`, `/var`, etc.)
- Read environment variables containing secrets
- Execute shell commands outside the vault context

### Tool Restrictions

Each agent has a restricted tool set:

| Agent | Read | Write | Edit | Bash | WebFetch |
|-------|------|-------|------|------|----------|
| Architect | ✓ | ✓ | ✓ | ask | ✗ |
| Scribe | ✓ | ✓ | ✓ | ✗ | ✗ |
| Sorter | ✓ | ✓ | ✓ | ✗ | ✗ |
| Seeker | ✓ | ✗ | ✗ | ✗ | ask |
| Connector | ✓ | ✓ | ✓ | ✗ | ✗ |
| Librarian | ✓ | ✓ | ✓ | ask | ✗ |
| Transcriber | ✓ | ✓ | ✓ | ✗ | ✗ |

### Input Validation

Agents must validate:

1. **File paths** — Reject `../`, absolute paths, symlinks outside vault
2. **User input** — Sanitize before writing to files
3. **External links** — Never auto-download from URLs in notes

---

## Reporting Vulnerabilities

If you discover a security vulnerability, please report it responsibly:

**Email**: Create an issue on GitHub with the tag `security` (after removing any sensitive details)

**Include**:
1. Description of the vulnerability
2. Steps to reproduce
3. Potential impact
4. Suggested fix (if any)

**Do NOT** publicly disclose until we've had time to respond and fix.

---

## Known Limitations

### Agent Prompts Are Trust-Bound

The agent prompt files (`.opencode/agents/*.md`, `AGENTS.md`) contain instructions that OpenCode executes. If an attacker modifies these files, they can potentially:

- Read any file in your vault
- Write/create any file in your vault
- Execute bash commands (for agents with Bash permission)

**Mitigation**: Verify integrity hashes match. Never run modified files with mismatched hashes.

### No Encryption

Notes stored in your vault are **not encrypted** by this system. If you need encryption:

- Use Obsidian's built-in encryption plugins
- Use filesystem-level encryption (LUKS, FileVault, BitLocker)

### No Network Isolation

Agents with `WebFetch` capability can access the internet. While useful for research, this could:

- Leak information about what you're searching
- Connect to attacker-controlled URLs (if prompts are modified)

**Mitigation**: Use `ask` permission for WebFetch, which prompts before each request.

---

## Security Best Practices

### For Users

1. **Run `verify-integrity.sh`** after cloning and after updates
2. **Review changes** before merging upstream (`verify-upstream-merge.sh`)
3. **Don't commit secrets** to your vault (API keys, passwords, etc.)
4. **Use signed commits** (Git commits with GPG/SSH signing)
5. **Keep backups** of your vault outside this system

### For Contributors

1. **Sign your commits** (`git commit -S`)
2. **Don't add network calls** to agent files without security review
3. **Don't add `eval` or `exec`** patterns
4. **Update the manifest** after changing agent files
5. **Run verification** before submitting PRs

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-24 | Initial security documentation |

---

## Contact

Security issues: Open a GitHub issue with the `security` label.