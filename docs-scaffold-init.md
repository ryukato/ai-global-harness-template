Existing repositories: do not use `--init-scaffold` unless you intentionally want to add missing scaffold files.

# Project Scaffold Initialization

Use this only for empty or throwaway projects.

For existing repositories, install only the harness and do not initialize scaffold files.

## TypeScript

```bash
./scripts/harness/install-to-project.sh /path/to/project --profile typescript --init-scaffold
```

Creates a minimal pnpm workspace:

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

## Python Poetry

```bash
./scripts/harness/install-to-project.sh /path/to/project --profile python-poetry --init-scaffold
```

Creates:

```text
pyproject.toml
apps/api/
libs/common/
tests/
```

## Python uv

```bash
./scripts/harness/install-to-project.sh /path/to/project --profile python-uv --init-scaffold
```

Creates:

```text
pyproject.toml
apps/api/
libs/common/
tests/
```

## JVM Gradle Java

```bash
./scripts/harness/install-to-project.sh /path/to/project --profile jvm-gradle-java --init-scaffold
```

Creates:

```text
settings.gradle.kts
build.gradle.kts
apps/api/src/main/java
apps/api/src/test/java
libs/common/src/main/java
```

## JVM Gradle Kotlin

```bash
./scripts/harness/install-to-project.sh /path/to/project --profile jvm-gradle-kotlin --init-scaffold
```

Creates:

```text
settings.gradle.kts
build.gradle.kts
apps/api/src/main/kotlin
apps/api/src/test/kotlin
libs/common/src/main/kotlin
```

## JVM Maven Java

```bash
./scripts/harness/install-to-project.sh /path/to/project --profile jvm-maven-java --init-scaffold
```

Creates:

```text
pom.xml
apps/api/src/main/java
apps/api/src/test/java
libs/common/src/main/java
```

## JVM Maven Kotlin

```bash
./scripts/harness/install-to-project.sh /path/to/project --profile jvm-maven-kotlin --init-scaffold
```

Creates:

```text
pom.xml
apps/api/src/main/kotlin
apps/api/src/test/kotlin
libs/common/src/main/kotlin
```
