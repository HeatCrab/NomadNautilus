---
name: antigravity-review
description: Trigger a design review by Antigravity (Gemini) through the agy CLI. Use when the user asks for an Antigravity, agy or Gemini review or a second opinion besides Codex, and on hard commits as the Code Review rules in CLAUDE.md define them. It never replaces /codex-review.
---

Run an Antigravity review. Tested with agy 1.5.14.

## When to use

- The user asks for it, by name or through `/antigravity-review`.
- A commit that needs `/codex-review` and is also hard, as the Code Review section of CLAUDE.md defines it. Run it in addition to Codex, and leave Codex's findings out of the prompt so the two stay independent.
- Not otherwise. When unsure whether a commit is hard, do not run it.

## How to run

Use the helper. It collects the diff itself, so rtk does not condense it, and it fails loudly when agy returns nothing. Set the Bash timeout to 600000.

Uncommitted changes (staged, unstaged, and the names of untracked files):

```bash
python3 ~/.claude/scripts/agy-review.py -C "$ROOT" --diff "Context: <what changed and why>. Focus on <what matters>."
```

Against a base branch, or one commit:

```bash
python3 ~/.claude/scripts/agy-review.py -C "$ROOT" --base main "Context: ..."
python3 ~/.claude/scripts/agy-review.py -C "$ROOT" --commit <SHA> "Context: ..."
```

A plan or arbitrary files, read by agy from the directory given with `-C`:

```bash
python3 ~/.claude/scripts/agy-review.py -C <dir> "Read plan.md and review it. Focus on: (1) Is this solving the right problem? (2) Design-level issues? (3) Better architectural approaches?"
```

The helper runs `gemini-4-hydrogen-high` by default. `-m <model>` overrides it and `agy models` lists the options; the list also holds Claude and GPT models, so stay on a Gemini one when the point is a different vendor's view. An unknown model fails the run.

## What to know

- agy runs with `--mode plan --sandbox`. Reads inside `-C` work. Plan mode is an instruction to the model, not a hard limit. What refuses shell commands (`git diff` included) and file writes is that they need an approval headless mode cannot ask for, so never add allow rules to `~/.gemini/antigravity-cli/settings.json` for this.
- Plan mode may answer with a pointer to an `implementation_plan.md` under `~/.gemini/antigravity-cli/brain/` instead of a review. Read that file, or rerun with a prompt that clearly asks for a review.
- A refused tool call ends the whole run with exit 0, status SUCCESS and an empty response. The helper turns that into exit 1 and prints agy's stderr. Never report an empty review as "no findings".
- Exit 2 means the review came back but the working tree changed meanwhile. Tell the user and check `git status` before anything else. The check covers git repositories only and does not see ignored files.
- The diff forms always cover the whole repository, even when `-C` names a subdirectory.
- A file outside `-C` cannot be read. Choose `-C` to cover what the review needs, or put the text in the prompt.
- An authentication error means the sign-in expired. Ask the user to run `agy` once interactively.
- Never add `--dangerously-skip-permissions`. Never add `--disable-slash-commands`, it silently turns plan mode off.
- The helper prints agy's stderr. A warning that plan mode has no effect means the run was not protected, tell the user.
- Runs also load `~/.gemini/config/AGENTS.md` and `~/.gemini/config/hooks.json`.

## Rules

- Returns design-level feedback, not lint, not style.
- Claude decides what feedback to adopt. All output is advisory. Present the findings to the user.
- Always give the relevant context (requirements, constraints) in the prompt.
