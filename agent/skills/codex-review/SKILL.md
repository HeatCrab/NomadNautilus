---
name: codex-review
description: Trigger an on-demand Codex CLI design review. Use before executing a plan or mid-session when a review is warranted.
---

Run an on-demand Codex review.

## When to use

- Before executing a significant plan
- Before committing (review staged changes)
- Mid-session when Claude judges a design review is warranted
- Invoked manually with `/codex-review`

## Codex CLI capabilities

- **Sandbox:** Codex runs in a read-only sandbox by default. It can read any file in the repo on its own — do NOT pipe file contents via stdin unless necessary.
- **Sandbox fallback:** If `codex exec` fails with a sandbox or bwrap error (e.g. `loopback: Failed RTM_NEWADDR`), retry the same command with `--dangerously-bypass-approvals-and-sandbox` added.
- **Images/PDFs:** Use `-i <file>` to attach images or PDFs as visual context.
- **Working directory:** Use `-C <dir>` to set the working root.
- **Model override:** Use `-m <model>` to pick a specific model.

## Review patterns

### Review staged changes (pre-commit)

```bash
!codex review --title "short description of changes"
```

Or with custom focus:

```bash
!codex review "Focus on correctness of the algorithm implementation and edge cases"
```

### Review uncommitted changes (staged + unstaged + untracked)

```bash
!codex review --uncommitted
```

### Review changes against a base branch

```bash
!codex review --base main
```

### Review a specific commit

```bash
!codex review --commit <SHA>
```

### Review arbitrary files with context (e.g., assignment spec)

Let Codex read the files itself in its sandbox. Attach PDFs/images with `-i`:

```bash
!codex exec -i "path/to/spec.pdf" "Read all .py files in src/ and review against the attached spec. Focus on: (1) correctness (2) design issues (3) what to change" --ephemeral
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
