# Guidelines

## How to work

- Read the existing code and verify against it before implementing. Never assume.
- Make small incremental changes that compile and pass tests, and commit each one.
- Update plan docs as you go.
- Stop after 3 failed attempts and reassess.
- End subagent tasks with a final summary (verdict, evidence, checks).

## Code design

- Pragmatic over dogmatic, boring and obvious over clever. If it needs explaining, it is too complex.
- One responsibility per function or class. No premature abstractions.
- Composition (dependency injection) over inheritance, and interfaces over singletons.
- Explicit data flow over implicit.

## Python style

- Use uv, ruff and ty for Python tooling.
- Enums over Literal types or string constants.
- Type every function and method argument.
- Plain dataclasses over dict/TypedDict, and pydantic dataclasses when validation is needed.
- No leading-underscore module names. Declare the public surface with `__all__` after the imports (leave existing `_helper` modules alone unless asked).

## Tests

- Write tests first when possible.
- Changed code updates the tests that cover it. New code ships with tests.
- A failing test means fixing the code. Never disable or weaken the test.

## Git

- Commit format: `<type>(<scope>): <subject>` (feat, fix, docs, style, refactor, perf, test, chore, ci), for PR titles too. Example: `feat(deploy): add image digest hashing for change detection`.
- Use `chore:`, not `refactor:`, for commits that only rename or move files.
- Before committing, run formatters and linters and self-review. The message explains why. It is the record, so write no summary docs.
- Every commit compiles and passes the existing tests.
- Never use `--no-verify`, never add `Co-Authored-By`, never commit `HANDOFF.md`.
- Commit spec, plan, or design docs (`docs/superpowers/specs/`, `docs/superpowers/plans/`) only with explicit approval.
- PR descriptions contain a `## Summary`, plus ad-hoc sections when the rationale or a complex implementation needs explaining. Never add a test plan, a checklist, or a generated-by footer.

## Writing

- Load the `jep-writing` skill before drafting any prose: docs, docstrings, comments, commit messages, PR descriptions, reports.

## Shell and files

- Single-file edits use `edit`/`write`. Bulk edits use `gsed` (macOS ships BSD sed) or `perl -i -pe`. Use Python only for programmatic transforms.
- Scope `find` to a directory, never `find /`.
- Bash loops of CLI API calls (for example `databricks api`): write JSON payloads to a file with `printf`, not inline `python3 -c`, and run a small batch in the foreground first.
- Long batch jobs on a shared AWS profile: SSO tokens expire mid-run, so make each item resumable and record which items succeeded.

## Services

- Vault: `vault-cli -U $VAULT_ADDR -T ~/.vault-token`.
- Gerrit (`review.leboncoin.ci`): query with `ssh review.leboncoin.ci gerrit query`, check that `.git/hooks/commit-msg` exists before committing, and rebase before `git push <remote> HEAD:refs/for/master` (Zuul `Merge Failed` with zero builds means the change needs a rebase).
- workspace-mcp: set `user_google_email` to `jean-eudes.peloye@adevinta.com`, because the @leboncoin.fr address fails OAuth.
