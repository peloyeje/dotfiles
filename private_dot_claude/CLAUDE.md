# Guidelines

## Principles

- Incremental progress: small changes that compile and pass tests
- Study existing code before implementing
- Pragmatic over dogmatic; boring and obvious over clever
- Single responsibility per function/class; avoid premature abstractions
- If you need to explain it, it's too complex
- Composition over inheritance (dependency injection); interfaces over singletons
- Explicit data flow over implicit; test-driven when possible — fix tests, never disable them

## Commits

Conventional format: `<type>(<scope>): <subject>` (feat, fix, docs, style, refactor, perf, test, chore, ci)

`feat(deploy): add image digest hashing for change detection`

Every commit: compiles, passes existing tests, includes tests for new functionality, follows formatting/linting, uses conventional format.

Before committing: run formatters/linters, self-review, write a message that explains why. No summary/markdown docs — the commit message is the record.

## Never

- `--no-verify` to bypass hooks; disabling tests instead of fixing them; committing code that doesn't compile
- Commit `HANDOFF.md`
- Assumptions instead of verifying against existing code
- "Co-Authored-By" in commits/descriptions
- Unscoped `find /` (scans the whole disk) — scope to a directory
- `/deep-research`

## Always

- Commit working code incrementally; update plan docs as you go; learn from existing implementations
- Stop after 3 failed attempts and reassess
- When modifying code, update tests that cover it
- Conventional format for commits and PR titles

Testing: see `python-testing` skill.

Code style:
- Enums over Literal types/string constants
- Type all function/method arguments
- Plain dataclasses over dict/TypedDict; pydantic dataclasses when validation is needed

Writing (docs, docstrings, code comments, commit messages, PR descriptions, reports, prose): see
`writing-docs` skill. Load it before drafting.

Tooling:
- `vault-cli -U $VAULT_ADDR -T ~/.vault-token` for vault secrets/operations
- Python: invoke `/astral:<skill>` for uv/ty/ruff
- Python symbol lookups: LSP tool (ty), never grep — load via ToolSearch "select:LSP"

@RTK.md
