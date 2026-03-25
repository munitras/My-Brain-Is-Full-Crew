#!/usr/bin/env bash
# =============================================================================
# My Brain Is Full - Crew :: Manifest Generator
# =============================================================================
# Generates Meta/agent-manifest.json with SHA256 hashes of all agent and
# reference files. Run after any changes to these files.
# =============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_DIR="$REPO_DIR/Meta"
MANIFEST="$MANIFEST_DIR/agent-manifest.json"

# Colors
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'
  CYAN='\033[0;36m'
  DIM='\033[2m'
  NC='\033[0m'
else
  GREEN=''
  CYAN=''
  DIM=''
  NC=''
fi

info()    { printf "   ${CYAN}>${NC} %s\n" "$*"; }
success() { printf "   ${GREEN}✓${NC} %s\n" "$*"; }

# Check jq
if ! command -v jq >/dev/null 2>&1; then
  printf "   Error: jq is required\n" >&2
  exit 1
fi

# Ensure Meta directory exists
mkdir -p "$MANIFEST_DIR"

# Collect files
FILES=()

# OpenCode agents
for f in "$REPO_DIR/.opencode/agents/"*.md; do
  [[ -f "$f" ]] && FILES+=("${f#$REPO_DIR/}")
done

# OpenCode references
for f in "$REPO_DIR/.opencode/references/"*.md; do
  [[ -f "$f" ]] && FILES+=("${f#$REPO_DIR/}")
done

# AGENTS.md
[[ -f "$REPO_DIR/AGENTS.md" ]] && FILES+=("AGENTS.md")

# New: include utility scripts in manifest
[[ -f "$REPO_DIR/scripts/validate-paths.sh" ]] && FILES+=("scripts/validate-paths.sh")
[[ -f "$REPO_DIR/scripts/generate-context.sh" ]] && FILES+=("scripts/generate-context.sh")

if [[ ${#FILES[@]} -eq 0 ]]; then
  printf "   Error: No agent files found\n" >&2
  exit 1
fi

# Generate manifest
info "Generating manifest for ${#FILES[@]} files..."

{
  printf '{\n'
  printf '  "version": "1.0.0",\n'
  printf '  "generated": "%s",\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  printf '  "files": {\n'
  
  for i in "${!FILES[@]}"; do
    relpath="${FILES[$i]}"
    filepath="$REPO_DIR/$relpath"
    hash=$(sha256sum "$filepath" | cut -d' ' -f1)
    
    if [[ $i -lt $((${#FILES[@]} - 1)) ]]; then
      printf '    "%s": "%s",\n' "$relpath" "$hash"
    else
      printf '    "%s": "%s"\n' "$relpath" "$hash"
    fi
  done
  
  printf '  }\n'
  printf '}\n'
} > "$MANIFEST"

# Print success messages AFTER writing manifest
for relpath in "${FILES[@]}"; do
  success "$relpath"
done

# Summary
printf "\n"
success "Manifest generated: Meta/agent-manifest.json"
printf "   ${DIM}Run this after any changes to agent or reference files${NC}\n"
printf "   ${DIM}Verify with: bash scripts/verify-integrity.sh${NC}\n"