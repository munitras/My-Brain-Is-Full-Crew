#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: Integrity Verification
# =============================================================================
# Verifies that agent and reference files have not been tampered with.
# Run this:
#   - After cloning
#   - After pulling updates
#   - Before installing updates
#   - If you suspect tampering
#
# Exit codes:
#   0 = All files verified
#   1 = Manifest missing or invalid
#   2 = File hash mismatch (POTENTIAL TAMPERING)
#   3 = File missing
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$REPO_DIR/Meta/agent-manifest.json"

# ── Banner ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}════════════════════════════════════════${NC}"
echo -e "${BOLD}  My Brain Is Full - Integrity Check  ${NC}"
echo -e "${BOLD}════════════════════════════════════════${NC}"
echo ""

# ── Check for manifest ──────────────────────────────────────────────────────
if [[ ! -f "$MANIFEST" ]]; then
  warn "No manifest found at Meta/agent-manifest.json"
  info "Run: bash scripts/generate-manifest.sh"
  exit 1
fi

# ── Check jq availability ────────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
  die "jq is required but not installed. Install with: apt install jq OR brew install jq"
fi

# ── Verify files ────────────────────────────────────────────────────────────
VERIFIED=0
FAILED=0
MISSING=0

# Get list of files from manifest
FILES=$(jq -r '.files | keys[]' "$MANIFEST" 2>/dev/null || true)

if [[ -z "$FILES" ]]; then
  die "Manifest is invalid or empty"
fi

echo -e "Verifying file integrity...\n"

for relpath in $FILES; do
  filepath="$REPO_DIR/$relpath"
  
  if [[ ! -f "$filepath" ]]; then
    echo -e "   ${RED}✗ MISSING: $relpath${NC}"
    MISSING=$((MISSING + 1))
    continue
  fi
  
  expected_hash=$(jq -r ".files[\"$relpath\"]" "$MANIFEST")
  actual_hash=$(sha256sum "$filepath" | cut -d' ' -f1)
  
  if [[ "$expected_hash" != "$actual_hash" ]]; then
    echo -e "   ${RED}✗ MISMATCH: $relpath${NC}"
    echo -e "     Expected: $expected_hash"
    echo -e "     Actual:   $actual_hash"
    FAILED=$((FAILED + 1))
  else
    echo -e "   ${GREEN}✓${NC} $relpath"
    VERIFIED=$((VERIFIED + 1))
  fi
done

echo ""

# ── Report ──────────────────────────────────────────────────────────────────
TOTAL=$((VERIFIED + FAILED + MISSING))

if [[ $FAILED -gt 0 ]]; then
  echo -e "${RED}${BOLD}   ⚠️  SECURITY ALERT: $FAILED file(s) failed integrity check!${NC}"
  echo ""
  echo -e "   ${RED}This may indicate:${NC}"
  echo -e "   ${RED}  - Malicious modification${NC}"
  echo -e "   ${RED}  - Corrupted download${NC}"
  echo -e "   ${RED}  - Upstream changes not in manifest${NC}"
  echo ""
  echo -e "   ${BOLD}Do NOT proceed with installation until verified.${NC}"
  exit 2
fi

if [[ $MISSING -gt 0 ]]; then
  echo -e "${YELLOW}${BOLD}   $MISSING file(s) missing${NC}"
  echo -e "   ${DIM}Run: bash scripts/generate-manifest.sh to update manifest${NC}"
  exit 3
fi

  if [[ $VERIFIED -eq $TOTAL && $TOTAL -gt 0 ]]; then
  success "All $VERIFIED files verified"
  exit 0
fi

die "Unexpected state: verified=$VERIFIED, failed=$FAILED, missing=$MISSING"