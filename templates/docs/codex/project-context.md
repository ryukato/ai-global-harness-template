# Project Context

## Project Name

{{PROJECT_NAME}}

## Purpose

TODO: Describe what this project does.

## Project Mode

TODO: Select one.

```text
new | existing | legacy
```

Use `legacy` for established systems where agents should preserve existing structure and behavior rather than applying new scaffold patterns.

If legacy:

```text
Legacy system name: TODO
Legacy compatibility notes: TODO
```

## Stack

TODO: Select and describe the stack and harness profile.

Selected harness profile:

```text
{{SELECTED_HARNESS_PROFILE}}
```

Examples:

- TypeScript / Node.js
- Python / Poetry
- Python / uv
- Kotlin / Gradle
- Java / Maven
- Mixed monorepo

## Repository Structure

```text
{{REPOSITORY_STRUCTURE}}
```

## App / Package Layout

TODO: List runnable apps and shared packages.

Example:

```text
apps/api                 TODO: purpose
apps/web                 TODO: purpose
apps/proxy-api           TODO: optional; only if this project uses a proxy/BFF-lite layer
packages/shared-contracts TODO: optional shared request/response contracts
libs/common              TODO: optional shared library
```

## Product Surfaces

Explicitly separate active code from placeholders so agents do not expand unused surfaces into unrequested features.

```text
Active product surfaces:
TODO: e.g. apps/cli, apps/web, services/api

Reserved placeholders:
TODO: e.g. apps/backend, apps/frontend

Out-of-scope surfaces:
TODO: e.g. Do not add backend/frontend behavior unless explicitly requested.
```

## Architecture Boundaries

TODO: Describe boundaries the agents must preserve.

Examples:

- Domain/application logic:
- Inbound adapters such as HTTP routes, CLIs, workers:
- Outbound adapters such as DB, external APIs, object storage, HTTP clients:
- Config/env access:
- Shared utilities:

For legacy projects, describe the existing boundaries instead of inventing new ones. Agents must preserve the documented boundaries unless a task explicitly asks for migration.

## Dependency Direction

TODO: Describe allowed dependency direction.

Examples:

```text
web -> proxy-api -> api
shared packages -> no dependency on runnable apps
api/domain -> no dependency on framework or infrastructure adapters
```

## Important Commands

```bash
# Setup
{{SETUP_COMMANDS}}

# Verify
./scripts/codex/verify.sh

# Test
{{TEST_COMMANDS}}
```

## Domain Notes

TODO: Add domain rules that agents must not infer incorrectly.

## Legacy Preservation Notes

TODO: Fill this section when Project Mode is `legacy`.

Examples:

- Existing package roots that must be preserved:
- Controller/service/repository naming conventions:
- Transaction boundaries:
- Error-handling conventions:
- External API compatibility requirements:
- Database/schema compatibility requirements:
- Deployment/runtime assumptions:
- Paths agents must avoid unless explicitly requested:

See:

```text
docs/codex/legacy-project-guidance.md
```

## API / Contract Notes

TODO: Add API compatibility requirements, Request/Response naming conventions, schema rules, or migration policies.

Default scaffold naming rule:

- Do not use `DTO` terminology in generated names.
- Use explicit `Request` and `Response` names.

## Root Version Policy

TODO: Describe root-level version conventions.

Examples:

- Python version is declared at root `.python-version`.
- Python sub-apps inherit the root Python version unless explicitly documented.
- Node package manager:

```text
{{PACKAGE_MANAGER}}
```

## Optional Proxy / BFF-Lite Usage

TODO: State whether this project uses a proxy/BFF-lite layer.

If enabled, document:

- Proxy app path:
- Backend base URL environment variable:
- Browser-facing API prefix:
- Dependency direction:

If disabled, agents should not add proxy infrastructure unless explicitly requested.

## Optional Graphify Usage

TODO: State whether Graphify is used for repository mapping.

If enabled:

- Store graph output under `graphify-out/`.
- Use Graphify before and after significant structural changes when practical.
- Do not commit large cache output unless intentionally tracked.

If Graphify cannot run, report the command attempted, error summary, likely cause, and recommended follow-up.

## Optional Atlassian MCP Usage

TODO: State whether Atlassian Jira and Confluence are used as external project context.

If enabled:

```text
Atlassian Cloud site URL: TODO
Jira project keys: TODO
Confluence spaces: TODO
Primary product/spec pages: TODO
Issue workflow constraints: TODO
Allowed write actions: read-only by default unless explicitly requested
Required confirmation before writes: yes
```

Use Atlassian MCP for Jira/Confluence context when available, especially when a task references tickets, wiki pages, specs, runbooks, or acceptance criteria.

If Atlassian MCP is unavailable, agents should report that clearly and ask for the relevant ticket/page content or URL.

See:

```text
docs/codex/atlassian-mcp.md
```

## Language Server Tooling

TODO: List selected language server, linter, formatter, and type checker tooling.

Examples:

- TypeScript: `tsc`, `eslint`, `typescript-language-server`, `prettier`
- Python: `ruff`, `pyright`, `mypy`
- JVM Java: `jdtls`
- JVM Kotlin: `kotlin-language-server`, `ktlint`

## Generated Files / Paths to Avoid

```text
TODO: Decide which project-generated paths are ignored, committed, or reviewed case by case.
```

Common examples:

```text
.codex-runs/
.ai-workspace/archive/
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
*.tsbuildinfo
graphify-out/cache/
reports/
reports/raw/
*.harness-new
```

## Additional Project References

TODO: List project reference documents agents must read before architecture-sensitive work.

```text
docs/project/TODO.md
```

## Agent Notes

- Prefer small changes.
- Update this file when new project-specific rules become stable.
- Do not infer architecture without checking this file and the references above.
