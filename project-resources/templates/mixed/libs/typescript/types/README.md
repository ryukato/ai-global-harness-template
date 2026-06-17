# Shared Types

## Purpose

Shared TypeScript request/response and contract types.

## Commands

```bash
pnpm --dir libs/types run lint
pnpm --dir libs/types run typecheck
pnpm --dir libs/types run test
pnpm --dir libs/types run build
./scripts/claude/verify.sh
```

## Boundaries

Use explicit `Request` and `Response` names. Do not use `DTO` naming. This
library should not depend on runnable apps.
