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
3. **Do not rely on training knowledge or memory of similar papers.** Same-topic
   papers are easy to mix up. If a detail is not in this paper's text, it does
   not go in the notes as fact.
4. **Do not transcribe specific numbers.** Point to the paper's table / figure
   ("see Table 3") rather than copying values — transcription is where errors
   start. When a precise value is actually needed, re-open the cited page and
   read it there.
5. **Tag every inference.** Anything not explicitly stated in the paper — an
   interpretation, an implication, a "this is good for X" judgment — is marked
   `[Inference]` and kept visually separate from paper facts.
6. **Write from the note-taker's (Claude's) point of view, not the user's.** The
   user may not have read the paper yet; do not absorb or echo their phrasing or
   framing. The notes are an independent reading, so they can serve as a check
   on the user's understanding rather than mirroring it.

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
- `gemini-research` — finding the paper / external context (separate from reading it)
