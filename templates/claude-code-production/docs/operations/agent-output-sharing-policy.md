# Agent Output Sharing Policy

## Purpose

This policy defines how Claude Code agents share outputs through files.

The goal is to make AI-assisted development reviewable by the team, not only visible in chat history.

## Standard Agents

### Explorer

Finds relevant code, documents, tests, and existing patterns.

Output:

```text
.ai-workspace/active/<TASK-ID>/outputs/explorer.md
```

### Architect

Used only for large or architecture-sensitive tasks.

Output:

```text
.ai-workspace/active/<TASK-ID>/outputs/architect.md
```

### Implementer

Records implementation summary, changed files, tests, and checks.

Output:

```text
.ai-workspace/active/<TASK-ID>/outputs/implementer.md
```

### Reviewer

Reviews the final change against requirements, architecture, tests, and risk.

Output:

```text
.ai-workspace/active/<TASK-ID>/outputs/reviewer.md
```

## Required vs Optional Outputs

Required for normal work:

- explorer
- implementer
- reviewer
- final-summary

Optional:

- architect

Architect output is required when:

- new architecture boundary is introduced
- data model changes
- dependency direction changes
- public API changes
- security or permission model changes
- deployment/runtime model changes
- integration contract changes

## File-Based Collaboration Rules

- Agents must write durable summaries to files.
- Files should be concise and reviewable.
- Do not copy entire chat transcripts.
- Prefer decisions, evidence, and links.
- Keep raw logs out unless necessary.
- Redact sensitive values.

## Team Review

Human reviewers should check:

- final-summary.md
- outputs/reviewer.md
- outputs/architect.md if present
- archive index for release-level traceability
