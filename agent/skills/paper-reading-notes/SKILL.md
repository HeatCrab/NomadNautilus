---
name: paper-reading-notes
description: Rules for recording reading notes on a paper (PDF / source) that will ground later discussion, review, or presentation prep. The paper is the single source of truth; notes are an index into it, not a replacement. Invoke when creating or updating notes on a specific paper, and when answering questions about a paper whose notes exist.
---

How to take notes on a paper so the notes stay trustworthy. The failure mode this
guards against: answering from the model's training-knowledge of similar papers
instead of from what THIS paper actually says. In dense subfields (e.g.
multi-objective pruning, evolutionary search, quantization) papers look alike and
their details conflate easily — a specific operator, equation, or number gets
misattributed from a neighbour paper. These rules keep the notes anchored.

## When to use

- Creating a notes file for a paper that will be discussed / presented / reviewed
- Updating an existing paper-notes file
- Answering a question about a paper whose notes already exist (anchor on the
  notes + the source, not on prior knowledge)

Not for: quick one-off lookups where no durable note is kept, or summarizing the
user's own draft (that is the user's wording, not a third-party paper).

## Core rules

1. **The source is ground truth; the notes are an index, never a replacement.**
   The PDF / source file is authoritative. Notes exist to point back into it
   quickly, not to stand in for it.
2. **Record only what the paper states**, and tag each fact with a pointer —
   section number, equation number, table / figure number. Every line should be
   traceable back to a page.
3. **Do not rely on training knowledge, on memory of similar papers, or on an
   existing summary of this one.** Same-topic papers are easy to mix up. If a
   detail is not in this paper's text, it does not go in the notes as fact.
   Where a summary of the same paper already exists — project memory, a
   colleague's digest, an earlier review — do not read it first: read the
   source, write the notes, then compare. An existing summary is the strongest
   available anchor, and reading it first yields a paraphrase of that summary
   instead of an independent reading. The comparison afterwards is itself a
   check.
4. **Do not transcribe specific numbers.** Point to the paper's table / figure
   ("see Table 3") rather than copying values — transcription is where errors
   start. When a precise value is actually needed, re-open the cited page and
   read it there. The line runs between measured results and design constants.
   Results — benchmark scores, speedups, ablation deltas — stay as pointers. A
   constant that is part of what the method *is*, such as a fixed group count or
   a stage count, can be recorded directly, because it identifies the method
   rather than reporting an outcome.
5. **Tag every inference.** Anything not explicitly stated in the paper — an
   interpretation, an implication, a "this is good for X" judgment — is marked
   `[Inference]` and kept visually separate from paper facts.
6. **Write from the note-taker's (Claude's) point of view, not the user's.** The
   user may not have read the paper yet; do not absorb or echo their phrasing or
   framing. That independence is what makes the notes usable in two ways: as the
   shared objective ground a later discussion starts from, and as the reference
   to check against when reviewing the user's own write-up of the same paper.
7. **Keep the file neutral.** Do not signal importance — no marking a finding as
   significant, promising, or relevant to the reader's work. Highlighting is
   itself an interpretation, and it frames the discussion before the discussion
   happens; what matters surfaces from the reader's own questions. Likewise,
   when the independent reading contradicts something the user or the project
   record already concluded, the notes stay neutral and the divergence is raised
   in conversation. A file that argues a position stops being a base.

## During later Q&A

- Anchor answers on the notes plus the source. When a question turns on a precise
  detail (exact number, exact equation form, which variant of an algorithm),
  re-open the cited page and read it — do not answer from the note's paraphrase
  or from recollection of the field.
- State the grounding when it matters: distinguish "the paper says X (§N)" from
  "[Inference] this implies Y."

## File conventions

- One notes file per paper. Frontmatter `name`, `description`, `type` (reference).
- Open with a **grounding-policy line** restating that the PDF is ground truth and
  the notes are an index, plus the absolute path to the source PDF.
- All note content in English (even when chat / drafting is zh-TW).
- Cross-link related notes and the project that owns the paper.
- When a paper is dropped / superseded, mark its notes file **void** rather than
  deleting silently, so stale facts are not mistaken for current.

## See also

- `report-writing` — prose / typography rules for the writeup the notes feed into
- Finding the paper or its external context is a separate activity from reading
  it — use the built-in WebSearch for that, not these rules.
