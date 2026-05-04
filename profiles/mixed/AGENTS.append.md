# Mixed Monorepo Profile

## Mixed Repository Rules

- Identify the affected stack before editing.
- Run only relevant checks first, then run full verification when practical.
- Avoid cross-stack dependency changes unless required.
- Preserve shared contracts across frontend/backend/shared libraries.
- Keep generated outputs out of commits.

## Common Areas

```text
apps/
services/
libs/
packages/
docs/
infra/
containers/
```

## Verification

Use the common entrypoint:

```bash
./scripts/codex/verify.sh
```
