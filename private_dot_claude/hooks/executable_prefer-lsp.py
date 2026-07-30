#!/usr/bin/env python3
"""Nudge Bash symbol-greps in Python files toward the ty LSP tool."""

import json
import re
import sys

SEARCH = re.compile(r"(^|[|;&(]\s*|\s)(grep|rg|ag)\b")
SYMBOL = re.compile(r"\b(class|def|import|from)\s")

data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")

if SEARCH.search(cmd) and ".py" in cmd and SYMBOL.search(cmd):
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "additionalContext": (
                        "This looks like a Python symbol lookup. Prefer the LSP tool "
                        "(ty server): workspaceSymbol to locate a symbol, "
                        "findReferences instead of grepping callers, goToDefinition "
                        "instead of grepping 'class X'/'def x', hover for types. "
                        "It is a deferred tool: load it with "
                        'ToolSearch query "select:LSP" first. '
                        "Use grep only for non-symbol text or non-Python files."
                    ),
                }
            }
        )
    )
