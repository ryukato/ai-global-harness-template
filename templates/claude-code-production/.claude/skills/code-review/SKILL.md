---
name: code-review
description: Use when reviewing a change, preparing a PR, or validating implementation quality before completion.
---


# Code Review Skill

## Purpose

Review code for correctness, maintainability, risk, and production readiness.

## Review Checklist

### Correctness

- Does the implementation satisfy acceptance criteria?
- Are edge cases handled?
- Are errors handled intentionally?
- Are existing behaviors preserved?

### Architecture

- Does the code follow existing layering?
- Are dependencies pointing in the right direction?
- Is business logic in the appropriate place?
- Are public APIs changed only when intended?

### Maintainability

- Is the code easy to read?
- Are names clear?
- Is duplication acceptable or should it be reduced?
- Are comments useful and not misleading?

### Testing

- Are relevant tests added or updated?
- Are business rules tested?
- Are regression cases covered?

### Security / Safety

- Are secrets avoided?
- Is input validation sufficient?
- Are permissions checked where required?
- Is logging safe and non-sensitive?

## Output

Report findings by severity:

- Must fix
- Should fix
- Nice to have

Do not invent issues. Prefer concrete observations tied to code.
