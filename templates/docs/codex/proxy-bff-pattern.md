# Proxy / BFF-Lite Pattern

A proxy or BFF-lite app is optional. Use it only when the project context or selected profile calls for it.

## Useful When

- Browser-to-backend calls need CORS mitigation.
- The frontend needs a stable, frontend-facing API shape.
- Session or token handling may be centralized later.
- Backend internals should not be exposed directly to browser code.

## Common Shape

```text
apps/proxy-api/
  src/
    config/
    routes/
    clients/
    middleware/
    shared/
```

## Rules

- Keep backend base URL configurable.
- Use a local development default only when useful.
- Do not hardcode production URLs.
- Do not add business logic to the proxy.
- Do not expose unnecessary backend internals to the frontend.
- Keep dependency direction clear, for example `web -> proxy-api -> api`.
