# NomadNautilus

Portable dev kit. Clone it on any machine and feel at home.

**Platform:** macOS · Linux

---

## Modules

| Module | Description |
|--------|-------------|
| [`agent/`](agent/) | Multi-agent Claude Code workflow — Gemini (research) + Codex (review) |

---

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

### Gemini CLI

```bash
npm install -g @google/gemini-cli
```

Set `GEMINI_API_KEY` in your shell profile. Free tier available at [aistudio.google.com/apikey](https://aistudio.google.com/apikey).

### Codex CLI

```bash
npm install -g @openai/codex
```

Set `OPENAI_API_KEY` in your shell profile. [platform.openai.com/api-keys](https://platform.openai.com/api-keys)

---

## Setup

```bash
git clone https://github.com/HeatCrab/NomadNautilus.git
cd NomadNautilus
./install.sh
```

Checks prerequisites, then sets up all modules. Each module also has its own `setup.sh` if you want to run them individually.
