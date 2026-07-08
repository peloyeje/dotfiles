---
name: act-on-pr
description: Use when a pull request has unresolved inline review comments that need to be fetched, triaged, and addressed in the code. Use this skill proactively whenever the user mentions PR review comments, reviewer feedback, or asks to act on/address/fix review comments.
allowed-tools: Bash(git branch:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh api:*), Bash(gh repo view:*), Bash(pre-commit run:*), Read, Glob, Grep, Edit, Write, TodoWrite
---

# Act on PR Review Comments

## Overview

Fetches unresolved inline review comments from the current PR, then walks through them one by one with the user - presenting remediation options for each and waiting for their choice before applying any change.

## Steps

### 1. Gather context (parallel)

```bash
git branch --show-current
gh repo view --json url --jq '.url | ltrimstr("https://") | ltrimstr("http://") | split("/")[0]'
gh pr view --json number --jq '.number'
gh repo view --json owner,name --jq '.owner.login + "/" + .name'
```

If no PR is found for the current branch, tell the user and stop.

### 2. Fetch review threads

```bash
gh api graphql $([ "<hostname>" != "github.com" ] && echo "--hostname <hostname>") -f query='
{
  repository(owner: "<owner>", name: "<repo>") {
    pullRequest(number: <pr_number>) {
      reviewThreads(first: 100) {
        nodes {
          path
          line
          isResolved
          comments(first: 10) {
            nodes {
              author { login }
              body
              createdAt
            }
          }
        }
      }
    }
  }
}'
```

### 3. Parse and filter

For each thread extract: file path, line number, all comments (author + body), and any inline code suggestion. Keep only threads where `isResolved: false` and the comment is actionable (has a real issue or suggestion - skip pure questions, "LGTM", or acknowledgment replies).

If no actionable unresolved threads remain, tell the user "No unresolved actionable comments found" and stop.

### 4. Build the work list

Classify each comment by severity to sort the queue: security/data-loss issues first, then functional bugs (wrong behavior, crashes, broken tests), then code quality (error handling, missing tests), then style/nits. Use the comment body to infer the category.

Use `TodoWrite` to create one task per comment with the format: `@author: <comment truncated to ~60 chars> (file:line)`.

### 5. Interactive remediation loop

For each comment in order, follow this sequence:

**a) Present the comment**

```
-- Comment N/total --
file/path.py  line 42   @reviewer_handle
"<reviewer's comment text, or full thread if multiple replies>"

Relevant code:
<~5 lines around the flagged line>
```

When a thread has multiple replies, show the full exchange and use the most recent reviewer message as the primary comment to act on. If the last message is from the PR author (not the reviewer), note that this thread may be awaiting re-review rather than a code change.

**b) Propose options**

Read the file and surrounding context, then think through the remediation space.

Present **1 option** only when:
- The reviewer included a GitHub code suggestion block, or
- The change is purely mechanical with no design implications (e.g., fix a typo, remove a dead import, rename per explicit instruction).

Otherwise present **2 or 3 genuinely distinct options** - different trade-offs, not minor wording variations. Each option gets a short title, a one-sentence rationale, and a concrete code snippet or description.

```
Options:
  A) <title> - <one-line rationale>
     <code snippet or change description>

  B) <title> - <one-line rationale>
     <code snippet or change description>

  C) <title> - <one-line rationale>  (if a third is warranted)
     <code snippet or change description>

  S) Skip - leave this comment for later
```

If a reviewer's suggestion looks incorrect, note it explicitly: "Warning: this suggestion may introduce X" - do not silently skip or blindly apply it.

**c) Wait for the user's choice**

Do not apply anything until the user replies. Accept:
- `A`, `B`, `C` - apply that option as described
- A modifier like "A but also rename x to y" - restate the interpretation in one sentence, then apply
- A free-text instruction that replaces all options - confirm the interpretation in one sentence before applying
- `S` - skip and move to the next comment
- `stop` - halt the session and jump to the wrap-up

**d) Apply the chosen remediation**

Make only the change scoped to that comment. Mark the corresponding todo task completed. Then immediately move to the next comment.

### 6. Wrap up

After the last comment or when the user types "stop":

1. List all changes applied: file:line and which option was chosen
2. List any skipped comments: file:line so the user can return to them
3. Run `pre-commit run --files <all changed files>` if pre-commit is available

## Rules

- One comment at a time - never apply multiple fixes in one step without user input
- Preserve original code intent unless the reviewer explicitly requests a behavior change
- Keep code snippets in option proposals short and focused - they are previews, not full diffs
