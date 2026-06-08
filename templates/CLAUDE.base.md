# CLAUDE.md

## Purpose

This file is the Claude Code entrypoint for projects installed with ai-global-harness.

Keep project-specific domain notes, architecture context, local workflows, and business rules in:

```text
docs/claude/project-context.md
```

The shared harness documents are installed under this agent's docs namespace. Claude Code should treat those documents as project guidance.

Repeatable Claude Code workflows are installed as project skills under:

```text
.claude/skills/
```

Claude Code discovers project skills from `.claude/skills/<skill-name>/SKILL.md` and loads them when their descriptions match the task.

## Required Context Before Editing

Before making changes:

1. Read the task carefully.
2. Read this file.
3. Read `docs/claude/project-context.md` when it exists.
4. Read project reference documents listed in `docs/claude/project-context.md` when they exist.
5. Inspect directly related files.
6. Check nearby tests, types, schemas, migrations, and docs.
7. Identify the minimum safe change set.

Do not infer project structure, architecture, dependency direction, product scope, or domain rules without checking repository documents first.

## External Context Sources

When a task references Jira issues, Confluence/wiki pages, product specs, runbooks, or acceptance criteria:

- Check `docs/claude/project-context.md` for the configured Atlassian site, Jira project keys, Confluence spaces, and allowed write actions.
- Use configured Atlassian MCP tools when available and when the user has appropriate permissions.
- Treat Atlassian context as external source material. Summarize relevant findings instead of copying large page contents into repository files.
- Confirm before creating or updating Jira issues or Confluence pages unless the user explicitly requested that exact write action.
- If Atlassian MCP is unavailable, report it clearly and ask for the relevant ticket/page content or URL.

See:

```text
.claude/skills/atlassian-context/SKILL.md
```

## Project Skills

Use installed project skills when the task matches their scope:

```text
.claude/skills/code-review/SKILL.md
.claude/skills/legacy-maintenance/SKILL.md
.claude/skills/atlassian-context/SKILL.md
.claude/skills/graphify/SKILL.md
.claude/skills/dependency-fallback/SKILL.md
.claude/skills/language-server-setup/SKILL.md
.claude/skills/summarize-changes/SKILL.md
```

General facts and stable project background belong in `docs/claude/project-context.md`. Repeatable procedures belong in project skills.

## Operating Principles

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

## Legacy Project Rules

When `docs/claude/project-context.md` marks the project as `legacy`:

- Preserve the existing module/package/directory structure unless the task explicitly asks for a migration.
- Follow nearby naming, layering, transaction, error-handling, and test conventions.
- Prefer small localized patches over architectural rewrites.
- Do not introduce new framework patterns, package boundaries, or cross-cutting infrastructure to "modernize" the project opportunistically.
- Keep compatibility with existing APIs, data shapes, persistence behavior, and operational assumptions.
- Document any intentional deviation from legacy conventions in the final report.
- Apply `.claude/skills/legacy-maintenance/SKILL.md` for detailed legacy handling rules.

## Verification

After code changes, run:

```bash
./scripts/claude/verify.sh
```

For setup validation, run:

```bash
./scripts/claude/bootstrap.sh --check
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
