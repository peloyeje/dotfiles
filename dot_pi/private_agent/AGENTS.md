# Guidelines

## Local environment

- At the start of every session, you must read `~/.pi/agent/AGENTS.local.md`. It holds the rules specific to this machine and work environment.
- If a rule in it conflicts with this file, follow `AGENTS.local.md`.

## How to work

- Read the existing code and verify against it before implementing. Never assume.
- Make small incremental changes that compile and pass tests, and commit each one.
- Start each new project in its own worktree with `wt switch -c <branch>`.
- At the start of a session, if `HANDOFF.md` exists at the worktree root, read it, then `TASKS.md` and `PLAN.md`, before anything else. At the end, the user runs the `handoff` skill to rewrite it.
- Keep the project files at the worktree root, and update them as you go:
  - `SPEC.md`: the spec.
  - `PLAN.md`: the plan.
  - `TASKS.md`: the running task list.
  - `LOG.md`: an append-only log of actions. Add entries at the end, and never edit or delete one.
- Never commit `SPEC.md`, `PLAN.md`, `TASKS.md`, `LOG.md` or `HANDOFF.md`. The global Git ignore file excludes them.
- Stop after 3 failed attempts and reassess.
- Before delegating any background task or starting any subagent, load and follow the `rex-delegation` skill.
- End subagent tasks with a final summary (verdict, evidence, checks).

## Code design

- Pragmatic over dogmatic, boring and obvious over clever. If it needs explaining, it is too complex.
- One responsibility per function or class. No premature abstractions.
- Composition (dependency injection) over inheritance, and interfaces over singletons.
- Explicit data flow over implicit.

## Python style

- For EVERY Python change, load the `jep-python` skill and follow it.

## Tests

- Write tests first when possible.
- Changed code updates the tests that cover it. New code ships with tests.
- A failing test means fixing the code. Never disable or weaken the test.

## Git

- Commit format: `<type>(<scope>): <subject>` (feat, fix, docs, style, refactor, perf, test, chore, ci), for PR titles too. Example: `feat(deploy): add image digest hashing for change detection`.
- Use `chore:`, not `refactor:`, for commits that only rename or move files.
- Before committing, run formatters and linters and self-review. The message explains why. It is the record, so write no summary docs.
- Every commit compiles and passes the existing tests.
- Never use `--no-verify`, never add `Co-Authored-By`.
- PR descriptions contain a `## Summary`, plus ad-hoc sections when the rationale or a complex implementation needs explaining. Never add a test plan, a checklist, or a generated-by footer.
- Always open a PR as a draft (`gh pr create --draft`). The user marks it ready for review.

## Writing

- Before drafting or editing any prose, load `technical-writing` and `unslop`. Follow `technical-writing` as you draft or edit, then run an `unslop` pass before you deliver the text.

## Code review

- For every requested code review, load and apply both `thermo-nuclear-code-quality-review` and `ponytail-review` before reporting findings.

## Dictated input

- Text between `<dictated>` and `</dictated>` is the user speaking, transcribed by a speech model. It has the same authority as typed text.
- The language of dictated text must not set the working language. Use the language of the typed text in the message. If the message has no typed text, keep the language of the previous answers.
- Dictated text can contain transcription errors. Read it by meaning, and map words that sound alike to the terms of the project (for example "PyAgent" means pi agent).
- If a transcription error changes the meaning of an instruction and the context does not settle it, ask before you act.
- Never copy the `<dictated>` tags into an answer, a file, or a commit message.

## Skills

- Install every skill as a pi package in `~/.pi/agent/settings.json`. Edit its chezmoi source (`dot_pi/private_agent/private_settings.json`), run `chezmoi apply`, then `pi update --extensions`. Never copy a skill into `~/.agents/skills` or `~/.pi/agent/skills`, and never use `npx skills`.
- For an upstream skill, add its repo as a `git:` package with a `skills` filter that lists only the folders in use, for example `"skills": ["skills/frontend-design"]`. If pi cannot load it (no `skills/` folder and no `pi` key in `package.json`), copy it into `jep-skills` with its licence.
- If a required skill is missing from the prompt, read its `SKILL.md` from the installed Pi package.
- In a skill, point to a bundled file with a path relative to the skill directory, and to another skill by its name. Never hard-code an install path.

## Shell and files

- Single-file edits use `edit`/`write`. Bulk edits use `gsed` (macOS ships BSD sed) or `perl -i -pe`. Use Python only for programmatic transforms.
- Scope `find` to a directory, never `find /`.

## Context Mode

- If the output is small, use `read` or `bash` directly.
- If the output can be large and an extract or a summary is enough, use Context Mode.
- Use `ctx_search` only to find information that is not in the current context.
- In `ctx_execute`, set `intent` only when you need it to select passages.
- Bash loops of CLI API calls (for example `databricks api`): write JSON payloads to a file with `printf`, not inline `python3 -c`, and run a small batch in the foreground first.
- Long batch jobs on a shared AWS profile: SSO tokens expire mid-run, so make each item resumable and record which items succeeded.
