# Monorepo Layout

This harness supports monorepos without requiring every project to be one.

## Common Directories

```text
apps/             runnable apps, services, workers, or CLIs
packages/         shared publishable packages or contracts
libs/             shared internal libraries
scripts/codex/    agent and harness scripts
docs/codex/       agent and harness documentation
```

Project-specific names are allowed. Optional examples:

```text
apps/api
apps/web
apps/proxy-api
packages/shared-contracts
libs/common
```

## README Expectations

Each app or package README should include:

- Purpose
- Local run command
- Test command
- Verification command
- Important boundaries and dependency direction

## Dependency Direction

Document dependency direction in `docs/codex/project-context.md`. For example, a project using an optional proxy may choose:

```text
web -> proxy-api -> api
```

Shared packages should not create reverse dependencies back into runnable apps.
