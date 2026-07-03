#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[✓]${NC} $1"; }
fail() { echo -e "${RED}[✗]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
MISSING=0

check() {
  local cmd="$1" hint="$2"
  if command -v "$cmd" &>/dev/null; then
    info "$cmd"
  else
    fail "$cmd — not found"
    echo "       $hint"
    MISSING=1
  fi
}

echo "=== NomadNautilus ==="
echo ""
echo "Checking prerequisites..."
echo ""

if [ "$OS" = "Darwin" ]; then
  check rtk    "brew install rtk"
else
  check rtk    "cargo install rtk   (need cargo? → curl -fsSL https://sh.rustup.rs | sh)"
fi

check npm    "https://nodejs.org  or  nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash"
check codex  "npm install -g @openai/codex"

echo ""

if [ "$MISSING" -eq 1 ]; then
  echo "Install the missing prerequisites above, then re-run."
  exit 1
fi

info "All prerequisites satisfied."
echo ""
echo "Installing modules..."
echo ""

bash "$SCRIPT_DIR/agent/setup.sh"

echo ""
info "Done."
