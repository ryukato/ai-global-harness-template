# Shared Contracts

Shared contracts are optional and should remain small until a project needs more.

## Naming

- Do not use `DTO` terminology in generated scaffold names.
- Use explicit `Request` and `Response` names.
- Prefer package-level files:

```text
XxxRequests.ts
XxxResponses.ts
XxxRequests.py
XxxResponses.py
```

## Boundaries

- Contracts describe API shapes and shared semantics.
- Contracts should not import runnable apps.
- Contracts should not contain framework, persistence, or transport implementation details.
- Avoid code generation until the project explicitly chooses it.
