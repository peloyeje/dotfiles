---
name: writing-docs
description: House writing style for every artifact a person reads: documentation, README, docstrings, code comments, commit messages, PR descriptions, reports, chat answers. Use before drafting or editing any prose or comment, not after.
---

# Writing

Write so a reader with the domain knowledge but none of the context understands on first pass.

Favour conciseness, and never buy it with a rarer word. A short sentence made of common words beats a
compact one made of niche vocabulary. Spell the steps out in order instead of compressing them, and
match the content to the reader (ISO 24495-1 plain language): complete and findable for someone with
adequate domain knowledge, nothing they have to hunt for.

## Sentences

- Use subject, verb, object. Active voice.
- One claim per sentence. One claim per bullet.
- State the cause, then the effect. "The writer holds the lock, so the second job waits" beats "the
  second job waits due to lock semantics".
- Prefer the short common word. "Use", not "leverage". "Because", not "owing to the fact that".
- Name the actor. "`load()` builds the schema", not "the schema is built".

## Simple does not mean vague

Plain wording and full technical detail go together. When you simplify, every one of these survives:

- Numbers, with their units and their scale. "1,432 rows skipped", not "a lot of rows".
- Identifiers exactly as they appear in the code: class, method, option, table, file, line.
- Version and environment facts that decide whether a claim holds.

If shortening a passage would drop one of these, restructure the passage instead. Cutting fluff is
free. Cutting facts is not.

## Structure

- Lead with the answer or the result. Put the reasoning after it.
- Use bullets when there are three or more parallel facts.
- A list of field/value pairs is a table, not bullets. Put the dimension in the header.
- Use sentence case for headings.
- Bold a label only when it lets the eye find a section. Do not bold for emphasis inside a sentence.
- Pros and cons as bullet lists, never paragraphs.

## Evidence

- Separate what you measured from what you inferred. Say "measured" or "reproduced" when you ran it.
  Say "expected" or "untested" when you did not.
- Give the evidence and stop. Do not add a closing sentence that relabels the evidence as a verdict.
- Report failures with their output. A failed command, a red test, a skipped step: state it plainly.
- A check that errored is not a check that passed. When a verification returns nothing, decide whether
  it proved absence or simply broke, and say which.
- Quantify before generalising. Two small samples do not establish a fleet-wide claim; say what the
  samples were.

## Corrections

- When new evidence contradicts something you said, correct it in one plain sentence and continue.
  "Correction: X, not Y" then move on.
- Do not apologise, do not re-derive how the error happened, do not tally past errors.
- Correct only what changes the reader's decisions.

## Avoid

- Em dashes. Use commas, parentheses, or a full stop.
- "It is not X, it is Y." State Y.
- Existential openings. Write "the repo contains no test", not "there is no test".
- Marketing adverbs: surgically, strategically, seamlessly, robustly.
- Metaphors and borrowed jargon: fan out, adopt, load-bearing, blast radius, discriminator, churn.
- Narrating your own process when the result is what matters.
- Restating the same fact in a summary line right after stating it.

## Documentation pages

- Pick one Diataxis shape per page: tutorial, how-to, reference, explanation.
- Keep each section within its own scope. Do not reference solution-space details (target primitives,
  chosen tooling) in a section describing current state.
- Lead with the file or object the reader edits. "`<config file>` declares every X", not "the vendor
  calls these Y".
- One action per step. Drop the justification when the action is obvious: "Delete the entry and
  apply."
- Cut design rationale. Keep the constraint and the exact error string.
- State the fix, not the consequence avoided. "Override it with `<field>`", not a paragraph on what
  breaks otherwise.
- Put the mechanism in parentheses and the effect in the main clause. "The apply never deletes a file
  (recursive delete is off)".
- Trim examples to the lines under discussion. Mark the rest with `...`.
- One risk per admonition (`!!! warning`, `!!! note`), one or two sentences of body.
- A section earns its place only if it changes what the reader does.

## Comments and docstrings in code

- Explain why, and explain the constraint. The code already says what.
- Docstrings explain intent and the non-obvious why. Never paraphrase the signature.
- Keep them environment agnostic so the file stays upstreamable. No real table names, hostnames,
  account ids, or team names. Describe the shape or the condition instead.
- Name the constraint rather than the vendor. "Engines that reject a nested null" travels, a product
  name does not.
- Describe the current state only. No history, no "previously", no "changed to", no "this used to".
  Git history holds that.
- Treat a stale comment as a bug. When behaviour changes, the comment describing it changes in the
  same edit.
- Link the issue or the ticket for anything external. One link beats a paragraph of retelling.
