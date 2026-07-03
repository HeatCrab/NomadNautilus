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
if ! command -v codex &>/dev/null; then
  warn "Missing CLI: codex"
  echo "  Install with the official standalone installer (no root required):"
  echo "    curl -fsSL https://chatgpt.com/codex/install.sh | sh"
  echo ""
  warn "Continuing — install codex before first use."
  echo ""
fi

# 2. Install all skills (discover every SKILL.md under skills/)
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$SKILLS_DIR/$skill_name"
  cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$skill_name/SKILL.md"
done
info "Skills installed → $SKILLS_DIR"

# 4. Append CLAUDE.md snippet (idempotent)
if grep -qF "$MARKER" "$CLAUDE_MD" 2>/dev/null; then
  warn "CLAUDE.md snippet already present — skipping"
else
  printf '\n' >> "$CLAUDE_MD"
  cat "$SCRIPT_DIR/CLAUDE.md.snippet" >> "$CLAUDE_MD"
  info "CLAUDE.md rules appended → $CLAUDE_MD"
fi

# 5. Auth and API key instructions
echo ""
echo "=== Auth Required ==="
echo ""
echo "Codex — store via codex login (keeps key out of shell profile):"
echo "  echo \"sk-proj-...\" | codex login --with-api-key"
echo "  → Get key: https://platform.openai.com/api-keys"
echo ""
info "Done. Open a new Claude Code session to activate."
