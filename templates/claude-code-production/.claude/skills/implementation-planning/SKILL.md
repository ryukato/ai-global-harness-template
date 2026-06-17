---
name: implementation-planning
description: Use before implementing any non-trivial feature, bug fix, refactor, or multi-file change.
---


# Implementation Planning Skill

## Purpose

Prevent partial work and unnecessary changes.

## Planning Rules

1. Keep the plan short.
2. Prefer vertical slices over large horizontal changes.
3. Identify files likely to change.
4. Identify tests likely to change.
5. Identify risks early.
6. Do not over-design.

## Task Decomposition

For larger work, split into independently verifiable steps:

1. Domain/model change
2. Use case/service behavior
3. Persistence or integration change
4. API/UI entry point
5. Tests
6. Documentation/update notes

Only use steps relevant to the task.

## Completion Guard

Do not stop after scaffolding. Do not leave future work for required acceptance criteria. Do not create TODOs for required implementation.

## Output

```text
Plan:
1. ...
2. ...
3. ...

Verification:
- ...
```
