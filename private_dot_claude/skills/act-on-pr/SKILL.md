---
name: act-on-pr
description: Use when a pull request has unresolved inline review comments that need to be fetched, triaged, and addressed in the code.
allowed-tools: Bash(git branch:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh api:*), Bash(gh repo view:*), Read, Glob, Grep, TodoWrite
---

# Act on PR Review Comments

## Overview

Fetches unresolved inline review comments from the current PR via GraphQL, creates a prioritized resolution plan, then applies fixes.

## Steps

### 1. Gather context (parallel)

```bash
git branch --show-current
gh repo view --json url --jq '.url | ltrimstr("https://") | ltrimstr("http://") | split("/")[0]'
gh pr view --json number --jq '.number'
gh repo view --json owner,name --jq '.owner.login + "/" + .name'
```

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

### 3. Parse and categorize

For each thread, extract:
- File path and line number
- Author and comment body
- Issue type (bug, security, performance, style)
- Code suggestion if present
- Severity if indicated

### 4. Filter actionable comments

**Include:** unresolved (`isResolved: false`), negative score or real issue, actionable suggestion

**Skip:** already resolved, pure questions, acknowledgments

### 5. Create resolution plan

Use `TodoWrite` - one task per unresolved actionable comment, ordered by severity (critical first). Each task references `file:line` and summarizes the issue.

### 6. Execute

For each task:
1. Read the relevant file
2. Understand context around the commented line
3. Apply fix or implement proper solution
4. Mark task completed

### 7. Summary

- List all changes made
- Note any comments intentionally skipped (with justification)
- Suggest running tests if applicable

## Output format

```
## PR Review Comments

### Unresolved Comments (X)

1. **file/path.py:123** - @author
   Issue: <brief description>
   Suggestion: <suggested fix>

### Resolution Plan

- [ ] Fix <issue 1> in file:line
- [ ] Fix <issue 2> in file:line
```

## Rules

- Only act on unresolved comments
- Preserve original code intent when fixing
- If a suggestion seems incorrect, explain why instead of blindly applying it
- Run pre-commit hooks after changes if available
