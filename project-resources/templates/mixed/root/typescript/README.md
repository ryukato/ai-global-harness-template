# Mixed Monorepo Harness Scaffold

## Layout

- `apps/frontend`: TypeScript frontend application placeholder.
- `apps/backend`: TypeScript backend application placeholder.
- `libs/types`: shared request/response and contract types.
- `libs/utils`: shared internal utilities.
- `scripts/codex` or `scripts/claude`: harness scripts when installed.

## Selected Stack

- Frontend language: TypeScript
- Backend language: TypeScript
- Workspace/package manager: pnpm

## Commands

```bash
pnpm install
pnpm run lint
pnpm run typecheck
pnpm run test
pnpm run build
./scripts/claude/verify.sh
```

## Boundaries

Keep runnable app code in `apps/`. Keep shared contracts and utilities in `libs/`.
Use explicit `Request` and `Response` names for API contracts; do not use `DTO`
naming.
