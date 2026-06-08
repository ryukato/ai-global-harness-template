---
name: legacy-maintenance
description: Make changes in existing or legacy projects while preserving structure, behavior, contracts, and local conventions.
---

# Legacy Maintenance

Use this skill when `docs/claude/project-context.md` marks the project as `legacy`, when the user mentions a legacy system such as SingleOne, or when changing an established codebase that should not be re-scaffolded.

## Core Rule

Do not modernize opportunistically.

Make the smallest safe change that satisfies the task while preserving the repository's existing structure and conventions.

## Before Editing

Read:

```text
CLAUDE.md
docs/claude/project-context.md
nearby README or architecture notes
directly related source files and tests
```

Identify:

- existing module, package, and directory layout
- controller, service, repository, adapter, and utility naming conventions
- API and persistence contracts
- transaction and error-handling patterns
- dependency injection, configuration, logging, and test style
- commands that are safe to run locally
- paths that must not be modified without an explicit request

## Preserve Structure

Prefer:

- editing the existing module where the behavior already lives
- adding small helpers next to existing code
- following nearby package boundaries and names
- extending existing tests in the same style

Avoid unless explicitly requested:

- moving packages or modules
- replacing the architecture with a new pattern
- changing build tools, package managers, dependency versions, or runtime versions
- adding new shared packages, proxy layers, databases, queues, vector stores, or other infrastructure
- broad formatting-only rewrites

## Preserve Behavior

Preserve:

- public APIs and response shapes
- database schemas, query semantics, and migration assumptions
- serialization formats
- auth, authorization, logging, monitoring, scheduler, batch, queue, and external integration behavior
- deployment and runtime assumptions

When behavior must change, document what changed, why it was necessary, affected callers, verification performed, and remaining compatibility risks.

## Final Report

For legacy changes, include:

- whether the existing structure was preserved
- any intentional deviation from legacy conventions
- verification command results
- remaining compatibility risks
