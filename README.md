# AI Global Harness

This repository contains reusable AI/Codex harness templates that can be copied into different projects.

The goal is to avoid rewriting long prompts for every task. Common rules, verification flows, review criteria, and stack-specific guidance should live here and be copied or adapted into each target repository.

## Supported Project Types

- TypeScript / Node.js
- Python / Poetry
- Python / uv
- JVM / Gradle
- JVM / Maven
- Documentation-only repositories
- Mixed monorepos

## Recommended Local Path

```bash
/Users/yoonyoul.yoo/DEV/projects/personal/ai-global-harness
```

## Main Concepts

```text
AGENTS.md
  Reusable common operating rules for coding agents.

docs/codex/project-context.md
  Project-specific notes copied into a target project and edited there.

docs/codex/code-review.md
  Shared code review checklist.

docs/codex/done-definition.md
  Completion criteria.

scripts/codex/verify.sh
  Stack-aware verification entrypoint.

scripts/codex/bootstrap.sh
  Applies basic harness setup to a target project.

profiles/
  Stack-specific append files and verification notes.
```

## Quick Start

From this repository:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile typescript
```

For Python with Poetry:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile python-poetry
```

For Python with uv:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile python-uv
```

For JVM Gradle:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile jvm-gradle-kotlin
```

For JVM Maven:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile jvm-maven-java
```

For mixed monorepos:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile mixed
```


## Existing Project Installation

Existing repositories are supported.

Default installation mode is safe:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript
```

Safe mode does not overwrite existing files. Conflicts are written as `*.harness-new`.

Preview first:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --dry-run
```

Apply with backups:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --mode backup
```

Use `--init-scaffold` only for empty or throwaway projects.


## After Installing Into a Project

Run:

```bash
cd /path/to/target-project
./scripts/codex/bootstrap.sh --check
./scripts/codex/verify.sh
```

Then edit:

```text
docs/codex/project-context.md
```

to describe the target project.



## Project Scaffold Initialization

For an empty target directory, use `--init-scaffold` so the selected profile also creates minimal language/project files.

TypeScript pnpm monorepo:

```bash
./scripts/harness/install-to-project.sh \
  /path/to/dummy-typescript-project \
  --profile typescript \
  --init-scaffold
```

This creates:

```text
package.json
pnpm-workspace.yaml
tsconfig.base.json
eslint.config.mjs
apps/backend/
apps/frontend/
libs/types/
libs/utils/
```

Python + Poetry monorepo-style scaffold:

```bash
./scripts/harness/install-to-project.sh \
  /path/to/dummy-python-poetry-project \
  --profile python-poetry \
  --init-scaffold
```

Python + uv monorepo-style scaffold:

```bash
./scripts/harness/install-to-project.sh \
  /path/to/dummy-python-uv-project \
  --profile python-uv \
  --init-scaffold
```

JVM Gradle multi-module scaffold:

```bash
./scripts/harness/install-to-project.sh \
  /path/to/dummy-jvm-gradle-project \
  --profile jvm-gradle-kotlin \
  --init-scaffold
```

JVM Maven multi-module scaffold:

```bash
./scripts/harness/install-to-project.sh \
  /path/to/dummy-jvm-maven-project \
  --profile jvm-maven-java \
  --init-scaffold
```

You can also run scaffold initialization separately:

```bash
./scripts/harness/init-project.sh /path/to/target --profile typescript --install-harness
```

For existing projects, omit `--init-scaffold` to avoid creating language-specific files.

## Optional Graphify Bootstrap

After installing the harness into a target project, Graphify can be applied through the project-local bootstrap script.

```bash
cd /path/to/target-project

# Codex integration
./scripts/codex/bootstrap.sh --apply --graphify --graphify-platform codex

# OpenCode integration
./scripts/codex/bootstrap.sh --apply --graphify --graphify-platform opencode

# Default Graphify install behavior
./scripts/codex/bootstrap.sh --apply --graphify --graphify-platform default
```

Graphify's PyPI package is `graphifyy`, while the installed CLI command is `graphify`.



## Profile-Aware Bootstrap

`install-to-project.sh` writes the selected profile into:

```text
docs/codex/harness-profile.env
```

Example:

```bash
HARNESS_PROFILE=typescript
```

The target project's bootstrap script reads this file and checks only the tools relevant to that profile.

For example, a TypeScript project checks:

```text
git
node
pnpm/npm/yarn depending on lockfile
```

It does not warn about Python, Poetry, uv, Java, Gradle, or Maven unless the project is installed with a matching profile or uses `mixed`/`auto`.

Graphify is optional and checked only when `--graphify` is provided.



## TypeScript Scaffold Notes

The TypeScript scaffold intentionally does not set `rootDir` in `apps/backend/tsconfig.json` or `apps/frontend/tsconfig.json`.

Reason: the scaffold imports workspace library source through path aliases such as `@repo/types` and `@repo/utils`. Setting app `rootDir` to only `src` causes TS6059 errors because imported library files live outside the app source directory.

See:

```text
docs/codex/typescript-scaffold-troubleshooting.md
```


## Profile-Aware Verification

Target projects contain:

```text
docs/codex/harness-profile.env
```

Example:

```bash
HARNESS_PROFILE=typescript
```

Both bootstrap and verification are profile-aware:

```bash
./scripts/codex/bootstrap.sh --check
./scripts/codex/verify.sh
```

For `typescript`, `verify.sh` runs only Node/TypeScript checks. It does not run Python or JVM checks.

For `python-poetry`, it runs only Poetry-based Python checks.

For `python-uv`, it runs only uv-based Python checks.

For `jvm-gradle-java`, `jvm-gradle-kotlin`, `jvm-maven-java`, and `jvm-maven-kotlin`, it runs only the matching JVM build checks.

Use `mixed` or `auto` when a repository intentionally contains multiple stacks.



## Dependency Fallback During Verification

`verify.sh` can install/sync missing dependencies according to the selected profile.

Default:

```bash
./scripts/codex/verify.sh
```

This uses:

```bash
VERIFY_AUTO_INSTALL_DEPS=true
```

Examples:

```text
typescript     -> pnpm install / npm ci / yarn install when node_modules is missing
python-poetry  -> POETRY_VIRTUALENVS_IN_PROJECT=true poetry install when .venv is missing
python-uv      -> uv sync when .venv is missing
```

To disable dependency fallback:

```bash
VERIFY_AUTO_INSTALL_DEPS=false ./scripts/codex/verify.sh
```



## JVM Language-Specific Profiles

For new JVM projects, prefer explicit build-tool + language profiles:

```text
jvm-gradle-java
jvm-gradle-kotlin
jvm-maven-java
jvm-maven-kotlin
```

Examples:

```bash
# Kotlin + Gradle
./scripts/harness/install-to-project.sh /path/to/project --profile jvm-gradle-kotlin --init-scaffold

# Java + Gradle
./scripts/harness/install-to-project.sh /path/to/project --profile jvm-gradle-java --init-scaffold

# Java + Maven
./scripts/harness/install-to-project.sh /path/to/project --profile jvm-maven-java --init-scaffold

# Kotlin + Maven
./scripts/harness/install-to-project.sh /path/to/project --profile jvm-maven-kotlin --init-scaffold
```




## Language Server Setup

Target projects include profile-aware language server setup:

```bash
./scripts/codex/language-server.sh --check
./scripts/codex/language-server.sh --apply
./scripts/codex/language-server.sh --apply --install
```

Or through bootstrap:

```bash
./scripts/codex/bootstrap.sh --apply --language-server
./scripts/codex/bootstrap.sh --apply --language-server --install-language-server
```

Examples:

```text
typescript           -> typescript-language-server, eslint, prettier
python-poetry / uv   -> pyright, ruff, mypy
jvm-*-java           -> jdtls
jvm-*-kotlin         -> kotlin-language-server, ktlint
```

Existing config files are not overwritten. Incoming config is written as `*.harness-new`.
