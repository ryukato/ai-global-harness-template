---
name: archive-management
description: Use when preparing AI task artifacts for release/tag archiving or repository cleanup.
disable-model-invocation: true
---

# Archive Management Skill

## Purpose

Prepare AI workspace artifacts for release/tag archive and prevent document growth.

## Pre-Archive Checklist

1. Every completed task has `final-summary.md`.
2. Every completed task has `.ai-workspace/completed/<TASK-ID>.md`.
3. Required agent outputs exist:
   - explorer
   - implementer
   - reviewer
4. Architect output exists when architecture-sensitive work was performed.
5. Sensitive values are removed or redacted.
6. Archive index entry is prepared.

## Archive Candidate Paths

```text
.ai-workspace/active/**
.ai-workspace/completed/**
work-items/**
docs/architecture/**
docs/domain/**
docs/decisions/**
CLAUDE.md
AGENTS.md
HARNESS-GUIDE.md
```

## Post-Archive Cleanup

After successful archive upload:

1. Keep completed summaries.
2. Keep release archive index.
3. Remove or move detailed active task folders.
4. Record archive location.

## Output

Produce:

```text
Archive Readiness:
- Ready / Not Ready

Blocking Issues:
- ...

Archive Location:
- ...
```
