---
name: codex-review
description: Trigger an on-demand Codex CLI design review. Use before executing a plan or mid-session when a review is warranted.
---

Run an on-demand Codex review.

Syntax below matches codex CLI >= 0.142 (breaking changes vs 0.118: `--title` now requires `--commit`; scope flags no longer accept a custom prompt; `--full-auto` removed from `codex exec`).

## When to use

- Before executing a significant plan
- Before committing (review uncommitted changes)
- Mid-session when Claude judges a design review is warranted
- Invoked manually with `/codex-review`

## Codex CLI capabilities

- **Sandbox:** Codex runs in a read-only sandbox by default. It can read any file in the repo on its own — do NOT pipe file contents via stdin unless necessary.
- **Sandbox fallback:** If `codex exec` fails with a sandbox or bwrap error (e.g. `loopback: Failed RTM_NEWADDR`), retry the same command with `--dangerously-bypass-approvals-and-sandbox` added.
- **Images/PDFs:** Use `-i <file>` to attach images or PDFs as visual context. `-i` takes a variable number of files, so a prompt written after it is swallowed as another filename and the run dies with `No prompt provided via stdin` — put the prompt first.
- **Working directory:** Use `-C <dir>` to set the working root.
- **Non-git roots:** `codex exec` refuses to start outside a git repo. Add `--skip-git-repo-check`.
- **Model override:** Use `-m <model>` to pick a specific model.

## Review patterns

### Review uncommitted changes (pre-commit — default scope)

The bare form reviews ALL uncommitted changes: staged + unstaged + untracked. It is also the only form that accepts custom instructions:

```bash
!codex review "Context: <what changed and why>. Focus on correctness of the algorithm implementation and edge cases."
```

There is no staged-only scope. If unstaged noise would pollute the review, scope it in the instructions ("only comment on changes to X") or stash the noise first.

`codex review --uncommitted` reviews the same scope but cannot take instructions.

### Review changes against a base branch

```bash
!codex review --base main
```

### Review a specific commit

```bash
!codex review --commit <SHA> --title "short description of changes"
```

Note: scope flags (`--uncommitted`, `--base`, `--commit`) can NOT be combined with a custom prompt, and `--title` is only valid together with `--commit`.

### Review arbitrary files with context (e.g., assignment spec)

Let Codex read the files itself in its sandbox. Attach PDFs/images with `-i`, placed after the prompt:

```bash
!codex exec "Read all .py files in src/ and review against the attached spec. Focus on: (1) correctness (2) design issues (3) what to change" -i "path/to/spec.pdf" --ephemeral
```

### Review a plan file

```bash
!codex exec "Read plan.md and review it. Focus on: (1) Is this solving the right problem? (2) Design-level issues? (3) Better architectural approaches?" --ephemeral
```

## Rules

- Returns design-level feedback — not lint, not style.
- Claude decides what feedback to adopt. All Codex output is advisory.
- Always provide relevant context (assignment requirements, constraints) in the prompt so Codex can give informed feedback.
- Prefer `codex review` for git-diff-based reviews; use `codex exec --ephemeral` for broader file/plan reviews.
