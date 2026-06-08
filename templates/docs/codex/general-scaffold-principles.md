# General Scaffold Principles

These principles are reusable across projects. Keep product domains, business rules, and feature plans in project-specific documents instead.

## Context First

- Agents must read `AGENTS.md` before editing.
- Agents must read `docs/codex/project-context.md` when it exists.
- Agents must read reference documents listed in `project-context.md` before making architectural assumptions.
- Do not infer product scope, dependency direction, or repository layout when the project already documents those decisions.

## Existing Projects

- Preserve existing files and directories.
- Make the smallest safe change that satisfies the task.
- Avoid destructive changes, broad rewrites, and unrelated formatting churn.
- Use safe install behavior, backup mode, or `*.harness-new` conflict files instead of silent overwrites.
- Do not change package managers, build tools, or framework choices unless explicitly requested.

## Legacy Projects

When `docs/codex/project-context.md` marks the project as `legacy`:

- Preserve the existing module/package/directory structure.
- Follow nearby conventions before applying generic harness or scaffold patterns.
- Prefer localized changes over architecture rewrites.
- Do not introduce new layers, packages, proxy apps, shared-contract packages, or infrastructure unless explicitly requested.
- Treat compatibility with existing APIs, data shapes, persistence behavior, and deployment assumptions as part of the task.

See:

```text
docs/codex/legacy-project-guidance.md
```

## Minimal But Explicit

- Scaffolds should be small enough to understand and complete enough to verify.
- Each runnable app or shared package should have a README with purpose, local run command, test command, verification command, and important boundaries.
- Add only dependencies needed for the selected profile and the current task.
- Do not add databases, migrations, auth, Docker, CI, queues, object storage, LLM, OCR, RAG, vector database, or business feature implementation unless explicitly requested or selected by a profile.

## Common Layout

Projects may use these directories when they fit:

```text
apps/             runnable apps and services
packages/         shared packages
libs/             shared libraries
scripts/codex/    harness scripts
docs/codex/       harness and agent docs
```

Optional examples include `apps/api`, `apps/web`, `apps/proxy-api`, and `packages/shared-contracts`. Do not force these names unless the chosen scaffold profile requires them.

## Contracts

- Do not use `DTO` terminology in generated scaffold names.
- Use explicit `Request` and `Response` names.
- Prefer package-level files such as `XxxRequests.ts`, `XxxResponses.ts`, `XxxRequests.py`, and `XxxResponses.py`.

## Verification

- `bootstrap.sh --check` should check only tools relevant to the selected profile.
- `verify.sh` should read `docs/codex/harness-profile.env`.
- `verify.sh` should run profile-relevant checks unless the profile is `mixed` or `auto`.
- Run only scripts that exist.
- Report missing tooling, missing configuration, and command failures clearly.
- Dependency fallback should be controlled by `VERIFY_AUTO_INSTALL_DEPS`.
