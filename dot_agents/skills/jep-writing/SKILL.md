---
name: jep-writing
description: "House writing style, in plain language with ADHD-friendly structure, for every text a person reads: documentation, README, docstrings, code comments, commit messages, PR descriptions, reports, chat answers, agent instructions. Also rewrites existing prose into this style. Load before you draft, edit or rewrite any prose or comment, including when asked to reword, restyle, or review the comments of a PR or diff."
---

# Writing

Write so a reader with the domain knowledge but none of the context understands on the first read.
Read this file for every text, then load the guide for what you write.
Rules rank in this order: the golden rule, section 1, then the rest.

**Golden rule:** choose vocabulary and syntax that a fluent but non-native English speaker understands on the first read. Prefer common words, literal phrasing, and regular word order over idioms, phrasal verbs, and rare words.

## Load the guide for what you write

Paths are relative to the `jep-writing` skill directory.

| You write | Load |
|---|---|
| A documentation page: README, tutorial, how-to, reference, explanation, spec, design doc | `references/documentation.md` |
| A procedure or agent instruction: runbook, AGENTS.md, skill, prompt | `references/instructions.md` |
| A code comment or docstring | `references/code-comments.md` |
| A commit message or PR description | `references/commits-and-prs.md` |
| A rewrite of text that already exists, or a review of the comments in a PR or diff | `references/rewrite.md`, plus the guide for the artifact type |
| A chat answer or report | This file only |

## 1. Core rule: do not perform

- Write about the matter and its consequences, nothing else.
- Cut any passage whose job is to show how careful you were: what you checked, what you read, what you ruled out.
- Keep a fact when it changes what the reader does. Drop it when it only proves you found it.
- State a simplification once. Do not defend it.
- Be concise, but spell out steps instead of compressing them.

## 2. Shape

- Number multi-step work, with one bounded action per step and the fewest steps that work.
- Use bullets for three or more parallel facts, and a table for field/value pairs (dimension in the header).
- Cap a list at five items. Split a longer list into ranked groups such as "Do now" and "Later".
- Bold only a label that helps the eye find a section.

Across a conversation:

- Finish the current issue before raising another. Offer the other one as one question at the end.
- If work remains, end with one next action that the reader can do in under two minutes.
- State what is done and what comes next: "Step 3 of 5 done: schema updated. Next: backfill the column."

## 3. Sentences

- Write one claim per sentence and per bullet.
- Put the condition before the command: "If the build fails, read the log."
- State the cause, then the effect: "The writer holds the lock, so the second job waits."
- Use one word for one meaning in a text: pick one of check, verify, validate, and keep it.

## 4. Words to cut

| Cut | Write instead |
|---|---|
| Em dashes and semicolons | A comma, parentheses, or a full stop |
| "It is not X, it is Y", "rather than" framing | Y |
| Passive voice: "has been updated" | The actor and an active verb: "the job updates" |
| A trailing ", -ing" clause (", making it easy to...") | A second sentence |
| "There is" and "there are" openings | The subject: "the repo contains no test" |
| Metaphors and borrowed jargon: surgically, fan out, load-bearing, blast radius, discriminator, churn, adopt | The literal action or property |

## 5. Evidence and corrections

- Say "measured" or "reproduced" when you ran it. Say "expected" or "untested" when you did not.
- Quantify before you generalise.
- Give the evidence and stop. Add no closing verdict and no summary that restates it.
- Report a failure with its output. A check that errored did not pass: say whether it proved absence or broke.
- Correct in one sentence ("Correction: X, not Y") and continue. Do not apologise or retell the error.

## 6. Exceptions

Override the defaults in these cases:

1. The reader asks for an explanation or walkthrough: explain fully and add headings, but keep the direct opening and ending.
2. The last three attempts failed the same way, or the request is materially ambiguous: stop and ask one short question that names the assumption.
3. The answer is a choice: give two to four ranked options with a one-line trade-off each, recommendation first.
4. The harness requires another shape: follow it, and do the work instead of asking permission.

## 7. Pre-send check

1. Search the draft for `—`, `;`, `**` outside section labels, ` has been `, `, making`, and, in procedures and instructions, `should`. Fix each hit.
2. Delete the last sentence if it offers more help or repeats the result.
3. Delete sidebars, hedges that add no information, and figurative phrases.
4. Read the first and last lines. Together they must show what happened and what the reader does next.

Sections 2 and 6 adapt [i-have-adhd](https://github.com/ayghri/i-have-adhd) (MIT). Parts of sections 3, 4 and 7 and of the guides adapt [SimpleEnglish](https://github.com/AminBlg/SimpleEnglish) (MIT).
