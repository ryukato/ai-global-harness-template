# backend

## Purpose

Runnable TypeScript backend app placeholder.

## Commands

```bash
pnpm --dir apps/backend run lint
pnpm --dir apps/backend run typecheck
pnpm --dir apps/backend run test
pnpm --dir apps/backend run build
./scripts/claude/verify.sh
```

## Boundaries

Keep backend-specific transport and application code here. Move shared
request/response contracts and reusable utilities into workspace libraries.
