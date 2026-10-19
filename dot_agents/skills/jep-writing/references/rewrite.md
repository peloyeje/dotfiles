# Rewrite existing prose

Apply this guide on top of `SKILL.md` and the guide for the artifact type.
The old text is a source of ideas only. Do not keep or imitate its wording, syntax or structure.

## Before you start

1. Fix the scope. For a PR or a diff, the scope is every comment and docstring the diff adds or
   changes, plus every comment in a touched block that describes behaviour the diff changed.
2. Read the code each block describes. A rewrite that trusts the old comment repeats its mistakes.

## Rewrite one block

Work on one comment, docstring or paragraph at a time.

1. **Distill.** Write each idea of the block as a bare note: one claim, constraint, reason or
   consequence per note, in your own words.
2. **Sort the notes.** Use the table below. Most blocks lose at least one note.
3. **Write from the notes only.** Do not look at the old text while you write.
4. **Fit the form.** Keep the comment markers, the indentation, the line width of the file, and any
   escaping the file needs (for example `$$` in a Helm or compose shell block).
5. **Apply to every copy.** If the same code lives in two places, the comment must read the same in
   both.

| Note | Action |
|---|---|
| True, and explains why or names a constraint | Keep |
| True for the old code, false for the current code | Fix it to match the current code |
| Says what the code already says | Drop |
| Shows effort (what was checked, measured or ruled out) and changes no decision | Drop |
| Names a real team, table, host, account or domain as an example | Replace it with the property it illustrates |
| Tells history ("used to", "now", "since the change") | Drop, git holds the history |

## Patterns to catch in older prose

These add to the words to cut in `SKILL.md`.

| Pattern | Rewrite |
|---|---|
| Several claims chained with `;`, `:` or `—` | One sentence per claim |
| "X is the point of Y", "the reason is that" | The cause, then the effect |
| A system call or tool name as the explanation (`rename(2)`, `ln -sfn`) | The behaviour it gives, with the name in parentheses if the reader needs it |
| A trailing ", so ..." clause that adds a second claim | A second sentence |

## What must not change

- Code, identifiers, and anything a program reads.
- Log and error message strings, because tests and people search for them. Change one only when
  asked, and update its test in the same commit.
- Generated files, changelogs, license headers, and quoted external text.
- The meaning. If a note is unclear, read the code until it is clear. If it stays unclear, ask.

## Check the result

1. Run the pre-send check of `SKILL.md` on every new block.
2. Show that only prose changed: the diff must touch comment, docstring or documentation lines only.
3. Run the formatter, the linter and the tests of the files you touched.
4. For a comment inside an embedded script (YAML, templates), extract the script and run a syntax
   check on it, because a broken comment marker breaks the script.
5. Commit as `docs(<scope>): ...`. The body names what the comments now explain, and ends with
   "No behaviour changes."

## Report

Report per block, in terms of ideas: what each block now says, and which notes were dropped or
fixed and why. Do not paraphrase the diff. Name any note you could not verify.
