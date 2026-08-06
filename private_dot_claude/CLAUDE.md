# Guidelines

## Principles

- Incremental progress: small changes that compile and pass tests
- Study existing code before implementing
- Match content to the reader (ISO 24495-1 plain language): complete and findable for someone with adequate domain knowledge, nothing they'd have to hunt for
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
- Assumptions instead of verifying against existing code
- "Co-Authored-By" in commits/descriptions
- Unscoped `find /` (scans the whole disk) — scope to a directory
- Restatement codas: a trailing sentence relabeling a fact as a verdict instead of adding information (e.g. "...removes 0 rows over 11 days. Adding it back would be dead code."). State the evidence and stop
- "it is not X, it is Y" contrast structures — state the conclusion directly
- Existential "there is/are" — make the real subject the grammatical subject ("the repo contains no X", not "there is no X")
- Em dash (use hyphens/commas/parentheses); title-case titles; marketing language ("surgically", "strategically", "smartly")
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

Documentation: see `writing-docs` skill.

Tooling:
- `vault-cli -U $VAULT_ADDR -T ~/.vault-token` for vault secrets/operations
- Python: invoke `/astral:<skill>` for uv/ty/ruff
- Python symbol lookups: LSP tool (ty), never grep — load via ToolSearch "select:LSP"

@RTK.md
