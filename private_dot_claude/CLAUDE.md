# Guidelines

## Philosophy

- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Learning from existing code** - Study and plan before implementing
- **Pragmatic over dogmatic** - Adapt to project reality
- **Clear intent over clever code** - Be boring and obvious

## Design principles

- Single responsibility per function/class
- Avoid premature abstractions
- If you need to explain it, it's too complex
- **Composition over inheritance** - Use dependency injection
- **Interfaces over singletons** - Enable testing and flexibility
- **Explicit over implicit** - Clear data flow and dependencies
- **Test-driven when possible** - Never disable tests, fix them

## Commits

Use conventional commit format: `<type>(<scope>): <subject>`

Types: feat, fix, docs, style, refactor, perf, test, chore, ci

Examples:
- `feat(deploy): add image digest hashing for change detection`
- `fix(workflow): remove --force-recreate flag`
- `docs(readme): update deployment timing expectations`

- **Every commit must**:
  - Compile successfully
  - Pass all existing tests
  - Include tests for new functionality
  - Follow project formatting/linting
  - Use conventional commit message format

- **Before committing**:
  - Run formatters/linters
  - Self-review changes
  - Ensure commit message explains "why"
  - Do not create summary documents or markdown files to explain changes (use commit message instead)

## Important reminders

**NEVER**:
- Use `--no-verify` to bypass commit hooks
- Disable tests instead of fixing them
- Commit code that doesn't compile
- Make assumptions - verify with existing code
- Add "Co-Authored-By" to commit messages or descriptions
- Add comments stating the obvious
- Use em dash (---). Use hyphens, commas, or parentheses instead
- Capitalize all words in titles
- Use marketing language in documentation or commit messages (e.g. "surgically", "purposefully", "strategically", "smartly")
- Use /deep-research

**ALWAYS**:

Follow these practices consistently:

Workflow:
- Commit working code incrementally
- Update plan documentation as you go
- Learn from existing implementations
- Stop after 3 failed attempts and reassess
- When modifying code, look for tests using this code and update the test cases
- Use conventional commit convention for commit messages and PR titles

Testing:
- Prefer pytest individual test functions over TestClass syntax
- Use tmp_path fixture in pytest tests instead of tempfile package
- Consolidate pytest tests for None/empty, single item, and multiple items behavior into one test using parametrize when shared setup is high; split only when factorizing leads to complex code

Code style:
- Prefer enums over Literal types and plain string constants
- Type all function and method arguments
- Prefer plain dataclasses over dicts and TypedDict; use pydantic dataclasses when validation is needed

Documentation:
- Adhere to the Diataxis framework
- Docstrings must explain intent and non-obvious "why", never paraphrase the signature

Tooling:
- Use vault-cli -U $VAULT_ADDR -T ~/.vault-token to access vault secrets or perform operations
- When working with Python, invoke the relevant /astral:<skill> for uv, ty, and ruff to ensure best practices are followed
- Python symbol lookups MUST use the LSP tool (ty), never grep. Load it first with ToolSearch "select:LSP". Map: grep "class X"/"def x" to goToDefinition or workspaceSymbol; grepping for callers to findReferences; checking a type to hover; "what is in this file" to documentSymbol. Use grep only for non-symbol text (log strings, YAML, config) or non-Python files

@RTK.md
