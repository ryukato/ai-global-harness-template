# TypeScript Profile

## TypeScript / Node Rules

- Keep request and response types explicit.
- Prefer shared types for API contracts.
- Avoid `any` unless the boundary is intentionally dynamic.
- Keep package manager usage consistent.
- Do not edit `dist/`, `node_modules/`, or `*.tsbuildinfo`.

## Common Commands

Prefer existing package scripts.

```bash
pnpm run lint
pnpm run typecheck
pnpm test
pnpm run build
```

For workspaces:

```bash
pnpm -r run lint
pnpm -r run typecheck
pnpm -r run test
pnpm -r run build
```
