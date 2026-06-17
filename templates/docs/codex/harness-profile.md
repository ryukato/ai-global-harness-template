# Harness Profile

This file is generated in target projects:

```text
docs/codex/harness-profile.env
```

Example:

```bash
HARNESS_PROFILE=typescript
```

Both `./scripts/codex/bootstrap.sh --check` and `./scripts/codex/verify.sh` read this value.

## Supported Values

```text
typescript
python-poetry
python-uv
jvm-gradle-java
jvm-gradle-kotlin
jvm-maven-java
jvm-maven-kotlin
mixed
docs-only
auto
```

Profiles are intentionally generic. Optional fullstack layouts such as `apps/api`, `apps/web`, `apps/proxy-api`, and `packages/shared-contracts` should be selected by project context or a future explicit profile, not assumed for every project.

## Bootstrap Behavior

`bootstrap.sh --check` checks only profile-relevant tools.

### typescript

Checks:

```text
git
node
pnpm/npm/yarn depending on lockfile
```

### python-poetry

Checks:

```text
git
python3 or python
poetry
```

### python-uv

Checks:

```text
git
python3 or python
uv
```

### jvm-gradle-java / jvm-gradle-kotlin

Checks:

```text
git
java
./gradlew or gradle
```

### jvm-maven-java / jvm-maven-kotlin

Checks:

```text
git
java
./mvnw or mvn
```

### mixed / auto

Auto-detects tools from repository files.

### docs-only

Checks only git.

## Verification Behavior

`verify.sh` also uses the profile.

### typescript

Runs only Node/TypeScript verification.

It prefers `package.json` `packageManager` through Corepack when declared, then falls back to lockfile detection:

```text
packageManager: pnpm@... -> corepack pnpm
packageManager: yarn@... -> corepack yarn
pnpm-lock.yaml / pnpm-workspace.yaml -> pnpm
yarn.lock -> yarn
package-lock.json / package.json -> npm
```

It runs root package scripts when present:

```text
lint
typecheck
test
build
```

If a `test` script contains a scaffold placeholder such as `No tests configured`, verification prints a warning. Passing placeholder tests are acceptable for initial scaffold bootstrapping but not enough for release readiness.

If root scripts exist, package-level `apps/*`, `libs/*`, `packages/*`, `services/*` checks are skipped by default to avoid duplicate recursive checks.

To force package-level checks:

```bash
VERIFY_DIRECT_PACKAGES=true ./scripts/codex/verify.sh
```

### python-poetry

Runs only Poetry-based Python verification:

```text
poetry check
poetry run ruff check .   # only when ruff is installed
poetry run pytest         # only when pytest is installed
poetry run mypy .         # only when mypy is installed
```

### python-uv

Runs only uv-based Python verification:

```text
uv run ruff check .
uv run pytest
uv run mypy .             # only when mypy is installed
```

### jvm-gradle-java / jvm-gradle-kotlin

Runs only Gradle verification:

```text
./gradlew test
# or gradle test
```

### jvm-maven-java / jvm-maven-kotlin

Runs only Maven verification:

```text
./mvnw test
# or mvn test
```

### mixed / auto

Auto-detects Node, Python, Gradle, and Maven from repository files and runs matching checks.

### docs-only

Does not run code verification.


## Dependency fallback

`verify.sh` can install/sync dependencies when they are missing.

Default:

```bash
VERIFY_AUTO_INSTALL_DEPS=true
```

Disable:

```bash
VERIFY_AUTO_INSTALL_DEPS=false ./scripts/codex/verify.sh
```

See:

```text
docs/codex/dependency-fallback.md
```


## JVM profile naming

For new JVM projects, prefer explicit build-tool + language profiles:

```text
jvm-gradle-java
jvm-gradle-kotlin
jvm-maven-java
jvm-maven-kotlin
```


Verification behavior is based on build tool:

```text
jvm-gradle-* -> Gradle verification
jvm-maven-*  -> Maven verification
```
