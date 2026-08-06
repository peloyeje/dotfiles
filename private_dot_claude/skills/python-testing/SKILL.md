---
name: python-testing
description: Conventions for writing pytest tests. Use when writing or editing Python test files.
---

# Python testing

- Prefer individual pytest test functions over TestClass syntax
- Use the `tmp_path` fixture instead of the `tempfile` package
- Consolidate none/empty, single-item, and multiple-item cases into one parametrized test when shared setup is heavy; split into separate tests only if that consolidation gets complex
