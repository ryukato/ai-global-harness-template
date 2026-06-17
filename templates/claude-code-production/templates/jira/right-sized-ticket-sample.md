# Right-Sized Jira Ticket Sample

## Summary

Implement user search API

## Background

Operators need to find users by name without manually scanning the full user list. The existing list API already supports pagination.

## Requirements

- Add optional name keyword filtering to the existing user list API.
- Matching should be case-insensitive if supported by the existing query pattern.
- Preserve existing behavior when no keyword is provided.

## Acceptance Criteria

- Searching with `kim` returns users whose name matches `kim`.
- Omitting keyword returns the same result as the current list API.
- Pagination still works with and without keyword.
- Relevant tests are added or updated.

## Out of Scope

- UI changes.
- Full-text search engine integration.
- Search by email or phone number.
