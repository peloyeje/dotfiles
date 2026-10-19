# Documentation pages

Apply this guide on top of `SKILL.md`.

## Pick the process

- If the page is new and substantial (a spec, a design doc, a proposal, a multi-section guide), offer the `doc-coauthoring` workflow (`../doc-coauthoring/SKILL.md`, relative to the `jep-writing` directory). It gathers context, builds the page section by section, and tests it with a reader that has no context.
- If the page is a small edit or the user declines the workflow, write it directly with this guide.

## Pick one Diataxis type per page

[Diataxis](https://diataxis.fr/) sorts documentation by what the reader needs.

| Type | The reader wants to | The page gives | The page must not contain |
|---|---|---|---|
| Tutorial | Learn, new to the topic | One guided path to a working result | Alternatives, options, or theory |
| How-to guide | Do one task, already competent | The steps for one goal | Lessons on the basics |
| Reference | Look up a fact | A description of the machinery: commands, options, fields | Instructions or opinions |
| Explanation | Understand why | Context, design, and trade-offs | Steps to follow |

- If a page needs two types, split it into one page per type and link them.
- Name the type in the page title or the first line when the reader could confuse it: "How to rotate the key".

## Content

- Lead with the file or object the reader edits: "`<config file>` declares every X".
- Name what each step depends on: the host, the flag, the prior step.
- Keep a section in its scope. A current-state section names no target tools or primitives.

## Form

- Cut design rationale outside an explanation page. Keep the constraint and the exact error string.
- State the fix, not the consequence avoided. Put the mechanism in parentheses and the effect in the main clause.
- Trim examples to the lines under discussion and mark the rest with `...`.
- Write one risk per admonition, in one or two sentences, with the command or condition first: "Do not run this on prod. It deletes rows."
