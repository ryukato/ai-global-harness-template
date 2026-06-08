---
name: dependency-fallback
description: Explain and validate profile-aware verify.sh dependency fallback for Node, Poetry, and uv projects.
---

# Dependency Fallback

Use this skill when the user asks why verification installed dependencies, how to disable dependency syncing, or how `verify.sh` handles missing dependencies.

`./scripts/claude/verify.sh` is profile-aware and can install or sync dependencies when they are missing.

## Default

Dependency fallback is enabled by default:

```bash
VERIFY_AUTO_INSTALL_DEPS=true
```

Disable it for a run:

```bash
VERIFY_AUTO_INSTALL_DEPS=false ./scripts/claude/verify.sh
```

## TypeScript / Node

For `HARNESS_PROFILE=typescript`, `verify.sh` treats dependencies as missing when `package.json` exists but `node_modules/` does not, or when common required binaries such as `eslint` or `tsc` are missing from `node_modules/.bin`.

Install behavior follows the detected package manager and lockfile:

```text
pnpm-lock.yaml or pnpm-workspace.yaml -> pnpm install --frozen-lockfile, fallback to pnpm install
package-lock.json -> npm ci, fallback to npm install
yarn.lock -> yarn install --frozen-lockfile, fallback to yarn install
```

## Python Poetry

For `HARNESS_PROFILE=python-poetry`, `verify.sh` checks `.venv/`, `poetry run python`, and declared harness tooling such as `pytest`, `ruff`, `mypy`, and `pyright`.

When missing, it uses project-local virtualenv behavior:

```bash
POETRY_VIRTUALENVS_IN_PROJECT=true poetry install --no-interaction --sync
```

If that fails, it falls back to normal Poetry install.

## Python uv

For `HARNESS_PROFILE=python-uv`, `verify.sh` checks `.venv/`, `uv run python`, and declared harness tooling such as `pytest`, `ruff`, `mypy`, and `pyright`.

When missing, it runs:

```bash
uv sync --frozen
```

If that fails, it falls back to:

```bash
uv sync
```

## Safety

Dependency fallback is convenient for fresh clones and scaffolded projects. In existing production repositories, use `VERIFY_AUTO_INSTALL_DEPS=false` when dependency installation should not happen automatically.

The fallback intentionally does not install JVM dependencies because Gradle and Maven resolve dependencies as part of normal build or test commands.
