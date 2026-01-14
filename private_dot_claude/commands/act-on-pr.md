---
allowed-tools: Bash(git:*), Bash(gh:*), Read, Edit, Glob, Grep, Write, Task, TodoWrite
description: Fetch PR inline review comments and create a resolution plan
---

## Context

- Current branch: !`git branch --show-current`
- GitHub hostname: !`gh repo view --json url --jq '.url' | sed -E 's|https?://([^/]+)/.*|\1|'`
- PR number: !`gh pr view --json number --jq '.number' 2>/dev/null || echo "No PR found"`
- Repository: !`gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'`

## Instructions

Fetch and act on inline review comments from the current PR.

### 1. Fetch PR review threads

Use the GraphQL API to fetch review threads:

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

### 2. Parse and categorize comments

For each review thread, extract:
- File path and line number
- Author and comment body
- Issue type (bug, security, performance, style, etc.)
- Code suggestions if present
- Severity/score if provided

### 3. Filter actionable comments

**Include comments that:**
- Are unresolved (`isResolved: false`)
- Have a negative score or identify real issues
- Contain actionable suggestions or code fixes

**Skip comments that:**
- Are already resolved
- Are pure questions without actionable feedback
- Are acknowledgments or approvals

### 4. Create a resolution plan

Use TodoWrite to create a task list:
- One task per unresolved actionable comment
- Order tasks by severity (most critical first)
- Reference file:line and summarize the issue in each task

### 5. Execute the resolution plan

For each task:
1. Read the relevant file
2. Understand the context around the commented line
3. Apply the suggested fix or implement a proper solution
4. Mark the task as completed

### 6. Summary

After addressing all comments:
- List the changes made
- Note any comments intentionally not addressed (with justification)
- Suggest running tests if applicable

## Output format

```
## PR Review Comments

### Unresolved Comments (X)

1. **file/path.py:123** - @author
   Issue: <brief description>
   Suggestion: <suggested fix>

2. ...

### Resolution Plan

- [ ] Fix <issue 1> in file:line
- [ ] Fix <issue 2> in file:line
...
```

## Important

- Only act on unresolved comments
- Preserve the original code intent when making fixes
- If a suggestion seems incorrect, explain why rather than blindly applying it
- Run pre-commit hooks after making changes if available
