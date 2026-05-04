# Code Review Checklist

## Scope

- Is the change limited to the requested task?
- Are unrelated files untouched?
- Are generated files excluded?
- Are large rewrites avoided when a focused fix is enough?

## General Code Quality

- Are names clear and domain-appropriate?
- Are types explicit enough?
- Are duplicated semantic literals extracted?
- Are edge cases handled intentionally?
- Are errors handled consistently?
- Are side effects visible and controlled?
- Are orphan objects avoided?

## Architecture

- Is business logic placed in the appropriate layer?
- Are transport, application, domain, persistence, and infrastructure concerns separated where practical?
- Are public contracts preserved or documented if changed?
- Are module boundaries respected?

## Data / Persistence

- Are transaction boundaries clear where applicable?
- Are migrations or schema changes documented?
- Are read/write responsibilities clear?
- Are data compatibility risks identified?

## Frontend

- Are API calls separated from UI rendering?
- Are loading, empty, error, and success states handled?
- Are form validation rules consistent?
- Are shared UI patterns reused?
- Are broad layout/style changes intentionally scoped?

## Backend

- Are controllers/routes thin?
- Are domain decisions centralized where practical?
- Are repositories limited to persistence concerns?
- Are error responses consistent?

## Tests / Verification

- Were relevant tests added or updated?
- Were lint/typecheck/test/build commands run?
- If checks were not run, is the reason documented?

## Documentation

- Were API, domain, setup, or operational docs updated when behavior changed?
- Are examples still accurate?

## Risk Review

- Could this break existing API clients?
- Could this alter persisted data semantics?
- Could this introduce inconsistent UI behavior?
- Could this create hidden coupling between apps and libs?
