#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: Project Context Generator
# =============================================================================
# Aggregates all human-readable project content into a single dated file
# for automated review or long-context LLM analysis.
# =============================================================================

set -eo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'; CYAN='\033[0;36m'
  RED='\033[0;31m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
else
  GREEN=''; CYAN=''; RED=''; BOLD=''; DIM=''; NC=''
fi

info()    { echo -e "   ${CYAN}>${NC} $*"; }
success() { echo -e "   ${GREEN}✓${NC} $*"; }
die()     { echo -e "\n   ${RED}Error: $*${NC}\n" >&2; exit 1; }

# ── Find paths ──────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATE=$(date +"%Y-%m-%d")
OUTPUT_FILE="${REPO_DIR}/project-context-${DATE}.txt"

# ── Files to include ────────────────────────────────────────────────────────
# We want AGENTS.md, all .opencode/*.md, docs/*.md, and root level *.md
FILES=()

# 1. Main dispatcher
[[ -f "${REPO_DIR}/AGENTS.md" ]] && FILES+=("AGENTS.md")

# 2. Agent definitions
while IFS= read -r -d '' f; do
  FILES+=("${f#"$REPO_DIR"/}")
done < <(find "${REPO_DIR}/.opencode/agents" -name "*.md" -print0 2>/dev/null)

# 3. Reference documents
while IFS= read -r -d '' f; do
  FILES+=("${f#"$REPO_DIR"/}")
done < <(find "${REPO_DIR}/.opencode/references" -name "*.md" -print0 2>/dev/null)

# 4. Documentation
while IFS= read -r -d '' f; do
  FILES+=("${f#"$REPO_DIR"/}")
done < <(find "${REPO_DIR}/docs" -name "*.md" -print0 2>/dev/null)

# 5. Root level MD files (excluding ones we might have already added or temporary ones)
while IFS= read -r -d '' f; do
  fname=$(basename "$f")
  # Filter out some files we might not want or are duplicates
  if [[ "$fname" != "AGENTS.md" && "$fname" != "tasks-bugs.md" && "$fname" != ".junie-analysis"* ]]; then
      FILES+=("${f#"$REPO_DIR"/}")
  fi
done < <(find "${REPO_DIR}" -maxdepth 1 -name "*.md" -print0)

# ── Generate Context ────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Project Context Generator               ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

info "Generating project context for ${#FILES[@]} files..."
info "Target: ${OUTPUT_FILE}"

{
  echo "============================================================================="
  echo " PROJECT CONTEXT: My Brain Is Full - Crew (OpenCode Edition)"
  echo " DATE: $(date)"
  echo " TOTAL FILES: ${#FILES[@]}"
  echo "============================================================================="
  echo ""

  for relpath in "${FILES[@]}"; do
    echo "-----------------------------------------------------------------------------"
    echo " FILE: ${relpath}"
    echo "-----------------------------------------------------------------------------"
    cat "${REPO_DIR}/${relpath}"
    echo ""
    echo ""
  done
} > "${OUTPUT_FILE}"

success "Context file generated successfully!"
echo -e "   ${DIM}Size: $(du -h "${OUTPUT_FILE}" | cut -f1)${NC}"
echo ""
