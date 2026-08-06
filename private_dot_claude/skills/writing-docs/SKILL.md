---
name: writing-docs
description: Guide for writing documentation (docstrings, READMEs, design docs). Use when writing or editing documentation, docstrings, or markdown docs.
---

# Writing docs

Follow the Diataxis framework (tutorial, how-to, reference, explanation — pick the right one for the content).

- Docstrings explain intent and non-obvious "why", never paraphrase the signature
- Short sentences and bullet points over prose, so the doc stays scannable
- Pros/cons as bullet lists, never paragraphs
- Keep each section within its own scope: don't reference solution-space details (target primitives, chosen tooling) in a section describing current state
- Every sentence adds information; cut sentences that only restate the previous one
