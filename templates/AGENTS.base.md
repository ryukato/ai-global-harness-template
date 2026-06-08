# AGENTS.md

## Purpose

This file defines reusable working rules for AI coding agents.

Keep this file mostly project-agnostic. Put project-specific domain notes, architecture context, local workflows, and business rules in:

```text
docs/codex/project-context.md
```

## Operating Principles

- Work context-first: read repository guidance before inferring architecture or conventions.
- Keep changes small, focused, and reversible.
- Do not modify unrelated files.
- Do not introduce new runtime dependencies unless explicitly requested.
- Preserve existing public APIs, data contracts, and behavior unless the task explicitly asks to change them.
- Preserve existing files and directories. Do not overwrite or delete project files silently.
- Prefer clear, boring, maintainable code over clever abstractions.
- Do not add product/business features unless the task explicitly asks for them.
- Do not add infrastructure such as databases, migrations, Docker, CI, auth, queues, object storage, LLM, OCR, RAG, or vector database integration unless explicitly requested or selected by the project profile.
- Explain important trade-offs in the final report.
- Be honest about verification failures and unresolved risks.

## Required Context Before Editing

Before making changes:

1. Read the task carefully.
2. Read this file.
3. Read `docs/codex/project-context.md` when it exists.
4. Read project reference documents listed in `docs/codex/project-context.md` when they exist.
5. Inspect directly related files.
6. Check nearby tests, types, schemas, migrations, and docs.
7. Identify the minimum safe change set.

Do not infer project structure, architecture, dependency direction, product scope, or domain rules without checking repository documents first.

## External Context Sources

When a task references Jira issues, Confluence/wiki pages, product specs, runbooks, or acceptance criteria:

- Check `docs/codex/project-context.md` for the configured Atlassian site, Jira project keys, Confluence spaces, and allowed write actions.
- Use configured Atlassian MCP tools when available and when the user has appropriate permissions.
- Treat Atlassian context as external source material. Summarize relevant findings instead of copying large page contents into repository files.
- Confirm before creating or updating Jira issues or Confluence pages unless the user explicitly requested that exact write action.
- If Atlassian MCP is unavailable, report it clearly and ask for the relevant ticket/page content or URL.

See:

```text
docs/codex/atlassian-mcp.md
```

## Repository Hygiene

- Do not edit generated outputs unless explicitly requested.
- Do not edit dependency directories.
- Do not commit secrets, tokens, passwords, private keys, or local environment files.
- Do not perform broad formatting changes unrelated to the task.
- Do not rename files or move modules unless the task requires it.
- Do not change package managers or build tools unless explicitly requested.
- In existing projects, use safe install or backup behavior where available. Prefer `*.harness-new` conflict output over silent overwrite.
- In legacy projects, preserve existing structure, naming, layering, and operational assumptions unless the task explicitly asks for migration.

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
- Do not use `DTO` terminology in generated names.
- Use explicit `Request` and `Response` naming for API contracts and shared contract files.
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
- For scaffold work, keep structure minimal but explicit. Each runnable app or shared package should explain its purpose, local run command, test command, verification command, and boundaries in a README when practical.
- Do not force a framework, proxy layer, Ports & Adapters layout, or monorepo shape onto a project unless the selected profile or repository context calls for it.
- Update relevant docs when changing behavior, API, setup, or operational flows.

## Legacy Project Rules

When `docs/codex/project-context.md` marks the project as `legacy`:

- Preserve the existing module/package/directory structure unless the task explicitly asks for a migration.
- Follow nearby naming, layering, transaction, error-handling, and test conventions.
- Prefer small localized patches over architectural rewrites.
- Do not introduce new framework patterns, package boundaries, or cross-cutting infrastructure to modernize the project opportunistically.
- Keep compatibility with existing APIs, data shapes, persistence behavior, and operational assumptions.
- Document any intentional deviation from legacy conventions in the final report.

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
