# Dependency Fallback in verify.sh

`./scripts/codex/verify.sh` is profile-aware and can install/sync dependencies when they are missing.

## Default Behavior

Dependency fallback is enabled by default:

```bash
VERIFY_AUTO_INSTALL_DEPS=true
```

To disable it:

```bash
VERIFY_AUTO_INSTALL_DEPS=false ./scripts/codex/verify.sh
```

## TypeScript / Node

For `HARNESS_PROFILE=typescript`, `verify.sh` checks whether Node dependencies appear to be installed.

It treats dependencies as missing when:

- `package.json` exists but `node_modules/` does not exist.
- common required binaries such as `eslint` or `tsc` are missing from `node_modules/.bin`.

Install behavior:

```text
package.json packageManager -> prefer corepack <manager>
pnpm-lock.yaml or pnpm-workspace.yaml -> pnpm install --frozen-lockfile, fallback to pnpm install
package-lock.json -> npm ci, fallback to npm install
yarn.lock -> yarn install --frozen-lockfile, fallback to yarn install
no lockfile -> package manager install
```

When `package.json` declares `packageManager`, verification prefers Corepack so the project-selected package-manager version is used. If Corepack is unavailable and the script falls back to a global package manager, it prints a warning. If global `pnpm` is incompatible with the active Node runtime, try:

```bash
corepack pnpm install --frozen-lockfile
```

`verify.sh` also warns when a `test` script is only a scaffold placeholder such as `echo 'No tests configured for cli'`. That command may pass for bootstrapping, but it is not release confidence.

## Python Poetry

For `HARNESS_PROFILE=python-poetry`, `verify.sh` checks whether `.venv/` exists, whether `poetry run python` works, and whether declared harness tooling such as `pytest`, `ruff`, `mypy`, and `pyright` is importable when present in `pyproject.toml`.

When missing, it runs:

```bash
POETRY_VIRTUALENVS_IN_PROJECT=true poetry install --no-interaction --sync
```

If that fails, it falls back to:

```bash
POETRY_VIRTUALENVS_IN_PROJECT=true poetry install --no-interaction
```

If no `poetry.lock` exists, it runs normal `poetry install`.

## Python uv

For `HARNESS_PROFILE=python-uv`, `verify.sh` checks whether `.venv/` exists, whether `uv run python` works, and whether declared harness tooling such as `pytest`, `ruff`, `mypy`, and `pyright` is importable when present in `pyproject.toml`.

When missing, it runs:

```bash
uv sync --frozen
```

If that fails, it falls back to:

```bash
uv sync
```

If no `uv.lock` exists, it runs normal `uv sync`.

## Existing Projects

Dependency fallback is convenient for fresh clones and scaffolded projects.

For existing production repositories, use this when you want verification to avoid dependency installation:

```bash
VERIFY_AUTO_INSTALL_DEPS=false ./scripts/codex/verify.sh
```

## Notes

The fallback intentionally does not install JVM dependencies because Gradle/Maven handle dependency resolution as part of their normal build/test commands.
