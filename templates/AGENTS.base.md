# AGENTS.md

## Purpose

This file defines reusable working rules for AI coding agents.

Keep this file mostly project-agnostic. Put project-specific domain notes, architecture context, local workflows, and business rules in:

```text
docs/codex/project-context.md
```

## Operating Principles

- Keep changes small, focused, and reversible.
- Do not modify unrelated files.
- Do not introduce new runtime dependencies unless explicitly requested.
- Preserve existing public APIs, data contracts, and behavior unless the task explicitly asks to change them.
- Prefer clear, boring, maintainable code over clever abstractions.
- Explain important trade-offs in the final report.
- Be honest about verification failures and unresolved risks.

## Required Context Before Editing

Before making changes:

1. Read the task carefully.
2. Read this file.
3. Read `docs/codex/project-context.md` when it exists.
4. Inspect directly related files.
5. Check nearby tests, types, schemas, migrations, and docs.
6. Identify the minimum safe change set.

## Repository Hygiene

- Do not edit generated outputs unless explicitly requested.
- Do not edit dependency directories.
- Do not commit secrets, tokens, passwords, private keys, or local environment files.
- Do not perform broad formatting changes unrelated to the task.
- Do not rename files or move modules unless the task requires it.
- Do not change package managers or build tools unless explicitly requested.

Common generated/dependency paths to avoid:

```text
dist/
build/
coverage/
node_modules/
.venv/
__pycache__/
.pytest_cache/
.mypy_cache/
.ruff_cache/
target/
.gradle/
.idea/
*.tsbuildinfo
graphify-out/cache/
```

## Code Quality Rules

- Keep types explicit where practical.
- Avoid duplicated literals when they represent shared semantics.
- Extract constants by meaning, not by value.
- Keep validation, transformation, and domain decision logic separated where practical.
- Keep side effects explicit.
- Avoid orphan objects that are created but never persisted, returned, or used.
- Avoid hidden coupling between modules.
- Prefer small functions with clear responsibilities.

## Architecture Rules

- Keep public API contracts stable unless the task explicitly changes them.
- Keep domain/business logic out of thin transport/controller layers.
- Keep persistence details out of domain objects.
- Keep infrastructure concerns at boundaries.
- Update relevant docs when changing behavior, API, setup, or operational flows.

## Verification

After code changes, run:

```bash
./scripts/codex/verify.sh
```

For setup validation, run:

```bash
./scripts/codex/bootstrap.sh --check
```

If a command cannot be run, explain why and list the command that should be run manually.

## Completion Report

At the end of a task, report:

```text
Summary
- ...

Files changed
- ...

Commands run
- ...

Verification result
- ...

Risks / follow-up
- ...
```
