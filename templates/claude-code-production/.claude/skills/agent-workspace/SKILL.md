---
name: agent-workspace
description: Use when creating, updating, or reviewing task-level AI workspace files for agent collaboration.
---

# Agent Workspace Skill

## Purpose

Ensure Claude Code agents share their outputs through files under `.ai-workspace`.

## Required Layout

For each task:

```text
.ai-workspace/active/<TASK-ID>/
├── task.md
├── context/
├── outputs/
└── final-summary.md
```

## Agent Output Targets

- Explorer: `outputs/explorer.md`
- Architect: `outputs/architect.md`
- Implementer: `outputs/implementer.md`
- Reviewer: `outputs/reviewer.md`

## Instructions

1. Create task workspace before meaningful multi-step work.
2. Keep each file concise.
3. Store decisions, findings, verification results, and risks.
4. Do not store secrets or raw sensitive data.
5. Create `final-summary.md` when the task is complete.
6. Create or update `.ai-workspace/completed/<TASK-ID>.md`.

## When To Use Architect Output

Use architect output only for large or architecture-sensitive tasks.

Do not create unnecessary documents for trivial changes.
