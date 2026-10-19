# Code comments and docstrings

Apply this guide on top of `SKILL.md`.

- Explain why and the constraint. The code already says what. A docstring never paraphrases the signature.
- Stay environment agnostic: no real table names, hostnames, account ids, or team names. Name the constraint, not the vendor.
- Describe the current state only, with no "previously" or "changed to". Git holds the history.
- Update a comment in the same edit as the behaviour it describes. A stale comment is a bug.
- Link the issue or ticket for anything external.
