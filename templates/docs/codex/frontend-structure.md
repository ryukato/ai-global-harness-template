# Frontend Structure

Frontend scaffolds should stay minimal unless a selected profile or project context chooses a UI framework.

## TypeScript App Shape

For TypeScript browser apps, an explicit structure may look like:

```text
src/
  app/
  pages/
  features/
  shared/
    api/
    config/
    ui/
```

## Rules

- Keep API clients under a shared API boundary.
- Keep environment/config access in a dedicated module.
- Keep feature-specific logic inside feature folders.
- Keep reusable UI primitives in `shared/ui` when a project has them.
- Do not add a heavy UI framework unless explicitly requested or selected by profile.
- Do not hardcode production backend URLs in browser code.
