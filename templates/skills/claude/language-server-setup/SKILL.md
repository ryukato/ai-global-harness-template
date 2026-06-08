---
name: language-server-setup
description: Check or apply profile-specific language server, linter, formatter, and editor config setup safely.
---

# Language Server Setup

Use this skill when the user asks about language servers, editor config, pyright, TypeScript tooling, JDTLS, Kotlin language server, or formatter/linter setup.

## Commands

Check only:

```bash
./scripts/claude/language-server.sh --check
```

Apply config files without installing tools:

```bash
./scripts/claude/language-server.sh --apply
```

Install missing tooling where possible only when the user explicitly approves:

```bash
./scripts/claude/language-server.sh --apply --install
```

Through bootstrap:

```bash
./scripts/claude/bootstrap.sh --apply --language-server
./scripts/claude/bootstrap.sh --apply --language-server --install-language-server
```

## Profile Tooling

```text
typescript           -> tsc, eslint, typescript-language-server, prettier
python-poetry / uv   -> ruff, pyright, mypy
jvm-*-java           -> jdtls
jvm-*-kotlin         -> kotlin-language-server, ktlint
```

## Existing Projects

Existing config files are not overwritten. Incoming config is written as:

```text
<file>.harness-new
```

Review and merge manually.

Language server installation is best-effort because availability differs by OS, package manager, IDE, and agent runtime. The goal is to make project-local conventions explicit, not to force one editor or one coding agent.
