# Multi-Agent Workflow: Claude Code + Gemini CLI + Codex

> Document version: v0.3
> Config template + install.sh. Community shares results of this kind of setup but rarely publishes the implementation.

---

## Motivation

1. **Save tokens**: Web search shouldn't burn Claude's context. Delegate to Gemini.
2. **Up-to-date knowledge**: Claude's cutoff is behind. Gemini handles current docs and real-time search.
3. **Peer-level quality check**: Codex acts as a second pair of eyes — not Claude reviewing itself.
4. **Do the right thing, not just do things right**: Code quality means solving the correct problem with sound design, not just passing tests.

---

## Architecture

```
User ↔ Claude Code (orchestrator + executor)
              │                         │
     [~/.claude/CLAUDE.md]      [PreToolUse hook]
     [~/.claude/skills/]               │
              │                   git commit*
         Gemini CLI            codex exec (review)
       (research/search)
```

**Claude Code** — only agent that reads/writes files, runs commands, manages git, talks to user, makes final decisions.

**Gemini CLI** — subagent dispatched for research and web search. Claude delegates; Gemini retrieves and reports back.

**Codex CLI** — subagent dispatched for code and plan review. Returns design-level feedback, not just syntax checks.

Claude acts on their output — Gemini's research and Codex's review feed back into Claude's decisions.

---

## Role Definitions

### Gemini CLI — Research Subagent
- **When**: Claude needs current docs, web search, or anything past its knowledge cutoff
- **Strategy**: CLAUDE.md strongly prefers Gemini for all research. Built-in WebSearch remains as emergency fallback only.
- **Saves**: Claude's context window + tokens (Gemini handles heavy retrieval independently)
- **Hallucination mitigation**: Gemini is used as a Google Search interface, not an answer synthesizer.
  - Queries must be specific, not open-ended
  - Gemini must return source URLs — answers without sources are treated as unverified
  - Claude is instructed in CLAUDE.md: if Gemini output has no sources, re-query with stricter prompt or fallback

### Codex CLI — Review Subagent
- **When**: before `git commit` (automatic), before executing a plan, or any mid-session review (on-demand)
- **Review scope**: "Do the right thing, rather than do things right"
  - Is this solving the correct problem?
  - Are design assumptions sound?
  - Are there better architectural approaches?
  - Are there security vulnerabilities? (injection, auth issues, exposed secrets, OWASP basics)
  - Not just: does the code work / is it clean
- **Returns**: review comments — Claude decides what to adopt

---

## Integration Strategy

### Layer 1: Global CLAUDE.md (`~/.claude/CLAUDE.md`)

Single source of truth for workflow rules. Applies to all projects automatically.

Contents:
- **Gemini preference rule**: "For web search, current documentation, or any information that may be outdated, strongly prefer Gemini CLI over built-in search. Use built-in search only if Gemini CLI is unavailable."
- **Codex awareness**: Claude knows Codex review runs before commit (via hook) and should incorporate that feedback before proceeding.
- **Review philosophy**: "When Codex flags issues, evaluate whether the direction is correct, not just whether the implementation is clean."

### Layer 2: Global Skills (`~/.claude/skills/`)

**`gemini-research`** — How to call Gemini non-interactively:
```bash
gemini -p "<specific factual question>. Return what you found with source URLs. Do not infer or synthesize beyond search results." --output-format text
```
- WHEN is defined in CLAUDE.md
- HOW is defined in this skill
- Queries must be specific and factual — not open-ended
- Invocable manually as `/gemini-research`

**`codex-review`** — On-demand Codex review:
```bash
codex exec "<content or file>" --ephemeral
```
- Use before executing a plan: `/codex-review` → pipe plan.md
- Use mid-session when Claude judges a review is warranted
- Invocable manually as `/codex-review`

> Note: SKILL.md supports `!<command>` syntax for direct shell execution before Claude sees the content.

### Layer 3: CLAUDE.md commit rule

**Confirmed broken: PreToolUse hook approach**

Tested `block` + `additionalContext` and `block` + `reason` — neither injects content into Claude's context. Hook API does not support content injection when blocking. Claude auto-retries on block, token already exists → allow. Commit goes through without user ever seeing the review.

**Correct approach: CLAUDE.md behavioral rule**

Add to `~/.claude/CLAUDE.md`:

> Before any `git commit`, run `/codex-review` on staged changes, present the review to the user, and wait for explicit approval before proceeding.

Flow:
1. Claude is about to run `git commit`
2. CLAUDE.md rule fires → Claude runs `/codex-review` first
3. Review is already in Claude's context — no injection needed
4. Claude presents review to user, waits for explicit approval
5. User approves → Claude commits

Hook (`codex-review.sh`, `settings.json` entry) can be removed.

---

## Trigger Rules

| Trigger | Agent | Mechanism |
|---------|-------|-----------|
| Web search / current docs needed | Gemini | CLAUDE.md preference → Skill |
| `git commit` | Codex | CLAUDE.md rule → `/codex-review` skill (before commit) |
| Before executing a plan | Codex | Skill `/codex-review` (manual or CLAUDE.md instruction) |
| Other mid-session review | Codex | Skill `/codex-review` (manual) |
| Per-project custom triggers | Either | Per-project CLAUDE.md overrides |

**CI/CD and test hooks dropped from scope.** Local workflow means commit hook covers this.

---

## Open Source Deliverable

**Format: Hybrid** — config template + optional `install.sh`

- README explains the design rationale (the "why" most community posts skip)
- Config files are the core artifact — users can copy manually or run install.sh
- install.sh automates: check CLIs installed, copy skills, append to CLAUDE.md, set up hook

Target audience: people who've seen multi-agent Claude Code setups shared on 小紅書/Twitter and want to know exactly how it's done.

### Repo structure

```
/
├── README.md
├── CLAUDE.md.snippet          # Append to ~/.claude/CLAUDE.md
├── skills/
│   ├── gemini-research/
│   │   └── SKILL.md
│   └── codex-review/
│       └── SKILL.md
├── hooks/
│   └── codex-review.sh
├── settings.json.snippet      # Hook config to add to ~/.claude/settings.json
└── install.sh
```

**MCP: excluded.** Hooks and skills are the native integration points for this use case.

---

## Open Questions

All previous open questions resolved. Remaining items are Phase 0 validations (require CLI installed):

| Item | What to validate |
|------|-----------------|
| Gemini CLI output format | ✅ `--output-format text` works. Supports `text`, `json`, `stream-json`. `-o` is shorthand. |
| Gemini hallucination prompt | ✅ "Return source URLs, do not synthesize" returns Google grounding URLs. Works. |
| Codex review prompt | ✅ `codex exec --ephemeral` returns design-level feedback, not lint. ~10k tokens/review (~$0.02). |
| `additionalContext` / `reason` in hook | ❌ Both fields confirmed non-functional with `permissionDecision: "block"`. Hook fires and Codex runs, but content never reaches Claude. Claude auto-retries → token exists → allow. Commit passes silently. Hook approach abandoned. |

---

## Development Roadmap

### Phase 0 — Install and validate
- [x] Install Gemini CLI (v0.36.0), test non-interactive mode
- [x] Install Codex CLI (v0.118.0), test `codex exec --ephemeral` with a real diff
- [x] Validate hook `additionalContext` — hook fires correctly, context injected silently (by design, no visible marker)
- [x] Validate Gemini output format usability

### Phase 1 — MVP (local, single project)
- [x] Write `~/.claude/CLAUDE.md` Gemini preference rule
- [x] Write `gemini-research` SKILL.md
- [x] Write `codex-review.sh` with "do the right thing" prompt
- [x] Write `codex-review` SKILL.md
- [x] Configure `Bash(git commit*)` PreToolUse hook
- [x] Redesign: replace hook with CLAUDE.md commit rule, re-validate end-to-end

### Phase 2 — Open source packaging
- [ ] Write `install.sh`
- [ ] Write README with design rationale
- [ ] Template all config files
- [ ] Test on a fresh machine

### Phase 3 — Release
- [ ] GitHub repo setup
- [ ] Post to community (Reddit, Twitter/X, 小紅書)
