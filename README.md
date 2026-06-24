# AI Global Harness

This repository contains reusable AI coding-agent harness templates that can be copied into different projects.

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
~/ai-global-harness
```

## Main Concepts

```text
AGENTS.md
  Reusable common operating rules for Codex and agents that read AGENTS.md.

CLAUDE.md
  Claude Code entrypoint when installed with --agent claude-code or --agent both.

docs/codex/project-context.md
  Project-specific notes copied into a target project and edited there.

docs/codex/code-review.md
  Shared code review checklist.

docs/codex/done-definition.md
  Completion criteria.

docs/codex/general-scaffold-principles.md
  Project-agnostic scaffold, safety, naming, and verification principles.

docs/codex/legacy-project-guidance.md
  Rules for preserving existing structure and behavior in legacy projects.

docs/codex/atlassian-mcp.md
  Optional Jira and Confluence integration guidance through Atlassian Rovo MCP.

docs/codex/local-mcp-setup.md
docs/operations/local-mcp-setup.md
  Local developer setup boundary for Atlassian/GitHub MCP, connectors, and CLI
  authentication used by coding-agent commands.

docs/codex/local-api-key-setup.md
docs/operations/local-api-key-setup.md
  Local developer setup boundary for API keys used by coding-agent providers,
  GitHub tooling, MCP servers, or internal sandboxes.

docs/architecture/
docs/domain/
docs/decisions/
docs/operations/
  Claude Code production harness context when installed with --agent claude-code
  or --agent both.

.ai-workspace/
  Task-centric workspace for sharing Claude Code agent outputs across explorer,
  architect, implementer, and reviewer roles.

.claude/agents/
.claude/commands/
  Claude Code production harness role guidance and reusable slash-command prompts.
  `.claude/commands/cawf/*` contains the plan, execute, review, and git
  workflow adapted from the internal coding-agent-wf POC.

.claude/skills/
  Claude Code project skills for Jira/GitHub analysis, implementation
  planning, project tech-stack context, domain context, code review, test
  strategy, release readiness, and agent workspace management.

docs/codex/monorepo-layout.md
docs/codex/backend-architecture-boundaries.md
docs/codex/frontend-structure.md
docs/codex/proxy-bff-pattern.md
docs/codex/shared-contracts.md
  Optional reusable structure guidance for projects that select those patterns.

scripts/codex/verify.sh
  Stack-aware verification entrypoint.

scripts/codex/bootstrap.sh
  Applies basic harness setup to a target project.

work-items/
  Repository-local task, feature, and epic templates for non-Jira work.

profiles/
  Stack-specific append files and verification notes.

project-resources/templates/
  Project scaffold source files copied by init-project.sh. Mixed monorepo
  resources are grouped by root/frontend/backend/libs and language.
```

## Quick Start

From this repository:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile typescript
```

Most installs should choose three things:

```text
profile      What kind of repository this is.
agent        Which agent entrypoint and harness assets to install.
mode         How to handle existing files.
```

Install Claude Code production harness for a mixed repository:

```bash
./scripts/harness/install-to-project.sh \
  /path/to/target-project \
  --profile mixed \
  --agent claude-code
```

Install both Codex and Claude Code harnesses:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile typescript --agent both
```

Create a new mixed frontend/backend monorepo from an empty directory:

```bash
./scripts/harness/install-to-project.sh \
  /path/to/new-project \
  --profile mixed \
  --init-scaffold \
  --agent claude-code \
  --frontend-lang typescript \
  --backend-lang typescript
```

## Installer Options

### Profiles

| Profile | Use When | Scaffold Support |
|---|---|---|
| `typescript` | TypeScript / Node.js workspace | yes |
| `python-poetry` | Python project managed by Poetry | yes |
| `python-uv` | Python project managed by uv | yes |
| `jvm-gradle-java` | Java project managed by Gradle | yes |
| `jvm-gradle-kotlin` | Kotlin project managed by Gradle | yes |
| `jvm-maven-java` | Java project managed by Maven | yes |
| `jvm-maven-kotlin` | Kotlin project managed by Maven | yes |
| `mixed` | Frontend/backend/libs monorepo or repository with multiple stacks | yes, TypeScript/TypeScript currently |
| `planning-design` | Lightweight planning/design workspace for product, design, and Jira/Figma handoff | document workspace only |
| `docs-only` | Documentation or planning repository with no application code | harness only |

### Agents

| Option | Installs |
|---|---|
| `--agent codex` | `AGENTS.md`, `docs/codex`, `scripts/codex`, `.codex-runs` |
| `--agent claude-code` | `CLAUDE.md`, `AGENTS.md`, `.claude`, `.ai-workspace`, `scripts/claude`, `docs/architecture`, `docs/domain`, `docs/operations`, `work-items` |
| `--agent both` | Both Codex and Claude Code harness assets |

Default:

```text
--agent codex
```

For `--profile planning-design`, the default agent target is treated as
`claude-code` because the lightweight workflow is built around Claude skills
and agents. Use `--agent claude-code` explicitly if desired; `--agent both`
is intentionally unsupported for this profile to keep the install lightweight.

### Existing File Modes

| Option | Behavior |
|---|---|
| `--mode safe` | Default. Preserve existing files and write incoming conflicts as `*.harness-new`. |
| `--mode backup` | Backup existing files to `.ai-harness-backups/<timestamp>/`, then overwrite. |
| `--mode overwrite` | Overwrite existing files directly. Use only for disposable or controlled targets. |
| `--dry-run` | Print planned changes without writing files. |

### Scaffold Options

| Option | Use When |
|---|---|
| `--init-scaffold` | Create minimal project files before installing the harness. Use for empty or throwaway directories. |
| `--force-init` | Allow scaffold files to overwrite existing files during initialization. |
| `--frontend-lang <lang>` | Frontend language for `--profile mixed --init-scaffold`. |
| `--backend-lang <lang>` | Backend language for `--profile mixed --init-scaffold`. |

Current mixed scaffold implementation:

```text
frontend-lang: typescript
backend-lang:  typescript
```

Supported language targets for mixed scaffolds:

```text
frontend-lang:
  - typescript

backend-lang:
  - typescript
  - java
  - kotlin
  - python
```

The current generator only creates the TypeScript/TypeScript mixed scaffold.
Other documented backend targets must be added as explicit templates before
they are accepted by the CLI.

Mixed scaffold source files live under:

```text
project-resources/templates/mixed/root/typescript/
project-resources/templates/mixed/frontend/typescript/
project-resources/templates/mixed/backend/typescript/
project-resources/templates/mixed/libs/typescript/
```

### Profile Examples

Python with Poetry:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile python-poetry
```

Python with uv:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile python-uv
```

JVM Gradle:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile jvm-gradle-kotlin
```

JVM Maven:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile jvm-maven-java
```

Mixed monorepo:

```bash
./scripts/harness/install-to-project.sh /path/to/target-project --profile mixed
```


## Existing Project Installation

Existing repositories are supported.

Default installation mode is safe and does not overwrite existing files:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript
```

Conflicts are written as `*.harness-new`. After a safe install:

- Compare each `*.harness-new` file with the existing project file.
- Merge useful template content into the real file.
- Delete or intentionally keep each `*.harness-new` file.
- Do not commit unresolved template placeholders.

Preview first:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --dry-run
```

Apply with backups:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile typescript --mode backup
```

Use `--init-scaffold` only for empty or throwaway projects.

Claude Code on an existing project:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile mixed --agent claude-code --dry-run
./scripts/harness/install-to-project.sh /path/to/existing-project --profile mixed --agent claude-code
```

Both Codex and Claude Code:

```bash
./scripts/harness/install-to-project.sh /path/to/existing-project --profile mixed --agent both
```

Planning/design workspace:

```bash
./scripts/harness/install-to-project.sh /path/to/planning-space --profile planning-design
```

This installs a lightweight document workspace for product briefs,
requirements, Figma review, Jira issue drafting, and local MCP/API-key setup.
It does not install application code, architecture docs, release archive
workflows, or verification scripts.

Reusable planning/design artifact templates are installed under:

```text
templates/planning/*
templates/design/*
templates/jira/*
templates/qa/*
templates/retrospective/*
```


## After Installing Into a Project

For Codex installs, run:

```bash
cd /path/to/target-project
./scripts/codex/bootstrap.sh --check
./scripts/codex/verify.sh
```

For Claude Code production harness installs, run:

```bash
cd /path/to/target-project
./scripts/claude/verify.sh
```

For planning/design installs, start from:

```text
docs/planning/product-brief.md
docs/planning/requirement-template.md
docs/design/design-note-template.md
docs/operations/local-mcp-setup.md
docs/operations/local-api-key-setup.md
```

No application verification script is installed for `planning-design`.

For development-oriented installs, then edit:

```text
docs/codex/project-context.md      # --agent codex or both
docs/architecture/tech-stack.md    # --agent claude-code or both
docs/domain/domain-model.md        # --agent claude-code or both
```

to describe the target project. `project-context.md` is prefilled with obvious local metadata when available, including project name, selected profile, package manager, root scripts, and observed top-level structure.

For scaffold and architecture guidance, also review:

```text
docs/codex/general-scaffold-principles.md
docs/codex/legacy-project-guidance.md
docs/codex/atlassian-mcp.md
docs/codex/monorepo-layout.md
docs/codex/backend-architecture-boundaries.md
docs/codex/frontend-structure.md
docs/codex/proxy-bff-pattern.md
docs/codex/shared-contracts.md
```

For Claude Code production harness installs, also review:

```text
CLAUDE.md
HARNESS-GUIDE.md
docs/architecture/*
docs/domain/*
docs/operations/*
work-items/*
```



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

Mixed frontend/backend monorepo:

```bash
./scripts/harness/install-to-project.sh \
  /path/to/dummy-mixed-project \
  --profile mixed \
  --init-scaffold \
  --frontend-lang typescript \
  --backend-lang typescript
```

This creates the same `apps/frontend`, `apps/backend`, `libs/types`, and
`libs/utils` workspace shape, but keeps the installed harness profile as
`mixed`. See the installer option tables above for supported language targets
and currently implemented scaffold combinations.

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
docs/codex/harness-profile.env          # Codex harness
docs/operations/harness-profile.env     # Claude Code production harness
```

Example:

```bash
HARNESS_PROFILE=typescript
```

The target project's bootstrap or verification script reads this file and checks only the tools relevant to that profile.

For example, a TypeScript project checks:

```text
git
node
pnpm/npm/yarn depending on lockfile
```

It does not warn about Python, Poetry, uv, Java, Gradle, or Maven unless the project is installed with a matching profile or uses `mixed`/`auto`.

Graphify is optional and checked only when `--graphify` is provided.


## General Scaffold Guidance

The harness templates capture reusable setup rules without assuming a product domain:

- Read `AGENTS.md`, `docs/codex/project-context.md`, and listed project references before inferring architecture.
- Preserve existing files; safe installs write conflicts as `*.harness-new`.
- Keep scaffolds minimal but explicit, with README files for runnable apps and shared packages.
- Use `apps/`, `packages/` or `libs/`. Codex installs `scripts/codex/` + `docs/codex/`; Claude Code installs the production harness under `.claude/`, `.ai-workspace/`, `docs/architecture/`, `docs/domain/`, and `work-items/`.
- Use explicit `Request` and `Response` contract names. Do not use `DTO` naming in generated scaffolds.
- Treat proxy/BFF-lite, Ports & Adapters, Graphify, and fullstack layouts as optional patterns selected by project context or profile.

An optional fullstack proxy profile is intentionally deferred for now. The reusable rules are documented in the template docs, but the current supported profiles remain language- or build-tool-oriented so existing behavior stays predictable.

## Claude Code Support

The installer can create a root `CLAUDE.md` entrypoint and the Claude Code production harness.

```bash
# Codex only, default
./scripts/harness/install-to-project.sh /path/to/project --profile typescript --agent codex

# Claude Code only
./scripts/harness/install-to-project.sh /path/to/project --profile typescript --agent claude-code

# Both entrypoints
./scripts/harness/install-to-project.sh /path/to/project --profile typescript --agent both
```

`AGENTS.md` and `CLAUDE.md` are generated from separate base templates but share the same profile append rules. Existing files are still protected by safe mode and conflicts are written as `*.harness-new`.

Installed harness assets:

```text
--agent codex       -> docs/codex,  scripts/codex,  .codex-runs
--agent claude-code -> CLAUDE.md, AGENTS.md, .claude, .ai-workspace, scripts/claude,
                       docs/architecture, docs/domain, docs/decisions,
                       docs/operations, work-items
--agent both        -> installs both Codex and Claude Code harness assets
```

For Claude Code, stable project context lives under `docs/architecture/` and `docs/domain/`, while repeatable workflow instructions are installed as project skills:

```text
.claude/skills/agent-workspace/SKILL.md
.claude/skills/archive-management/SKILL.md
.claude/skills/code-review/SKILL.md
.claude/skills/domain-context/SKILL.md
.claude/skills/fix-bug/SKILL.md
.claude/skills/github-issue-analysis/SKILL.md
.claude/skills/implementation-planning/SKILL.md
.claude/skills/jira-ticket-analysis/SKILL.md
.claude/skills/project-tech-stack/SKILL.md
.claude/skills/release-checklist/SKILL.md
.claude/skills/test-strategy/SKILL.md
```

Claude Code project skills follow Anthropic's documented layout: `.claude/skills/<skill-name>/SKILL.md`. The skill frontmatter `description` tells Claude when to load the skill.

Claude Code installs two command layers:

```text
.claude/commands/start-task.md
.claude/commands/implement-feature.md
.claude/commands/review-change.md
.claude/commands/complete-task.md
```

These are lightweight harness-native commands.

The internal CAWF-style workflow is also installed under `.claude/commands/cawf/`:

```text
/project:cawf:plan     -> analyze Jira/GitHub/work-item input and save plan-v<N>.md
/project:cawf:execute  -> implement an approved plan and save execute-v<N>.md
/project:cawf:review   -> review the current diff and save review-v<N>.md
/project:cawf:git      -> prepare commit, push, and PR steps after approval
```

CAWF command outputs are written under:

```text
.ai-workspace/active/<TASK-ID>/outputs/
```

This keeps the POC's plan/execution/review discipline while using the production harness archive policy and workspace layout.

Jira and GitHub source loading still depends on the target Claude runtime:

```text
Jira    -> Atlassian connector/MCP credentials must be configured.
GitHub  -> GitHub connector/MCP or authenticated gh CLI must be configured.
```

The harness provides the analysis skills and command prompts; credentials and
connector installation remain environment-specific and should not be committed.
For the installed project guidance, see:

```text
docs/operations/local-api-key-setup.md
docs/operations/local-mcp-setup.md
```

## Legacy Project Mode

For established systems, install the harness without `--init-scaffold`, then mark the project as legacy in:

```text
docs/codex/project-context.md
docs/architecture/overview.md
docs/domain/domain-model.md
```

Set:

```text
Project Mode: legacy
Legacy system name: SingleOne or another legacy system name
```

Legacy mode tells agents to preserve existing package/module layout, naming, transaction boundaries, API behavior, data shapes, persistence assumptions, and deployment conventions. See:

```text
docs/codex/legacy-project-guidance.md
docs/architecture/coding-rules.md
docs/domain/business-rules.md
```

## Atlassian Jira / Confluence MCP

The harness includes optional guidance for connecting agents to Jira and Confluence through Atlassian's official Rovo MCP Server.

Coding agents run in each developer's local environment, so Atlassian and
GitHub connectors, MCP servers, OAuth sessions, and CLI credentials must be
configured locally by each developer. The repository should contain only
non-secret setup guidance. See:

```text
docs/codex/local-mcp-setup.md
docs/codex/local-api-key-setup.md
docs/operations/local-mcp-setup.md
docs/operations/local-api-key-setup.md
```

The documented current remote endpoint is:

```text
https://mcp.atlassian.com/v1/mcp/authv2
```

For local IDE or custom MCP clients that need a stdio proxy, Atlassian documents `mcp-remote`:

```bash
npx -y mcp-remote@latest https://mcp.atlassian.com/v1/mcp/authv2
```

Do not commit OAuth tokens, API tokens, cookies, or local MCP credential files. Project-specific Jira project keys, Confluence spaces, and allowed write actions should be recorded in:

```text
docs/codex/project-context.md or the relevant docs/architecture and docs/domain files
```

See:

```text
docs/codex/atlassian-mcp.md or .claude/skills/jira-ticket-analysis/SKILL.md
```



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
docs/codex/harness-profile.env          # Codex harness
docs/operations/harness-profile.env     # Claude Code production harness
```

Example:

```bash
HARNESS_PROFILE=typescript
```

Codex bootstrap and verification are profile-aware:

```bash
./scripts/codex/bootstrap.sh --check
./scripts/codex/verify.sh
```

Claude Code production harness installs profile guidance into `CLAUDE.md`,
writes `docs/operations/harness-profile.env`, and provides
`./scripts/claude/verify.sh`. Record project-specific commands in
`docs/architecture/build-and-run.md`.

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
typescript     -> corepack package manager / pnpm install / npm ci / yarn install when node_modules is missing
python-poetry  -> POETRY_VIRTUALENVS_IN_PROJECT=true poetry install when .venv is missing
python-uv      -> uv sync when .venv is missing
```

For Node projects, `verify.sh` prefers Corepack when `package.json` declares `packageManager`. It also warns when test scripts are scaffold placeholders such as `No tests configured`.

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

Existing config files are not overwritten. Incoming config is written as `*.harness-new`; compare, merge, and clean up those artifacts before committing generated docs.
