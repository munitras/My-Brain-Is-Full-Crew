#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: Upstream Merge Safety Check
# =============================================================================
# Run this BEFORE merging changes from upstream (fork-from/main).
# Checks for potentially malicious changes in agent files.
# =============================================================================

set -eo pipefail

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

info()    { echo -e "   ${CYAN}>${NC} $*"; }
success() { echo -e "   ${GREEN}✓${NC} $*"; }
warn()    { echo -e "   ${YELLOW}!${NC} $*"; }
die()     { echo -e "\n   ${RED}Error: $*${NC}\n" >&2; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

# ── Banner ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}══════════════════════════════════════${NC}"
echo -e "${BOLD}  Upstream Merge Safety Check         ${NC}"
echo -e "${BOLD}══════════════════════════════════════${NC}"
echo ""

# ── Fetch upstream ──────────────────────────────────────────────────────────
if ! git remote | grep -q "^fork-from$"; then
  die "Remote 'fork-from' not configured. Run: git remote add fork-from https://github.com/gnekt/My-Brain-Is-Full-Crew.git"
fi

info "Fetching upstream changes..."
git fetch fork-from --quiet 2>/dev/null || true

# ── Check for new commits ───────────────────────────────────────────────────
UPSTREAM_HASH=$(git rev-parse fork-from/main 2>/dev/null)
LOCAL_HASH=$(git rev-parse upstream 2>/dev/null)

if [[ "$UPSTREAM_HASH" == "$LOCAL_HASH" ]]; then
  success "No new upstream commits"
  exit 0
fi

echo ""
info "New upstream commits detected"
echo -e "   Local:  ${LOCAL_HASH:0:8}"
echo -e "   Upstream: ${UPSTREAM_HASH:0:8}"
echo ""

# ── Review changes ───────────────────────────────────────────────────────────
echo -e "${BOLD}Changes to review:${NC}"
echo ""

git log upstream..fork-from/main --oneline

echo ""
echo -e "${BOLD}Files changed:${NC}"
git diff upstream..fork-from/main --stat | head -30

# ── Security patterns to check ───────────────────────────────────────────────
echo ""
echo -e "${BOLD}Security scan:${NC}"
echo ""

WARNINGS=0

# Check for suspicious patterns in changed files
CHANGED_FILES=$(git diff upstream..fork-from/main --name-only)

for file in $CHANGED_FILES; do
  # Skip non-existent files (deleted)
  [[ -f "$file" ]] || continue
  
  # Check for network patterns in agent/reference files
  if [[ "$file" =~ \.opencode/|AGENTS\.md|references/ ]]; then
    SUSPICIOUS=$(git diff upstream..fork-from/main -- "$file" | grep -E '^\+.*\b(curl|wget|http://|https://|eval|exec|system\(|subprocess|socket|fetch\(|axios|request\()\b' || true)
    if [[ -n "$SUSPICIOUS" ]]; then
      echo -e "   ${RED}⚠ $file${NC}"
      echo "$SUSPICIOUS" | head -5 | sed 's/^/     /'
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done

# Check for executable script changes
EXEC_CHANGES=$(git diff upstream..fork-from/main --name-only | grep -E 'scripts/.*\.sh$' || true)
if [[ -n "$EXEC_CHANGES" ]]; then
  echo -e "   ${YELLOW}! Script changes detected:${NC}"
  while IFS= read -r script; do
    echo "     $script"
  done <<< "$EXEC_CHANGES"
  WARNINGS=$((WARNINGS + 1))
fi

echo ""
# ── Report ──────────────────────────────────────────────────────────────────
if [[ $WARNINGS -gt 0 ]]; then
  echo -e "${YELLOW}${BOLD}   ⚠️  $WARNINGS warning(s) found${NC}"
  echo ""
  echo -e "   ${DIM}Review the changes above before merging.${NC}"
  echo -e "   ${DIM}If you trust the upstream, run:${NC}"
  echo ""
  echo -e "   ${BOLD}git checkout upstream${NC}"
  echo -e "   ${BOLD}git merge fork-from/main${NC}"
  echo -e "   ${BOLD}git checkout main${NC}"
  echo -e "   ${BOLD}git merge upstream${NC}"
  echo -e "   ${BOLD}bash scripts/generate-manifest.sh${NC}"
  echo ""
  exit 1
fi

success "No suspicious patterns detected"
echo ""
echo -e "   ${DIM}To merge upstream changes:${NC}"
echo ""
echo -e "   ${BOLD}git checkout upstream${NC}"
echo -e "   ${BOLD}git merge fork-from/main${NC}"
echo -e "   ${BOLD}git checkout main${NC}"
echo -e "   ${BOLD}git merge upstream${NC}"
echo -e "   ${BOLD}bash scripts/generate-manifest.sh${NC}"
echo ""