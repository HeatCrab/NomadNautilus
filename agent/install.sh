#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKER="# === Multi-Agent Workflow (auto-installed) ==="

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo "=== Claude Code Multi-Agent Workflow Installer ==="
echo ""

# 1. Check prerequisites
MISSING=()
for cmd in codex gemini; do
  command -v "$cmd" &>/dev/null || MISSING+=("$cmd")
done

if [ ${#MISSING[@]} -gt 0 ]; then
  warn "Missing CLIs: ${MISSING[*]}"
  echo "  Install with npm (no root required):"
  for cmd in "${MISSING[@]}"; do
    case "$cmd" in
      gemini) echo "    npm install -g @google/gemini-cli" ;;
      codex)  echo "    npm install -g @openai/codex" ;;
    esac
  done
  echo ""
  warn "Continuing — install missing CLIs before first use."
  echo ""
fi

# 2. Create ~/.claude directories
mkdir -p "$SKILLS_DIR/gemini-research"
mkdir -p "$SKILLS_DIR/codex-review"

# 3. Copy skill files
cp "$SCRIPT_DIR/skills/gemini-research/SKILL.md" "$SKILLS_DIR/gemini-research/SKILL.md"
cp "$SCRIPT_DIR/skills/codex-review/SKILL.md"    "$SKILLS_DIR/codex-review/SKILL.md"
info "Skills installed → $SKILLS_DIR"

# 4. Append CLAUDE.md snippet (idempotent)
if grep -qF "$MARKER" "$CLAUDE_MD" 2>/dev/null; then
  warn "CLAUDE.md snippet already present — skipping"
else
  printf '\n' >> "$CLAUDE_MD"
  cat "$SCRIPT_DIR/CLAUDE.md.snippet" >> "$CLAUDE_MD"
  info "CLAUDE.md rules appended → $CLAUDE_MD"
fi

# 5. API key instructions
echo ""
echo "=== API Keys Required ==="
echo ""
echo "Add to your ~/.bashrc or ~/.zshrc:"
echo ""
echo "  export GEMINI_API_KEY=<your key>"
echo "  → Get free key: https://aistudio.google.com/apikey"
echo ""
echo "  export OPENAI_API_KEY=<your key>"
echo "  → Get key: https://platform.openai.com/api-keys"
echo ""
echo "Then reload: source ~/.bashrc"
echo ""
info "Done. Open a new Claude Code session to activate."
