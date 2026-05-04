# TypeScript Scaffold Troubleshooting

## TS6059 rootDir error

Symptom:

```text
TS6059: File 'libs/types/src/index.ts' is not under 'rootDir' 'apps/backend/src'.
```

Cause:

The app package imports workspace library source through TypeScript path aliases, but the app `tsconfig.json` restricts `rootDir` to only its own `src` directory.

Fix:

For the minimal scaffold, app `tsconfig.json` should not set `rootDir`.

Use:

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist"
  },
  "include": ["src/**/*.ts"]
}
```

For frontend:

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist",
    "jsx": "react-jsx"
  },
  "include": ["src/**/*.ts", "src/**/*.tsx"]
}
```

## Not a git repository

The scaffold can be tested before `git init`.

`verify.sh` should skip git status when the directory is not a Git repository.

Optional:

```bash
git init
```

## Duplicate package-level checks

Root scripts such as `pnpm -r run lint` already run workspace package scripts.

The default `verify.sh` avoids running direct app/lib checks again when root scripts exist.

To force direct checks:

```bash
VERIFY_DIRECT_PACKAGES=true ./scripts/codex/verify.sh
```
