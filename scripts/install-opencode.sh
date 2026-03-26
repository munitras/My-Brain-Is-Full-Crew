#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: OpenCode Installer
# =============================================================================
# Run this from inside the cloned repo:
#
#   cd /path/to/your-vault/My-Brain-Is-Full-Crew
#   bash scripts/install-opencode.sh
#
# It sets up the crew for use with OpenCode.
# =============================================================================

set -eo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
  RED='\033[0;31m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
else
  GREEN=''; CYAN=''; YELLOW=''; RED=''; BOLD=''; DIM=''; NC=''
fi

info()    { echo -e "   ${CYAN}>${NC} $*"; }
success() { echo -e "   ${GREEN}✓${NC} $*"; }
warn()    { echo -e "   ${YELLOW}!${NC} $*"; }
die()     { echo -e "\n   ${RED}Error: $*${NC}\n" >&2; exit 1; }

# ── Find paths ──────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VAULT_DIR="$(cd "$REPO_DIR/.." && pwd)"

# Sanity checks
[[ -d "$REPO_DIR/.opencode" ]] || die "Can't find .opencode/ in $REPO_DIR — are you running this from the repo?"
[[ -d "$REPO_DIR/.opencode/references" ]] || die "Can't find .opencode/references/ in $REPO_DIR"
[[ -f "$REPO_DIR/AGENTS.md" ]] || die "Can't find AGENTS.md in $REPO_DIR"

# ── Integrity check ──────────────────────────────────────────────────────────
if [[ ! -f "$REPO_DIR/Meta/agent-manifest.json" ]]; then
  echo ""
  warn "No manifest found. Generating one now..."
  bash "$REPO_DIR/scripts/generate-manifest.sh"
fi

if command -v sha256sum >/dev/null 2>&1; then
  echo ""
  info "Verifying file integrity..."
  
  MANIFEST="$REPO_DIR/Meta/agent-manifest.json"
  FAILED=0
  
  for relpath in $(jq -r '.files | keys[]' "$MANIFEST" 2>/dev/null || true); do
    filepath="$REPO_DIR/$relpath"
    if [[ ! -f "$filepath" ]]; then
      echo -e "   ${RED}✗ MISSING: $relpath${NC}"
      FAILED=$((FAILED + 1))
      continue
    fi
    
    expected_hash=$(jq -r ".files[\"$relpath\"]" "$MANIFEST")
    actual_hash=$(sha256sum "$filepath" | cut -d' ' -f1)
    
    if [[ "$expected_hash" != "$actual_hash" ]]; then
      echo -e "   ${RED}✗ MISMATCH: $relpath${NC}"
      FAILED=$((FAILED + 1))
    fi
  done
  
  if [[ $FAILED -gt 0 ]]; then
    echo ""
    echo -e "${RED}${BOLD}   ⚠️  SECURITY ALERT: $FAILED file(s) failed integrity check!${NC}"
    echo -e "${RED}   This may indicate tampering or corruption.${NC}"
    echo -e "${RED}   Do NOT proceed with installation.${NC}"
    echo ""
    echo -e "   If you trust the source, regenerate the manifest:"
    echo -e "   ${BOLD}bash scripts/generate-manifest.sh${NC}"
    exit 1
  fi
  
  success "Integrity check passed"
fi

# ── Banner ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  My Brain Is Full — OpenCode Crew Setup  ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "   Repo:   ${BOLD}${REPO_DIR}${NC}"
echo -e "   Vault:  ${BOLD}${VAULT_DIR}${NC}"
echo ""

# ── Confirm vault location ─────────────────────────────────────────────────
echo -e "${BOLD}Is this your Obsidian vault folder?${NC}"
echo -e "   ${DIM}${VAULT_DIR}${NC}"
echo ""
echo -e "   ${BOLD}y)${NC} Yes, install here"
echo -e "   ${BOLD}n)${NC} No, let me type the correct path"
read -r -p "   > " CONFIRM

if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
  echo ""
  echo -e "${BOLD}Enter the full path to your Obsidian vault:${NC}"
  read -r -p "   > " VAULT_DIR
  VAULT_DIR="${VAULT_DIR/#\~/$HOME}"
  [[ -d "$VAULT_DIR" ]] || die "Directory not found: $VAULT_DIR"
elif [[ -n "$CONFIRM" && ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  # User typed a path directly instead of y/n
  VAULT_DIR="${CONFIRM/#\~/$HOME}"
  [[ -d "$VAULT_DIR" ]] || die "Directory not found: $VAULT_DIR"
fi

# ── Create vault directories ──────────────────────────────────────────────
echo ""
info "Creating vault structure..."

for dir in "00-Inbox" "01-Projects" "02-Areas" "03-Resources" "04-Archive" "05-People" "06-Meetings" "07-Daily" "MOC" "Templates" "Meta"; do
  mkdir -p "$VAULT_DIR/$dir"
done
mkdir -p "$VAULT_DIR/Meta/health-reports"
mkdir -p "$VAULT_DIR/Meta/agent-message-archive"
success "Created vault directory structure"

# ── Create .opencode directory in vault ─────────────────────────────────────
echo ""
info "Copying agent definitions..."
mkdir -p "$VAULT_DIR/.opencode/agents"

AGENT_COUNT=0
for agent in "$REPO_DIR/.opencode/agents/"*.md; do
  if [[ -f "$agent" ]]; then
    cp "$agent" "$VAULT_DIR/.opencode/agents/"
    AGENT_COUNT=$((AGENT_COUNT + 1))
  fi
done
success "Copied $AGENT_COUNT agent definitions"

# ── Copy AGENTS.md ─────────────────────────────────────────────────────────
echo ""
info "Copying AGENTS.md..."
cp "$REPO_DIR/AGENTS.md" "$VAULT_DIR/"
[[ -f "$REPO_DIR/.opencode/ON_START.md" ]] && cp "$REPO_DIR/.opencode/ON_START.md" "$VAULT_DIR/.opencode/"
[[ -f "$REPO_DIR/.opencode/ON_CLOSE.md" ]] && cp "$REPO_DIR/.opencode/ON_CLOSE.md" "$VAULT_DIR/.opencode/"
success "Copied AGENTS.md, ON_START.md, and ON_CLOSE.md"

# ── Copy references ────────────────────────────────────────────────────────
echo ""
info "Copying references..."
mkdir -p "$VAULT_DIR/.opencode/references"
cp "$REPO_DIR/.opencode/references/"*.md "$VAULT_DIR/.opencode/references/"
success "Copied references"

# ── Copy scripts ───────────────────────────────────────────────────────────
echo ""
info "Copying scripts..."
mkdir -p "$VAULT_DIR/scripts"
for script in "$REPO_DIR/scripts/"*; do
  if [[ -f "$script" ]]; then
    cp "$script" "$VAULT_DIR/scripts/"
  fi
done
success "Copied scripts"

# ── Create initial Meta files ──────────────────────────────────────────────
echo ""
info "Creating initial Meta files..."

# Store install location for update script
echo "$VAULT_DIR" > "$REPO_DIR/.mbifc-vault-path"

if [[ -f "$REPO_DIR/Meta/vault-structure.json" && ! -f "$VAULT_DIR/Meta/vault-structure.json" ]]; then
  cp "$REPO_DIR/Meta/vault-structure.json" "$VAULT_DIR/Meta/vault-structure.json"
  success "Copied Meta/vault-structure.json"
fi

if [[ -f "$REPO_DIR/Meta/tag-taxonomy.json" && ! -f "$VAULT_DIR/Meta/tag-taxonomy.json" ]]; then
  cp "$REPO_DIR/Meta/tag-taxonomy.json" "$VAULT_DIR/Meta/tag-taxonomy.json"
  success "Copied Meta/tag-taxonomy.json"
fi

if [[ ! -d "$VAULT_DIR/Meta/queues" ]]; then
  echo '{"timestamp": "2026-03-25T08:00:00Z", "from": "system", "to": "architect", "status": "resolved", "intent": "initialize_bus", "payload": {"status": "online"}, "resolution": "JSONL bus initialized successfully."}' > "$VAULT_DIR/Meta/agent-messages.jsonl"
  success "Created Meta/queues/ directories"
fi

if [[ ! -f "$VAULT_DIR/Meta/agent-log.md" ]]; then
  cat > "$VAULT_DIR/Meta/agent-log.md" << 'EOF'
# Agent Log

Chronological log of automated changes made by crew agents.

## Setup
- Installed OpenCode Crew
- Created vault structure
- Initialized Meta files
EOF
  success "Created Meta/agent-log.md"
fi

# ── Security notice ────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}════════════════════════════════════════${NC}"
echo -e "${BOLD}SECURITY NOTICE${NC}"
echo -e "${BOLD}════════════════════════════════════════${NC}"
echo ""
echo -e "All agents are ${BOLD}RESTRICTED${NC} to the vault root directory."
echo -e "They cannot:"
echo -e "  • Access files outside your vault"
echo -e "  • Execute system commands outside vault context"
echo -e "  • Access environment variables or secrets"
echo ""
echo -e "To verify file integrity after updates, run:"
echo -e "  ${BOLD}bash scripts/verify-integrity.sh${NC}"
echo ""

# ── Done ────────────────────────────────────────────────────────────────────
echo -e "${GREEN}${BOLD}   Setup complete!${NC}"
echo ""
echo -e "   Your vault is ready:"
echo ""
echo -e "   ${VAULT_DIR}/"
echo -e "   ├── .opencode/"
echo -e "   │   ├── agents/          ${DIM}← ${AGENT_COUNT} agent definitions${NC}"
echo -e "   │   └── references/      ${DIM}← shared documentation${NC}"
echo -e "   ├── AGENTS.md            ${DIM}← dispatcher instructions${NC}"
echo -e "   ├── Meta/                 ${DIM}← logs, messages, config${NC}"
echo -e "   ├── scripts/              ${DIM}← utility scripts${NC}"
echo -e "   └── [vault folders]      ${DIM}← 00-Inbox, 01-Projects, etc.${NC}"
echo ""
echo -e "   ${BOLD}Next steps:${NC}"
echo -e "   1. cd into your vault: ${BOLD}cd \"${VAULT_DIR}\"${NC}"
echo -e "   2. Start OpenCode: ${BOLD}opencode${NC}"
echo -e "   3. Say: ${BOLD}\"Initialize my vault\"${NC}"
echo -e "   4. The Architect agent will guide you through setup"
echo ""
echo -e "   ${DIM}To update after pulling changes: bash scripts/update-opencode.sh${NC}"
echo ""