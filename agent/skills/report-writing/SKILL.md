---
name: report-writing
description: Writing rules for human-read documents. Universal tier for ANY prose document — punctuation discipline (comma/period only; 頓號 or bullets for enumerations; full-width marks in zh-TW). Full tier for reports/notes — reflective first-person process narrative, zh-TW drafting default, typography (code / italic / math), Results vs Observations layout. Invoke before writing or editing any prose document except memory and CLAUDE.md-type instruction files.
---

Style rules for human-read prose. Apply from the first draft so the user does not have to correct each issue manually.

## Two tiers

**Universal — every human-read document** (README, resume, docs, anything that is not a Claude-self-use file):

- Punctuation: comma (，/,) and period (。/.) are the only default marks. Enumerations may use 頓號 (、, zh-TW) or a bullet list. Colons, semicolons, dashes, parentheses — only where a full-tier rule below explicitly allows them.
- zh-TW prose uses full-width punctuation throughout.
- Target language: when not obvious from the document itself, ask the user before drafting.

**Full tier — reports and notes**, where process and reflection are the point. All sections below apply on top of the universal tier.

## When to use the full tier

- Drafting a new report or note (course assignment, design note, study notes)
- Editing or restructuring an existing draft
- Doing a typography / punctuation pass
- Preparing a draft for codex review
- Translating a zh-TW draft to English for submission

Not for: short index / memo files, source-code comments (always English, separate rule), tool-output relays.

## Deliverable type drives formality

Ask (or infer) up front whether the report is a personal note, a course submission, or destined for LaTeX / PDF. The register and typography rules below all hold, but figure formality scales with the target:

- **Self-use note**: figures stay inline with the narrative — English alt text, and the surrounding paragraph acts as the de-facto caption. No figure numbers, no `Figure N` caption lines.
- **Submission / LaTeX conversion**: numbered `Figure N` captions, caption labels, and renumber-on-relocation apply.

When the target is unclear, ask before adding or stripping figure numbering.

## Language

- **Default to Traditional Chinese (zh-TW)** for any long-form prose the user will read and adjust. The user finds it much easier to review and edit prose in Chinese, even when the final published form is English.
- Switch to English only when the user explicitly says so at the start of the task (e.g. "write in English", "PLAN in English").
- **Translation is faithful, not a rewrite.** Translate the agreed zh-TW one-to-one; preserve meaning, sentence order, and voice. Do not over-polish into generic fluent English, do not restructure paragraphs, do not touch layout (tables, figures, headings, code blocks, citation markers stay placed as is). The English version is a render of the Chinese, not an improved version.
- **Codex review happens on the zh-TW version, before translation.** Order: zh-TW draft → user reviews → codex review on zh-TW → translate → translation frozen → pandoc → PDF → submit. Reviewing after translation would force re-translating every adjustment.
- **Post-freeze content fixes go directly into the English version.** If a factual error surfaces after translation, edit the English text in place — do not re-translate, and accept that the zh-TW draft goes stale from that point.

## Voice

- **Reflective first-person is the default register.** "I expected X, then I found Y, so I decided Z." The report's value (vs the demo) is the process and reflection — partly a reflective essay, not a pure technical write-up.
- Switch to academic third-person / passive only for displaying facts: addresses, register layouts, polarity, hardware behaviour.
- **Decision narratives are welcome, not noise.** When a non-obvious choice was made (which dataset source, why this metric, why this threshold), write the short story of arriving at it — the option first reached for, why it fell short, what was chosen instead. A paragraph tracing "tried the obvious source, hit a gating / credibility problem, found a better-grounded alternative" is exactly the reflective value the report carries over a demo. Do not compress these into a single declarative result sentence.
- **Preserve the hand-written feel.** Intentional prose imperfections — sparing em-dashes, slightly awkward phrasings, clause-joining punctuation choices, first-person reflective asides — are voice markers, not errors. Flag a style issue at most once; never re-push after the user says "leave it."

## Structure

- **Paragraph prose is the default.** Narrative flow, not point form.
- **Bullets only for real enumerations** — parallel items that stand alone (operator / parameter lists, baseline lists, metric lists). Process narratives ("first ..., then ..., finally ...") stay as prose.
- **Bullets are situational, not owed to any section.** A spec section that flows naturally as prose stays prose (the Setup of a report can list model / resolution / token math entirely in sentences). Only when a spec section actually contains a clean enumeration is the **bullet sandwich** the right pattern: short prose opening (context) → bullet middle (operator / hyperparam spec) → prose closing (mechanism, rationale). Aim for roughly 0–15 % of report length in bullets total; beyond that the document becomes a slide deck.
- **"Less than N pages" is a hard upper bound, not a target.** Aim tight and well within. Padding to hit N looks bad; undershooting by more than ~30 % looks unfinished.
- **Results vs Observations split** when the report uses a Methods / Results / Observations (or Results / Discussion) structure. Do not dump all figures and tables at the end of Results.
  - Results keeps the hard numbers (metric / reference tables, each right after the sentence that announces it).
  - Observations holds the figures, each beside the paragraph that interprets it. Figures are analytical; they belong with the discussion.
  - De-duplicate prose between the two: Results states raw facts; Observations interprets without re-citing the same raw counts. Keep only load-bearing numbers (ones that appear *only* in Observations) in the discussion.
  - Renumber figures so figure-number = reading order after relocation (submission / LaTeX targets only — see Deliverable type). Grep in-text figure references first to confirm low risk.

## Typography

### Code snippets
- **Verbatim** from source. Mark omissions with `# omitted` or `...`. Never silently drop fields, substitute literal values for constant names, or merge functions.
- Lead each snippet with a file-path comment: `# lib/fitness.py` or `# run_part2.py: main()`.
- When tempted to "simplify" for readability, either pick a smaller scope (just the relevant function) or use `# omitted` for the parts you don't want to show.

### Three formatting roles — don't substitute
- **Backticks** (`` ` ``, monospace) for code identifiers verifiable against the repo:
  - Function / class names (`make_cv_fitness`, `KMeans`, `LogisticRegression`)
  - Variable / dict key names (`best_pos`)
  - Parameter assignments (`pop = 50`, `n_clusters = 2`)
  - Literal values (`0xFFFF`, `'lbfgs'`)
  - Protocol / fixed-phrase keywords (`train = test`, `train = test resubstitution`)
  - Verbatim label strings drawn from a dataset — values that appear unchanged in code, filenames, or metadata (class labels like `biking through snow`, `golf driving`). Decision: would this exact string appear in a file path or a config? Then backtick, even though the dataset *name* itself is italic.
- **Italic** (`*…*`) for:
  - Feature / attribute names treated as field references (`*Age*`, `*Polyuria*`)
  - Dataset / corpus names, paper titles, section refs (`*Kinetics-400*`, `*Part I*`, `*Part II*`, `*Part I/II*`)
  - Domain-specific terms on first introduction
  - Instance names that need to stand out from prose (`*ARMv8_0*`, `*UART_2*`, `*nIRQ_0*`)
- **LaTeX math** (`$…$` / `$$…$$`) for:
  - Math variables (`$w$`, `$k$`), Greek letters (`$\lambda$`, `$\alpha$`)
  - Math expressions (`$[0, 1]^{16}$`, `$c_1 = c_2 = 2$`, `$-\infty$`, `$2^{16}$`)
  - Math symbols (`$\approx$`, `$\to$`, `$\pm$`)
  - `$$…$$` for major formula definitions; inline `$…$` for embedded math

**Decision test (code vs math)**: would a reader paste this into a Python REPL? Code (backtick). Would they typeset it in a paper formula? Math. `n_clusters = 2` is code (sklearn parameter name). `c_1 = c_2 = 2` is math (subscripted variables in a formula). `k = 3` is math (single-letter variable in tournament-selection literature).

Pandoc + xelatex renders `` ` `` to `\texttt{}` and `$…$` to math mode cleanly; no need to second-guess the LaTeX form when writing markdown.

### Pragmatic exceptions
- `±` in stat tables stays Unicode — too pervasive to convert to `$\pm$`; pandoc renders Unicode fine.
- `×` in dimensions (`520 × 17`) stays Unicode for the same reason.
- Image alt text (`![alt](path)`) stays plain — markdown renderers (and pandoc) do not process markdown formatting inside alt text. Italicize in the caption underneath, not in the alt.

## Punctuation (full-tier refinements)

These refine the universal punctuation rule for reports, where a few extra marks earn their place.

### Overall budget — the unifying principle

Comma (，/,) and period (。/.) are the default marks. Every other mark — colon, em-dash, semicolon, 頓號 (、), parentheses — is a special-purpose tool, not default punctuation. Across a whole document these non-default marks combined should stay a small minority, roughly **under 15 % of all punctuation**. This is simply how a student outside a literature / creative-writing discipline writes; reaching for these marks by default reads as affected. Every per-mark rule below is one instance of this single budget — when in doubt, recast with a comma or period.

### No colon-subtitle pattern
Headings: never `Title: explanation`. Use a real heading line or run as prose.

### Prose elaboration colon
**Test: keep the colon only when its right side is a *list of things*, and even then it is optional; remove it when its right side is a *sentence*.** Applies in both English and zh-TW drafts. A list, table, figure, or display equation reads fine after a full sentence ending in a period — the "…如下。" + new-line pattern is the preferred default. Reach for a lead-in colon only when the sentence genuinely feels unfinished without it.

- **Keep** (the few genuinely-needed cases): figure / table caption labels ("Table 3.1:", "Figure 3.1:") and bullet-item labels ("**Majority-class baseline**: always predicts Positive ..."). A lead-in to a list / equation / code block / table *may* keep the colon ("fitness is defined as:") but does not need it — prefer the period form above unless the colon clearly reads better.
- **Remove** → period (split into two sentences) or comma (let the clause flow): complete claim or noun where the right side is more prose. "The gap is reasonable: this assignment uses ..." → "The gap is reasonable. This assignment uses ..." A claim-then-evidence colon almost always wants a period. Noun-definition colons ("Protocol: the full ...") are not automatically safe either — a comma usually works.

### Em-dashes (—)
Sparingly (part of the under-15 % budget). Default to periods and commas. Em-dash is fine for occasional inline pauses or titles, not as default punctuation.

### Semicolons (；in zh-TW, ; in English)
Almost never in flowing exposition — the single most over-reached mark for students, and a prime target of the budget. Legitimate only when separating parallel list items that themselves contain internal commas. Two independent clauses joined by a semicolon should become two sentences. Parallel structures ("GA ..., ...; PSO ..., ...") handle just as well with a period.

### Enumeration comma 頓號 (、) — zh-TW only
For words / short phrases, not clauses, and still inside the budget — do not sprinkle 、 just because a sentence lists several nouns; a few well-placed ones are enough. Use 、 between parallel nouns (e.g. listing categorical values, metric pairs). When 、 sits between two full clauses it should be a comma (，). **Caveat:** the user uses 、 as a voice marker; convert only genuine clause-joins, and only on an explicit punctuation pass — never as unsolicited smoothing.

### Brackets / parentheses — three categories
Discern with two questions: "does the main clause stand without the bracket?" and "is the bracket carrying essential spec content?"

- **Keep**: main clause complete; bracket adds factual breakdown or short clarification. Example: "520 rows × 17 columns (16 attributes + 1 class label)" — the breakdown is supplementary, not essential.
- **Promote to prose**: bracket smuggles essential spec into an aside. Example: "uniform crossover (each bit independently swapped with probability 0.5)" → "Crossover uses uniform form, with each bit independently swapped at probability 0.5" (or convert to a bullet). The operator name alone is meaningless without the per-bit probability.
- **Remove**: redundant with nearby prose, trivially obvious, or a forward-reference the doc structure already provides. Examples: "(see next section)", "(increases variation)" when the next sentence elaborates.

Do a single bracket pass before submission: list every parenthetical, mark keep / promote / remove, execute.

## Codex review scope

When sending a report draft to codex review:

- Scope STRICTLY to: (1) factual errors checked against the actual results / code, (2) typos, (3) spec-coverage gaps.
- **Forbid** prose / tone / style / wording / flow commentary in the prompt.
- Filter codex output before relaying — drop any style / fluency findings, surface only factual / typo / spec.
- Let codex explore the repo autonomously (read report + code + result JSON itself, read the spec PDF via pdftotext) rather than spoon-feeding hand-picked files.
- Confirm scope with the user before running.

## See also

- `codex-review` — design review for code (separate from report review)
