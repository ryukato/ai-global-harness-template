# AI Workspace

This directory is used to share task-level outputs between Claude Code agents and human reviewers.

## Purpose

The workspace preserves the reasoning artifacts needed for team collaboration:

- What was requested
- What context was inspected
- What design decisions were made
- What was implemented
- What was reviewed
- What remains risky or unresolved

## Layout

```text
.ai-workspace/
├── active/
├── templates/
├── completed/
└── archive-index/
```

## Active Task Layout

```text
active/<TASK-ID>/
├── task.md
├── context/
│   ├── jira.md
│   ├── domain-summary.md
│   └── architecture-summary.md
├── outputs/
│   ├── explorer.md
│   ├── architect.md
│   ├── implementer.md
│   └── reviewer.md
└── final-summary.md
```

## Templates

Task workspace templates live outside `active/` so release archives do not treat
templates as real in-progress tasks:

```text
templates/TASK-000-template/
```

## Required Output Policy

Not every task needs every agent output.

Required for most tasks:

- `task.md`
- `outputs/explorer.md`
- `outputs/implementer.md`
- `outputs/reviewer.md`
- `final-summary.md`

Optional:

- `outputs/architect.md`
- `context/architecture-summary.md`

Use architect output only when the task changes architecture, domain boundaries, major dependencies, data model, security model, deployment model, or public APIs.

## Archive Policy

Detailed task folders should be archived at release/tag time.
See:

```text
docs/operations/ai-artifact-archive-policy.md
```
