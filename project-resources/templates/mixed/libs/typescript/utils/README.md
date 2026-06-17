# Shared Utils

## Purpose

Shared internal utility functions.

## Commands

```bash
pnpm --dir libs/utils run lint
pnpm --dir libs/utils run typecheck
pnpm --dir libs/utils run test
pnpm --dir libs/utils run build
./scripts/claude/verify.sh
```

## Boundaries

Keep reusable, dependency-light helpers here. Do not add app-specific behavior
or generated output.
