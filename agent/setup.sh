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

# 3. Install helper scripts
mkdir -p "$CLAUDE_DIR/scripts"
cp "$SCRIPT_DIR/scripts/commit-msg-fmt.sh" "$CLAUDE_DIR/scripts/"
chmod +x "$CLAUDE_DIR/scripts/commit-msg-fmt.sh"
info "Helper scripts installed → $CLAUDE_DIR/scripts"

# 4. Install hooks and register them in settings.json (idempotent)
mkdir -p "$CLAUDE_DIR/hooks"
cp "$SCRIPT_DIR/hooks/memory-tidy-reminder.py" "$CLAUDE_DIR/hooks/"
chmod +x "$CLAUDE_DIR/hooks/memory-tidy-reminder.py"
python3 - "$CLAUDE_DIR/settings.json" \
  "$CLAUDE_DIR/hooks/memory-tidy-reminder.py" <<'EOF'
import json, os, shlex, sys

path, cmd = sys.argv[1], shlex.quote(sys.argv[2])
data = {}
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)
entries = data.setdefault("hooks", {}).setdefault("SessionStart", [])
# Drop registrations left by older kit versions (renamed or unquoted
# variants of the same hook) so reruns converge instead of piling up.
# Filter at hook level so hooks grouped in the same entry survive.
for e in entries:
    e["hooks"] = [h for h in e.get("hooks", [])
                  if "memory-tidy-reminder" not in h.get("command", "")]
entries[:] = [e for e in entries if e.get("hooks")]
entries.append(
    {"hooks": [{"type": "command", "command": cmd, "timeout": 10}]})
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
EOF
info "Hooks installed and registered → $CLAUDE_DIR/hooks"

# 5. Append CLAUDE.md snippet (idempotent)
if grep -qF "$MARKER" "$CLAUDE_MD" 2>/dev/null; then
  warn "CLAUDE.md snippet already present — skipping"
else
  printf '\n' >> "$CLAUDE_MD"
  cat "$SCRIPT_DIR/CLAUDE.md.snippet" >> "$CLAUDE_MD"
  info "CLAUDE.md rules appended → $CLAUDE_MD"
fi

# 6. Auth and API key instructions
echo ""
echo "=== Auth Required ==="
echo ""
echo "Codex — store via codex login (keeps key out of shell profile):"
echo "  echo \"sk-proj-...\" | codex login --with-api-key"
echo "  → Get key: https://platform.openai.com/api-keys"
echo ""
info "Done. Open a new Claude Code session to activate."
