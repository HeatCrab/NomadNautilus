---
name: gemini-research
description: Delegate web search or current-docs lookup to Gemini CLI. Returns factual results with source URLs.
---

Run a Gemini CLI research query non-interactively.

## When to use

Invoked by Claude when web search, current documentation, or anything past Claude's knowledge cutoff is needed. Can also be triggered manually with `/gemini-research`.

## Command

```bash
gemini -p "<specific factual question>. Return what you found with source URLs. Do not infer or synthesize beyond search results." -o text
```

## Rules

- Queries must be **specific and factual** — not open-ended.
- Gemini must return source URLs. If output contains no sources, re-query with a stricter prompt, or fall back to built-in WebSearch.
- Gemini is a Google Search interface, not an answer synthesizer. Treat it as retrieval, not reasoning.

## Fallback behavior

- If Gemini output shows repeated `MODEL_CAPACITY_EXHAUSTED` (429) errors and the final response is clearly from a fallback model (e.g., Flash instead of Pro), **discard that response** — it is low quality and unreliable.
- In that case, fall back to Claude's own built-in WebSearch + WebFetch tools to perform the same query directly.
- Do not present Flash-fallback results to the user as if they came from Gemini Pro.
