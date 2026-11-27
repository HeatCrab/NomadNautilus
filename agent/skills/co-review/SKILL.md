---
name: co-review
description: >-
  Run a two-stage cross-vendor agent co-review (primary reviewer loop, then
  independent final reviewer right before commit or test runs). Use whenever
  code logic, plans, or acceptance scripts need design review, or when invoked
  with /co-review.
---

# Cross-Vendor Agent Co-Review

Run design-level review across three independent model families (OpenAI/Codex,
Gemini, Claude) using a two-stage sequential gate. Never review with the same
model family as the lead agent.

## When to use

- Before executing a significant plan or hard-to-reverse change
- Before running formal tests, benchmarks, or acceptance suites
- Before committing changes that add or modify code logic
- Mid-session when the lead judges a design review is warranted
- Invoked manually with `/co-review`

Skip for prose, documentation, pure deletions or reverts, mechanical syncs,
and minor config tweaks.

## Two-stage sequential flow

Do **not** run both reviewers in parallel.

1. **Stage 1 — Primary reviewer (iteration loop)**:
   - Send the work to the primary reviewer (Round 1 cold read) and iterate
     until the primary reviewer approves.
   - Do not call the final reviewer while Stage 1 is still iterating.
2. **Stage 2 — Final reviewer (pre-commit / pre-test gate)**:
   - Only right before committing or launching formal tests/acceptance, call
     the final reviewer **independently**. Never include the primary
     reviewer's findings or transcript in the final reviewer's prompt.
   - If the final reviewer approves, the review is complete.
   - If the final reviewer finds issues: fix at the root cause, return to the
     **primary reviewer** (resumed) until it approves the fix, then return to
     the **final reviewer** (resumed) for final confirmation. Repeat until
     both approve.
3. **Stop-loss**: If either reviewer has not converged after 5 rounds, stop
   and present the blocking points to the user for a decision.

## Reviewer selection matrix

Pick reviewers from the lead's **active model family**, not only the host CLI:

| Lead active model family | Stage 1 (Primary) | Stage 2 (Final gate) |
| --- | --- | --- |
| **Gemini** (Antigravity running Gemini) | **Codex** (`codex exec`) | **Claude** (`claude-opus-5-5-high`) |
| **Claude** (Claude Code, or Antigravity running Claude) | **Codex** (`codex exec`) | **Gemini** (`gemini-4-neon-high`) |
| **OpenAI / GPT** (Codex CLI, or Antigravity running GPT/ChatGPT) | **Gemini** (`gemini-4-neon-high`) | **Claude** (`claude-opus-5-5-high`) |

Choose the invocation channel from the lead's host environment:

- **Codex reviewer**: always Codex CLI (`codex exec` / `codex exec resume`).
- **Gemini or Claude reviewer when the lead is Antigravity**: use the built-in
  `swarm` tool directly (this skill explicitly authorizes invoking `swarm` for
  co-review without requiring the user to type `/swarm` first). Pin the worker
  to `claude-opus-5-5-high` or `gemini-4-neon-high`. Fall back to CLI
  (`claude -p --safe-mode` or `agy-review.py`) if that model's Antigravity
  quota is exhausted or `swarm` is unavailable.
- **Gemini or Claude reviewer when the lead is Claude Code or Codex CLI**: use
  `agy-review.py` (`-m gemini-4-neon-high` or `-m claude-opus-5-5-high`). Use
  `claude -p --safe-mode` as fallback for Claude.

## Prompt and review discipline

- **Independence — no checklist**: Describe what the change is for, what
  files or diff to inspect, and hard constraints (read-only, no shell/GPU
  runs), then ask for an open review of design and correctness defects. Do not
  include a checklist of your own concerns or frame unsettled decisions as
  facts.
- **Root cause before patching**: Before editing after any review round, write
  the findings' shared root cause in one sentence and fix the root rather than
  patching findings one by one.
- **Round 1 cold, Round 2+ resume**: Run Round 1 as a fresh cold read and
  record the session or conversation ID. On Round 2+, resume that reviewer's
  own session with only the incremental changes and fixes. Once a reviewer has
  approved, do not re-run it if nothing material changed since its approval;
  if Stage 2 raises issues that require code changes, Stage 1 must re-confirm
  the fix (resumed) before returning to Stage 2 (resumed).
- **Background execution and sandbox**: Launch CLI reviewers in the background
  with `< /dev/null`, redirect output to files, and verify the job actually
  started (for `codex exec`, verify `stderr.log` is growing; `agy-review.py`
  buffers output until `agy` exits, so check task/process status rather than
  treating an empty log as a hang). In Claude Code, run CLI reviewers with
  `run_in_background` (foreground Bash caps at 10 minutes, shorter than the
  `20m` review timeout). When Codex is the lead, calling `agy-review.py` or
  `claude -p` requires an escalated command (`sandbox_permissions:
  "require_escalated"`) because Codex's default sandbox blocks network access.
- **Keep review artifacts outside the repo**: Write all review prompts,
  diffs, responses, and logs into a dedicated directory outside the reviewed
  repository (for example `REVIEW_DIR=$(mktemp -d "${TMPDIR:-/tmp}/co-review.XXXXXX")`).
  Never write review artifacts inside the repo working tree, because
  `agy-review.py --diff` lists untracked files under `Untracked files, read
  them:` and would leak Stage 1 findings to Stage 2.
- **Design over style**: Prioritize correctness and architecture over lint or
  style. Never copy defensive reviewer wording ("do not X, instead of Y") into
  revised docs. All reviewer output is advisory; present findings to the user.

## Invocation recipes

Before running any CLI reviewer, create an artifact directory outside `"$ROOT"`:

```bash
REVIEW_DIR=$(mktemp -d "${TMPDIR:-/tmp}/co-review.XXXXXX")
```

### 1. Codex CLI (`codex exec` and `resume`)

Syntax matches codex CLI >= 0.142 (tested through 0.170).

Round 1 (cold read-only review; omit `--ephemeral` so Round 2+ can resume):

```bash
codex exec -C "$ROOT" -s read-only -o "$REVIEW_DIR/review-codex-1.md" \
  "<neutral review prompt>" < /dev/null \
  > "$REVIEW_DIR/review-codex-1.stdout.log" \
  2> "$REVIEW_DIR/review-codex-1.stderr.log"
```

Record `session id:` from `"$REVIEW_DIR/review-codex-1.stderr.log"`.

Round 2+ (resume — always re-pass read-only and any model/effort overrides,
because `codex exec resume` resets CLI flags to `config.toml` defaults):

```bash
codex exec -C "$ROOT" resume <SESSION_ID> \
  -c 'sandbox_mode="read-only"' -o "$REVIEW_DIR/review-codex-2.md" \
  "<incremental changes and fixes>" < /dev/null \
  > "$REVIEW_DIR/review-codex-2.stdout.log" \
  2> "$REVIEW_DIR/review-codex-2.stderr.log"
```

Notes:
- Add `-m <model>` and `-c 'model_reasoning_effort="high"'` on both Round 1
  and `resume` if overriding `config.toml` defaults.
- Outside a git repo, add `--skip-git-repo-check`.
- Attach images/PDFs with `-i <file>` placed **after** the prompt (otherwise
  `-i` swallows the prompt as a filename).
- Sandbox fallback: if `codex exec` fails with a sandbox or `bwrap` error
  (e.g. `loopback: Failed RTM_NEWADDR`), retry with
  `--dangerously-bypass-approvals-and-sandbox`.
- For a quick single-shot uncommitted diff review without multi-round resume,
  bare `codex review "<instructions>"` also works (scope flags
  `--uncommitted`, `--base`, `--commit` cannot be combined with a prompt).

### 2. Antigravity Swarm worker (Antigravity lead only)

This skill explicitly instructs Antigravity to call `swarm` for a Stage 1 or
Stage 2 reviewer without waiting for a manual `/swarm` command.

- Check quota if needed with `swarm{action: "models", all: true}`.
- Name the swarm once (`swarm{action: "title", title: "Co-review: <topic>"}`)
  and spawn one reviewer worker pinned to the target model:
  - Claude reviewer: `name: "claude-reviewer"`, `model: "claude-opus-5-5-high"`
  - Gemini reviewer: `name: "gemini-reviewer"`, `model: "gemini-4-neon-high"`
- In the brief, state explicitly: read-only review only, do not edit files,
  run shell commands, or spawn sub-workers/reviews; inspect the named
  diff/files; and post `@coordinator [done] <findings or APPROVE>` when
  finished.
- Snapshot `git status` before and after to verify the working tree stayed
  clean (worker read-only is prompt-enforced).
- Round 2+: reuse the same waiting worker via `post_message`
  (`@claude-reviewer ...` or `@gemini-reviewer ...`) with only the
  incremental changes.
- Once approved and no further rounds are needed, terminate the worker with
  `swarm{action: "kill", name: "<worker>"}` and post `[done] <summary>` (no
  `@`) on the board.

### 3. Antigravity CLI (`agy-review.py`)

Used when Claude Code or Codex CLI calls Gemini (`-m gemini-4-neon-high`, the
default on Round 1) or Claude (`-m claude-opus-5-5-high`), or as an
Antigravity fallback. Runs with `--mode plan --sandbox` and defaults to
`--timeout 20m`. Tested with agy 1.5.14–1.5.18 (`--resume` uses
`--conversation` and reads `conversation_id` from `--output-format json`).

Round 1 (uncommitted diff, base branch, commit, or files/plan):

```bash
python3 ~/.claude/scripts/agy-review.py -C "$ROOT" -m <MODEL> --diff \
  "<neutral review prompt>" < /dev/null \
  > "$REVIEW_DIR/review-agy-1.md" \
  2> "$REVIEW_DIR/review-agy-1.stderr.log"
```

Set `<MODEL>` to `gemini-4-neon-high` for Gemini review or
`claude-opus-5-5-high` when Codex requests its Stage 2 Claude review. Other
scopes: `--base main`, `--commit <SHA>`, or omit all diff flags for a
plan/file review.

Record `conversation_id:` from `"$REVIEW_DIR/review-agy-1.stderr.log"`.

Round 2+ (resume — keep passing the same `-m <MODEL>` so the model family
stays pinned across rounds; omit `--diff` to let the resumed reviewer read
only the changed files inside `"$ROOT"`, or include `--diff` to re-send the
full refreshed diff):

```bash
python3 ~/.claude/scripts/agy-review.py -C "$ROOT" -m <MODEL> \
  --resume <CONV_ID> \
  "<summary of incremental fixes and changed files under $ROOT>" < /dev/null \
  > "$REVIEW_DIR/review-agy-2.md" \
  2> "$REVIEW_DIR/review-agy-2.stderr.log"
```

Notes:
- The diff forms (`--diff`, `--base`, `--commit`) always cover the whole
  repository, even when `-C` names a subdirectory.
- Files outside `-C` cannot be read by `agy`. Choose `-C` to cover what the
  review needs, or put the text directly in the prompt.
- Plan mode may answer with a pointer to an `implementation_plan.md` under
  `~/.gemini/antigravity-cli/brain/`; read that file or re-prompt clearly for
  a review.
- A refused tool call ends `agy` with exit 0 and an empty response; the helper
  turns that into exit 1. Never treat an empty review as "no findings".
- Exit 2 means the working tree changed during the review; stop and check
  `git status` immediately.
- Never add `--dangerously-skip-permissions` or `--disable-slash-commands`
  (the latter silently disables plan mode), and never add allow rules to
  `~/.gemini/antigravity-cli/settings.json`.
- A stderr warning that plan mode has no effect means the run was not
  protected; inform the user.
- Runs load `~/.gemini/config/AGENTS.md`, `hooks.json`, and
  `~/.gemini/config/skills/`; `agy-review.py` injects a rule forbidding nested
  reviews, swarm, or other agent calls so the reviewer does not recurse.
- If authentication fails, ask the user to run `agy` interactively once.

### 4. Claude Code CLI (fallback for Claude review)

Use when Antigravity's Claude quota is unavailable or a strictly tool-locked
read-only Claude CLI run is needed. Write any `git diff` to
`"$REVIEW_DIR/changes.diff"` first, because `--tools Read,Glob,Grep` has no
shell. Pass `--add-dir "$ROOT" "$REVIEW_DIR"` before `-p` (so `dontAsk` can
read both the repo and diff regardless of launch directory, and the variadic
`--add-dir` flag cannot swallow the prompt). Do not pass `--model` or
`--effort`; the user's settings choose them.

Round 1 (cold read, persistent session for resume):

```bash
rtk proxy claude --add-dir "$ROOT" "$REVIEW_DIR" -p --safe-mode \
  --tools Read,Glob,Grep --permission-mode dontAsk \
  --output-format json -- \
  "<neutral review prompt pointing to $REVIEW_DIR/changes.diff and files in $ROOT>" \
  < /dev/null > "$REVIEW_DIR/review-claude-1.json" \
  2> "$REVIEW_DIR/review-claude-1.stderr.log"
```

Read `result` and record `session_id` from `"$REVIEW_DIR/review-claude-1.json"`.
(For a one-shot run with no follow-up rounds, omit `--output-format json` and
add `--no-session-persistence`.)

Round 2+ (resume):

```bash
rtk proxy claude --add-dir "$ROOT" "$REVIEW_DIR" -p --resume <SESSION_ID> \
  --safe-mode --tools Read,Glob,Grep --permission-mode dontAsk -- \
  "<incremental changes and fixes>" \
  < /dev/null > "$REVIEW_DIR/review-claude-2.md" \
  2> "$REVIEW_DIR/review-claude-2.stderr.log"
```

`--safe-mode` disables `CLAUDE.md`, skills, plugins, MCP servers, and hooks so
the review is a clean cold read and project hooks do not fire.
