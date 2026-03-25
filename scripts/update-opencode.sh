#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: OpenCode Updater
# =============================================================================
# After pulling new changes from the repo, run this to update the agents
# in your vault:
#
#   cd /path/to/your-vault/My-Brain-Is-Full-Crew
#   git pull
#   bash scripts/update-opencode.sh
#
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

# ── Determine vault directory ─────────────────────────────────────────────
# Priority: 1) Stored path from install, 2) Parent directory (legacy assumption)
VAULT_DIR=""
if [[ -f "$REPO_DIR/.mbifc-vault-path" ]]; then
  VAULT_DIR=$(tr -d '\n' < "$REPO_DIR/.mbifc-vault-path")
  if [[ ! -d "$VAULT_DIR" ]]; then
    warn "Stored vault path no longer exists: $VAULT_DIR"
    VAULT_DIR=""
  fi
fi

if [[ -z "$VAULT_DIR" ]]; then
  # Legacy: assume repo is a subdirectory inside the vault
  VAULT_DIR="$(cd "$REPO_DIR/.." && pwd)"
fi

[[ -d "$REPO_DIR/.opencode" ]] || die "Can't find .opencode/ — are you running this from the repo?"

# ── Integrity check ──────────────────────────────────────────────────────────
if [[ -f "$REPO_DIR/Meta/agent-manifest.json" ]] && command -v sha256sum >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  echo ""
  info "Verifying file integrity..."
  
  MANIFEST="$REPO_DIR/Meta/agent-manifest.json"
  VERIFIED=0
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
    else
      VERIFIED=$((VERIFIED + 1))
    fi
  done
  
  if [[ $FAILED -gt 0 ]]; then
    echo ""
    echo -e "${RED}${BOLD}   ⚠️  $FAILED file(s) failed integrity check!${NC}"
    echo -e "${RED}   This may indicate tampering or corruption.${NC}"
    echo -e "${RED}   Do NOT proceed with this update.${NC}"
    echo ""
    read -r -p "   Continue anyway? [y/N] " FORCE
    if [[ ! "$FORCE" =~ ^[Yy]$ ]]; then
      exit 1
    fi
    warn "Proceeding with failed integrity check"
  else
    success "Integrity check passed ($VERIFIED files)"
  fi
fi

# ── Banner ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  My Brain Is Full — OpenCode Update       ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

# ── Check vault has been set up ─────────────────────────────────────────────
if [[ ! -d "$VAULT_DIR/.opencode/agents" ]]; then
  echo ""
  echo -e "   ${YELLOW}Can't find installed agents in:${NC}"
  echo -e "   ${DIM}$VAULT_DIR${NC}"
  echo ""
  echo -e "   ${BOLD}Enter the path to your Obsidian vault:${NC}"
  read -r -p "   > " INPUT_VAULT
  INPUT_VAULT="${INPUT_VAULT/#\~/$HOME}"
  if [[ -d "$INPUT_VAULT/.opencode/agents" ]]; then
    VAULT_DIR="$INPUT_VAULT"
    # Save for future updates
    echo "$VAULT_DIR" > "$REPO_DIR/.mbifc-vault-path"
    success "Vault path updated"
  else
    die "No .opencode/agents/ found in $INPUT_VAULT — run install-opencode.sh first"
  fi
fi

# ── Update agents ───────────────────────────────────────────────────────────
info "Ensuring vault structure..."
for dir in "00-Inbox" "01-Projects" "02-Areas" "03-Resources" "04-Archive" "05-People" "06-Meetings" "07-Daily" "MOC" "Templates" "Meta"; do
  mkdir -p "$VAULT_DIR/$dir"
done
mkdir -p "$VAULT_DIR/Meta/health-reports"
mkdir -p "$VAULT_DIR/Meta/agent-message-archive"

AGENT_COUNT=0
for agent in "$REPO_DIR/.opencode/agents/"*.md; do
  if [[ -f "$agent" ]]; then
    name="$(basename "$agent")"
    if [[ -f "$VAULT_DIR/.opencode/agents/$name" ]]; then
      if ! diff -q "$agent" "$VAULT_DIR/.opencode/agents/$name" >/dev/null 2>&1; then
        cp "$agent" "$VAULT_DIR/.opencode/agents/"
        info "Updated $name"
        AGENT_COUNT=$((AGENT_COUNT + 1))
      fi
    else
      cp "$agent" "$VAULT_DIR/.opencode/agents/"
      info "Added $name (new agent)"
      AGENT_COUNT=$((AGENT_COUNT + 1))
    fi
  fi
done

# ── Update references ───────────────────────────────────────────────────────
REF_COUNT=0
mkdir -p "$VAULT_DIR/.opencode/references"
for ref in "$REPO_DIR/.opencode/references/"*.md; do
  if [[ -f "$ref" ]]; then
    name="$(basename "$ref")"
    if ! diff -q "$ref" "$VAULT_DIR/.opencode/references/$name" >/dev/null 2>&1; then
      cp "$ref" "$VAULT_DIR/.opencode/references/"
      info "Updated reference: $name"
      REF_COUNT=$((REF_COUNT + 1))
    fi
  fi
done

# ── Update AGENTS.md ────────────────────────────────────────────────────────
AGENTS_MD_UPDATED=""
if [[ -f "$REPO_DIR/AGENTS.md" ]]; then
  if [[ ! -f "$VAULT_DIR/AGENTS.md" ]] || ! diff -q "$REPO_DIR/AGENTS.md" "$VAULT_DIR/AGENTS.md" >/dev/null 2>&1; then
    cp "$REPO_DIR/AGENTS.md" "$VAULT_DIR/AGENTS.md"
    info "Updated AGENTS.md"
    AGENTS_MD_UPDATED="1"
  fi
fi

# ── Update ON_START.md ────────────────────────────────────────────────────────
ON_START_UPDATED=""
if [[ -f "$REPO_DIR/.opencode/ON_START.md" ]]; then
  if [[ ! -f "$VAULT_DIR/.opencode/ON_START.md" ]] || ! diff -q "$REPO_DIR/.opencode/ON_START.md" "$VAULT_DIR/.opencode/ON_START.md" >/dev/null 2>&1; then
    cp "$REPO_DIR/.opencode/ON_START.md" "$VAULT_DIR/.opencode/"
    info "Updated ON_START.md"
    ON_START_UPDATED="1"
  fi
fi

# ── Update scripts ────────────────────────────────────────────────────────────
SCRIPTS_UPDATED=""
mkdir -p "$VAULT_DIR/scripts"
for script in "$REPO_DIR/scripts/"*.sh; do
  if [[ -f "$script" ]]; then
    name="$(basename "$script")"
    if [[ ! -f "$VAULT_DIR/scripts/$name" ]] || ! diff -q "$script" "$VAULT_DIR/scripts/$name" >/dev/null 2>&1; then
      cp "$script" "$VAULT_DIR/scripts/"
      info "Updated script: $name"
      SCRIPTS_UPDATED="1"
    fi
  fi
done

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
if [[ $AGENT_COUNT -eq 0 && $REF_COUNT -eq 0 && -z "$AGENTS_MD_UPDATED" && -z "$ON_START_UPDATED" && -z "$SCRIPTS_UPDATED" ]]; then
  success "Everything is already up to date!"
else
  success "Updated $AGENT_COUNT agent(s), $REF_COUNT reference(s)"
fi
echo ""
echo -e "   ${DIM}Restart OpenCode to pick up the changes.${NC}"
echo ""