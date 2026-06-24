# Acceptance Criteria Guide

Use acceptance criteria to make planning decisions testable.

## Format

Prefer concise Given / When / Then statements when behavior matters.

```text
Given ...
When ...
Then ...
```

## Checklist

- Happy path is covered.
- Empty, loading, error, and permission states are covered when relevant.
- Boundary values and validation rules are covered.
- Analytics, audit, or notification behavior is covered when relevant.
- Out-of-scope behavior is explicit.
