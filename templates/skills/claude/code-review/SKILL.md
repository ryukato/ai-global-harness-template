---
name: code-review
description: Review code changes for correctness, regressions, missing tests, unsafe broad edits, and project-harness rule violations.
---

# Code Review

Use this skill when the user asks for a review, asks whether a change is safe, or wants risks in a diff or implementation.

## Review Stance

Prioritize findings over summaries.

Look for:

- behavioral regressions
- missing or weak tests
- unsafe changes to public APIs, data contracts, persistence behavior, or deployment assumptions
- unrelated edits or broad rewrites
- generated or dependency files edited by mistake
- unclear error handling, transaction boundaries, side effects, or orphan objects
- frontend state, validation, loading, empty, success, and error handling gaps

## Context To Check

Before reviewing, inspect:

```text
CLAUDE.md
docs/claude/project-context.md
docs/claude/done-definition.md
directly changed files
nearby tests and configuration
```

For legacy projects, also apply:

```text
.claude/skills/legacy-maintenance/SKILL.md
```

## Output Shape

If issues exist, lead with findings ordered by severity. Include file and line references when available.

Use this order:

```text
Findings
- ...

Open questions / assumptions
- ...

Summary
- ...

Verification gaps
- ...
```

If no issues are found, say that clearly and mention remaining test gaps or residual risk.

Keep the review focused on actionable defects and risks. Do not rewrite code during a review unless the user asks for fixes.
