---
name: writing-docs
description: "House writing style for every artifact a person reads: documentation, README, docstrings, code comments, commit messages, PR descriptions, reports, chat answers. Uses plain language and ADHD-friendly structure. Use before drafting or editing any prose or comment, not after."
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

## Commit messages and PR descriptions

- Write in an action-oriented voice: lead with what the change does to the system, then the reason it
  was needed, then what it supersedes or breaks.
- Describe the resulting state when it carries a design choice the reviewer should notice. Skip it when
  it only restates the diff.
- Keep the reader's next step in it: what to apply first, what to re-run, what fails differently now.
- The subject line stays imperative and conventional, `<type>(<scope>): <subject>`.

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

## ADHD-friendly output

Adapted from [i-have-adhd](https://github.com/ayghri/i-have-adhd/blob/main/skills/i-have-adhd/SKILL.md), licensed under MIT.

Shape the output so a reader with ADHD can act on it. Brief output alone is not enough.

### Why the structure matters

1. Working memory is small. Keep required context on screen instead of asking the reader to remember it.
2. Knowing the answer does not complete the task. Reduce the friction between understanding and action.
3. Starting is the hardest step. Make the first action small, clear, and immediately possible.
4. Vague time estimates feel alike. Use specific units.
5. Visible progress provides motivation. Do not bury completed work.

### Lead with the next action

Put the first useful action on the first line. Do not start with context or a plan. If the answer is a
command, path, or snippet, put it first. Add only the prose needed to use it.

Bad: "Let's think about this. Your auth flow has a few moving pieces."

Good: "Run `npm install jsonwebtoken`, then edit `src/auth.ts:42`."

### Number multi-step tasks

Use a numbered list when the work takes more than one step. Each step contains one bounded action. Do
not put several actions into one step. Use the fewest steps that work, and fold trivial steps into the
step before them.

Bad: "Open the file, find the function, replace it, then run the tests."

Good:

```text
1. Open `src/auth.ts`.
2. Replace `verifyToken` on lines 42 to 58 with the snippet below.
3. Run `npm test -- auth.spec.ts`.
```

### End with one next action

If work remains, end with one action that the reader can complete in under two minutes.

Bad: "Hope that helps. Let me know if you want to dig deeper."

Good: "Next: run `npm test` and paste the first failing line."

### Suppress tangents

Finish the current issue before raising another. Offer a separate issue as one question after the first
is complete. Answer questions that arise during the work when the available evidence supports an
answer. Ask the reader only when their input is required.

Bad: "Here is the fix. Your dependency is also stale, and your README is out of date."

Good: "Here is the fix. Separately, one dependency is stale. Should I update it next?"

### Restate state across turns

The reader may not retain the previous step between messages. State the completed step and the next
step. If the harness has a task or plan tool, use it for multi-step work with one item per step and one
item in progress. The checklist carries the state, so do not repeat the full plan in prose.

Bad: "Done. Ready for the next part?"

Good: "Step 3 of 5 done: schema updated. Next: backfill the new column."

### Use specific time estimates

Use concrete units and state what changes the estimate.

Bad: "This will take some work."

Good: "About 15 minutes if tests already cover this. An afternoon if they do not."

### Make completed work visible

State what now works and give a concrete way to verify it.

Bad: "I made some changes to the auth flow."

Good: "Login now accepts magic links. Run `npm run dev`, then open `/login`."

### Report errors directly

State the failure, cause, and fix without emotional framing.

Bad: "Oh no, the test is failing. There seems to be an issue."

Good: "`auth.spec.ts:42` expected 200 and received 401. The request lacks an auth header. Add
`Authorization: Bearer ${token}`."

### Keep lists short

Cap a list at five items. Split longer lists into ranked groups such as "Do now" and "Later", or
"Must" and "Nice to have".

### Remove preambles, recaps, and pleasantries

Do not open with "Great question", "Let me", "I'll", "Sure", "Looking at your", or "To answer your
question". Do not close with a recap, "Let me know if you need anything else", "Hope this helps",
"Happy to clarify", or "Feel free to ask". Start with the answer and stop when it is complete.

### Exceptions

Override these defaults when:

1. The reader asks for an explanation or walkthrough. Explain as fully as needed and add headings for
   navigation, but keep the direct opening and ending.
2. The next action is destructive, such as `rm -rf`, a force push, a schema migration, or dropping a
   table. Confirm before acting.
3. The last three attempts produced the same failure. Stop changing code, name the assumption that may
   be wrong, and ask one diagnostic question.
4. The request is materially ambiguous. Ask one short clarifying question instead of guessing.
5. The rule would remove the requested answer. For options, give two to four ranked choices with a
   one-line trade-off for each, and put the recommendation first.
6. The agent harness requires another shape. Follow the harness, do the work instead of asking for
   permission, and direct time estimates at the person who will execute the steps.

### Pre-send check

Delete:

1. The first sentence if it only announces what follows.
2. The last sentence if it asks whether the reader needs more help or repeats the result.
3. Any unrelated sidebar.
4. Any hedge that adds no information. Keep hedges that express real uncertainty.
5. Any idiom or figurative phrase. Replace it with the literal action.

Check the first and last lines. Together, they should show what happened and what the reader should do
next.
