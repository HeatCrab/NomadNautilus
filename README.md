# NomadNautilus

Portable dev kit. Clone it on any machine and feel at home.

**Platform:** macOS · Linux

## Modules

| Module | Description |
|--------|-------------|
| [`agent/`](agent/) | Multi-agent Claude Code workflow — Codex (review) |

## Prerequisites

Install these once per machine before running any module's `install.sh`.

### Claude Code

[claude.ai/code](https://claude.ai/code)

### RTK — token-optimized CLI proxy

```bash
# macOS
brew install rtk

# Linux
cargo install rtk
```

> RTK rewrites common CLI commands (git, npm, etc.) to strip noise before it reaches Claude's context. 60–90% token savings on dev operations.  
> Repo: [rtk-ai/rtk](https://github.com/rtk-ai/rtk)

### Codex CLI

```bash
npm install -g @openai/codex
```

Then store your API key with:

```bash
echo "sk-proj-..." | codex login --with-api-key
```

Get a key at [platform.openai.com/api-keys](https://platform.openai.com/api-keys). Storing via `codex login` keeps the key out of your shell profile.

## Setup

```bash
git clone https://github.com/HeatCrab/NomadNautilus.git
cd NomadNautilus
./install.sh
```

Checks prerequisites, then sets up all modules. Each module also has its own `setup.sh` if you want to run them individually.
