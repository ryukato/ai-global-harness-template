# frontend

## Purpose

Runnable TypeScript frontend app placeholder.

## Commands

```bash
pnpm --dir apps/frontend run lint
pnpm --dir apps/frontend run typecheck
pnpm --dir apps/frontend run test
pnpm --dir apps/frontend run build
./scripts/claude/verify.sh
```

## Boundaries

Keep frontend-specific UI and proxy code here. Move shared request/response
contracts and reusable utilities into workspace libraries.
