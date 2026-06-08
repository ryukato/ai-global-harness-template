# Legacy Project Guidance

Use this guidance when `docs/codex/project-context.md` marks a project as `legacy`.

Legacy mode is for existing systems where preserving behavior, structure, deployment assumptions, and team conventions is more important than applying a new scaffold style.

## Core Rule

Do not modernize opportunistically.

Make the smallest safe change that satisfies the task while preserving the repository's existing structure and conventions.

## Before Editing

Read:

```text
AGENTS.md or CLAUDE.md
docs/codex/project-context.md
docs/codex/legacy-project-guidance.md
nearby README or architecture notes
directly related source files and tests
```

Then identify:

- existing module/package layout
- naming conventions
- API and persistence contracts
- transaction and error-handling patterns
- framework boundaries
- test style and available verification commands

## Structure Preservation

Prefer:

- editing the existing module where the behavior already lives
- adding small helper functions/classes next to the existing code
- following nearby names and package boundaries
- extending existing tests in the same style
- using existing dependency injection, config, logging, and error patterns

Avoid unless explicitly requested:

- moving packages or modules
- splitting layers into a new architecture
- introducing Ports & Adapters, BFF/proxy, new monorepo layout, or new shared packages
- changing build tools, package managers, dependency versions, or runtime versions
- replacing established framework conventions
- broad formatting or lint-only rewrites

## Behavior Preservation

Preserve:

- public APIs and response shapes
- database schemas, query semantics, and migration assumptions
- serialization formats
- authentication/authorization behavior
- logging and monitoring expectations
- batch, scheduler, queue, or external integration behavior
- existing compatibility with consumers and deployment environments

When behavior must change, document:

- what changed
- why it was necessary
- affected callers or operational assumptions
- verification performed

## Legacy SingleOne-Style Projects

For legacy SingleOne-derived projects, project-specific conventions should be recorded in `docs/codex/project-context.md`.

At minimum, document:

```text
legacy system name:
important package roots:
controller/service/repository conventions:
transaction boundaries:
external APIs and contracts:
database/schema compatibility notes:
commands that are safe to run locally:
paths that agents must not modify:
```

Agents should treat those conventions as authoritative for that repository.

## Final Report Expectations

For legacy changes, the final report should include:

- whether the existing structure was preserved
- any intentional deviation from legacy conventions
- verification command results
- remaining compatibility risks
