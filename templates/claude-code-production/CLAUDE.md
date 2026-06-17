# CLAUDE.md

## Purpose

Repository-wide instructions for Claude Code.

Keep this file concise. Put detailed technology, domain, and process documents in:

- `docs/architecture/*`
- `docs/domain/*`
- `docs/decisions/*`
- `.claude/skills/*`

## Operating Principles

- Keep changes small, focused, and reversible.
- Do not modify unrelated files.
- Prefer existing project patterns over introducing new ones.
- Preserve public behavior unless the task explicitly asks for behavior change.
- Do not introduce new dependencies unless the task requires it and the trade-off is clear.
- State assumptions explicitly.
- Do not leave incomplete implementation work unless a hard blocker exists.

## Context Loading

Before implementation:

1. Read the task source: Jira ticket, `work-items/tasks/*`, or user request.
2. Read relevant architecture documents.
3. Read relevant domain documents.
4. Use relevant skills from `.claude/skills/*`.

## Required Workflow

1. Understand the request.
2. Inspect affected code and documents.
3. Identify assumptions and risks.
4. Create a short implementation plan.
5. Implement the change completely.
6. Add or update tests.
7. Run relevant checks.
8. Report results.

## Definition of Done

A task is complete only when:

- Acceptance criteria are satisfied.
- Implementation is complete.
- Relevant tests pass or a concrete reason is provided.
- No unnecessary TODO/FIXME remains.
- No unrelated changes are included.
- Behavior changes are documented when relevant.

## Final Response Format

### Summary

What changed.

### Files Changed

List important files.

### Checks

List commands/tests executed and results.

### Notes / Risks

Only include real risks, blockers, or follow-up items. Do not invent future work.


---

## AI Agent Workspace

This repository uses a task-centric AI workspace so that multiple Claude Code agents can share their work through files.

Agent outputs must not live only in chat responses.
For implementation work, store the important intermediate and final outputs under:

```text
.ai-workspace/active/<TASK-ID>/
```

### Workspace Layout

```text
.ai-workspace/
├── active/
│   └── <TASK-ID>/
│       ├── task.md
│       ├── context/
│       │   ├── jira.md
│       │   ├── domain-summary.md
│       │   └── architecture-summary.md
│       ├── outputs/
│       │   ├── explorer.md
│       │   ├── architect.md
│       │   ├── implementer.md
│       │   └── reviewer.md
│       └── final-summary.md
│
├── templates/
│   └── TASK-000-template/
│
├── completed/
│   └── <TASK-ID>.md
│
└── archive-index/
    └── releases/
        └── <VERSION>.md
```

### Agent Output Rules

- `explorer` writes findings to `outputs/explorer.md`.
- `architect` writes design decisions to `outputs/architect.md` only for large or architecture-sensitive tasks.
- `implementer` writes implementation notes to `outputs/implementer.md`.
- `reviewer` writes review findings to `outputs/reviewer.md`.
- The final task result is summarized in `final-summary.md`.
- After completion, create or update `.ai-workspace/completed/<TASK-ID>.md`.

### Required Files Per Task

For normal tasks:

```text
task.md
outputs/explorer.md
outputs/implementer.md
outputs/reviewer.md
final-summary.md
```

For large or architecture-sensitive tasks, also include:

```text
outputs/architect.md
context/architecture-summary.md
```

### Document Growth Control

Detailed active task folders are temporary.
They should be archived on release/tag according to:

```text
docs/operations/ai-artifact-archive-policy.md
```

After successful archive, keep only:

- `.ai-workspace/completed/<TASK-ID>.md`
- `.ai-workspace/archive-index/releases/<VERSION>.md`
- external archive location reference

Do not keep every detailed intermediate artifact in the repository forever.
