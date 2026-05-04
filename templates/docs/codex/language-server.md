# Language Server Setup

This harness can prepare profile-specific language server, linter, and formatter tooling.

## Commands

Check only:

```bash
./scripts/codex/language-server.sh --check
```

Apply config files without installing tools:

```bash
./scripts/codex/language-server.sh --apply
```

Install missing tooling where possible:

```bash
./scripts/codex/language-server.sh --apply --install
```

Through bootstrap:

```bash
./scripts/codex/bootstrap.sh --apply --language-server
./scripts/codex/bootstrap.sh --apply --language-server --install-language-server
```

## Supported Profiles

### TypeScript

Checks:

```text
tsc
eslint
typescript-language-server
prettier
```

Install fallback:

```text
pnpm add -Dw typescript typescript-language-server prettier
npm install -D typescript typescript-language-server prettier
yarn add -D typescript typescript-language-server prettier
```

Generated config:

```text
.editorconfig
.vscode/settings.json
```

### Python Poetry

Checks:

```text
ruff
pyright
mypy
```

Install fallback:

```bash
poetry add --group dev ruff pyright mypy
```

Generated config:

```text
.editorconfig
pyrightconfig.json
.vscode/settings.json
```

### Python uv

Checks:

```text
ruff
pyright
mypy
```

Install fallback:

```bash
uv add --dev ruff pyright mypy
```

Generated config:

```text
.editorconfig
pyrightconfig.json
.vscode/settings.json
```

### JVM Java

Profiles:

```text
jvm-gradle-java
jvm-maven-java
```

Checks:

```text
jdtls
```

Best-effort install on macOS when Homebrew is available:

```bash
brew install jdtls
```

Generated config:

```text
.editorconfig
.vscode/settings.json
```

### JVM Kotlin

Profiles:

```text
jvm-gradle-kotlin
jvm-maven-kotlin
```

Checks:

```text
kotlin-language-server
ktlint
```

Best-effort install on macOS when Homebrew is available:

```bash
brew install kotlin-language-server
brew install ktlint
```

Generated config:

```text
.editorconfig
.vscode/settings.json
```

## Existing Projects

Existing files are not overwritten.

If a config file already exists, the incoming file is written as:

```text
<file>.harness-new
```

Review and merge manually.

## Notes

Language server installation is best-effort because availability differs by OS, package manager, IDE, and agent runtime.

The goal is to make project-local conventions explicit, not to force one editor or one coding agent.
