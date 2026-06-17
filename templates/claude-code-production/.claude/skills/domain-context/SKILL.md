---
name: domain-context
description: Use when a task changes business behavior, domain model, permissions, state transitions, validation rules, audit behavior, or user-visible workflow.
---


# Domain Context Skill

## Purpose

Ensure business rules are respected during implementation.

## Required References

Read relevant files under:

- `docs/domain/domain-model.md`
- `docs/domain/business-rules.md`
- `docs/domain/status-transitions.md`
- `docs/domain/permissions-and-roles.md`
- `docs/domain/audit-policy.md`
- `docs/domain/glossary.md`

## Instructions

Before changing domain-sensitive code:

1. Identify affected domain concepts.
2. Check business rules and state transitions.
3. Check permissions and audit requirements.
4. Preserve invariants.
5. Add tests for business rules, not just technical behavior.

## Red Flags

Do not proceed blindly if the task conflicts with documented business rules, status transition behavior is unclear, permission scope is unclear, or audit requirements are unclear.

If blocked, state the missing decision clearly.
