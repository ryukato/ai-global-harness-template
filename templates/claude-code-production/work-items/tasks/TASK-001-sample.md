# TASK-001 Sample: Implement User Search API

> Sample only. Do not implement this task unless a user explicitly selects it.

## Source

Feature: `work-items/features/FEATURE-001-sample.md`

## Goal

Add an API endpoint that supports searching users by name.

## Requirements

- Accept optional `keyword`.
- Return paginated users.
- Use existing user repository/query pattern.

## Acceptance Criteria

- When keyword is provided, matching users are returned.
- When keyword is omitted, existing list behavior is preserved.
- Pagination parameters are respected.
- Relevant tests are added or updated.

## Out of Scope

- UI changes.
- Search engine integration.
