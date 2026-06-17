---
name: fix-bug
description: Use when investigating and fixing a defect, failed test, regression, or production-like issue.
---


# Fix Bug Skill

## Purpose

Fix the root cause, not just the symptom.

## Workflow

1. Understand observed behavior.
2. Identify expected behavior.
3. Reproduce or locate failing path.
4. Find the smallest root cause.
5. Implement the fix.
6. Add or update regression tests.
7. Run relevant checks.

## Guardrails

- Avoid broad refactors during bug fixes.
- Avoid changing public behavior beyond the bug.
- Preserve existing successful behavior.
- State uncertainty clearly.

## Output

- root cause
- fix summary
- regression test
- verification result
